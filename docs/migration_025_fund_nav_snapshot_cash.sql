-- Migration 025: fund_nav_snapshots.cash
-- 2026-09-13 -- the Charts screen's planned Cash vs Invested chart needs a
-- per-month cash figure to split AUM into "sitting in cash" vs "actually
-- invested in holdings" (invested = aum - cash), but fund_nav_snapshots
-- only ever stored aum/nav_per_unit/units_outstanding, not the fund's own
-- cash balance at snapshot time. fundNavSnapshotService.js already reads
-- fund.cash every run to compute aum -- this just also persists it.
-- NULL for every row written before this migration (same "no data yet"
-- convention as a month with no snapshot at all), not backfilled since the
-- historical cash split can't be reconstructed after the fact.

ALTER TABLE fund_nav_snapshots ADD COLUMN IF NOT EXISTS cash NUMERIC;
