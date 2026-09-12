-- Migration 024: fund_trade_proposals.commission
-- 2026-09-12 -- the Proposal detail card redesign wanted a "broker
-- commission" row like every other trading system in the app already has
-- (personal portfolio + stress test both charge 0.5% via
-- brokerCommissionRate), but fund trades charged no fee at all. Adds the
-- same 0.5% (see fundTradeService.js's FUND_COMMISSION_RATE), applied to
-- the fund's cash by fund_execute_trade alongside the trade cost itself,
-- and recorded on the proposal row next to executed_price/executed_at.

ALTER TABLE fund_trade_proposals ADD COLUMN IF NOT EXISTS commission NUMERIC;

-- Replaces Migration 021's version of this function -- same row-locking
-- shape, adds p_commission (defaults to 0 so any other caller passing the
-- old 5-argument shape still works): buys pay cost + commission out of
-- cash, sells net cost - commission back into cash. insufficient_cash now
-- checks against cost + commission so a trade can't leave the fund short
-- once the fee is taken into account.
CREATE OR REPLACE FUNCTION fund_execute_trade(
  p_fund_id UUID,
  p_symbol TEXT,
  p_side TEXT,
  p_quantity NUMERIC,
  p_price NUMERIC,
  p_commission NUMERIC DEFAULT 0
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
    IF v_cash < v_cost + p_commission THEN
      RAISE EXCEPTION 'insufficient_cash';
    END IF;
    UPDATE funds SET cash = cash - v_cost - p_commission WHERE id = p_fund_id;
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
    UPDATE funds SET cash = cash + v_cost - p_commission WHERE id = p_fund_id;
  ELSE
    RAISE EXCEPTION 'invalid_side';
  END IF;

  RETURN v_cost;
END;
$$;
