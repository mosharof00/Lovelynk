-- Admin audit log removed from scope.
drop trigger if exists broadcasts_audit on public.broadcasts;
drop trigger if exists support_tickets_audit on public.support_tickets;
drop trigger if exists app_settings_audit on public.app_settings;
drop trigger if exists admins_audit on public.admins;

drop function if exists private.audit_admin_change();
drop function if exists private.prevent_audit_update();

drop table if exists public.admin_audit_log;
