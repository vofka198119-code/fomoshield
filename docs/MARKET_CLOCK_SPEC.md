# Market Clock — Spec

Status: DRAFT — scope being defined with user, not yet implemented.

## Scope decisions so far

- **v1 covers Wall Street only** (NYSE/NASDAQ). No other exchanges/timezones yet.
- Replaces the just-removed NEWS widget/card slot on Home + the `/news` route
  (same physical location in the UI, different feature).
- Reference visual: user-provided mockup (ChatGPT-generated), a single card with:
  1. A circular clock face split into 4 colored arcs — PRE-MARKET / MARKET OPEN /
     AFTER HOURS / CLOSED — with a live hour/minute hand and a center icon.
  2. A status side-panel: current phase badge, "Open for Xh Ym" / "Until HH:MM",
     "Today: Normal Day" (or holiday/early-close label), next event line, a
     contextual tip line.
  3. A horizontal 24h timeline bar with the same 4 phases, current-time marker.
  4. "MARKET CONDITIONS" card (Liquidity / Volatility / News Risk bars).
  5. "WHAT'S HAPPENING NOW" card (auto-generated one-line market summary).
  6. Footer tip/link row.

## Build plan (phased, per user's explicit instruction — one piece at a time)

### v1 — Core clock (data-free, pure time math)
- Items 1–3 above only (clock face, status panel, timeline bar).
- Needs: current time in America/New_York, and a fixed Wall Street schedule:
  - Pre-market: 4:00 AM – 9:30 AM ET
  - Market open (regular session): 9:30 AM – 4:00 PM ET
  - After-hours: 4:00 PM – 8:00 PM ET
  - Closed: 8:00 PM – 4:00 AM ET
  - Weekends: closed all day.
  - NYSE holiday calendar + early-close days (half days before certain
    holidays) — need the exact list before this counts as "done", not just
    weekday/weekend math.
- No backend/API call needed for this layer — everything is computable
  client-side from a clock + a static holiday table.

### v2+ — Data-dependent side panels (NOT started, one at a time, source TBD per item)
- "Next important event" (e.g. CPI Report) → needs an economic calendar data
  source. Not yet identified/vetted.
- "Market Conditions": Liquidity / Volatility / News Risk → needs a real or
  heuristic signal per metric (e.g. VIX for volatility). Not yet designed.
- "What's Happening Now" auto-summary → same class of problem as the
  just-removed general news feature (unreliable/messy third-party sourcing).
  Do not casually re-introduce a live news dependency here without the
  earlier lesson in mind — see the "News widget fixes" memory: general news
  content itself (lags, cookie/registration walls, spam) was the reason the
  News feature got gutted back to a placeholder, not the app code.
- Each of these ships independently, only after its own data source is
  confirmed to actually work — do not bundle multiple into one PR/commit.

## Time segments + copy (user-provided, 2026-07-26)

9 sub-periods, each with a short widget hint (emoji + phrase, ET) and an
expanded tap-through description (4 fields: Что происходит / Почему это
важно / Опасность для новичка / Что делать). All times are America/New_York.

**Note — reconciling with the mockup's 4-arc clock face**: the visual clock
face still has 4 colored arcs (Pre-Market / Market Open / After-Hours /
Closed), but the *text* (short widget hint + tap-through detail) is more
granular — 9 windows total, several sharing the same arc color. E.g.
"Opening Bell" 09:30–10:30, "Morning Session" 10:30–12:00, "Lunch Hour"
12:00–14:00, "Mid-Afternoon" 14:00–15:30 and "Power Hour" 15:30–16:00 are
5 distinct copy windows all inside the single green "MARKET OPEN" arc.
Confirm before building: does the arc stay 4-color, with only the
status-panel text/emoji switching every sub-window? (Assumed yes for now.)

### 1. Early Pre-Market — 04:00–07:00
- Widget hint: 🌙 Ранний премаркет | Низкая ликвидность, опасные спреды
- Что происходит: открываются первые электронные торги для крупных фондов и ранних трейдеров; параллельно открываются биржи в Европе.
- Почему это важно: очень мало денег и участников (низкая ликвидность) → спред может быть огромным.
- Опасность для новичка: рыночный ордер (Market Order) может исполниться по любой доступной цене — переплата на пустом месте.
- Что делать: торговать только при крайней необходимости, только лимитными ордерами (Limit Order).

### 2. Pre-Market / отчёты — 07:00–09:30
- Widget hint: ☕ Премаркет и новости | Высокий риск, публикация отчетов
- Что происходит: в 08:30 часто публикуются квартальные отчёты компаний и ключевые макро-новости США (инфляция, безработица).
- Почему это важно: резкая волатильность — акции могут двигаться на 10–20% ещё до открытия основной сессии.
- Опасность для новичка: хаотичное движение цены на эмоциях — легко ошибиться на панике.
- Что делать: наблюдать со стороны, не пытаться угадать направление на новостях.

### 3. Opening Bell — 09:30–10:30
- Widget hint: 🔔 Открытие биржи | Пик волатильности, хаос первых минут
- Что происходит: звонит колокол NYSE, подключаются миллионы розничных инвесторов и торговые роботы.
- Почему это важно: самый активный час дня — исполняются заявки, накопленные за ночь и премаркет.
- Опасность для новичка: первые 15–30 минут — "зона хаоса", случайный скачок может выбить из сделки.
- Что делать: подождать 20–30 минут после открытия, пока не сформируется понятное направление.

### 4. Morning Session — 10:30–12:00
- Widget hint: 📈 Утренний тренд | Лучшее время для спокойных сделок
- Что происходит: утренний хаос улёгся, крупные игроки уже определились с планами на день.
- Почему это важно: высокая ликвидность + предсказуемые, плавные движения, минимальные спреды.
- Опасность для новичка: минимальная за весь день.
- Что делать: самое безопасное время для запланированных покупок/продаж.

### 5. Lunch Hour — 12:00–14:00
- Widget hint: 🥪 Обеденный перерыв | Затишье, низкая активность
- Что происходит: управляющие фондами уходят на обед в Нью-Йорке; европейские биржи в это время закрываются.
- Почему это важно: объёмы падают, цена двигается в узком боковом коридоре без чёткого направления.
- Опасность для новичка: импульсивные сделки от скуки, попытка найти движение там, где его нет.
- Что делать: отдохнуть от графика; долгосрочные покупки можно делать, но сильных трендов ждать не стоит.

### 6. Mid-Afternoon — 14:00–15:30
- Widget hint: 📊 Дневная сессия | Стабильные торги, реакция на ФРС
- Что происходит: трейдеры возвращаются; в дни заседаний ФРС ставки объявляют ровно в 14:00.
- Почему это важно: в дни ФРС — мощный всплеск активности; в обычные дни — спокойное продолжение утреннего тренда.
- Опасность для новичка: высокая волатильность в дни заседаний ФРС (~8 раз в год).
- Что делать: обычные дни — хорошее время для сделок; дни ФРС — не входить в рынок за 15 минут до/после 14:00.

### 7. Power Hour — 15:30–16:00
- Widget hint: ⚡ Час пик (Power Hour) | Финал дня, крупные объемы
- Что происходит: последние 30–60 минут перед закрытием — дневные трейдеры закрывают позиции, фонды балансируют портфели.
- Почему это важно: второй по силе всплеск активности за день, часто обновляются максимумы/минимумы дня.
- Опасность для новичка: быстрые развороты цены прямо перед закрытием.
- Что делать: хорошее время зафиксировать прибыль по утренним сделкам или докупить на закрытии.

### 8. After-Hours — 16:00–20:00
- Widget hint: 🌙 Постмаркет | Рынок закрыт, вечерние отчеты
- Что происходит: основная сессия закрылась в 16:00; в 16:05 многие техгиганты (Apple/Amazon/Google) публикуют квартальные отчёты.
- Почему это важно: крайне низкая ликвидность + сильные новости → акция может двигаться на 15–20% за пару минут на единичных сделках.
- Опасность для новичка: очень высокая — широкие спреды, риск купить по неадекватной цене.
- Что делать: не торговать, использовать время только для чтения отчётов и подготовки к завтрашнему открытию.

### 9. Closed — 20:00–04:00
- Widget hint: 🛑 Биржа закрыта | Торги не ведутся
- Что происходит: торги полностью остановлены, серверы биржи обрабатывают дневные операции.
- Почему это важно: рынок отдыхает, ничего не исполняется до 04:00.
- Что делать: готовиться к следующему торговому дню, анализировать графики и новости.

(Weekends: closed all day — same "Closed" copy/state, not a separate segment.)

## NYSE holiday calendar (user-provided, 2026-07-26)

### Full closure (no pre-market/regular/after-hours at all)
- Jan 1 — New Year's Day
- 3rd Monday of January — Martin Luther King Jr. Day
- 3rd Monday of February — Presidents' Day (Washington's Birthday)
- Friday before Easter — Good Friday
- Last Monday of May — Memorial Day
- Jun 19 — Juneteenth National Independence Day
- Jul 4 — Independence Day (if Jul 4 falls Sat → observed Fri Jul 3; if Sun → observed Mon Jul 5)
- 1st Monday of September — Labor Day
- 4th Thursday of November — Thanksgiving Day
- Dec 25 — Christmas Day

### Early close (regular session ends 1:00 PM ET instead of 4:00 PM — pre-market/after-hours schedule around that shift TBD, not specified by user yet)
- Day after Thanksgiving ("Black Friday")
- Dec 24 — Christmas Eve (may not apply if Dec 25 falls on a weekend)

### Explicitly NOT closed — common misconception to avoid
Columbus Day (October) and Veterans Day (November) are federal holidays
(banks/bond market closed) but **NYSE/NASDAQ trade normally** — do not
close the market on these days.

### Implementation implication — this is a rule engine, not a static list
Most of these are **not fixed calendar dates** and must be computed per
year:
- "Nth weekday of month" rules: MLK Day, Presidents' Day, Memorial Day
  (last Monday), Labor Day, Thanksgiving (4th Thursday).
- Good Friday depends on the Easter date (needs an Easter-calculation
  algorithm, e.g. Anonymous Gregorian/Meeus algorithm).
- Fixed-date holidays (Jan 1, Jun 19, Jul 4, Dec 25) still need the
  weekend-observed-shift rule applied.
- Black Friday / Christmas Eve early closes derive from Thanksgiving/
  Christmas dates respectively, plus the "may not apply" exception noted
  for Christmas Eve.
This is the single biggest implementation-effort item in v1 — budget for
it as real logic + a few years of hardcoded verification, not a quick
lookup table.

## Still open

- Notification logic (e.g. alert user X minutes before open/Power Hour) —
  explicitly deferred, a separate feature layered on top of the clock, not
  part of v1 scope.
- Whether "Learn more" / "Explore guides" / footer education content is in
  scope for v1 or deferred.
- Confirm the 4-arc-visual / 9-window-copy reconciliation noted above before
  building the clock face.
- **Ring color — ANSWERED**: stays 4-color-coded by phase, as in the mockup,
  for now — revisit later if it looks off in our style.
- **Marker icon — ANSWERED**: changes per phase (one icon per macro-phase,
  matching the 4 ring colors — not all 9 sub-windows). Proposed default,
  not yet confirmed visually:
  - Closed (20:00–04:00): moon icon
  - Pre-Market (04:00–09:30): sunrise/dawn icon
  - Market Open (09:30–16:00): sun icon
  - After-Hours (16:00–20:00): sunset/dusk icon

## Design questions — all resolved, ready to move to implementation

Remaining before "v1 done": build the holiday/early-close rule engine,
build the clock face + ring + timing box, wire the 9-window copy in, verify
icon choices on-device (may swap for better Material icon matches once
seen for real).
