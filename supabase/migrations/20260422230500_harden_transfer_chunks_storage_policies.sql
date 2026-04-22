-- Harden transfer chunk storage policies:
-- - only transfer participants can read
-- - only sender can write/update/delete objects
-- - object path must follow: <transfer_id>/<file_id>/chunk_<n>.part

drop policy if exists "transfer_chunks_insert_participant" on storage.objects;
drop policy if exists "transfer_chunks_select_participant" on storage.objects;
drop policy if exists "transfer_chunks_update_participant" on storage.objects;
drop policy if exists "transfer_chunks_delete_sender" on storage.objects;
drop policy if exists "transfer_chunks_insert_sender" on storage.objects;
drop policy if exists "transfer_chunks_select_sender_or_receiver" on storage.objects;
drop policy if exists "transfer_chunks_update_sender" on storage.objects;

create policy "transfer_chunks_select_sender_or_receiver"
  on storage.objects
  for select
  to authenticated
  using (
    bucket_id = 'transfer-chunks'
    and (storage.foldername(name))[1] is not null
    and (storage.foldername(name))[2] is not null
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

create policy "transfer_chunks_insert_sender"
  on storage.objects
  for insert
  to authenticated
  with check (
    bucket_id = 'transfer-chunks'
    and (storage.foldername(name))[1] is not null
    and (storage.foldername(name))[2] is not null
    and storage.filename(name) ~ '^chunk_[0-9]+\\.part$'
    and exists (
      select 1
      from public.transfer_sessions ts
      where ts.transfer_id = (storage.foldername(name))[1]
        and auth.uid() = ts.sender_id
    )
  );

create policy "transfer_chunks_update_sender"
  on storage.objects
  for update
  to authenticated
  using (
    bucket_id = 'transfer-chunks'
    and (storage.foldername(name))[1] is not null
    and (storage.foldername(name))[2] is not null
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
    and (storage.foldername(name))[2] is not null
    and storage.filename(name) ~ '^chunk_[0-9]+\\.part$'
    and exists (
      select 1
      from public.transfer_sessions ts
      where ts.transfer_id = (storage.foldername(name))[1]
        and auth.uid() = ts.sender_id
    )
  );

create policy "transfer_chunks_delete_sender"
  on storage.objects
  for delete
  to authenticated
  using (
    bucket_id = 'transfer-chunks'
    and (storage.foldername(name))[1] is not null
    and (storage.foldername(name))[2] is not null
    and exists (
      select 1
      from public.transfer_sessions ts
      where ts.transfer_id = (storage.foldername(name))[1]
        and auth.uid() = ts.sender_id
    )
  );
