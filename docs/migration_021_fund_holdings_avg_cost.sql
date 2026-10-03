-- Migration 021: fund_holdings.avg_cost
-- Phase 4 follow-up (ETF_FUND_EMULATION.md) -- fund_holdings only ever stored
-- quantity, so the fund's own P&L per holding had nothing to compare the
-- live price against. This adds a weighted-average cost basis, maintained by
-- fund_execute_trade (Migration 020) on every buy; sells never change it.

ALTER TABLE fund_holdings ADD COLUMN IF NOT EXISTS avg_cost NUMERIC NOT NULL DEFAULT 0;

-- Replaces Migration 020's version of this function -- same row-locking
-- shape, buy branch now maintains a weighted-average cost basis instead of
-- just quantity. Sell branch is untouched: selling doesn't change the
-- remaining shares' average cost.
CREATE OR REPLACE FUNCTION fund_execute_trade(
  p_fund_id UUID,
  p_symbol TEXT,
  p_side TEXT,
  p_quantity NUMERIC,
  p_price NUMERIC
) RETURNS NUMERIC
LANGUAGE plpgsql
AS $$
DECLARE
  v_cash NUMERIC;
  v_cost NUMERIC;
  v_current_qty NUMERIC;
BEGIN
  SELECT cash INTO v_cash FROM funds WHERE id = p_fund_id FOR UPDATE;
  IF v_cash IS NULL THEN
    RAISE EXCEPTION 'fund_not_found';
  END IF;

  v_cost := p_quantity * p_price;

  IF p_side = 'buy' THEN
    IF v_cash < v_cost THEN
      RAISE EXCEPTION 'insufficient_cash';
    END IF;
    UPDATE funds SET cash = cash - v_cost WHERE id = p_fund_id;
    INSERT INTO fund_holdings (fund_id, symbol, quantity, avg_cost)
    VALUES (p_fund_id, p_symbol, p_quantity, p_price)
    ON CONFLICT (fund_id, symbol)
    DO UPDATE SET
      avg_cost = (fund_holdings.quantity * fund_holdings.avg_cost + EXCLUDED.quantity * p_price)
                 / (fund_holdings.quantity + EXCLUDED.quantity),
      quantity = fund_holdings.quantity + EXCLUDED.quantity;
  ELSIF p_side = 'sell' THEN
    SELECT quantity INTO v_current_qty FROM fund_holdings
      WHERE fund_id = p_fund_id AND symbol = p_symbol FOR UPDATE;
    IF v_current_qty IS NULL OR v_current_qty < p_quantity THEN
      RAISE EXCEPTION 'insufficient_shares';
    END IF;
    UPDATE fund_holdings SET quantity = quantity - p_quantity
      WHERE fund_id = p_fund_id AND symbol = p_symbol;
    UPDATE funds SET cash = cash + v_cost WHERE id = p_fund_id;
  ELSE
    RAISE EXCEPTION 'invalid_side';
  END IF;

  RETURN v_cost;
END;
$$;
