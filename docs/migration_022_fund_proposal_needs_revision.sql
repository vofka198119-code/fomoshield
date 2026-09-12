-- Migration 022: fund_trade_proposals.status gets 'needs_revision'
-- Phase 4 follow-up (2026-09-12) -- a fourth resolution alongside
-- approve/reject: the approver sends the proposal back to the proposer
-- with a reason instead of rejecting it outright. Reuses the existing
-- rejection_reason column as a generic "why" note (same shape either way,
-- just a different terminal status) -- no new column needed.

ALTER TABLE fund_trade_proposals DROP CONSTRAINT IF EXISTS fund_trade_proposals_status_check;
ALTER TABLE fund_trade_proposals ADD CONSTRAINT fund_trade_proposals_status_check
  CHECK (status IN ('pending', 'approved', 'rejected', 'executed', 'needs_revision'));
