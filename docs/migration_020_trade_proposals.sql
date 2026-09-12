-- Migration 020: fund_trade_proposals + fund_execute_trade
-- Phase 4 (ETF_FUND_EMULATION.md) -- the first server-side order engine.
-- Analyst proposes -> Head/Co-Manager approves/rejects -> auto-executes
-- immediately if the fund has no Trader hired, otherwise sits "approved"
-- until a Trader executes it. Risk Manager can flag a proposal as risky
-- (informational only, never blocks approval).

CREATE TABLE fund_trade_proposals (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  fund_id UUID NOT NULL REFERENCES funds(id) ON DELETE CASCADE,
  proposer_user_id UUID NOT NULL REFERENCES auth.users(id),
  symbol TEXT NOT NULL,
  side TEXT NOT NULL CHECK (side IN ('buy', 'sell')),
  order_type TEXT NOT NULL CHECK (order_type IN ('market', 'limit')),
  limit_price NUMERIC,
  quantity NUMERIC NOT NULL CHECK (quantity > 0),
  justification TEXT,
  status TEXT NOT NULL DEFAULT 'pending'
    CHECK (status IN ('pending', 'approved', 'rejected', 'executed')),
  flagged_risky BOOLEAN NOT NULL DEFAULT false,
  flagged_by UUID REFERENCES auth.users(id),
  resolved_by UUID REFERENCES auth.users(id),
  resolved_at TIMESTAMPTZ,
  rejection_reason TEXT,
  executed_price NUMERIC,
  executed_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX fund_trade_proposals_fund_id_idx ON fund_trade_proposals (fund_id);
CREATE INDEX fund_trade_proposals_proposer_idx ON fund_trade_proposals (proposer_user_id);

-- fund_holdings needs a unique (fund_id, symbol) target for the upsert
-- below -- a plain unique index works fine as an ON CONFLICT target, no
-- named constraint required.
CREATE UNIQUE INDEX IF NOT EXISTS fund_holdings_fund_symbol_uidx
  ON fund_holdings (fund_id, symbol);

-- Atomic cash + holdings mutation, same row-locking convention as
-- fund_subscribe/fund_redeem (Migration 015) -- caller (fundTradeService.js)
-- supplies the live market price, this function only does the mutation.
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
    INSERT INTO fund_holdings (fund_id, symbol, quantity)
    VALUES (p_fund_id, p_symbol, p_quantity)
    ON CONFLICT (fund_id, symbol)
    DO UPDATE SET quantity = fund_holdings.quantity + EXCLUDED.quantity;
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
