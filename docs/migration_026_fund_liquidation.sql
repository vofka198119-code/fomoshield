-- Migration 026: fund bankruptcy/liquidation engine, Phase A
-- 2026-09-14 -- see fomoshield_etf_bankruptcy_flow_spec memory for the
-- full formula. Node computes the entire payout plan (needs live holding
-- quotes, which SQL can't fetch) and passes it as a JSONB array to this
-- one RPC, which does the actual state mutation atomically: zero the
-- fund's holdings/cash, mark it bankrupt, and write every payout row in
-- one transaction.
--
-- Real Portfolio cash has no server write path (see fomoshield_scanco_
-- backend_local_clone-adjacent architecture notes) -- each payout instead
-- sits here unclaimed until the recipient's own client picks it up on
-- next load and locally credits their own startingBalance, same "catch-up"
-- shape as weekly premium payout. `details` carries everything a
-- settlement notification needs to render (assets sold, broker commission,
-- neustойка, reason, date) rather than a fixed column per field -- this
-- table only ever has ONE writer (this RPC) and one reader shape (the
-- claim endpoint), so there's no query need for those fields individually.

CREATE TABLE public.fund_liquidation_payouts (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    fund_id uuid NOT NULL REFERENCES public.funds(id) ON DELETE CASCADE,
    user_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    recipient_type text NOT NULL CHECK (recipient_type IN ('employee', 'investor')),
    amount numeric NOT NULL CHECK (amount >= 0),
    details jsonb NOT NULL DEFAULT '{}'::jsonb,
    created_at timestamptz NOT NULL DEFAULT now(),
    claimed_at timestamptz
);

CREATE INDEX fund_liquidation_payouts_user_unclaimed_idx
  ON public.fund_liquidation_payouts (user_id)
  WHERE claimed_at IS NULL;

ALTER TABLE public.fund_liquidation_payouts ENABLE ROW LEVEL SECURITY;

-- Same shape as funds' own RLS (docs/supabase_migration.sql:530) -- only
-- service_role (the backend) writes; a signed-in user can read their own
-- rows straight from Supabase if ever needed, but today's client only
-- reads via the backend's own claim endpoint.
CREATE POLICY "Users can view their own liquidation payouts"
  ON public.fund_liquidation_payouts FOR SELECT
  USING (auth.uid() = user_id);

-- p_payouts shape: [{ "user_id": uuid, "recipient_type": "employee"|"investor",
-- "amount": numeric, "details": jsonb }, ...]. Guards against double-
-- liquidation (status must still be 'active') and locks the fund row
-- before touching anything else, same discipline as fund_execute_trade.
CREATE OR REPLACE FUNCTION fund_liquidate(
  p_fund_id UUID,
  p_payouts JSONB
) RETURNS INTEGER
LANGUAGE plpgsql
AS $$
DECLARE
  v_status TEXT;
  v_payout JSONB;
  v_count INTEGER := 0;
BEGIN
  SELECT status INTO v_status FROM funds WHERE id = p_fund_id FOR UPDATE;
  IF v_status IS NULL THEN
    RAISE EXCEPTION 'fund_not_found';
  END IF;
  IF v_status != 'active' THEN
    RAISE EXCEPTION 'fund_not_active';
  END IF;

  DELETE FROM fund_holdings WHERE fund_id = p_fund_id;

  UPDATE funds SET cash = 0, status = 'bankrupt' WHERE id = p_fund_id;

  FOR v_payout IN SELECT * FROM jsonb_array_elements(p_payouts)
  LOOP
    INSERT INTO fund_liquidation_payouts (fund_id, user_id, recipient_type, amount, details)
    VALUES (
      p_fund_id,
      (v_payout->>'user_id')::UUID,
      v_payout->>'recipient_type',
      (v_payout->>'amount')::NUMERIC,
      COALESCE(v_payout->'details', '{}'::jsonb)
    );
    v_count := v_count + 1;
  END LOOP;

  RETURN v_count;
END;
$$;
