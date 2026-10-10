-- =============================================================================
-- F.O.M.O. Shield — Supabase Migration 036  (PENDING — run this)
-- Table: fund_vacancies
-- Feature: ETF Fund Emulation — the employee exchange, the half that never
--          existed. A head could browse candidates; nobody could see which
--          funds were hiring. The app's own "Вакансии" and "Заявки" cards
--          opened a ComingSoonScreen, which is how it was found (2026-10-10).
--
-- A vacancy is POSTED, not derived (his decision, 2026-10-10, against the
-- alternative of listing every fund with a free seat). A real board shows
-- what someone chose to advertise: which role, in which fund, with what on
-- offer. The cost of that choice is a board that is empty until a head posts
-- something, which is accepted deliberately.
--
-- `offered_limit_amount` is the discretionary budget the head is willing to
-- grant (fundDiscretion.js) — advertised here, not granted here. Nothing
-- reads it as permission; the head still sets the real limit on the team
-- member after hiring. It is a promise in a job ad, and it is stored so the
-- candidate can compare two funds by what they offer.
--
-- Closing rather than deleting: a filled vacancy is how a fund's hiring
-- history reads later, and an application (next phase) points at the row it
-- was sent to. Deleting would orphan that.
--
-- Written and read only by scanco-backend (fundVacancyService.js), always
-- through supabaseAdmin, i.e. service_role. The Flutter app never touches it
-- directly — same arrangement as fund_trade_proposals and fund_target_weights.
-- =============================================================================
CREATE TABLE IF NOT EXISTS public.fund_vacancies (
    id         uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    fund_id    uuid NOT NULL REFERENCES public.funds(id) ON DELETE CASCADE,
    -- The same four the roster knows (fundTeamService.ROLES). A vacancy for
    -- a role that cannot be hired would be an advert for nothing.
    role       text NOT NULL
               CHECK (role IN ('analyst', 'co_manager', 'trader', 'risk_manager')),
    -- "Кого ищем" — the head's own words, the part that makes this an advert
    -- rather than a row. Optional: a role and a fund is already an offer.
    pitch      text CHECK (pitch IS NULL OR char_length(pitch) <= 500),
    -- Advertised discretionary budget, in dollars. NULL means none offered,
    -- which is not the same as zero — see fundDiscretion.budgetOf.
    offered_limit_amount numeric(14,2)
               CHECK (offered_limit_amount IS NULL OR offered_limit_amount >= 0),
    -- 'filled' is its own ending, distinct from a head simply withdrawing
    -- the advert, because the two read differently in a fund's history.
    status     text NOT NULL DEFAULT 'open'
               CHECK (status IN ('open', 'closed', 'filled')),
    created_at timestamptz NOT NULL DEFAULT now(),
    closed_at  timestamptz
);

-- The board itself: every open vacancy, newest first. The one query this
-- table exists to answer.
CREATE INDEX fund_vacancies_open_idx
    ON public.fund_vacancies (created_at DESC) WHERE status = 'open';
-- A fund's own adverts, for the head's screen and for the service's
-- "how many are already open" check.
CREATE INDEX fund_vacancies_fund_idx ON public.fund_vacancies (fund_id);

-- One open advert per role per fund. Two identical "ищем аналитика" rows
-- from the same fund are not two jobs, they are a double tap.
CREATE UNIQUE INDEX fund_vacancies_open_role_unique_idx
    ON public.fund_vacancies (fund_id, role) WHERE status = 'open';

ALTER TABLE public.fund_vacancies ENABLE ROW LEVEL SECURITY;
-- Deliberately no policies, the same shape as fund_target_weights and
-- fund_trade_proposals: service_role bypasses RLS and is the only writer,
-- and the board is served by the API, not read from the Data API. Add
-- policies HERE if a client ever reads vacancies directly.

-- Data API grants. Mandatory for tables created from 2026-10-30 (see the
-- header of docs/supabase_migration.sql). Reproduces the default Supabase
-- used to apply automatically; RLS is what actually restricts access.
GRANT ALL ON TABLE public.fund_vacancies TO anon, authenticated, service_role;
