-- =============================================================================
-- F.O.M.O. Shield — Supabase Migration 037  (PENDING — run this)
-- Changes: fund_vacancies.status — 'open'/'closed'/'filled' becomes
--          'open'/'paused', and withdrawn adverts stop being kept at all.
--
-- Migration 036 kept a withdrawn advert as a 'closed' row, reasoning that an
-- application would later point at it. His decision on 2026-10-10, once he
-- saw the card: a dead advert sitting in the list beside a live one is just
-- clutter -- "неактивную заявку нужно стирать нафиг из памяти полностью".
-- Deleting is now what Delete means, and the softer state is a PAUSE: the
-- advert stays, off the public board, and says so in red until it is resumed.
--
-- So the three states collapse to two. 'filled' never had a writer -- nothing
-- in the code ever set it -- and 'closed' is replaced by deletion.
-- =============================================================================

-- Withdrawn adverts were never meant to outlive their usefulness. Anything
-- already parked in the old states goes; a paused one would have to be
-- paused again deliberately, and there is nothing to lose in either.
DELETE FROM public.fund_vacancies WHERE status IN ('closed', 'filled');

ALTER TABLE public.fund_vacancies
    DROP CONSTRAINT IF EXISTS fund_vacancies_status_check;

ALTER TABLE public.fund_vacancies
    ADD CONSTRAINT fund_vacancies_status_check
    CHECK (status IN ('open', 'paused'));

-- closed_at outlived its meaning with 'closed': what it records now is when
-- the advert was paused, and it is cleared again on resume.
COMMENT ON COLUMN public.fund_vacancies.closed_at IS
    'When the advert was paused; NULL while it is open.';

-- The partial unique index (fund_id, role) WHERE status = 'open' still holds:
-- a paused advert frees the role for a new one, which is the right answer --
-- pausing is not holding a seat.
