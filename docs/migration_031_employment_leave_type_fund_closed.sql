-- =============================================================================
-- F.O.M.O. Shield — Supabase Migration 031   (APPLIED 2026-09-29)
-- Table: employment_history
-- Feature: ETF Fund Emulation — a third way a stint can end.
--
-- Until now employment_history.leave_type allowed only 'resigned' (the
-- employee walked) and 'terminated' (the head let them go). A fund being
-- LIQUIDATED ended nobody's stint at all: fund_liquidate (Migration 026)
-- deletes holdings, zeroes the cash and flips the fund to 'bankrupt', but
-- never touches fund_team_members or employment_history. Every employee of
-- a closed fund therefore stayed on its roster forever and kept an open
-- (left_at IS NULL) history row -- their résumé claimed they still worked
-- at a fund that no longer exists.
--
-- 'fund_closed' is that third reason, so a résumé can say "the fund closed"
-- rather than implying the person resigned or was fired -- neither of which
-- is true, and both of which read worse to a head browsing the marketplace.
--
-- ORDER OF DEPLOY MATTERS: apply this BEFORE the backend change that writes
-- 'fund_closed' (fundBankruptcyService.liquidateFund). Against the old
-- constraint that write fails, and because closeEmploymentHistory only logs
-- its errors rather than throwing, the failure would be silent -- the fund
-- would liquidate and the history rows would quietly stay open.
--
-- Applied 2026-09-29 on project zbtcpgbelupoybgrwuub (FomoSheild / main), in
-- the right order: the DB now allows 'fund_closed' and the backend that
-- writes it is still only committed, not deployed. Verified by reading the
-- constraint back --
--   CHECK ((leave_type = ANY (ARRAY['resigned'::text, 'terminated'::text,
--                                   'fund_closed'::text])))
-- and exactly ONE constraint row came back, so the DROP really did land
-- rather than leaving the old two-value one in place beside a new one.
--
-- Both clean-up statements matched ZERO rows, checked before running: no
-- stint was open at an already-bankrupt fund and no roster row belonged to
-- one. Nothing was deleted. They stay here so a fresh project comes up
-- consistent.
-- =============================================================================

ALTER TABLE public.employment_history
    DROP CONSTRAINT IF EXISTS employment_history_leave_type_check;

ALTER TABLE public.employment_history
    ADD CONSTRAINT employment_history_leave_type_check
    CHECK (leave_type = ANY (ARRAY['resigned'::text, 'terminated'::text, 'fund_closed'::text]));

-- Back-fill: any stint still open at a fund that is already bankrupt ended
-- when that fund closed, we just had no way to record it. funds carries no
-- "closed at" timestamp, so the stint is closed out as of now -- the reason
-- is the honest part, the exact minute was never recorded.
UPDATE public.employment_history AS eh
SET left_at = now(),
    leave_type = 'fund_closed'
FROM public.funds AS f
WHERE f.id = eh.fund_id
  AND f.status = 'bankrupt'
  AND eh.left_at IS NULL;

-- Same clean-up for the roster itself: a bankrupt fund has no staff.
DELETE FROM public.fund_team_members AS ftm
USING public.funds AS f
WHERE f.id = ftm.fund_id
  AND f.status = 'bankrupt';
