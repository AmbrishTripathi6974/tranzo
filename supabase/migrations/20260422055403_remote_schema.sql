drop extension if exists "pg_net";

drop policy "transfer_sessions_insert_sender" on "public"."transfer_sessions";

drop policy "transfer_sessions_select_participant" on "public"."transfer_sessions";

drop policy "transfer_sessions_update_participant" on "public"."transfer_sessions";

revoke delete on table "public"."transfer_sessions" from "authenticated";

revoke insert on table "public"."transfer_sessions" from "authenticated";

revoke references on table "public"."transfer_sessions" from "authenticated";

revoke select on table "public"."transfer_sessions" from "authenticated";

revoke trigger on table "public"."transfer_sessions" from "authenticated";

revoke truncate on table "public"."transfer_sessions" from "authenticated";

revoke update on table "public"."transfer_sessions" from "authenticated";

revoke delete on table "public"."transfer_sessions" from "service_role";

revoke insert on table "public"."transfer_sessions" from "service_role";

revoke references on table "public"."transfer_sessions" from "service_role";

revoke select on table "public"."transfer_sessions" from "service_role";

revoke trigger on table "public"."transfer_sessions" from "service_role";

revoke truncate on table "public"."transfer_sessions" from "service_role";

revoke update on table "public"."transfer_sessions" from "service_role";

alter table "public"."transfer_sessions" drop constraint "transfer_sessions_file_size_check";

alter table "public"."transfer_sessions" drop constraint "transfer_sessions_receiver_id_fkey";

alter table "public"."transfer_sessions" drop constraint "transfer_sessions_sender_id_fkey";

alter table "public"."transfer_sessions" drop constraint "transfer_sessions_sender_receiver_check";

alter table "public"."transfer_sessions" drop constraint "transfer_sessions_transfer_id_key";

alter table "public"."transfer_sessions" drop constraint "transfer_sessions_pkey";

drop index if exists "public"."transfer_sessions_pkey";

drop index if exists "public"."transfer_sessions_receiver_created_at_idx";

drop index if exists "public"."transfer_sessions_sender_created_at_idx";

drop index if exists "public"."transfer_sessions_status_idx";

drop index if exists "public"."transfer_sessions_transfer_id_key";

drop table "public"."transfer_sessions";

set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.rls_auto_enable()
 RETURNS event_trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'pg_catalog'
AS $function$
DECLARE
  cmd record;
BEGIN
  FOR cmd IN
    SELECT *
    FROM pg_event_trigger_ddl_commands()
    WHERE command_tag IN ('CREATE TABLE', 'CREATE TABLE AS', 'SELECT INTO')
      AND object_type IN ('table','partitioned table')
  LOOP
     IF cmd.schema_name IS NOT NULL AND cmd.schema_name IN ('public') AND cmd.schema_name NOT IN ('pg_catalog','information_schema') AND cmd.schema_name NOT LIKE 'pg_toast%' AND cmd.schema_name NOT LIKE 'pg_temp%' THEN
      BEGIN
        EXECUTE format('alter table if exists %s enable row level security', cmd.object_identity);
        RAISE LOG 'rls_auto_enable: enabled RLS on %', cmd.object_identity;
      EXCEPTION
        WHEN OTHERS THEN
          RAISE LOG 'rls_auto_enable: failed to enable RLS on %', cmd.object_identity;
      END;
     ELSE
        RAISE LOG 'rls_auto_enable: skip % (either system schema or not in enforced list: %.)', cmd.object_identity, cmd.schema_name;
     END IF;
  END LOOP;
END;
$function$
;

drop policy "transfer_chunks_insert_participant" on "storage"."objects";

drop policy "transfer_chunks_select_participant" on "storage"."objects";

drop policy "transfer_chunks_update_participant" on "storage"."objects";


