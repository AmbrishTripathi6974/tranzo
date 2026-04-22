-- Simplify transfer chunk storage RLS to two policies:
-- 1) read policy for sender/receiver
-- 2) write policy (insert/update/delete) for sender only

drop policy if exists "transfer_chunks_insert_participant" on storage.objects;
drop policy if exists "transfer_chunks_select_participant" on storage.objects;
drop policy if exists "transfer_chunks_update_participant" on storage.objects;
drop policy if exists "transfer_chunks_delete_sender" on storage.objects;
drop policy if exists "transfer_chunks_insert_sender" on storage.objects;
drop policy if exists "transfer_chunks_select_sender_or_receiver" on storage.objects;
drop policy if exists "transfer_chunks_update_sender" on storage.objects;
drop policy if exists "transfer_chunks_write_sender_only" on storage.objects;

create policy "transfer_chunks_select_sender_or_receiver"
  on storage.objects
  for select
  to authenticated
  using (
    bucket_id = 'transfer-chunks'
    and (storage.foldername(name))[1] is not null
    and exists (
      select 1
      from public.transfer_sessions ts
      where ts.transfer_id = (storage.foldername(name))[1]
        and (
          auth.uid() = ts.sender_id
          or auth.uid() = ts.receiver_id
        )
    )
  );

create policy "transfer_chunks_write_sender_only"
  on storage.objects
  for all
  to authenticated
  using (
    bucket_id = 'transfer-chunks'
    and (storage.foldername(name))[1] is not null
    and storage.filename(name) ~ '^chunk_[0-9]+\\.part$'
    and exists (
      select 1
      from public.transfer_sessions ts
      where ts.transfer_id = (storage.foldername(name))[1]
        and auth.uid() = ts.sender_id
    )
  )
  with check (
    bucket_id = 'transfer-chunks'
    and (storage.foldername(name))[1] is not null
    and storage.filename(name) ~ '^chunk_[0-9]+\\.part$'
    and exists (
      select 1
      from public.transfer_sessions ts
      where ts.transfer_id = (storage.foldername(name))[1]
        and auth.uid() = ts.sender_id
    )
  );
