-- Tranzo transfer pipeline schema expected by TransferService.
-- Adds transfer session metadata table, required indexes, RLS,
-- and storage bucket policies for chunk upload/download.

create table if not exists public.transfer_sessions (
  id uuid primary key default gen_random_uuid(),
  transfer_id text not null unique,
  sender_id uuid not null references auth.users (id) on delete cascade,
  receiver_id uuid not null references auth.users (id) on delete cascade,
  file_name text not null,
  file_size bigint not null check (file_size > 0),
  file_hash text not null,
  status text not null,
  storage_path text not null,
  created_at timestamptz not null default now(),
  expires_at timestamptz,
  intent_expiry timestamptz,
  intent_score double precision,
  constraint transfer_sessions_sender_receiver_check check (sender_id <> receiver_id)
);

create index if not exists transfer_sessions_receiver_created_at_idx
  on public.transfer_sessions (receiver_id, created_at desc);
create index if not exists transfer_sessions_sender_created_at_idx
  on public.transfer_sessions (sender_id, created_at desc);
create index if not exists transfer_sessions_status_idx
  on public.transfer_sessions (status);

alter table public.transfer_sessions enable row level security;

drop policy if exists "transfer_sessions_select_participant" on public.transfer_sessions;
drop policy if exists "transfer_sessions_insert_sender" on public.transfer_sessions;
drop policy if exists "transfer_sessions_update_participant" on public.transfer_sessions;

create policy "transfer_sessions_select_participant"
  on public.transfer_sessions
  for select
  to authenticated
  using (auth.uid() = sender_id or auth.uid() = receiver_id);

create policy "transfer_sessions_insert_sender"
  on public.transfer_sessions
  for insert
  to authenticated
  with check (auth.uid() = sender_id);

create policy "transfer_sessions_update_participant"
  on public.transfer_sessions
  for update
  to authenticated
  using (auth.uid() = sender_id or auth.uid() = receiver_id)
  with check (auth.uid() = sender_id or auth.uid() = receiver_id);

revoke all on table public.transfer_sessions from anon;
grant select, insert, update on table public.transfer_sessions to authenticated;

insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values (
  'transfer-chunks',
  'transfer-chunks',
  false,
  1073741824,
  null
)
on conflict (id) do update
set
  public = excluded.public,
  file_size_limit = excluded.file_size_limit,
  allowed_mime_types = excluded.allowed_mime_types;

drop policy if exists "transfer_chunks_insert_participant" on storage.objects;
drop policy if exists "transfer_chunks_select_participant" on storage.objects;
drop policy if exists "transfer_chunks_update_participant" on storage.objects;

create policy "transfer_chunks_insert_participant"
  on storage.objects
  for insert
  to authenticated
  with check (
    bucket_id = 'transfer-chunks'
    and exists (
      select 1
      from public.transfer_sessions ts
      where ts.id::text = split_part(name, '/', 1)
        and (auth.uid() = ts.sender_id or auth.uid() = ts.receiver_id)
    )
  );

create policy "transfer_chunks_select_participant"
  on storage.objects
  for select
  to authenticated
  using (
    bucket_id = 'transfer-chunks'
    and exists (
      select 1
      from public.transfer_sessions ts
      where ts.id::text = split_part(name, '/', 1)
        and (auth.uid() = ts.sender_id or auth.uid() = ts.receiver_id)
    )
  );

create policy "transfer_chunks_update_participant"
  on storage.objects
  for update
  to authenticated
  using (
    bucket_id = 'transfer-chunks'
    and exists (
      select 1
      from public.transfer_sessions ts
      where ts.id::text = split_part(name, '/', 1)
        and (auth.uid() = ts.sender_id or auth.uid() = ts.receiver_id)
    )
  )
  with check (
    bucket_id = 'transfer-chunks'
    and exists (
      select 1
      from public.transfer_sessions ts
      where ts.id::text = split_part(name, '/', 1)
        and (auth.uid() = ts.sender_id or auth.uid() = ts.receiver_id)
    )
  );
