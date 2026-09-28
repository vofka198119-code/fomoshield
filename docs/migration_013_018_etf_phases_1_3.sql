-- =============================================================================
-- F.O.M.O. Shield — Supabase Migrations 013-018  (ETF branch only)
-- Feature: ETF Fund Emulation, Phases 1-3 — see docs/ETF_FUND_EMULATION.md.
--
-- These lived at the bottom of docs/supabase_migration.sql until 2026-09-28.
-- They moved out here so that file stays byte-identical on master and on
-- feature/etf-fund-emulation and the two merge with no conflict at all —
-- appending to it from both branches is what produced two different
-- migrations numbered 013 (this file's, and master's subscription_purchases,
-- since renumbered 019 into its own file). Nothing is changed below beyond
-- the GRANT blocks every table now carries; all of it is already applied in
-- production.
--
-- Migrations 019 (master), 020-028 and 029 each live in their own
-- docs/migration_0NN_*.sql file. Next free number: 030.
-- =============================================================================

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

-- Data API grants. Mandatory for tables created from 2026-10-30 (see the
-- header of docs/supabase_migration.sql). Reproduces the default Supabase
-- used to apply automatically; RLS is what actually restricts access.
GRANT ALL ON TABLE public.funds TO anon, authenticated, service_role;
ALTER TABLE public.fund_holdings ENABLE ROW LEVEL SECURITY;

-- Data API grants. Mandatory for tables created from 2026-10-30 (see the
-- header of docs/supabase_migration.sql). Reproduces the default Supabase
-- used to apply automatically; RLS is what actually restricts access.
GRANT ALL ON TABLE public.fund_holdings TO anon, authenticated, service_role;
ALTER TABLE public.fund_nav_snapshots ENABLE ROW LEVEL SECURITY;

-- Data API grants. Mandatory for tables created from 2026-10-30 (see the
-- header of docs/supabase_migration.sql). Reproduces the default Supabase
-- used to apply automatically; RLS is what actually restricts access.
GRANT ALL ON TABLE public.fund_nav_snapshots TO anon, authenticated, service_role;

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

-- Data API grants. Mandatory for tables created from 2026-10-30 (see the
-- header of docs/supabase_migration.sql). Reproduces the default Supabase
-- used to apply automatically; RLS is what actually restricts access.
GRANT ALL ON TABLE public.fund_investor_positions TO anon, authenticated, service_role;
ALTER TABLE public.fund_investor_transactions ENABLE ROW LEVEL SECURITY;

-- Data API grants. Mandatory for tables created from 2026-10-30 (see the
-- header of docs/supabase_migration.sql). Reproduces the default Supabase
-- used to apply automatically; RLS is what actually restricts access.
GRANT ALL ON TABLE public.fund_investor_transactions TO anon, authenticated, service_role;

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

-- Data API grants. Mandatory for tables created from 2026-10-30 (see the
-- header of docs/supabase_migration.sql). Reproduces the default Supabase
-- used to apply automatically; RLS is what actually restricts access.
GRANT ALL ON TABLE public.employee_profiles TO anon, authenticated, service_role;
ALTER TABLE public.fund_team_members ENABLE ROW LEVEL SECURITY;

-- Data API grants. Mandatory for tables created from 2026-10-30 (see the
-- header of docs/supabase_migration.sql). Reproduces the default Supabase
-- used to apply automatically; RLS is what actually restricts access.
GRANT ALL ON TABLE public.fund_team_members TO anon, authenticated, service_role;
ALTER TABLE public.fund_invitations ENABLE ROW LEVEL SECURITY;

-- Data API grants. Mandatory for tables created from 2026-10-30 (see the
-- header of docs/supabase_migration.sql). Reproduces the default Supabase
-- used to apply automatically; RLS is what actually restricts access.
GRANT ALL ON TABLE public.fund_invitations TO anon, authenticated, service_role;

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
--
-- Numbering, as of 2026-09-28: 019 is taken — subscription_purchases, in
-- docs/migration_019_subscription_purchases.sql on master (it used to be
-- "013*" in this file, colliding with the 013 above; see the file header).
-- 020-028 are separate docs/migration_0NN_*.sql files on this branch.
-- Next free number is 030, and every new table needs its GRANT block.
-- =============================================================================
