-- =============================================================================
-- F.O.M.O. Shield — Supabase Migration 033
-- Table: user_data (ADD COLUMN)
-- Description: Daily snapshots of a portfolio's total value (cash + holdings
--              at market), so the Portfolio screen can finally draw a chart of
--              how it changed over time.
--
--              Nothing of the kind existed anywhere before this — not on the
--              device, not in the database. Every number on the Portfolio
--              screen was computed live from current prices, so "what was this
--              worth last Tuesday" had no answer to give. Asked for
--              2026-10-03; he chose to start accumulating from the update
--              rather than reconstruct the past from trade history and old
--              candles (possible, but approximate and far more work).
--
--              One point per calendar day, written whenever the Portfolio
--              screen computes a fresh total — the day's existing point is
--              updated rather than appended to, so a user who opens the app
--              ten times a day still produces one point. Capped at 365 points,
--              oldest dropped first, which keeps the row small and bounds a
--              JSONB column that would otherwise grow forever.
--
--              Shape: [{"at": "<iso8601>", "value": <number>}, ...]
--              ordered oldest first.
-- =============================================================================

ALTER TABLE public.user_data
ADD COLUMN IF NOT EXISTS portfolio_value_history JSONB NOT NULL DEFAULT '[]'::jsonb;
