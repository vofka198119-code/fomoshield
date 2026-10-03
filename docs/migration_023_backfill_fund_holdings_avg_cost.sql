-- Migration 023: backfill fund_holdings.avg_cost from real execution history
-- Bug found 2026-09-12: holdings that existed before Migration 021 got
-- avg_cost defaulted to 0. fund_execute_trade's weighted-average buy
-- formula then blended that stale 0 into the NEXT buy, silently corrupting
-- the cost basis (a fund's "O" position showed a fake +60% P&L after its
-- second buy). This recomputes avg_cost for every existing holding from the
-- fund's own executed buy history (fund_trade_proposals), which is the
-- actual source of truth -- sells are excluded on purpose, same convention
-- as Portfolio's own cost-basis tracking (a sell never changes the
-- remaining shares' average cost, only buys do).

UPDATE fund_holdings fh
SET avg_cost = sub.avg_cost
FROM (
  SELECT fund_id, symbol,
         SUM(quantity * executed_price) / SUM(quantity) AS avg_cost
  FROM fund_trade_proposals
  WHERE status = 'executed' AND side = 'buy'
  GROUP BY fund_id, symbol
) sub
WHERE fh.fund_id = sub.fund_id AND fh.symbol = sub.symbol;
