-- Migration 027: fund_liquidate frees up name/ticker on bankruptcy
-- 2026-09-14 -- the soft-delete decision (Migration 026: status='bankrupt',
-- not a hard DELETE) had an unintended side effect confirmed live: Migration
-- 013's UNIQUE constraint on ticker and Migration 014's unique index on
-- lower(name) both still hold on a bankrupt fund's row, so its name/ticker
-- stayed permanently squatted -- a user couldn't create a new fund reusing
-- either, even though the whole point of a fund closing is that its name
-- becomes available again. Fixes it at the source: fund_liquidate itself
-- appends a short, visually-obvious suffix to both on close, freeing the
-- original strings immediately, same fix already applied by hand to the
-- one fund that hit this live.

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
  v_suffix TEXT;
BEGIN
  SELECT status INTO v_status FROM funds WHERE id = p_fund_id FOR UPDATE;
  IF v_status IS NULL THEN
    RAISE EXCEPTION 'fund_not_found';
  END IF;
  IF v_status != 'active' THEN
    RAISE EXCEPTION 'fund_not_active';
  END IF;

  DELETE FROM fund_holdings WHERE fund_id = p_fund_id;

  -- Short, unique-enough suffix (first 8 hex chars of the fund's own id) --
  -- frees the original name/ticker for reuse while keeping the closed
  -- fund's row recognizable if it's ever looked at directly.
  v_suffix := substring(p_fund_id::text from 1 for 8);
  UPDATE funds
  SET cash = 0,
      status = 'bankrupt',
      name = name || ' (закрыт ' || v_suffix || ')',
      ticker = ticker || '-X' || upper(v_suffix)
  WHERE id = p_fund_id;

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
