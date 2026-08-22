# FOMO Shield — Design Standard (the "monument")

> **Rewritten 2026-08-12** — merged from two previously-separate references (light card doc +
> a dark-card doc that only existed in Claude's session memory) into this ONE file, plus a fresh
> full-app grep to catch drift and undocumented patterns. Every value below was re-read from the
> live source files on 2026-08-12, not carried over from the previous version.
>
> **Scope**: this is the practical "what do we actually follow" reference for card-style widgets
> app-wide — both the light card and the dark/premium card, plus two smaller reused sub-patterns.
> For the full app-wide consistency audit (dead code, mock-data-as-live, orphaned screens) see
> `docs/VISUAL_AUDIT.md` instead — that's the "what's broken" doc, this is the "what's correct" one.

---

## 1. The short version

**Light card** (default — list widgets, info cards, most of Home/Market Clock/company detail):
- Shell: `FomoShieldTheme.cardDecoration` (`lib/src/core/theme/fomo_shield_theme.dart`)
- Colors: `ThemeV2` (`lib/src/core/theme/theme_v2.dart`) — not `FomoShieldTheme`'s own color set (§5)
- Title: `FomoShieldTheme.cardTitle()`
- Divider: `Divider(color: Colors.black.withValues(alpha: 0.06), indent: 16, endIndent: 16)`
- Numbers: always `FontWeight.w600` — never `w800`/bold

**Dark/premium card** ("branded" feel — balance/CTA cards, PREMIUM badges, Verdict/stress-test cards):
- Shell: `darkCardDecoration(borderRadius: BorderRadius.circular(22))` — the radial "instrument
  panel" gradient, from `lib/src/features/market_clock/market_clock_dial.dart` (unified app-wide
  2026-08-14, was Market Clock-only before — see §3)
- Radius: `22` everywhere, no exceptions for full cards (`FomoShieldTheme.cardRadius`, the helper's
  default) — buttons/pills/badges pass their own smaller radius
- Divider: `Colors.white.withValues(alpha: 0.12)`, `indent`/`endIndent: 16` — the dominant pattern,
  use this for new work (§3)
- Text: `Colors.white` / `Colors.white70` / `Colors.white54` — never `ThemeV2.textPrimary/Secondary`
  (both near-black, illegible on this background), and never `dialIvory` outside Market Clock's own
  file (§3)

Two real files already do the light style correctly and are good copy-paste references:
`lib/src/features/market_clock/market_clock_phase_widget.dart` and
`lib/src/features/market_clock/market_clock_timing_widget.dart` (the latter also has the one
gold-divider dark-card variant, see §3).

---

## 2. Light card shell

```dart
Container(
  decoration: FomoShieldTheme.cardDecoration,
  child: Column(
    children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(22, 14, 22, 14),
        child: Row(children: [
          Text('TITLE', style: FomoShieldTheme.cardTitle()),
          const Spacer(),
          const Icon(Icons.chevron_right_rounded, color: ThemeV2.textSecondary, size: 20),
        ]),
      ),
      Divider(height: 1, indent: 16, endIndent: 16, color: Colors.black.withValues(alpha: 0.06)),
      Padding(padding: const EdgeInsets.all(16), child: /* body content */),
    ],
  ),
)
```

| Property | Value | Source |
|---|---|---|
| Card background | `#FFFDF9` | `FomoShieldTheme.card` |
| Card border | `#E8E1D5`, 1px | `FomoShieldTheme.border` |
| Card radius | `22px` | `FomoShieldTheme.radius` / `cardRadius` |
| Card shadow | **none** | `cardDecoration` sets no `boxShadow` |
| Header padding | `EdgeInsets.fromLTRB(22, 14, 22, 14)` | confirmed pattern |
| Body padding | `EdgeInsets.all(16)` | confirmed pattern |
| Divider | `Colors.black.withValues(alpha: 0.06)`, indent/endIndent `16` | **not** `ThemeV2.divider` (`#ECECEC`) |

`WidgetContainer` (`lib/src/shared/widgets/widget_container.dart`) is an older wrapper around
`CardFrame(showTopBar: false, ...)` used by 4 Home/Portfolio/Stress-Test widgets — confirmed
2026-08-12 to still render byte-identical to the hand-rolled shell above (both explicitly disable
`CardFrame`'s decorative top-bar stripe). Safe to reuse; not required.

**Trap**: `CardFrame` defaults `showTopBar` to visible (a 5px gradient stripe,
`cardTopBarStart`/`End`). Every active light-card consumer explicitly passes `showTopBar: false`.
One widget doesn't — `ExplainableCard` (`lib/src/shared/widgets/explainable_card.dart`) — but it
has zero call sites anywhere, i.e. it's dead. If it's ever revived, add `showTopBar: false` or it
will render an unintended stripe no other card has.

---

## 3. Dark/premium card shell

**Unified 2026-08-14** — every dark card, button, badge, pill and segmented-control highlight in
the app now uses the same radial "instrument panel" gradient that used to be Market Clock-only.
User's own words: this was Market Clock's exact look ("цвета градиенты карточки подсвечивания") —
applied everywhere via one shared helper instead of copy-pasting the gradient at 40+ call sites.

```dart
Container(
  decoration: darkCardDecoration(borderRadius: BorderRadius.circular(22)),
  child: Column(
    children: [
      // header row, white text
      Divider(height: 1, indent: 16, endIndent: 16, color: Colors.white.withValues(alpha: 0.12)),
      // body content, white/white70/white54 text — NOT dialIvory, see below
    ],
  ),
)
```

`darkCardDecoration()` and the underlying `DarkCardPalette` class both live in
`lib/src/features/market_clock/market_clock_dial.dart`:

```dart
BoxDecoration darkCardDecoration({
  BorderRadius? borderRadius,           // defaults to 22 (FomoShieldTheme.cardRadius)
  DarkCardPalette palette = DarkCardPalette.instrumentPanel,
}) // → RadialGradient(center: Alignment(0,-0.3), radius: 1.2,
   //     colors: [gradientStart, gradientMid, gradientEnd], stops: [0,0.6,1]),
   //   boxShadow: FomoShieldTheme.shadowSoft (every dark card now has this glow)
```

For the rare shape that can't take a `borderRadius` at all (a circular avatar-style badge), use the
gradient alone: `darkCardGradient()`.

**This `DarkCardPalette` indirection is deliberate groundwork, not premature abstraction** — user
asked (2026-08-14) to prepare the seam for a future alternate palette (e.g. a premium theme) without
building the actual switcher yet. `DarkCardPalette.instrumentPanel` is still the only palette that
exists; a future one is a new `DarkCardPalette` instance + passing it to `darkCardDecoration(palette:
...)`, not another pass through every consumer file.

| Property | Value | Source |
|---|---|---|
| Gradient | `[dialLight #173A2E, dialMid #0F281F, dialDark #0A1B15]`, radial, center `(0,-0.3)`, radius `1.2`, stops `[0, 0.6, 1.0]` | `market_clock_dial.dart` |
| Gold accent | `dialBrassLight #E8C468` | same file — icons, "PREMIUM" text, nested-window borders |
| Title/emphasis text | `Colors.white` — **stays plain white app-wide, deliberately not `dialIvory`** (user explicitly kept white when rolling the gradient out; only Market Clock's own file still uses `dialIvory` directly, not through this helper) | |
| Secondary/body text | `Colors.white70` | |
| Tertiary/caption text | `Colors.white54` | |
| Semantic colors | `ThemeV2.success`/`loss`/`warning`, `FomoShieldTheme.factorHype` unchanged | read fine on dark green |

**Nested "window" sub-panel** (a bordered sub-section inside a dark card, e.g. a risk-score readout):
```dart
BoxDecoration(
  color: dialDark.withValues(alpha: 0.35),
  borderRadius: BorderRadius.circular(12),
  border: Border.all(color: dialBrassLight.withValues(alpha: 0.4)),
)
```

A handful of sites keep their own extra `border`/custom `boxShadow` on top of the shared shell —
use `darkCardDecoration(...).copyWith(border: ..., boxShadow: ...)` for those rather than duplicating
the gradient inline (e.g. `portfolio_selector.dart`'s gold-bordered premium pills, the "Continue
Learning" button's tinted shadow).

### Radius — unified to 22 everywhere 2026-08-14

Previously a `{16, 20, 22}` spread (see git history if you need the old per-file breakdown) —
collapsed to a single `22` (`FomoShieldTheme.cardRadius`, `darkCardDecoration()`'s default) across
every full dark card, as part of the same rollout. Buttons/pills/badges/segmented-control highlights
keep their own smaller radii (pass `borderRadius:` explicitly) — that's a different element type,
not radius drift.

### Divider/border — 4 real patterns, not a grab-bag

- **No border on the outer shell** — the majority of `20`/`22`-radius cards.
- **Divider `Colors.white.withValues(alpha: 0.12)`, indent/endIndent `16`** — the dominant pattern,
  all the Verdict/Stress-Test radius-20 cards plus `stress_test_portfolio_balance_screen.dart`,
  `portfolio_cash_widget.dart`. **Use this for new work.**
  Distinct sub-cluster, `alpha: 0.15`, **no indent** (full-width) — company/stock-detail screens:
  `financial_score_widget.dart`, `price_header.dart`, `position_section.dart`,
  `stock_why_today_card.dart`, `stock_position_card.dart`.
- **Gold divider** `dialBrassLight.withValues(alpha: 0.3)`, indent/endIndent `20` —
  `market_clock_timing_widget.dart` only. One file, not "a few" — don't assume this is a
  common variant.

`Colors.black12`/`ThemeV2.divider` sightings near dark-card files turned out to be on *different,
plain-colored sub-elements in the same file* (e.g. a light metric cell, §9A) — not on the dark
shell itself. If you see one of those tokens applied directly to a `[dialLight, dialDark]`
container, that's a real inconsistency worth flagging, not the documented pattern.

---

## 4. Colors (ground truth: `ThemeV2`, `lib/src/core/theme/theme_v2.dart`)

| Token | Hex | Usage |
|---|---|---|
| `ThemeV2.primary` | `#215C42` | Brand accent — card titles, icons, links, selected states |
| `ThemeV2.success` | `#2DBE63` | Gains, positive change, "safe" states |
| `ThemeV2.loss` | `#C64545` | Losses, negative change, "risky" states |
| `ThemeV2.warning` | `#D7AE42` | Neutral/caution states (sideways market, pending) |
| `ThemeV2.background` | `#F8F5EC` | Scaffold base (before gradient overlay) |
| `ThemeV2.surface` | `#FFFFFF` | Plain white surface — **not** the card standard, see §5 |
| `ThemeV2.surfaceDark` | `#E8E4D6` | Secondary surfaces, grid lines, range selectors, §9B rows |
| `ThemeV2.textPrimary` | `#202020` | Primary text (near-black) — light card only, illegible on dark |
| `ThemeV2.textSecondary` | `#8B8B8B` | Secondary/muted text — light card only |
| `ThemeV2.divider` | `#ECECEC` | Declared token — bypassed by both card standards' own dividers (§2/§3), but genuinely used by §9A's metric-cell border |

### App-wide background gradient
Applied once in `main.dart` behind every Scaffold (which must set `backgroundColor: Colors.transparent`):

```dart
ThemeV2.backgroundGradient // top→bottom
LinearGradient(
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
  colors: [Color(0xFFF7F7F5), Color(0xFFDCDBD7)], // neutral, no yellow/pink cast — matches splash bg
)
```

---

## 5. Why there are three theme files (and which one wins)

`ThemeV2` (`theme_v2.dart`) is the theme actually registered in `main.dart`
(`theme: ThemeV2.lightTheme`). `FomoShieldTheme` (`fomo_shield_theme.dart`) is a second, older
token set that declares its **own** `primary` (`#355C7D`, a blue — unused for the brand accent in
practice), its own success/loss (`#37B86B`/`#D04E4E`), and its own background (`#F6F1E7`). Notably
`FomoShieldTheme.cardTitle()` itself defaults to `ThemeV2.primary`, not `FomoShieldTheme.primary`
— even the "canonical" file leaks a value from the other system.

**In practice**: use `FomoShieldTheme` only for its card *shell geometry* (`cardDecoration`,
`cardTitle()`, `cardRadius`) — use `ThemeV2` for every actual color. Real technical debt, not a
design choice worth defending; documented so it's applied consistently rather than "fixed" ad hoc.

A third file, `app_theme.dart` ("Editorial Heritage"), is legacy and used only by
`monetization_modal.dart` + `premium_promo_overlay.dart` — do not use it for new work.

---

## 6. Brand CTA / Premium gradient ("dial" gradient) — scope corrected 2026-08-12

Defined once in `lib/src/features/market_clock/market_clock_dial.dart`:

```dart
const dialLight = Color(0xFF173A2E);   // gradient start (topLeft)
const dialMid   = Color(0xFF0F281F);   // used for the round dial face only
const dialDark  = Color(0xFF0A1B15);   // gradient end (bottomRight)
const dialBrassLight = Color(0xFFE8C468); // gold accent
```

**Real footprint: 37 consumer files**, not the "~7" a previous pass estimated — that number only
ever counted files with a *named private const* wrapper. The literal `colors: [dialLight, dialDark]`
(with or without a local const) appears at 40+ call sites total, across every dark card, button,
badge, pill, and segmented-control highlight in the app. Nobody has exported a shared
`brandGradient` constant or a `darkCardDecoration()` helper the way `marketClockCardDecoration()`
already exists for the dial's own radial gradient — this remains real, uncorrected duplication,
now confirmed larger in scope than previously written down.

Files with a named private const (6, confirmed 2026-08-12 — membership has shifted since the last
count, not literally the same 7 files): `portfolio/widgets/target_widget.dart` (`_indicatorGradient`),
`home/widgets/stress_test_widget.dart` (`_brandGradient`), `home/widgets/shield_signal_widget.dart`
(`_priceCellGradient`), `stress_test/stress_test_hub_screen.dart` (`_brandGradient`),
`stress_test/stress_test_setup_screen.dart` (`_brandGradient`),
`company_detail/widgets/portfolio_option_tile.dart` (`_walletGradient`).

---

## 7. Typography

| Use | Style |
|---|---|
| Card title (section header) | `FomoShieldTheme.cardTitle()` — Inter 13px, w700, letterSpacing 1.2, color `ThemeV2.primary` (light card) or `Colors.white` (dark card, override manually) |
| Body text | Inter, size varies by context (13–16px seen in practice — no single enforced body style) |
| **Any numeric value** (price, P&L, %, balance, score) | `FontWeight.w600` (Semibold) — **never** `w800`/bold. See `interNums()` helper in `typography_helpers.dart`. |

---

## 8. Radii & spacing quick reference

| Token | Value | Source | Status |
|---|---|---|---|
| Card radius (light standard) | `22px` | `FomoShieldTheme.radius` | in active use |
| Small/badge radius | `14px` | `FomoShieldTheme.radiusSm` | in active use |
| Extra-large radius | `34px` | `FomoShieldTheme.radiusXl` | in active use |
| Gap between cards | `24px` | `FomoShieldTheme.cardGap` | in active use |
| `ThemeV2.radiusSmall/Medium/Large` (12/18/24) | — | `theme_v2.dart` | **no longer unused as of 2026-08-12** — now live in `why_today_screen.dart` (5 sites), `key_metrics_section.dart`, `financial_score_widget.dart`, `stock_why_today_card.dart`, `stress_test_portfolio_health_widget.dart`. Stands in tension with the `FomoShieldTheme.radius`(22)/`radiusSm`(14) convention above — don't assume either is "the" answer without checking which family the file you're editing already uses. |
| `ThemeV2.space4`…`space40` | — | `theme_v2.dart` | **still 0 call sites**, confirmed 2026-08-12. Don't reach for it. |
| Header padding | `fromLTRB(22, 14, 22, 14)` | confirmed pattern | |
| Body padding | `all(16)` | confirmed pattern | |
| Divider indent | `16px` both sides (light + white-dark variant) | confirmed pattern | |

---

## 9. Two smaller reused patterns — not previously written down anywhere

### A. "Metric cell" — small stat box inside a light card
Label + big value pair, e.g. a portfolio stat grid. `color:` caller-supplied (usually white or a
semantic tint), `borderRadius: BorderRadius.circular(16)`, `border: Border.all(color: ThemeV2.divider)`.
This is the **one place `ThemeV2.divider` (#ECECEC) is actually used as declared** — everywhere
else on this page it's bypassed. Currently a private `_cell()` helper, independently copy-pasted
(not shared) in `home/widgets/portfolio_widget.dart` and `company_detail/widgets/price_header.dart`
— the latter's own comment admits it: "Same shape as Home Portfolio widget's `_cell`."

### B. "Reorderable widget settings row" — drag-to-reorder sheets
`color: ThemeV2.surfaceDark` (`.withValues(alpha: 0.5)` when hidden), `borderRadius.circular(14)`,
`border: Border.all(color: Colors.black12)` (or `black.withValues(alpha: 0.03)` when hidden).
Byte-identical block copy-pasted 4×: `home/home_screen.dart`,
`company_detail/widgets/company_widgets_settings_sheet.dart`,
`portfolio/widgets/portfolio_widgets_settings_sheet.dart`,
`market_clock/market_clock_widgets_settings_sheet.dart`.

Neither pattern is broken or inconsistent between its own copies — just genuinely undocumented
until now, and each is a candidate for a shared widget if anyone touches this area again.

---

## 10. Where this doc's guidance was confirmed

- Light card shell/divider/padding: confirmed against `market_clock_phase_widget.dart` +
  `market_clock_timing_widget.dart`, re-verified 2026-08-12.
- Dark card gradient/gold/text rules: confirmed against 7+ consumer files, re-verified 2026-08-12
  (full 37-file census this pass, up from a partial count previously only tracked in session memory).
- Numeric weight rule: confirmed 2026-07-25 (Portfolio widget pass).
- `ThemeV2` vs `FomoShieldTheme` vs `AppTheme` split: confirmed against `docs/VISUAL_AUDIT.md`
  (2026-07-20), re-verified 2026-08-12 — still accurate.
- Radius/divider drift tables, brand-gradient file census, `ThemeV2.radiusSmall/Medium` now-in-use
  finding, and the two §9 patterns: all fresh 2026-08-12, full `lib/` re-grep.

---

## 11. User-confirmed gold-standard widgets (2026-08-14)

User explicitly named these as visually ideal as-is — colors, gradients, cards, highlights, fonts —
**no changes needed to them**. Captured here purely as the copy-source for future point-fixes
elsewhere, not as a to-do list:

| Area | File(s) | Pattern it exemplifies |
|---|---|---|
| Market Clock | `market_clock_widget.dart` (Home mini card), `market_clock_screen.dart`, `market_clock_phase_widget.dart`, `market_clock_timing_widget.dart`, `market_clock_new_york_time_widget.dart` | Radial instrument-panel dark card (§3) + light card shell (§2) |
| TARGET | `portfolio/widgets/target_widget.dart` | Light card shell (§2) wrapping a nested `_GraphWindow` panel (now radial, see below) + segmented bidirectional bar + §9A metric-cell goal/remaining boxes |
| Allocation ring | `shared/widgets/donut_ring_painter.dart` | Shared painter — already the single source for both Stress Test's and real Portfolio's Portfolio Balance cards, byte-identical by design |
| Holdings | `portfolio/widgets/portfolio_holdings_widget.dart` | Light card shell, 72px row, 40px logo avatar ringed in `donutAllocationColor(i)` |
| Portfolio Balance | `portfolio/widgets/portfolio_balance_widget.dart` | Light card shell + centered donut + legend rows |
| Verdict cards | now the unified radial dark shell, §3 | |
| Company Card / Company Detail | now the unified radial dark shell, §3 (`financial_score_widget.dart`, `price_header.dart`, `position_section.dart`, `stock_why_today_card.dart`, `stock_position_card.dart`) | |

All of the above were re-read from live source 2026-08-14 and already conformed to §2/§3/§9A as
documented that same day — this pass didn't find drift, it found the exemplars the rest of the doc
was written from. The one genuinely new finding was the Market Clock radial+`dialIvory` variant.

**Same-day follow-up**: user then asked for that radial variant to become the app-wide dark-card
standard (not just Market Clock's own look) — done same session, see §3's "Unified 2026-08-14" note.
TARGET's `_GraphWindow` and CTA button, previously flat-gradient, are now also radial via
`darkCardDecoration()` like everything else — text stayed plain white, not `dialIvory` (user's
explicit call). The `20`/`16` radius clusters mentioned in earlier passes were folded into the
unified `22`.
