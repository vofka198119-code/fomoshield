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

-- =============================================================================
-- Set Aleksejs.Ziznevskis@gmail.com as Premium (10 years from now — tester account)
-- Run this AFTER running Migration 003 ALTER statements above.
-- =============================================================================

UPDATE public.users
SET subscription_tier = 'premium',
    subscription_expires_at = now() + INTERVAL '10 years'
WHERE email = 'Aleksejs.Ziznevskis@gmail.com';


-- =============================================================================
-- F.O.M.O. Shield — Supabase Migration 004
-- Table: user_data (ALTER)
-- Description: Adds stress-test session sync, so active stress-test progress
--              survives reinstall the same way portfolios/watchlist do.
-- =============================================================================

ALTER TABLE public.user_data
ADD COLUMN IF NOT EXISTS stress_test_sessions JSONB NOT NULL DEFAULT '[]'::jsonb;


-- =============================================================================
-- F.O.M.O. Shield — Supabase Migration 005
-- Table: auth.users (DROP TRIGGER)
-- Description: Removes the auto_confirm_email trigger from Migration 001.
--              That trigger was labeled "for dev environment" but was live
--              in production, silently confirming every signup's email
--              without the user ever clicking a confirmation link — i.e.
--              anyone could register with an email they don't own.
--
-- Supabase's own Auth setting (mailer_autoconfirm) is already `false` on
-- this project (confirmed via GET /auth/v1/settings) — real confirmation
-- emails will now actually be required and sent once this trigger is gone.
-- The Flutter app's signup flow (auth_screen.dart) already handles this
-- correctly: if signUp() returns no session, it shows "Please check your
-- email to confirm registration." and does not auto-login. No app change
-- needed for this migration to take effect.
-- =============================================================================

DROP TRIGGER IF EXISTS on_auth_user_created_auto_confirm ON auth.users;
DROP FUNCTION IF EXISTS public.auto_confirm_email();


-- =============================================================================
-- F.O.M.O. Shield — Supabase Migration 006
-- Table: auth.users (DROP TRIGGER)
-- Description: Migration 005 didn't fully close the gap — live DB had a
--              SECOND, differently-named auto-confirm trigger
--              (on_auth_user_created_confirm) not present anywhere in this
--              file, i.e. created out-of-band (dashboard/an earlier draft),
--              never tracked here. Found by listing every trigger on
--              auth.users directly, since a fresh throwaway signup still
--              auto-confirmed immediately after Migration 005 ran.
-- =============================================================================

DROP TRIGGER IF EXISTS on_auth_user_created_confirm ON auth.users;


-- =============================================================================
-- F.O.M.O. Shield — Supabase Migration 007
-- Table: user_data (ALTER)
-- Description: Completed stress-test verdicts (VerdictArchiveEntry — the
--              archived results/scores from every finished test) were only
--              ever persisted to local SharedPreferences, never synced to
--              Supabase like Migration 004 did for active sessions. Confirmed
--              real data loss 2026-08-06: a phone-side reinstall wiped every
--              past verdict with no way to recover it. This column is the fix.
-- =============================================================================

ALTER TABLE public.user_data
ADD COLUMN IF NOT EXISTS stress_test_verdicts JSONB NOT NULL DEFAULT '[]'::jsonb;


-- =============================================================================
-- F.O.M.O. Shield — Supabase Migration 008
-- Table: users (TRIGGER)
-- Description: Closes a real privilege-escalation hole found in the
--              2026-08-15 pre-release audit — the `users_update_own` RLS
--              policy (Migration 001) authorizes a signed-in user to
--              UPDATE their whole own row, with no column-level
--              restriction. Since subscription_tier/subscription_expires_at
--              (Migration 003) live on that same row, any authenticated
--              user could PATCH their own row directly via Supabase's
--              REST API (their own JWT + the publicly-embedded anon key
--              are both meant to be public) and grant themselves
--              `subscription_tier: 'premium'` for free — completely
--              bypassing the app and the admin-only grant path
--              (scripts/set-premium.js). This was live/exploitable
--              immediately, even before any real payment flow exists.
--
-- Fix: a BEFORE UPDATE trigger that silently reverts
-- subscription_tier/subscription_expires_at to their previous value
-- whenever the request does NOT come from the service_role (i.e. any
-- normal user-authenticated request). scripts/set-premium.js already
-- uses the service_role key, so the admin grant path is unaffected.
-- Every other column a user legitimately self-updates (email,
-- is_setup_complete, disclaimer_accepted_version, ...) is untouched —
-- this only locks the two subscription columns.
-- =============================================================================

CREATE OR REPLACE FUNCTION public.protect_subscription_columns()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER SET search_path = ''
AS $$
BEGIN
    IF auth.role() <> 'service_role' THEN
        NEW.subscription_tier := OLD.subscription_tier;
        NEW.subscription_expires_at := OLD.subscription_expires_at;
    END IF;
    RETURN NEW;
END;
$$;

CREATE OR REPLACE TRIGGER protect_subscription_columns_trigger
    BEFORE UPDATE ON public.users
    FOR EACH ROW
    EXECUTE FUNCTION public.protect_subscription_columns();


-- =============================================================================
-- F.O.M.O. Shield — Supabase Migration 009
-- Table: users (COLUMN)
-- Description: 14-day soft-delete for account deletion (2026-08-16). The
--              "Delete Account" button previously called
--              supabaseAdmin.auth.admin.deleteUser() directly — immediate,
--              permanent, no recovery. Now it only sets this timestamp;
--              the account keeps existing untouched. A daily sweep on the
--              backend (see scanco-backend's src/services/accountCleanup.js)
--              hard-deletes any account whose deletion_requested_at is more
--              than 14 days old. Signing back in while this is set routes
--              the user to a full-block "Restore Account" screen instead of
--              the app (see app_router.dart's session guard) — restoring
--              just clears this column back to NULL.
-- =============================================================================

ALTER TABLE public.users
ADD COLUMN IF NOT EXISTS deletion_requested_at TIMESTAMPTZ NULL DEFAULT NULL;


-- =============================================================================
-- F.O.M.O. Shield — Supabase Migration 010
-- Table: company_encyclopedia
-- Description: "Company History" long-form text per ticker (business history
--              + market/exchange history, RU+EN) — the Encyclopedia widget on
--              Company Detail (2026-08-29). Content is authored offline
--              (ChatGPT-drafted, human-reviewed) and filled in company-by-
--              company over time, not a launch-day complete dataset — a
--              symbol with no row here is expected and the app just shows
--              "no data yet" for it, not an error.
--
--              Read-only from the app's perspective: any signed-in user can
--              SELECT (the free/premium/admin ad-gate that decides who's
--              actually allowed to open the read screen is entirely client-
--              side, same trust model as subscription_tier gating
--              elsewhere in this app — see scanco-backend's routes/
--              encyclopedia.js). Writes only ever come from scanco-backend's
--              scripts/seed-company-encyclopedia.js using the service_role
--              key, which bypasses RLS entirely — same admin-script pattern
--              as scripts/set-premium.js. No INSERT/UPDATE/DELETE policy is
--              defined for normal users on purpose.
-- =============================================================================

CREATE TABLE IF NOT EXISTS public.company_encyclopedia (
    symbol                TEXT PRIMARY KEY,
    business_history_ru   TEXT,
    business_history_en   TEXT,
    market_history_ru     TEXT,
    market_history_en     TEXT,
    updated_at            TIMESTAMPTZ NOT NULL DEFAULT now()
);

ALTER TABLE public.company_encyclopedia ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "company_encyclopedia_select_authenticated" ON public.company_encyclopedia;
CREATE POLICY "company_encyclopedia_select_authenticated"
    ON public.company_encyclopedia
    FOR SELECT
    TO authenticated
    USING (true);

CREATE OR REPLACE TRIGGER on_company_encyclopedia_updated
    BEFORE UPDATE ON public.company_encyclopedia
    FOR EACH ROW
    EXECUTE FUNCTION public.update_updated_at_column();


-- =============================================================================
-- F.O.M.O. Shield — Supabase Migration 011
-- Table: company_encyclopedia (COLUMNS)
-- Description: Third Encyclopedia row, "В наши дни" / "Present Day" (2026-08-
--              29) — same RU+EN, nullable-until-filled shape as the two
--              Migration 010 text pairs, no other schema change needed.
-- =============================================================================

ALTER TABLE public.company_encyclopedia
ADD COLUMN IF NOT EXISTS present_day_ru TEXT,
ADD COLUMN IF NOT EXISTS present_day_en TEXT;


-- =============================================================================
-- F.O.M.O. Shield — Supabase Migration 012
-- Table: user_data (TRIGGER)
-- Description: Blunt anti-cheat ceiling on user_data, found in the 2026-09-05
--              pre-release audit. Unlike subscription_tier (Migration 008 —
--              two flat columns the client never legitimately writes, so that
--              trigger can just revert any client-side change outright),
--              portfolios/stress_test_sessions/stress_test_verdicts are JSONB
--              blobs the client is SUPPOSED to keep rewriting on every trade,
--              tick, and session deletion — a normal Postgres RLS/trigger
--              can't tell a legitimate save from a client that PATCHed its
--              own row via the REST API with a fabricated transaction history
--              (both use nothing but the user's own JWT + the public anon
--              key). Properly closing that hole means the backend
--              re-deriving balances from an authoritative trade log server-
--              side instead of trusting the client's JSON wholesale — too
--              large a change to bundle here, and out of proportion for a
--              small closed beta where the only stake is fake money (i.e.
--              beta-leaderboard/test-integrity, not real funds).
--
--              This trigger instead only rejects the crudest version of the
--              exploit: a starting-balance field set absurdly high. Every
--              tier's real starting balance tops out at $15,000 (see
--              portfolio_limits_provider.dart / stress test tier setup), so
--              $1,000,000 is a ceiling no legitimate write can ever reach.
--              It deliberately does NOT touch `cash`, `price`, `avgCost`,
--              `finalValue`, or similar — those can plausibly grow large
--              over many trades/compounding, and stress_test_sessions also
--              stores genuine large numbers unrelated to money (epoch-
--              millisecond price-history timestamps), which a naive "any
--              number anywhere" check would have falsely rejected. A patient
--              cheater who leaves startingBalance/startingCash alone and
--              fabricates a smaller, plausible-looking gain elsewhere still
--              gets through — this only stops someone typing themselves a
--              blatant, lazy number.
-- =============================================================================

CREATE OR REPLACE FUNCTION public.guard_user_data_sanity_ceiling()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER SET search_path = ''
AS $$
DECLARE
    max_starting_balance CONSTANT numeric := 1000000; -- $1,000,000 — real tier caps top out at $15k
    vars CONSTANT jsonb := jsonb_build_object('ceiling', max_starting_balance);
BEGIN
    -- Admin/service scripts (set-premium.js-style, service_role key) bypass —
    -- same precedent as Migration 008's protect_subscription_columns.
    IF auth.role() = 'service_role' THEN
        RETURN NEW;
    END IF;

    IF jsonb_path_exists(
           NEW.portfolios,
           '$.**.startingBalance ? (@.type() == "number" && @ > $ceiling)',
           vars
       )
       OR jsonb_path_exists(
           NEW.stress_test_sessions,
           '$.**.startingCash ? (@.type() == "number" && @ > $ceiling)',
           vars
       )
       OR jsonb_path_exists(
           NEW.stress_test_verdicts,
           '$.**.startingCash ? (@.type() == "number" && @ > $ceiling)',
           vars
       )
    THEN
        RAISE EXCEPTION
            'user_data write rejected: a startingBalance/startingCash field exceeds the $% sanity ceiling (Migration 012 — blunt anti-cheat guard, see its comment)',
            max_starting_balance;
    END IF;

    RETURN NEW;
END;
$$;

CREATE OR REPLACE TRIGGER guard_user_data_sanity_ceiling_trigger
    BEFORE INSERT OR UPDATE ON public.user_data
    FOR EACH ROW
    EXECUTE FUNCTION public.guard_user_data_sanity_ceiling();
