-- Migration 028: fund auto-succession, Phase B
-- 2026-09-15 -- see fomoshield_etf_bankruptcy_flow_spec memory. If a fund's
-- head hasn't signed in (Supabase auth.users.last_sign_in_at) for 60 days,
-- eligible active premium/admin employees get a 14-day window to accept
-- management; whoever accepts wins by seniority
-- (fund_team_members.joined_at) if more than one does. No acceptance by
-- the deadline auto-liquidates the fund via the existing Phase A engine
-- (fund_liquidate, Migration 026). The head signing back in while an offer
-- is still pending cancels it outright.
--
-- Node's fundSuccessionService.js does the actual sweep/decision logic
-- (it needs auth.users.last_sign_in_at, which SQL functions can't read) --
-- these two tables are just the ledger, and fund_resolve_succession_accept
-- is the one place multiple tables need to mutate together atomically.

CREATE TABLE public.fund_succession_offers (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    fund_id uuid NOT NULL REFERENCES public.funds(id) ON DELETE CASCADE,
    started_at timestamptz NOT NULL DEFAULT now(),
    deadline timestamptz NOT NULL,
    status text NOT NULL DEFAULT 'pending'
        CHECK (status IN ('pending', 'resolved_accepted', 'resolved_liquidated', 'cancelled')),
    new_head_user_id uuid REFERENCES auth.users(id),
    resolved_at timestamptz
);

-- Only one pending offer per fund at a time -- the sweep only ever starts
-- a new one when it finds none already pending for that fund.
CREATE UNIQUE INDEX fund_succession_offers_one_pending_idx
  ON public.fund_succession_offers (fund_id)
  WHERE status = 'pending';

CREATE TABLE public.fund_succession_acceptances (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    offer_id uuid NOT NULL REFERENCES public.fund_succession_offers(id) ON DELETE CASCADE,
    user_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    accepted_at timestamptz NOT NULL DEFAULT now(),
    UNIQUE (offer_id, user_id)
);

ALTER TABLE public.fund_succession_offers ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.fund_succession_acceptances ENABLE ROW LEVEL SECURITY;

-- Same trust model as funds/fund_liquidation_payouts: only service_role
-- (the backend) writes; a signed-in user can read rows that involve their
-- own fund directly from Supabase if ever needed, even though today's
-- client only reads via the backend's own endpoints.
CREATE POLICY "Team members can view their fund's succession offers"
  ON public.fund_succession_offers FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM fund_team_members
      WHERE fund_team_members.fund_id = fund_succession_offers.fund_id
        AND fund_team_members.user_id = auth.uid()
    )
    OR EXISTS (
      SELECT 1 FROM funds
      WHERE funds.id = fund_succession_offers.fund_id
        AND funds.head_user_id = auth.uid()
    )
  );

CREATE POLICY "Users can view their own succession acceptances"
  ON public.fund_succession_acceptances FOR SELECT
  USING (auth.uid() = user_id);

-- p_new_head_user_id must already be a row in fund_succession_acceptances
-- for this offer -- checked here, not just trusted from the caller, since
-- Node picks the winner by seniority but the mutation itself (funds.head_
-- user_id, dropping the old team-member row, flipping the offer's status)
-- needs to happen atomically together.
CREATE OR REPLACE FUNCTION fund_resolve_succession_accept(
  p_offer_id UUID,
  p_new_head_user_id UUID
) RETURNS VOID
LANGUAGE plpgsql
AS $$
DECLARE
  v_fund_id UUID;
  v_status TEXT;
BEGIN
  SELECT fund_id, status INTO v_fund_id, v_status
  FROM fund_succession_offers WHERE id = p_offer_id FOR UPDATE;

  IF v_fund_id IS NULL THEN
    RAISE EXCEPTION 'offer_not_found';
  END IF;
  IF v_status != 'pending' THEN
    RAISE EXCEPTION 'offer_not_pending';
  END IF;
  IF NOT EXISTS (
    SELECT 1 FROM fund_succession_acceptances
    WHERE offer_id = p_offer_id AND user_id = p_new_head_user_id
  ) THEN
    RAISE EXCEPTION 'not_an_accepted_candidate';
  END IF;

  UPDATE funds SET head_user_id = p_new_head_user_id WHERE id = v_fund_id;

  -- The new head has implicit full authority (see fundTradeService.js) --
  -- no fund_team_members row needed for a head, same as every fund's
  -- original creator never got one.
  DELETE FROM fund_team_members
  WHERE fund_id = v_fund_id AND user_id = p_new_head_user_id;

  UPDATE fund_succession_offers
  SET status = 'resolved_accepted', resolved_at = now(), new_head_user_id = p_new_head_user_id
  WHERE id = p_offer_id;
END;
$$;
