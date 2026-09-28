-- =============================================================================
-- F.O.M.O. Shield — Supabase Migration 019
-- Table: subscription_purchases (NEW)
-- Description: Real Google Play Billing subscriptions (2026-09-20 session).
--              Tracks which Supabase user owns each Play purchase token, so
--              the RTDN webhook (scanco-backend's routes/playRtdn.js) can
--              resync subscription_tier/subscription_expires_at on renewal/
--              cancel/refund events, when all Google's push gives us is the
--              token — not our user id. Written by the backend only
--              (service_role, via services/playBilling.js's
--              syncSubscriptionForUser); the app never reads or writes this
--              table directly, so no RLS policy is needed. Same
--              subscription_tier/subscription_expires_at columns this writes
--              into are the ones Migration 008 already locks down against
--              direct client writes.
--
--              Numbered 013* and kept inside supabase_migration.sql until
--              2026-09-28. That number collided head-on with the ETF branch's
--              own Migration 013 (funds/fund_holdings/fund_nav_snapshots),
--              sitting at the same line of the same file — a guaranteed
--              conflict the day feature/etf-fund-emulation merges. Renumbered
--              019 and moved out here; supabase_migration.sql now ends at 012
--              on both branches and merges clean. Already applied in
--              production (audited 2026-09-28) — this file is the record, not
--              a pending change.
-- =============================================================================
CREATE TABLE IF NOT EXISTS public.subscription_purchases (
    purchase_token text PRIMARY KEY,
    user_id uuid NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    product_id text NOT NULL,
    base_plan_id text NOT NULL,
    subscription_state text,
    updated_at timestamptz NOT NULL DEFAULT now()
);

ALTER TABLE public.subscription_purchases ENABLE ROW LEVEL SECURITY;

-- Data API grants. Mandatory for tables created from 2026-10-30 (see the
-- header of docs/supabase_migration.sql). Reproduces the default Supabase
-- used to apply automatically; RLS is what actually restricts access.
GRANT ALL ON TABLE public.subscription_purchases TO anon, authenticated, service_role;
-- No policies — service_role (used exclusively by scanco-backend) bypasses
-- RLS entirely, and the app itself never queries this table.
