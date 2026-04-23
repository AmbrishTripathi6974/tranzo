-- New production transfers pipeline (UUID PK, progress, chunk counters).
-- Coexists with legacy transfer_sessions until clients fully migrate.

create table if not exists public.transfers (
  id uuid primary key default gen_random_uuid(),
  sender_id uuid not null references auth.users (id) on delete cascade,
  receiver_id uuid not null references auth.users (id) on delete cascade,
  file_name text not null,
  file_size bigint not null check (file_size > 0),
  mime_type text,
  file_hash text not null,
  storage_root text not null,
  status text not null,
  progress int not null default 0 check (progress between 0 and 100),
  total_chunks int not null check (total_chunks > 0),
  uploaded_chunks int not null default 0 check (uploaded_chunks >= 0),
  downloaded_chunks int not null default 0 check (downloaded_chunks >= 0),
  last_error text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  expires_at timestamptz,
  intent_expiry timestamptz,
  intent_score double precision,
  constraint transfers_sender_receiver_check check (sender_id <> receiver_id),
  constraint transfers_uploaded_chunks_cap check (uploaded_chunks <= total_chunks),
  constraint transfers_downloaded_chunks_cap check (downloaded_chunks <= total_chunks),
  constraint transfers_status_check check (
    status in (
      'queued',
      'uploading',
      'uploaded',
      'downloading',
      'completed',
      'failed',
      'cancelled'
    )
  )
);

create index if not exists transfers_receiver_created_at_idx
  on public.transfers (receiver_id, created_at desc);
create index if not exists transfers_sender_created_at_idx
  on public.transfers (sender_id, created_at desc);
create index if not exists transfers_status_idx
  on public.transfers (status);

create or replace function public.set_transfers_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

create or replace function public.transfers_enforce_immutable_columns()
returns trigger
language plpgsql
as $$
begin
  if tg_op = 'UPDATE' then
    if new.id is distinct from old.id
      or new.sender_id is distinct from old.sender_id
      or new.receiver_id is distinct from old.receiver_id
      or new.file_size is distinct from old.file_size
      or new.file_hash is distinct from old.file_hash
      or new.total_chunks is distinct from old.total_chunks
      or new.storage_root is distinct from old.storage_root then
      raise exception 'transfers: immutable column change denied';
    end if;
  end if;
  return new;
end;
$$;

drop trigger if exists transfers_enforce_immutable on public.transfers;
create trigger transfers_enforce_immutable
  before update on public.transfers
  for each row
  execute function public.transfers_enforce_immutable_columns();

drop trigger if exists transfers_set_updated_at on public.transfers;
create trigger transfers_set_updated_at
  before update on public.transfers
  for each row
  execute function public.set_transfers_updated_at();

alter table public.transfers enable row level security;

drop policy if exists "transfers_select_participant" on public.transfers;
drop policy if exists "transfers_insert_sender" on public.transfers;
drop policy if exists "transfers_update_participant" on public.transfers;

create policy "transfers_select_participant"
  on public.transfers
  for select
  to authenticated
  using (auth.uid() = sender_id or auth.uid() = receiver_id);

create policy "transfers_insert_sender"
  on public.transfers
  for insert
  to authenticated
  with check (auth.uid() = sender_id);

create policy "transfers_update_participant"
  on public.transfers
  for update
  to authenticated
  using (auth.uid() = sender_id or auth.uid() = receiver_id)
  with check (auth.uid() = sender_id or auth.uid() = receiver_id);

revoke all on table public.transfers from anon;
grant select, insert, update on table public.transfers to authenticated;

-- RPCs: monotonic chunk progress + guarded status transitions (SECURITY DEFINER).

create or replace function public.transfers_recalc_progress(p_total int, p_done int)
returns int
language sql
immutable
as $$
  select case
    when p_total <= 0 then 0
    else least(100, greatest(0, floor((100.0 * p_done) / p_total)::int))
  end;
$$;

create or replace function public.report_chunk_uploaded(
  p_transfer_id uuid,
  p_chunk_index int
)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  v_rows int;
begin
  if p_chunk_index < 0 then
    raise exception 'invalid chunk index';
  end if;

  update public.transfers t
  set
    uploaded_chunks = greatest(
      t.uploaded_chunks,
      least(t.total_chunks, p_chunk_index + 1)
    ),
    progress = public.transfers_recalc_progress(
      t.total_chunks,
      greatest(
        t.uploaded_chunks,
        least(t.total_chunks, p_chunk_index + 1)
      )
    ),
    updated_at = now()
  where t.id = p_transfer_id
    and t.sender_id = auth.uid()
    and t.status in ('queued', 'uploading');

  get diagnostics v_rows = row_count;
  if v_rows = 0 then
    raise exception 'not authorized or invalid transfer state';
  end if;
end;
$$;

create or replace function public.mark_transfer_uploaded(p_transfer_id uuid)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  v_rows int;
begin
  update public.transfers t
  set
    status = 'uploaded',
    uploaded_chunks = t.total_chunks,
    progress = 100,
    updated_at = now()
  where t.id = p_transfer_id
    and t.sender_id = auth.uid()
    and t.status in ('queued', 'uploading')
    and t.uploaded_chunks >= t.total_chunks;

  get diagnostics v_rows = row_count;
  if v_rows = 0 then
    raise exception 'upload not complete or not authorized';
  end if;
end;
$$;

create or replace function public.begin_transfer_download(p_transfer_id uuid)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  v_rows int;
begin
  update public.transfers t
  set
    status = 'downloading',
    downloaded_chunks = 0,
    progress = 0,
    updated_at = now()
  where t.id = p_transfer_id
    and t.receiver_id = auth.uid()
    and t.status = 'uploaded';

  get diagnostics v_rows = row_count;
  if v_rows = 0 then
    raise exception 'transfer not ready or not authorized';
  end if;
end;
$$;

create or replace function public.report_chunk_downloaded(
  p_transfer_id uuid,
  p_chunk_index int
)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  v_rows int;
begin
  if p_chunk_index < 0 then
    raise exception 'invalid chunk index';
  end if;

  update public.transfers t
  set
    downloaded_chunks = greatest(
      t.downloaded_chunks,
      least(t.total_chunks, p_chunk_index + 1)
    ),
    progress = public.transfers_recalc_progress(
      t.total_chunks,
      greatest(
        t.downloaded_chunks,
        least(t.total_chunks, p_chunk_index + 1)
      )
    ),
    updated_at = now()
  where t.id = p_transfer_id
    and t.receiver_id = auth.uid()
    and t.status = 'downloading';

  get diagnostics v_rows = row_count;
  if v_rows = 0 then
    raise exception 'not authorized or invalid transfer state';
  end if;
end;
$$;

create or replace function public.mark_transfer_completed(p_transfer_id uuid)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  v_rows int;
begin
  update public.transfers t
  set
    status = 'completed',
    progress = 100,
    downloaded_chunks = t.total_chunks,
    updated_at = now()
  where t.id = p_transfer_id
    and t.receiver_id = auth.uid()
    and t.status = 'downloading'
    and t.downloaded_chunks >= t.total_chunks;

  get diagnostics v_rows = row_count;
  if v_rows = 0 then
    raise exception 'download not complete or not authorized';
  end if;
end;
$$;

create or replace function public.mark_transfer_failed(
  p_transfer_id uuid,
  p_message text
)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  v_rows int;
begin
  update public.transfers t
  set
    status = 'failed',
    last_error = left(coalesce(p_message, 'failed'), 2000),
    updated_at = now()
  where t.id = p_transfer_id
    and (t.sender_id = auth.uid() or t.receiver_id = auth.uid())
    and t.status not in ('completed', 'cancelled');

  get diagnostics v_rows = row_count;
  if v_rows = 0 then
    raise exception 'not authorized or terminal state';
  end if;
end;
$$;

revoke all on function public.transfers_recalc_progress(int, int) from public;
grant execute on function public.transfers_recalc_progress(int, int) to authenticated;

revoke all on function public.report_chunk_uploaded(uuid, int) from public;
grant execute on function public.report_chunk_uploaded(uuid, int) to authenticated;

revoke all on function public.mark_transfer_uploaded(uuid) from public;
grant execute on function public.mark_transfer_uploaded(uuid) to authenticated;

revoke all on function public.begin_transfer_download(uuid) from public;
grant execute on function public.begin_transfer_download(uuid) to authenticated;

revoke all on function public.report_chunk_downloaded(uuid, int) from public;
grant execute on function public.report_chunk_downloaded(uuid, int) to authenticated;

revoke all on function public.mark_transfer_completed(uuid) from public;
grant execute on function public.mark_transfer_completed(uuid) to authenticated;

revoke all on function public.mark_transfer_failed(uuid, text) from public;
grant execute on function public.mark_transfer_failed(uuid, text) to authenticated;

-- Realtime: add table to supabase_realtime publication (idempotent).
do $$
begin
  if not exists (
    select 1
    from pg_publication_tables
    where pubname = 'supabase_realtime'
      and schemaname = 'public'
      and tablename = 'transfers'
  ) then
    alter publication supabase_realtime add table public.transfers;
  end if;
end $$;
