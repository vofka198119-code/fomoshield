-- =============================================================================
-- F.O.M.O. Shield — Supabase Migration 002
-- Table: user_data
-- Description: Stores all user data (portfolios, watchlist, widget settings)
-- =============================================================================
--
-- Each user gets a single JSONB row with all their app data:
--   portfolios: JSON array of Portfolio objects (with transactions)
--   watchlist:  JSON array of ticker symbols
--   widget_order: JSON array of {id, visible} objects
--
-- This approach keeps RLS simple (one row per user) and avoids schema changes
-- when adding new data types. Loaded on login, saved on every mutation.
--
-- =============================================================================

CREATE TABLE IF NOT EXISTS public.user_data (
    id            UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    portfolios    JSONB NOT NULL DEFAULT '[]'::jsonb,
    watchlist     JSONB NOT NULL DEFAULT '[]'::jsonb,
    widget_order  JSONB NOT NULL DEFAULT '[]'::jsonb,
    orders        JSONB NOT NULL DEFAULT '[]'::jsonb,
    created_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at    TIMESTAMPTZ NOT NULL DEFAULT now()
);

ALTER TABLE public.user_data ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "user_data_select_own" ON public.user_data;
CREATE POLICY "user_data_select_own"
    ON public.user_data
    FOR SELECT
    USING (auth.uid() = id);

DROP POLICY IF EXISTS "user_data_insert_own" ON public.user_data;
CREATE POLICY "user_data_insert_own"
    ON public.user_data
    FOR INSERT
    WITH CHECK (auth.uid() = id);

DROP POLICY IF EXISTS "user_data_update_own" ON public.user_data;
CREATE POLICY "user_data_update_own"
    ON public.user_data
    FOR UPDATE
    USING (auth.uid() = id);

-- Auto-create user_data row on signup
CREATE OR REPLACE FUNCTION public.handle_new_user_data()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER SET search_path = ''
AS $$
BEGIN
    INSERT INTO public.user_data (id)
    VALUES (NEW.id)
    ON CONFLICT (id) DO NOTHING;
    RETURN NEW;
END;
$$;

CREATE OR REPLACE TRIGGER on_auth_user_created_data
    AFTER INSERT ON auth.users
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_new_user_data();

-- Auto-update updated_at
CREATE OR REPLACE TRIGGER on_user_data_updated
    BEFORE UPDATE ON public.user_data
    FOR EACH ROW
    EXECUTE FUNCTION public.update_updated_at_column();


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

DROP POLICY IF EXISTS "users_update_own" ON public.users
;
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


-- =============================================================================
-- F.O.M.O. Shield — Supabase Migration 003
-- Table: users (ALTER)
-- Description: Adds subscription management columns
-- =============================================================================
--
-- Adds:
--   subscription_tier      — 'free', 'premium', or 'admin'
--   subscription_expires_at — NULL for lifetime, timestamp for fixed-term
--
-- Usage:
--   -- Make a user premium for 1 year:
--   UPDATE public.users
--   SET subscription_tier = 'premium',
--       subscription_expires_at = now() + INTERVAL '1 year'
--   WHERE email = 'user@example.com';
--
--   -- Make a user premium (lifetime):
--   UPDATE public.users
--   SET subscription_tier = 'premium',
--       subscription_expires_at = NULL
--   WHERE email = 'user@example.com';
--
-- =============================================================================

ALTER TABLE public.users
ADD COLUMN IF NOT EXISTS subscription_tier TEXT NOT NULL DEFAULT 'free';

ALTER TABLE public.users
ADD COLUMN IF NOT EXISTS subscription_expires_at TIMESTAMPTZ;

-- =============================================================================
-- Set vofka198119@gmail.com as Premium (5 years from now — test account)
-- Run this AFTER running Migration 003 ALTER statements above.
-- =============================================================================

UPDATE public.users
SET subscription_tier = 'premium',
    subscription_expires_at = now() + INTERVAL '5 years'
WHERE email = 'vofka198119@gmail.com';
