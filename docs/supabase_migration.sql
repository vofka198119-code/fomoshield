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


-- =============================================================================
-- F.O.M.O. Shield — Supabase Migration 013
-- Tables: funds, fund_holdings, fund_nav_snapshots
-- Feature: ETF Fund Emulation, Phase 1 (see docs/ETF_FUND_EMULATION.md and the
--          phased implementation plan referenced from that doc).
--
-- These are deliberately NEW, STANDALONE tables — none of them touch
-- `user_data`. Migration 012's $1,000,000 ceiling trigger above only
-- inspects portfolios/stress_test_sessions/stress_test_verdicts inside
-- `user_data`, so it never applies to fund state by construction. If a
-- future change ever moves any fund data into a `user_data` column instead,
-- Migration 012 MUST be revisited first (ceiling raised or path excluded) —
-- see open question #9 in docs/ETF_FUND_EMULATION.md.
--
-- Server-authoritative by design (unlike user_data, which the Flutter app
-- writes directly): RLS grants SELECT to `authenticated` only — every
-- INSERT/UPDATE/DELETE goes through the backend's service-role client
-- (supabaseAdmin.js in scanco-backend-work), never directly from the app via
-- the anon/authenticated key. This is the app's first server-authoritative
-- financial state (Portfolio/Stress Test are entirely client-authoritative).
-- =============================================================================

CREATE TABLE public.funds (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    head_user_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    name text NOT NULL,
    ticker text NOT NULL UNIQUE,
    description text,
    strategy text,
    sectors text[] NOT NULL DEFAULT '{}',
    starting_capital numeric NOT NULL CHECK (starting_capital > 0 AND starting_capital <= 150000),
    -- Cash on hand (part of AUM alongside fund_holdings' market value). Starts
    -- equal to starting_capital; moves with Phase 2's subscribe/redeem flow
    -- and Phase 4's trade execution, neither of which exists yet in Phase 1.
    cash numeric NOT NULL,
    units_outstanding numeric NOT NULL DEFAULT 0,
    -- 'active' is the only status Phase 1 uses; Phase 8 (succession/
    -- bankruptcy) adds 'frozen'/'bankrupt' and the ownership-transfer columns.
    status text NOT NULL DEFAULT 'active',
    created_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE public.fund_holdings (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    fund_id uuid NOT NULL REFERENCES public.funds(id) ON DELETE CASCADE,
    symbol text NOT NULL,
    quantity numeric NOT NULL DEFAULT 0,
    UNIQUE (fund_id, symbol)
);

CREATE TABLE public.fund_nav_snapshots (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    fund_id uuid NOT NULL REFERENCES public.funds(id) ON DELETE CASCADE,
    nav_per_unit numeric NOT NULL,
    aum numeric NOT NULL,
    units_outstanding numeric NOT NULL,
    snapshot_date date NOT NULL,
    created_at timestamptz NOT NULL DEFAULT now(),
    -- One snapshot per fund per day — the daily batched job (Phase 1's
    -- fundNavSnapshotService.js) upserts on conflict rather than duplicating.
    UNIQUE (fund_id, snapshot_date)
);

ALTER TABLE public.funds ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.fund_holdings ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.fund_nav_snapshots ENABLE ROW LEVEL SECURITY;

CREATE POLICY funds_select_authenticated ON public.funds
    FOR SELECT TO authenticated USING (true);
CREATE POLICY fund_holdings_select_authenticated ON public.fund_holdings
    FOR SELECT TO authenticated USING (true);
CREATE POLICY fund_nav_snapshots_select_authenticated ON public.fund_nav_snapshots
    FOR SELECT TO authenticated USING (true);

-- No INSERT/UPDATE/DELETE policies for `authenticated` on any of the three
-- tables above, intentionally — only the backend's service_role client can
-- write (RLS is bypassed entirely for service_role, same precedent as
-- company_encyclopedia in Migration 010/011).


-- =============================================================================
-- F.O.M.O. Shield — Supabase Migration 014
-- Table: funds (INDEX)
-- Feature: ETF Fund Emulation, Phase 1 — fund names must be unique
-- (case-insensitive), not just tickers. fundService.js's assertNameAvailable
-- is the fast-path check; this unique index is the real backstop against a
-- race between two concurrent fund-creation requests both passing that
-- check before either has inserted (caught as Postgres error 23505 in
-- fundService.js's createFund and turned into a clean validation error).
-- =============================================================================

CREATE UNIQUE INDEX funds_name_unique_ci_idx ON public.funds (lower(name));


-- =============================================================================
-- F.O.M.O. Shield — Supabase Migration 015
-- Tables: fund_investor_positions, fund_investor_transactions
-- Functions: fund_subscribe, fund_redeem
-- Feature: ETF Fund Emulation, Phase 2 — buy/sell fund units. Money flow is
-- direct-cash, not a real-world AP/creation-redemption basket: subscribing
-- adds the invested amount straight onto `funds.cash` (the fund's own
-- spendable balance, so a head/analyst can actually deploy it), redeeming
-- subtracts the payout from it. There is deliberately NO separate "Fund
-- Investing" balance — the money comes straight out of the investor's real
-- Portfolio cash on the Flutter side; these two tables only track the
-- FUND's side of the ledger (server-authoritative, same as Migration 013).
--
-- fund_investor_positions is the current-state cap table (units held per
-- user per fund) — needed for redeem's "can't sell more than you hold"
-- check and for Phase 3+'s Management Room cap table.
-- fund_investor_transactions is the append-only ledger — doubles as the
-- source for the "distinct holders" popularity metric (count distinct
-- user_id, not summed inflow — see design doc's anti-abuse resolution) and
-- future audit trail.
--
-- Concurrency: fund_subscribe/fund_redeem are plpgsql functions, not plain
-- app-level read-then-write — each takes a `SELECT ... FOR UPDATE` row lock
-- on the contested `funds` row (and, for redeem, the investor's position
-- row) before computing NAV and mutating cash/units_outstanding, so two
-- concurrent buys/sells against the same fund can't race each other. The
-- holdings' market value (which needs a live external quote, impossible
-- inside a plain SQL function) is computed by the Node layer just before
-- calling in and passed as `p_holdings_value` — that number doesn't need
-- locking since it isn't a contested column, only cash/units_outstanding
-- are.
--
-- Both functions lock `funds` BEFORE `fund_investor_positions` (redeem
-- locks the position row second, after the funds row) — same order in
-- both, deliberately, so a subscribe and a redeem racing on the same
-- fund+user pair can't deadlock from acquiring the two locks in opposite
-- orders.
--
-- No cash floor enforced on redeem — per the design doc's explicit
-- decision, sell liquidity is always instant and guaranteed regardless of
-- the fund's cash reserve (a head who invested all the cash and faces a
-- big redemption is a textual onboarding warning, not a hard failure).
-- =============================================================================

CREATE TABLE public.fund_investor_positions (
    fund_id uuid NOT NULL REFERENCES public.funds(id) ON DELETE CASCADE,
    user_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    units_held numeric NOT NULL DEFAULT 0 CHECK (units_held >= 0),
    updated_at timestamptz NOT NULL DEFAULT now(),
    PRIMARY KEY (fund_id, user_id)
);

CREATE TABLE public.fund_investor_transactions (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    fund_id uuid NOT NULL REFERENCES public.funds(id) ON DELETE CASCADE,
    user_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    type text NOT NULL CHECK (type IN ('subscribe', 'redeem')),
    units numeric NOT NULL CHECK (units > 0),
    nav_per_unit numeric NOT NULL CHECK (nav_per_unit > 0),
    amount numeric NOT NULL CHECK (amount > 0),
    created_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX fund_investor_transactions_fund_id_idx ON public.fund_investor_transactions (fund_id);
CREATE INDEX fund_investor_transactions_user_id_idx ON public.fund_investor_transactions (user_id);

ALTER TABLE public.fund_investor_positions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.fund_investor_transactions ENABLE ROW LEVEL SECURITY;

-- Unlike funds/fund_holdings (intentionally public-readable), a user's own
-- position/transactions are private — scoped to auth.uid(). Aggregate
-- numbers derived from these tables (holder counts, popularity) are
-- computed server-side via the service-role client, never through a
-- broad SELECT-all policy here.
CREATE POLICY fund_investor_positions_select_own ON public.fund_investor_positions
    FOR SELECT TO authenticated USING (user_id = auth.uid());
CREATE POLICY fund_investor_transactions_select_own ON public.fund_investor_transactions
    FOR SELECT TO authenticated USING (user_id = auth.uid());

-- No INSERT/UPDATE/DELETE policies for `authenticated` — only the backend's
-- service-role client writes, exclusively through the two functions below.

CREATE OR REPLACE FUNCTION public.fund_subscribe(
    p_fund_id uuid,
    p_user_id uuid,
    p_amount numeric,
    p_holdings_value numeric
) RETURNS TABLE (nav_per_unit numeric, units_issued numeric, new_cash numeric, new_units_outstanding numeric)
LANGUAGE plpgsql
AS $$
DECLARE
    v_cash numeric;
    v_units_outstanding numeric;
    v_nav numeric;
    v_units_issued numeric;
BEGIN
    IF p_amount <= 0 THEN
        RAISE EXCEPTION 'amount must be positive';
    END IF;

    SELECT cash, units_outstanding INTO v_cash, v_units_outstanding
    FROM public.funds WHERE id = p_fund_id FOR UPDATE;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'fund not found';
    END IF;

    v_nav := CASE WHEN v_units_outstanding > 0
                  THEN (v_cash + p_holdings_value) / v_units_outstanding
                  ELSE 10.0 END;
    v_units_issued := p_amount / v_nav;

    UPDATE public.funds
    SET cash = cash + p_amount,
        units_outstanding = units_outstanding + v_units_issued
    WHERE id = p_fund_id
    RETURNING cash, units_outstanding INTO v_cash, v_units_outstanding;

    INSERT INTO public.fund_investor_positions (fund_id, user_id, units_held, updated_at)
    VALUES (p_fund_id, p_user_id, v_units_issued, now())
    ON CONFLICT (fund_id, user_id)
    DO UPDATE SET units_held = fund_investor_positions.units_held + v_units_issued,
                  updated_at = now();

    INSERT INTO public.fund_investor_transactions (fund_id, user_id, type, units, nav_per_unit, amount)
    VALUES (p_fund_id, p_user_id, 'subscribe', v_units_issued, v_nav, p_amount);

    RETURN QUERY SELECT v_nav, v_units_issued, v_cash, v_units_outstanding;
END;
$$;

CREATE OR REPLACE FUNCTION public.fund_redeem(
    p_fund_id uuid,
    p_user_id uuid,
    p_units numeric,
    p_holdings_value numeric
) RETURNS TABLE (nav_per_unit numeric, payout numeric, new_cash numeric, new_units_outstanding numeric)
LANGUAGE plpgsql
AS $$
DECLARE
    v_cash numeric;
    v_units_outstanding numeric;
    v_nav numeric;
    v_payout numeric;
    v_units_held numeric;
BEGIN
    IF p_units <= 0 THEN
        RAISE EXCEPTION 'units must be positive';
    END IF;

    -- Locks `funds` first, `fund_investor_positions` second — same order
    -- fund_subscribe uses, see this migration's header comment on why.
    SELECT cash, units_outstanding INTO v_cash, v_units_outstanding
    FROM public.funds WHERE id = p_fund_id FOR UPDATE;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'fund not found';
    END IF;

    SELECT units_held INTO v_units_held
    FROM public.fund_investor_positions
    WHERE fund_id = p_fund_id AND user_id = p_user_id
    FOR UPDATE;

    IF NOT FOUND OR v_units_held < p_units THEN
        RAISE EXCEPTION 'insufficient_units';
    END IF;

    v_nav := CASE WHEN v_units_outstanding > 0
                  THEN (v_cash + p_holdings_value) / v_units_outstanding
                  ELSE 10.0 END;
    v_payout := p_units * v_nav;

    UPDATE public.funds
    SET cash = cash - v_payout,
        units_outstanding = units_outstanding - p_units
    WHERE id = p_fund_id
    RETURNING cash, units_outstanding INTO v_cash, v_units_outstanding;

    UPDATE public.fund_investor_positions
    SET units_held = units_held - p_units, updated_at = now()
    WHERE fund_id = p_fund_id AND user_id = p_user_id;

    DELETE FROM public.fund_investor_positions
    WHERE fund_id = p_fund_id AND user_id = p_user_id AND units_held <= 0;

    INSERT INTO public.fund_investor_transactions (fund_id, user_id, type, units, nav_per_unit, amount)
    VALUES (p_fund_id, p_user_id, 'redeem', p_units, v_nav, v_payout);

    RETURN QUERY SELECT v_nav, v_payout, v_cash, v_units_outstanding;
END;
$$;


-- =============================================================================
-- F.O.M.O. Shield — Supabase Migration 016
-- Tables: employee_profiles, fund_team_members, fund_invitations
-- Column: funds.last_invite_message
-- Feature: ETF Fund Emulation, Phase 3 — hiring marketplace, roles, résumé.
-- See docs/ETF_FUND_EMULATION.md, "Ветка «Инвестиционный помощник»" /
-- "Ветка «Глава фонда»" / "Роли и права сотрудников" sections.
--
-- employee_profiles is one row per user who has ever created an analyst
-- profile (nickname/bio/language/availability, editable by the user) plus
-- career-stats columns the ALGORITHM writes (approved/rejected proposal
-- counts, funds-changed count, 1-10 rating) — these all start at zero/null
-- here because Phase 4 (trade proposals) is what actually produces
-- approved/rejected counts to compute a rating from; this migration only
-- reserves the columns.
--
-- fund_team_members is the roster: one row per (fund, user) currently
-- employed there. `role` is a starting permissions TEMPLATE, not a fixed
-- restriction — the head can freely edit `permissions` per employee
-- (fundTeamService.js's ROLE_PERMISSION_TEMPLATES seeds it at hire time).
-- `status`/`termination_notice_at` implement the doc's 5-day termination
-- notice (a head fires someone → status flips to pending_termination,
-- notice period elapses → a periodic sweep job actually removes the row —
-- never an instant DELETE).
--
-- fund_invitations is the envelope-invite flow: head sends one (with a
-- role + message) to a specific user found via the employee marketplace,
-- invitee accepts/declines. The partial unique index blocks a second
-- pending invite to the same person from the same fund without blocking a
-- new one after the first was resolved (accepted/declined/cancelled).
--
-- Public readability mirrors funds/fund_holdings (Migration 013): a fund's
-- roster is meant to be visible to its own investors (insider-holding
-- transparency, per the design doc's anti-self-dealing compensating
-- control) and employee_profiles are the public "resume" the marketplace
-- browses. fund_invitations is the one exception — private between the
-- fund's head and the invitee, never publicly readable.
-- =============================================================================

CREATE TABLE public.employee_profiles (
    user_id uuid PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    nickname text NOT NULL,
    bio text,
    language text,
    available_for_hire boolean NOT NULL DEFAULT true,
    approved_proposals_count integer NOT NULL DEFAULT 0,
    rejected_proposals_count integer NOT NULL DEFAULT 0,
    funds_changed_count integer NOT NULL DEFAULT 0,
    rating numeric,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE public.fund_team_members (
    fund_id uuid NOT NULL REFERENCES public.funds(id) ON DELETE CASCADE,
    user_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    role text NOT NULL CHECK (role IN ('analyst', 'co_manager', 'trader', 'risk_manager')),
    permissions jsonb NOT NULL DEFAULT '{}'::jsonb,
    treasurer_limit_amount numeric,
    status text NOT NULL DEFAULT 'active' CHECK (status IN ('active', 'pending_termination')),
    termination_notice_at timestamptz,
    joined_at timestamptz NOT NULL DEFAULT now(),
    PRIMARY KEY (fund_id, user_id)
);

CREATE TABLE public.fund_invitations (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    fund_id uuid NOT NULL REFERENCES public.funds(id) ON DELETE CASCADE,
    invitee_user_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    role text NOT NULL CHECK (role IN ('analyst', 'co_manager', 'trader', 'risk_manager')),
    message text NOT NULL,
    status text NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'accepted', 'declined', 'cancelled')),
    created_at timestamptz NOT NULL DEFAULT now(),
    responded_at timestamptz
);

-- Blocks a second pending invite to the same person from the same fund;
-- a fresh invite is fine once the earlier one is no longer pending.
CREATE UNIQUE INDEX fund_invitations_pending_unique_idx
    ON public.fund_invitations (fund_id, invitee_user_id) WHERE status = 'pending';
CREATE INDEX fund_invitations_invitee_idx ON public.fund_invitations (invitee_user_id);

-- Head types the invite message once; the app pre-fills it next time.
ALTER TABLE public.funds ADD COLUMN last_invite_message text;

ALTER TABLE public.employee_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.fund_team_members ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.fund_invitations ENABLE ROW LEVEL SECURITY;

CREATE POLICY employee_profiles_select_authenticated ON public.employee_profiles
    FOR SELECT TO authenticated USING (true);
CREATE POLICY fund_team_members_select_authenticated ON public.fund_team_members
    FOR SELECT TO authenticated USING (true);
CREATE POLICY fund_invitations_select_own ON public.fund_invitations
    FOR SELECT TO authenticated USING (
        invitee_user_id = auth.uid()
        OR fund_id IN (SELECT id FROM public.funds WHERE head_user_id = auth.uid())
    );

-- No INSERT/UPDATE/DELETE policies for `authenticated` on any of the three
-- tables — only the backend's service-role client writes, same precedent
-- as every prior fund-related migration.


-- =============================================================================
-- F.O.M.O. Shield — Supabase Migration 017
-- Column: users.nickname
-- Feature: global account nickname — one persistent handle per user, shown
-- instead of email anywhere another user can see who's involved (fund team
-- roster, hiring marketplace, employee profile). Replaces
-- employee_profiles.nickname (Migration 016), which was a free-text field
-- re-typed per profile — this is one identity per account instead.
--
-- Chosen once via a mandatory screen slotted into resolvePostAuthRoute()
-- (auth_providers.dart) right after the disclaimer gate — catches both a
-- brand-new signup and any already-existing account that doesn't have one
-- yet, since that resolver runs on every splash/login, not just first-ever
-- signup. Immutable after that — enforced app-side (the screen only shows
-- when nickname IS NULL), not by a DB trigger, consistent with how this
-- app handles its other "set once" fields.
--
-- Latin letters/digits/underscore only, 1-25 chars, enforced by the CHECK
-- below AND client-side before submit (belt-and-suspenders, same as fund
-- ticker validation). Case-insensitive uniqueness via the functional index
-- below — the client checks availability by attempting the update and
-- reading the resulting unique-violation (Postgres error 23505) rather
-- than a separate pre-check call, avoiding a check-then-write race; same
-- "attempt, map the error code" pattern as fund name/ticker uniqueness.
--
-- No new RLS policy needed: `users_select_own`/`users_update_own` (defined
-- above) already let a user read/set their OWN nickname, which is all the
-- client ever needs directly. Cross-user display (fund team roster,
-- marketplace) is read by the backend's service-role client, which
-- already bypasses RLS entirely — adding a blanket public SELECT policy
-- on this table would leak email/subscription_tier/other private columns
-- to any authenticated user, so deliberately not doing that.
-- =============================================================================

ALTER TABLE public.users ADD COLUMN nickname text
    CONSTRAINT users_nickname_format CHECK (nickname ~ '^[A-Za-z0-9_]{1,25}$');

CREATE UNIQUE INDEX users_nickname_unique_idx
    ON public.users (lower(nickname)) WHERE nickname IS NOT NULL;


-- =============================================================================
-- F.O.M.O. Shield — Supabase Migration 018+ (RESERVED)
-- Feature: ETF Fund Emulation, Phases 4-8 — see docs/ETF_FUND_EMULATION.md.
-- Remaining tables (fund_trade_proposals, fund_transactions,
-- fund_chat_messages, fund_meetings, fund_meeting_invites,
-- bot_investor_profiles, bot_investor_state, fund_fee_ledger,
-- manager_earnings_balance, fund_succession_events) are written
-- phase-by-phase as each phase is implemented, not upfront.
-- =============================================================================
