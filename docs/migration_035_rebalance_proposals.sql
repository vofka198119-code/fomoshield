-- =============================================================================
-- F.O.M.O. Shield — Supabase Migration 035  (PENDING — run this)
-- Table: fund_trade_proposals — a proposal may now be a whole rebalance
-- Feature: ETF Fund Emulation — target weights, phase 4.
--
-- Why this exists. A rebalance works out every trade needed to bring the fund
-- onto its plan: on the real fund it came to 29 legs in one case and 44 in
-- another. Filed as individual proposals that is 44 cards to open and 44
-- approvals to tap, for what is a single decision — "bring us onto the plan".
-- His call (2026-10-09): «мы в одном ордере даём всю пачку, где написано: так
-- продать то-то на столько-то, докупить то-то на столько-то, и всё».
--
-- So a proposal gains a KIND. 'trade' is everything that exists today and
-- stays exactly as it is — one company, one side, one quantity. 'rebalance'
-- carries its trades in `legs` instead, and the single columns go unused.
--
-- Why not a second table: the proposal is the same object either way. It goes
-- into the same list, through the same pending/approved/rejected/executed
-- states, the same permissions, the same blotter, the same notifications. A
-- parallel table would duplicate all of that and then have to be merged back
-- together on every screen.
--
-- The single-trade columns therefore lose their NOT NULL, and a shape CHECK
-- takes over: a 'trade' still cannot exist without symbol/side/quantity/
-- order_type, and a 'rebalance' cannot exist without legs. Nothing becomes
-- more permissive than it was — the rule just moved from four column
-- constraints to one table constraint that knows about both shapes.
--
-- Existing rows: every one of them is a 'trade', which the DEFAULT handles,
-- so this migration rewrites no data.
-- =============================================================================

ALTER TABLE public.fund_trade_proposals
  ADD COLUMN IF NOT EXISTS kind TEXT NOT NULL DEFAULT 'trade';

ALTER TABLE public.fund_trade_proposals
  DROP CONSTRAINT IF EXISTS fund_trade_proposals_kind_check;
ALTER TABLE public.fund_trade_proposals
  ADD CONSTRAINT fund_trade_proposals_kind_check
  CHECK (kind IN ('trade', 'rebalance'));

-- One leg per company:
--   { "symbol": "AAPL", "side": "buy", "quantity": 2.5, "price": 201.4,
--     "amount": 503.5, "shareNow": 6.03, "shareAfter": 6.42 }
-- price/amount/shareNow/shareAfter are AS PLANNED, kept so the card can show
-- what the proposer saw. Execution re-prices at the market, exactly as a
-- market order of kind 'trade' does — and each leg's realised price and
-- commission are written back into this same array on execution.
ALTER TABLE public.fund_trade_proposals
  ADD COLUMN IF NOT EXISTS legs JSONB;

-- Which route produced the plan: 'cash' (spend free money, sell nothing) or
-- 'full' (sell what is above target, buy what is below). Null for a 'trade'.
ALTER TABLE public.fund_trade_proposals
  ADD COLUMN IF NOT EXISTS rebalance_mode TEXT;

ALTER TABLE public.fund_trade_proposals
  DROP CONSTRAINT IF EXISTS fund_trade_proposals_rebalance_mode_check;
ALTER TABLE public.fund_trade_proposals
  ADD CONSTRAINT fund_trade_proposals_rebalance_mode_check
  CHECK (rebalance_mode IS NULL OR rebalance_mode IN ('cash', 'full'));

ALTER TABLE public.fund_trade_proposals ALTER COLUMN symbol     DROP NOT NULL;
ALTER TABLE public.fund_trade_proposals ALTER COLUMN side       DROP NOT NULL;
ALTER TABLE public.fund_trade_proposals ALTER COLUMN order_type DROP NOT NULL;
ALTER TABLE public.fund_trade_proposals ALTER COLUMN quantity   DROP NOT NULL;

ALTER TABLE public.fund_trade_proposals
  DROP CONSTRAINT IF EXISTS fund_trade_proposals_shape_check;
ALTER TABLE public.fund_trade_proposals
  ADD CONSTRAINT fund_trade_proposals_shape_check CHECK (
    (kind = 'trade'
      AND symbol IS NOT NULL
      AND side IS NOT NULL
      AND order_type IS NOT NULL
      AND quantity IS NOT NULL)
    OR
    (kind = 'rebalance'
      AND legs IS NOT NULL
      AND jsonb_typeof(legs) = 'array'
      AND jsonb_array_length(legs) > 0)
  );

-- RLS is already on this table (Migration 029) and its policies are about who
-- the fund's people are, not about columns — nothing to add here. The Data
-- API grants from 029 likewise still stand; writes come only from
-- scanco-backend through service_role.
