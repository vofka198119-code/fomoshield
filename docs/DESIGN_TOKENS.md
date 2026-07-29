# FOMO Shield — Design Standard (Home / Market Clock card style)

> **Rewritten**: 2026-07-29 — the previous version of this file (dated 07-14) had drifted from
> the actual code (wrong hex values for `primary`/`success`/`loss`/`warning`/`textPrimary` etc.).
> Every value below was re-read from the live source files on 2026-07-29, not carried over.
>
> **Scope**: this is the practical "what do we actually follow" reference for card-style widgets
> (Home screen widgets, Market Clock widgets, and anything built to match them). For the full
> app-wide consistency audit (which screens DON'T follow this, hardcoded-color hotspots, dead
> code, orphaned themes) see `docs/VISUAL_AUDIT.md` instead — that's the "what's broken" doc,
> this is the "what's correct" doc.

---

## 1. The short version

When building or editing a Home/Market Clock-style card widget, use:

- **Card shell**: `FomoShieldTheme.cardDecoration` (from `lib/src/core/theme/fomo_shield_theme.dart`)
- **Colors**: `ThemeV2` (from `lib/src/core/theme/theme_v2.dart`) — **not** `FomoShieldTheme`'s own
  color constants, which are legacy/unused for this purpose (see §4 for why both exist)
- **Card title text style**: `FomoShieldTheme.cardTitle()`
- **Divider**: hand-rolled `Divider(color: Colors.black.withValues(alpha: 0.06))`, not `ThemeV2.divider`
- **Numeric values**: always `FontWeight.w600` (Semibold) — never `w800`/bold
- **Brand CTA / PREMIUM badge gradient**: `dialLight` → `dialDark` (see §5) — not `ThemeV2.primary`
  as a flat fill

Two real files already do this correctly and are good copy-paste references:
`lib/src/features/market_clock/market_clock_phase_widget.dart` and
`lib/src/features/market_clock/market_clock_timing_widget.dart`.

---

## 2. Card shell

```dart
Container(
  decoration: FomoShieldTheme.cardDecoration,
  child: Column(
    children: [
      // header row
      Padding(
        padding: const EdgeInsets.fromLTRB(22, 14, 22, 14),
        child: Row(children: [
          Text('TITLE', style: FomoShieldTheme.cardTitle()),
          const Spacer(),
          // optional chevron if the header is tappable/navigates:
          const Icon(Icons.chevron_right_rounded, color: ThemeV2.textSecondary, size: 20),
        ]),
      ),
      Divider(height: 1, indent: 16, endIndent: 16, color: Colors.black.withValues(alpha: 0.06)),
      Padding(
        padding: const EdgeInsets.all(16),
        child: /* body content */,
      ),
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
| Header padding | `EdgeInsets.fromLTRB(22, 14, 22, 14)` | confirmed pattern, not a named constant |
| Body padding | `EdgeInsets.all(16)` | confirmed pattern, not a named constant |
| Divider | `Colors.black.withValues(alpha: 0.06)`, `indent`/`endIndent: 16` | confirmed pattern — **not** `ThemeV2.divider` (`#ECECEC`), that token exists but this is what's actually used |

`WidgetContainer` (`lib/src/shared/widgets/widget_container.dart`) is an older, still-used
implementation of this same visual shell for Home-screen widgets specifically. Market Clock's
widgets (and this doc) build the shell by hand instead of wrapping `WidgetContainer`, but the
rendered result is meant to look identical — if the two ever visually diverge, that's a bug, not
an intentional difference.

---

## 3. Colors (ground truth: `ThemeV2`, `lib/src/core/theme/theme_v2.dart`)

| Token | Hex | Usage |
|---|---|---|
| `ThemeV2.primary` | `#215C42` | Brand accent — card titles, icons, links, selected states |
| `ThemeV2.success` | `#2DBE63` | Gains, positive change, "safe" states |
| `ThemeV2.loss` | `#C64545` | Losses, negative change, "risky" states |
| `ThemeV2.warning` | `#D7AE42` | Neutral/caution states (sideways market, pending) |
| `ThemeV2.background` | `#F8F5EC` | Scaffold base (before gradient overlay) |
| `ThemeV2.surface` | `#FFFFFF` | Plain white surface — **not** the card standard, see §4 |
| `ThemeV2.surfaceDark` | `#E8E4D6` | Secondary surfaces, grid lines, range selectors |
| `ThemeV2.textPrimary` | `#202020` | Primary text (near-black) |
| `ThemeV2.textSecondary` | `#8B8B8B` | Secondary/muted text |
| `ThemeV2.divider` | `#ECECEC` | Declared divider token — largely bypassed in practice, see §2 |

### App-wide background gradient
Applied once in `main.dart` behind every Scaffold (which must set `backgroundColor: Colors.transparent`):

```dart
ThemeV2.backgroundGradient // top→bottom
LinearGradient(
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
  colors: [Color(0xFFFDFBF5), Color(0xFFC8BFA8)],
)
```

---

## 4. Why there are two theme files (and which one wins)

`ThemeV2` (`theme_v2.dart`) is the theme actually registered in `main.dart` (`theme: ThemeV2.lightTheme`).
`FomoShieldTheme` (`fomo_shield_theme.dart`) is a second, older token set ("Design Bible") that
declares its **own** `primary` (`#355C7D`, a blue — unused for the brand accent in practice),
its own success/loss (`#37B86B` / `#D04E4E`), and its own background (`#F6F1E7`). Notably,
`FomoShieldTheme.cardTitle()` itself defaults to `ThemeV2.primary`, not `FomoShieldTheme.primary`
— even the "canonical" file leaks a value from the other system.

**In practice**: use `FomoShieldTheme` only for its card *shell* geometry (`cardDecoration`,
`cardTitle()`, `cardRadius`) — use `ThemeV2` for every actual color. This split is real
technical debt, not a design choice worth defending; it's documented here so it's applied
consistently rather than "fixed" ad hoc one file at a time. Full inventory of where this causes
visible inconsistency (screens that use neither correctly) is in `docs/VISUAL_AUDIT.md`.

A third file, `app_theme.dart` ("Editorial Heritage"), is legacy and used only by
`monetization_modal.dart` + `premium_promo_overlay.dart` — do not use it for new work.

---

## 5. Brand CTA / Premium gradient ("dial" gradient)

Used for primary action buttons and every "PREMIUM" badge across Home, Market Clock, Stress
Test, Profile, and Portfolio widgets. Defined once in
`lib/src/features/market_clock/market_clock_dial.dart`:

```dart
const dialLight = Color(0xFF173A2E);   // gradient start (topLeft)
const dialMid   = Color(0xFF0F281F);   // used for the round dial face only
const dialDark  = Color(0xFF0A1B15);   // gradient end (bottomRight)
const dialBrassLight = Color(0xFFE8C468); // gold accent — text/icon on top of the gradient
```

Standard usage:

```dart
const List<Color> _brandGradient = [dialLight, dialDark];

BoxDecoration(
  gradient: const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: _brandGradient,
  ),
)
```

**Known duplication**: `const List<Color> _brandGradient = [dialLight, dialDark];` (or an
equivalent inline `colors: [dialLight, dialDark]`) is currently copy-pasted as a private constant
in at least 7 separate files (`stress_test_setup_screen.dart`, `stress_test_hub_screen.dart`,
`home/widgets/stress_test_widget.dart`, `home/widgets/shield_signal_widget.dart`,
`home/widgets/portfolio_widget.dart`, `portfolio/widgets/target_widget.dart`, `profile_screen.dart`)
instead of being exported once from `market_clock_dial.dart` and imported everywhere. Not fixed
as part of this pass — flagging it here so a future centralization doesn't come as a surprise.

---

## 6. Typography

| Use | Style |
|---|---|
| Card title (section header) | `FomoShieldTheme.cardTitle()` — Inter 13px, w700, letterSpacing 1.2, color `ThemeV2.primary` |
| Body text | Inter, size varies by context (13–16px seen in practice — no single enforced body style) |
| **Any numeric value** (price, P&L, %, balance, score) | `FontWeight.w600` (Semibold) — **never** `w800`/bold. See `interNums()` helper in `typography_helpers.dart`. This was a deliberate app-wide de-bolding pass (2026-07-25); if you see a bold number while editing a widget, fix it in place. |

---

## 7. Radii & spacing quick reference

| Token | Value | Source |
|---|---|---|
| Card radius (standard) | `22px` | `FomoShieldTheme.radius` |
| Small/badge radius | `14px` | `FomoShieldTheme.radiusSm` |
| Extra-large radius | `34px` | `FomoShieldTheme.radiusXl` |
| Gap between cards | `24px` | `FomoShieldTheme.cardGap` |
| Header padding | `fromLTRB(22, 14, 22, 14)` | confirmed pattern (§2) |
| Body padding | `all(16)` | confirmed pattern (§2) |
| Divider indent | `16px` both sides | confirmed pattern (§2) |

`ThemeV2` also declares its own radius scale (`radiusSmall: 12`, `radiusMedium: 18`,
`radiusLarge: 24`) and its own spacing scale (`space4`…`space40`) — per `VISUAL_AUDIT.md`,
`ThemeV2.space*` has **zero** call sites in the app. Don't reach for it; the confirmed pattern
above is what's actually in use.

---

## 8. Where this doc's guidance was confirmed

- Card shell, divider, and padding values: confirmed against `market_clock_phase_widget.dart`
  and `market_clock_timing_widget.dart` (both current, 2026-07-29).
- Numeric weight rule: confirmed 2026-07-25 (Portfolio widget pass).
- `ThemeV2` vs `FomoShieldTheme` split: confirmed against `docs/VISUAL_AUDIT.md` (2026-07-20)
  and re-verified directly against both theme files 2026-07-29 — still accurate.
- Brand gradient duplication count: re-grepped 2026-07-29.
