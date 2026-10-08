-- =============================================================================
-- F.O.M.O. Shield — Supabase Migration 034  (PENDING — run this)
-- Table: fund_target_weights
-- Feature: ETF Fund Emulation — target allocation per holding, the fund's
--          answer to a Trading 212 pie. The head (and a deputy who has been
--          given the right) says what share of the fund each company SHOULD
--          be; the app then shows actual against target, and a rebalance
--          turns the gap into trade proposals.
--
-- Why a table and not a column on fund_holdings: a target must be able to
-- exist for a symbol the fund does not hold yet — deciding "AAPL should be
-- 8% of this fund" is exactly how you plan a purchase, and a column beside
-- a position could not hold that. It also has to outlive a position: a
-- holding sold to zero disappears from fund_holdings, and whether its
-- target goes with it is a decision this schema leaves to the service.
--
-- Precision is two decimals, deliberately (2026-10-07 decision). Whole
-- percents would make 0.39% impossible, and proportional redistribution
-- almost never lands on round numbers anyway. Thousandths are dropped. The
-- sum is NOT constrained to exactly 100: after a proportional redistribution
-- it may read 99.98 or 100.02, and that was explicitly accepted rather than
-- papered over with a reconciliation nobody can follow.
--
-- A target of zero is not stored. "Zero percent" means "no opinion about
-- this company", which is the absence of a row, not a row saying nothing —
-- hence the CHECK below. That also removes a degenerate case from the
-- redistribution maths: there can never be a set of remaining targets that
-- are all zero and therefore impossible to scale against.
--
-- Written and read only by scanco-backend (fundService.js), always through
-- supabaseAdmin, i.e. service_role. The Flutter app never touches it
-- directly — same arrangement as fund_trade_proposals and employment_history.
-- =============================================================================
CREATE TABLE IF NOT EXISTS public.fund_target_weights (
    fund_id        uuid NOT NULL REFERENCES public.funds(id) ON DELETE CASCADE,
    symbol         text NOT NULL,
    -- 0 < target <= 100. See the note above on why zero is not a value.
    target_percent numeric(5,2) NOT NULL
                   CHECK (target_percent > 0 AND target_percent <= 100),
    updated_at     timestamptz NOT NULL DEFAULT now(),
    -- One opinion per company per fund. Doubles as the lookup index: every
    -- read is "all targets for this fund", which this prefix serves.
    PRIMARY KEY (fund_id, symbol)
);

ALTER TABLE public.fund_target_weights ENABLE ROW LEVEL SECURITY;
-- Deliberately no policies, the same shape as fund_trade_proposals and
-- employment_history: service_role bypasses RLS and is the only writer, and
-- no client reads targets straight from the Data API. Add policies HERE if a
-- future phase ever shows another fund's targets client-side.

-- Data API grants. Mandatory for tables created from 2026-10-30 (see the
-- header of docs/supabase_migration.sql). Reproduces the default Supabase
-- used to apply automatically; RLS is what actually restricts access.
GRANT ALL ON TABLE public.fund_target_weights TO anon, authenticated, service_role;
