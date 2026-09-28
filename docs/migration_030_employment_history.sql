-- =============================================================================
-- F.O.M.O. Shield — Supabase Migration 030  (ALREADY APPLIED — documentation)
-- Table: employment_history
-- Feature: ETF Fund Emulation, Phase 3 — the hiring marketplace's audit trail.
--          One row per stint: who worked at which fund, in what role, from
--          when to when, and how it ended. `left_at IS NULL` means the person
--          still works there. Written only by scanco-backend's
--          fundTeamService.js (insert on hire, close-out on leave/fire, read
--          for the résumé), always through supabaseAdmin — i.e. service_role.
--          The Flutter app never queries it directly.
--
-- Description: This table has been live since the Phase 3 session but was
--              never written down anywhere in this repo — it was created
--              straight from the Supabase SQL Editor and the DDL was lost.
--              Found by the 2026-09-28 grants audit, which listed 17 live
--              tables against 15 in the migration files. Reconstructed here
--              verbatim from the live schema (columns, constraints and
--              indexes read back out of information_schema/pg_catalog), so
--              re-applying it is a no-op and a fresh project now comes up
--              complete.
--
--              NOT a pending change — do not look for something to run. The
--              only reason it exists is so `docs/` matches the database.
-- =============================================================================
CREATE TABLE IF NOT EXISTS public.employment_history (
    id          uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id     uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    fund_id     uuid NOT NULL REFERENCES public.funds(id) ON DELETE CASCADE,
    role        text NOT NULL,
    joined_at   timestamptz NOT NULL,
    -- NULL while the person is still employed; set when they leave or are let go.
    left_at     timestamptz,
    leave_type  text CHECK (leave_type = ANY (ARRAY['resigned'::text, 'terminated'::text])),
    created_at  timestamptz NOT NULL DEFAULT now()
);

-- Résumé lookup: every stint of one person, across all funds.
CREATE INDEX IF NOT EXISTS employment_history_user_id_idx
    ON public.employment_history USING btree (user_id);

-- Partial index for the hot path — finding the ONE open stint to close out
-- when someone leaves or is fired (fundTeamService.js's close-out query).
CREATE INDEX IF NOT EXISTS employment_history_open_idx
    ON public.employment_history USING btree (fund_id, user_id)
    WHERE (left_at IS NULL);

ALTER TABLE public.employment_history ENABLE ROW LEVEL SECURITY;
-- Deliberately no policies, the same shape as subscription_purchases and (since
-- Migration 029) fund_trade_proposals: service_role bypasses RLS and is the only
-- writer, and no client is meant to read employment records straight from the
-- Data API. Add policies HERE if a future phase shows résumés client-side.

-- Data API grants. Mandatory for tables created from 2026-10-30 (see the
-- header of docs/supabase_migration.sql). Reproduces the default Supabase
-- used to apply automatically; RLS is what actually restricts access.
GRANT ALL ON TABLE public.employment_history TO anon, authenticated, service_role;
