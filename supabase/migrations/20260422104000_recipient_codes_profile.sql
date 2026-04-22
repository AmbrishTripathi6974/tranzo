-- Tranzo profile + pairing: AuthService and TransferService expect this table.
-- See lib/core/services/auth_service.dart (loadCurrentSessionProfile, createAnonymousUserWithShortCode)
-- and lib/core/services/transfer_service.dart (resolveRecipientIdByCode).

create table if not exists public.recipient_codes (
  user_id uuid not null references auth.users (id) on delete cascade,
  short_code text not null,
  created_at timestamptz not null default now(),
  constraint recipient_codes_pkey primary key (user_id),
  constraint recipient_codes_short_code_key unique (short_code),
  constraint recipient_codes_short_code_format check (
    short_code ~ '^[A-Z0-9]{4,12}$'
  )
);

comment on table public.recipient_codes is
  'One row per auth user: public short code for transfers and profile (Tranzo).';

alter table public.recipient_codes enable row level security;

drop policy if exists "recipient_codes_select_authenticated" on public.recipient_codes;
drop policy if exists "recipient_codes_insert_own_user" on public.recipient_codes;

-- Pairing: any signed-in client must resolve short_code -> user_id (sender validates recipient).
create policy "recipient_codes_select_authenticated"
  on public.recipient_codes
  for select
  to authenticated
  using (true);

-- Sign-up path inserts exactly one row for auth.uid().
create policy "recipient_codes_insert_own_user"
  on public.recipient_codes
  for insert
  to authenticated
  with check (auth.uid() = user_id);

revoke all on table public.recipient_codes from anon;
grant select, insert on table public.recipient_codes to authenticated;
