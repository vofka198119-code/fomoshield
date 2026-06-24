-- =============================================================================
-- F.O.M.O. Shield — Supabase Migration 001
-- Table: users
-- Description: Stores user profile and setup progress
-- =============================================================================
--
-- NOTE (2026-06-23):
-- - PIN system and biometrics have been REMOVED from the Flutter app.
-- - The column `is_biometrics_enabled` is kept for backward compatibility
--   but is no longer used by the app. It can be dropped in a future migration.
-- - Authentication is now purely email+password via Supabase Auth.
-- - "Remember Me" is handled client-side via FlutterSecureStorage (not in DB).
--
-- =============================================================================

-- 1. Create the users table
CREATE TABLE IF NOT EXISTS public.users (
    id          UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    email       TEXT NOT NULL,
    is_setup_complete          BOOLEAN NOT NULL DEFAULT false,
    disclaimer_accepted_version TEXT,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- 2. Enable Row-Level Security
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;

-- 3. RLS policies (idempotent — safe to run multiple times)

DROP POLICY IF EXISTS "users_select_own" ON public.users;
CREATE POLICY "users_select_own"
    ON public.users
    FOR SELECT
    USING (auth.uid() = id);

DROP POLICY IF EXISTS "users_insert_own" ON public.users;
CREATE POLICY "users_insert_own"
    ON public.users
    FOR INSERT
    WITH CHECK (auth.uid() = id);

DROP POLICY IF EXISTS "users_update_own" ON public.users;
CREATE POLICY "users_update_own"
    ON public.users
    FOR UPDATE
    USING (auth.uid() = id);

-- 4. Auto-create a users row on signup (trigger)
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER SET search_path = ''
AS $$
BEGIN
    INSERT INTO public.users (id, email)
    VALUES (NEW.id, NEW.email)
    ON CONFLICT (id) DO NOTHING;
    RETURN NEW;
END;
$$;

-- Trigger fires after a new user is created in auth.users
CREATE OR REPLACE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_new_user();

-- 5. Legacy: is_biometrics_enabled (no longer used by app, kept for compat)
ALTER TABLE public.users ADD COLUMN IF NOT EXISTS is_biometrics_enabled BOOLEAN NOT NULL DEFAULT false;

-- 6. Auto-confirm email for dev environment
-- When email confirmation is ON in Supabase, this trigger auto-confirms new users
CREATE OR REPLACE FUNCTION public.auto_confirm_email()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER SET search_path = ''
AS $$
BEGIN
    UPDATE auth.users
    SET email_confirmed_at = COALESCE(email_confirmed_at, now())
    WHERE id = NEW.id AND email_confirmed_at IS NULL;
    RETURN NEW;
END;
$$;

CREATE OR REPLACE TRIGGER on_auth_user_created_auto_confirm
    AFTER INSERT ON auth.users
    FOR EACH ROW
    EXECUTE FUNCTION public.auto_confirm_email();

-- 7. Auto-update updated_at timestamp
CREATE OR REPLACE FUNCTION public.update_updated_at_column()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER SET search_path = ''
AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW;
END;
$$;

CREATE OR REPLACE TRIGGER on_users_updated
    BEFORE UPDATE ON public.users
    FOR EACH ROW
    EXECUTE FUNCTION public.update_updated_at_column();
