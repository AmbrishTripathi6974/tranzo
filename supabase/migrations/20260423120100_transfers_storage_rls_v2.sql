-- Chunk storage for new pipeline: transfers/{sender_id}/{transfer_id}/chunk_{n}
-- Coexists with legacy transfer_sessions-based policies on the same bucket.

drop policy if exists "transfer_chunks_select_transfers_v2" on storage.objects;
drop policy if exists "transfer_chunks_write_transfers_v2_sender" on storage.objects;

create policy "transfer_chunks_select_transfers_v2"
  on storage.objects
  for select
  to authenticated
  using (
    bucket_id = 'transfer-chunks'
    and (storage.foldername(name))[1] = 'transfers'
    and (storage.foldername(name))[2] is not null
    and (storage.foldername(name))[3] is not null
    and exists (
      select 1
      from public.transfers t
      where t.id::text = (storage.foldername(name))[3]
        and t.sender_id::text = (storage.foldername(name))[2]
        and (auth.uid() = t.sender_id or auth.uid() = t.receiver_id)
    )
  );

create policy "transfer_chunks_write_transfers_v2_sender"
  on storage.objects
  for all
  to authenticated
  using (
    bucket_id = 'transfer-chunks'
    and (storage.foldername(name))[1] = 'transfers'
    and (storage.foldername(name))[2] is not null
    and (storage.foldername(name))[3] is not null
    and storage.filename(name) ~ '^chunk_[0-9]+$'
    and exists (
      select 1
      from public.transfers t
      where t.id::text = (storage.foldername(name))[3]
        and t.sender_id::text = (storage.foldername(name))[2]
        and auth.uid() = t.sender_id
    )
  )
  with check (
    bucket_id = 'transfer-chunks'
    and (storage.foldername(name))[1] = 'transfers'
    and (storage.foldername(name))[2] is not null
    and (storage.foldername(name))[3] is not null
    and storage.filename(name) ~ '^chunk_[0-9]+$'
    and exists (
      select 1
      from public.transfers t
      where t.id::text = (storage.foldername(name))[3]
        and t.sender_id::text = (storage.foldername(name))[2]
        and auth.uid() = t.sender_id
    )
  );
