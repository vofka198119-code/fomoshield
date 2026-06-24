# F.O.M.O. Shield — Architecture Guide

> **Version:** 1.0.0  
> **Last updated:** 2026-06-23  
> **Project root:** `D:\Projects\scanco`

---

## Table of Contents

1. [Project Overview](#1-project-overview)
2. [Tech Stack](#2-tech-stack)
3. [Directory Structure](#3-directory-structure)
4. [Routing & Navigation](#4-routing--navigation)
5. [State Management (Riverpod)](#5-state-management-riverpod)
6. [Data Flow](#6-data-flow)
7. [Services Layer](#7-services-layer)
8. [Theme & Design System](#8-theme--design-system)
9. [Widget Architecture](#9-widget-architecture)
10. [Persistence Layer](#10-persistence-layer)
11. [Authentication Flow](#11-authentication-flow)
12. [API Integration (Finnhub)](#12-api-integration-finnhub)
13. [Caching Strategy](#13-caching-strategy)

---

## 1. Project Overview

**F.O.M.O. Shield** is a mobile-first Flutter application for stock market research and portfolio management. It provides:

- **Shield Signal** — A proprietary Fear/Greed style market sentiment indicator
- **Watchlist** — Track your favorite companies with real-time quotes
- **Portfolio Management** — Mock portfolios with P&L tracking
- **Company Research** — Deep-dive with FS Score, financial metrics, price charts, news, and company history
- **Earnings Calendar** — Upcoming earnings and dividends for watched companies
- **QR Scanner** — Scan stock tickers (future feature)

### Target Users

- Retail investors looking for a modern, intuitive stock research tool
- Users who want a **Revolut-style** clean UI experience

---

## 2. Tech Stack

| Layer | Technology | Version |
|---|---|---|
| **Framework** | Flutter | 3.12.1 |
| **Language** | Dart | 3.x |
| **State Management** | Riverpod | ^2.6.1 |
| **Routing** | GoRouter | ^15.1.2 |
| **HTTP Client** | Dio | ^5.8.0+1 |
| **Backend / Auth** | Supabase | ^2.8.3 |
| **Local Storage** | SharedPreferences | ^2.3.0 |
| **Secure Storage** | FlutterSecureStorage | ^9.2.4 |
| **Charts** | fl_chart | ^0.70.2 |
| **Fonts** | Google Fonts (Inter) | ^6.2.1 |
| **Environment** | flutter_dotenv | ^5.2.1 |
| **Scanner** | mobile_scanner | ^6.0.0 |
| **SVG** | flutter_svg | ^2.1.0 |
| **URL Launch** | url_launcher | ^6.3.1 |
| **Intl** | intl | ^0.20.2 |

---

## 3. Directory Structure

```
lib/
├── main.dart                          # App entry point, providers + router setup
└── src/
    ├── core/
    │   ├── router/
    │   │   └── app_router.dart        # GoRouter config, 11 routes + ShellRoute
    │   ├── supabase/
    │   │   ├── supabase_client.dart   # Supabase URL + anon key singleton
    │   │   └── supabase_providers.dart # authState, currentUser, isSetupComplete
    │   ├── theme/
    │   │   └── app_theme.dart         # Dark theme, colors, text styles, components
    │   └── utils/
    │       └── constants.dart         # Finnhub config, cache TTL, thresholds
    ├── features/
    │   ├── auth/                      # Sign In / Sign Up screen
    │   ├── company_detail/            # Full company research (5 tabs)
    │   ├── disclaimer/                # Legal disclaimer + versioning
    │   ├── history/                   # Company history (Wikipedia)
    │   ├── home/                      # Main dashboard with widget grid
    │   │   ├── screens/               # Full-screen pages (watchlist, events)
    │   │   └── widgets/               # Home card widgets (shield, markets, etc.)
    │   ├── news/                      # Market news feed
    │   ├── portfolio/                 # Portfolio management
    │   ├── profile/                   # User profile + sign out
    │   ├── scanner/                   # QR/barcode scanner
    │   ├── search/                    # Company search
    │   ├── settings/                  # App settings
    │   └── splash/                    # Animated splash screen
    ├── l10n/                          # (empty — not yet localized)
    └── shared/
        ├── services/
        │   ├── finnhub_service.dart   # Finnhub API client (Dio + cache)
        │   ├── history_service.dart   # Wikipedia REST client
        │   └── scoring_engine.dart    # FS Score algorithm
        └── widgets/
            └── widget_container.dart  # Reusable Revolut-style card
```

---

## 4. Routing & Navigation

### Route Map

| Path | Screen | Auth Required | Has Bottom Nav |
|---|---|---|---|
| `/` | SplashScreen | — | ❌ |
| `/auth` | AuthScreen | — | ❌ |
| `/disclaimer` | DisclaimerScreen | ✅ | ❌ |
| `/company/:symbol` | CompanyDetailScreen | ✅ | ❌ |
| `/watchlist` | WatchlistFullScreen | ✅ | ❌ |
| `/events` | EventsFullScreen | ✅ | ❌ |
| `/home` | HomeScreen | ✅ | ✅ |
| `/search` | SearchScreen | ✅ | ✅ |
| `/portfolio` | PortfolioScreen | ✅ | ✅ |
| `/news` | NewsScreen | ✅ | ✅ |
| `/profile` | ProfileScreen | ✅ | ✅ |

### Navigation Flow

```
Splash (/) ──► Auth (/auth) ──► Disclaimer (/disclaimer) ──► Home (/home)
                  │                                                     │
                  └── (auto-login with Remember Me) ────────────────────┘
                                                              │
                                                    ┌────────┴────────┐
                                                    │  Bottom Nav     │
                                                    │  Home / Search  │
                                                    │  Portfolio /    │
                                                    │  News / Profile │
                                                    └─────────────────┘
```

### Router Implementation

- **GoRouter** with `ShellRoute` for bottom navigation
- `_rootNavigatorKey` for full-screen routes (auth, splash, company detail)
- `_shellNavigatorKey` for tab routes (home, search, portfolio, news, profile)
- Routes are **not** nested under Shell — splash/auth/disclaimer/company/watchlist/events are at root level

---

## 5. State Management (Riverpod)

### Provider Categories

| Category | Riverpod Type | Purpose |
|---|---|---|
| **Async Data** | `FutureProvider<T>` | API calls with loading/error/data states |
| **Parameterized** | `FutureProvider.family<T, Arg>` | Per-symbol/per-portfolio data |
| **Mutable State** | `StateNotifierProvider<T, S>` | Watchlist, portfolios, auth, search |
| **Simple State** | `StateProvider<T>` | Loading flags, active selections |
| **Singletons** | `Provider<T>` | Services, caches, debouncers |
| **Streaming** | `StreamProvider<T>` | Supabase auth state |

### Provider Map (complete)

#### Core Providers (`supabase_providers.dart`)
| Provider | Returns | Description |
|---|---|---|
| `authStateProvider` | `AuthState` | Stream of Supabase auth changes |
| `currentUserProvider` | `User?` | Currently signed-in user |
| `authLoadingProvider` | `bool` | Loading indicator for auth ops |
| `authErrorProvider` | `String?` | Auth error message |
| `isSetupCompleteProvider` | `bool` | Reads `is_setup_complete` from DB |

#### Auth Providers (`auth_providers.dart`)
| Provider | Returns | Description |
|---|---|---|
| `hasSupabaseSessionProvider` | `bool` | Checks active Supabase session |
| `rememberMeProvider` | `RememberMeCredentials?` | Stored email+password (SecureStorage) |
| `savedCredentialsProvider` | `RememberMeCredentials?` | Async read from SecureStorage |
| `isLoggedInProvider` | `bool` | SharedPreferences flag |

#### Home Providers (`home_providers.dart`)
| Provider | Returns | Description |
|---|---|---|
| `watchlistSymbolsProvider` | `List<String>` | Watchlist tickers (managed by WatchlistNotifier) |
| `shieldSignalProvider` | `ShieldSignal` | Market sentiment (SPY quote + Fear/Greed) |
| `marketIndicesProvider` | `List<MarketIndex>` | SPY, QQQ, DIA quotes |
| `watchlistQuotesProvider` | `List<Map>` | Real-time quotes for watched tickers |
| `calendarEventsProvider` | `List<CalendarEvent>` | Earnings + dividends for watched tickers |
| `marketCacheProvider` | `MarketCache` | 4-hour cache for market indices |
| `eventsCacheProvider` | `EventsCache` | 12-hour cache for calendar events |
| `watchlistQuoteCacheProvider` | `WatchlistQuoteCache` | Per-symbol 4h cache |
| `debouncerProvider` | `Debouncer` | 1-second debounce timer |

#### Company Detail Providers
| Provider | Returns | Description |
|---|---|---|
| `companyCacheProvider` | `CompanyCacheManager` | Per-ticker 4h cache manager |
| `companyDetailProvider(symbol)` | `Map` | Profile + metrics + score from Finnhub |

#### Search Providers
| Provider | Returns | Description |
|---|---|---|
| `searchProvider` | `SearchState` | ChangeNotifier with query debounce |

#### Portfolio Providers
| Provider | Returns | Description |
|---|---|---|
| `portfoliosProvider` | `List<Portfolio>` | User-created mock portfolios |
| `activePortfolioIdProvider` | `String?` | Currently selected portfolio |
| `portfolioPerformanceProvider(id)` | `PortfolioPerformance` | P&L calculation |

#### Disclaimer Providers
| Provider | Returns | Description |
|---|---|---|
| `remoteVersionsProvider` | `DocumentVersions` | Server-side disclaimer versions |
| `acceptedVersionsProvider` | `DocumentVersions?` | Locally accepted versions |
| `versionsMatchProvider` | `bool` | Are all versions accepted? |
| `isDisclaimerAcceptedProvider` | `bool` | Shortcut: versionsMatch + geoCheck |
| `geoCheckProvider` | `GeoCheckResult` | Country-based eligibility |

---

## 6. Data Flow

```
┌─────────────────────────────────────────────────────────────────────┐
│                        PRESENTATION LAYER                            │
│                                                                      │
│  Widget (ref.watch(provider))  ←  Loading/Error/Data pattern        │
│       │                                                             │
│       │ ref.watch()                                                  │
│       ▼                                                             │
├─────────────────────────────────────────────────────────────────────┤
│                        PROVIDER LAYER (Riverpod)                     │
│                                                                      │
│  ┌─────────────────────────────────────────────────────────────┐    │
│  │  FutureProvider.async                                  │    │
│  │   1. Check cache → if valid, return cache               │    │
│  │   2. Call FinnhubService.method()                       │    │
│  │   3. Store in cache + return                            │    │
│  └─────────────────────────────────────────────────────────────┘    │
│                                                                      │
│  ┌─────────────────────────────────────────────────────────────┐    │
│  │  StateNotifierProvider                                        │    │
│  │   • Read/write from SharedPreferences                       │    │
│  │   • Notify listeners on mutation                             │    │
│  └─────────────────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────────────────┘
       │
       │ Services called via Provider
       ▼
┌─────────────────────────────────────────────────────────────────────┐
│                         SERVICE LAYER                                │
│                                                                      │
│  FinnhubService     HistoryService     ScoringEngine                 │
│  (Dio + cache)      (Dio)              (pure Dart)                  │
│       │                  │                  │                        │
│       ▼                  ▼                  ▼                        │
│  finnhub.io         en.wikipedia.org   6-marker FS Score            │
│  supabase.co                                             │
└─────────────────────────────────────────────────────────────────────┘
```

### Key Pattern: Cache-before-API

```dart
final data = ref.watch(someFutureProvider);
// 1. Provider checks in-memory cache (4h TTL)
// 2. If valid → return cached data
// 3. If expired/missing → call API → cache → return
// 4. Manual refresh via invalidate()
```

---

## 7. Services Layer

### FinnhubService (`shared/services/finnhub_service.dart`)

Singleton service wrapping the **Finnhub API** (`https://finnhub.io/api/v1`).

| Method | Endpoint | Description |
|---|---|---|
| `search(query)` | `/search` | Company search with dedup |
| `companyProfile(symbol)` | `/stock/profile2` | Company profile |
| `quote(symbol)` | `/quote` | Real-time stock quote |
| `previousTradingDayQuote(symbol)` | `/quote` | Current price + change |
| `metrics(symbol)` | `/stock/metric` | Financial metrics |
| `companyNews(symbol, {days})` | `/company-news` | Company-specific news |
| `generalNews()` | `/news` | General market news |
| `indexQuote(symbol)` | `/quote` | Index price (SPY, QQQ, DIA) |
| `earningsCalendar({symbol, daysAhead})` | `/calendar/earnings` | Earnings events |
| `dividendsCalendar({symbol, daysAhead})` | `/calendar/dividends` | Dividend events |
| `earningsSurprises(symbol)` | `/earnings-surprises` | Historical surprises |
| `candles(symbol, resolution, from, to)` | `/stock/candle` | OHLCV chart data |

**Key implementation details:**
- Dio interceptor logs all requests/responses/errors
- `handler.next()` MUST be called in all 3 interceptor callbacks (onRequest, onResponse, onError) — missing this was the root cause of infinite loading
- Rate-limit safe: sequential fetches with 1s delay between symbols

### ScoringEngine (`shared/services/scoring_engine.dart`)

Pure Dart utility class that computes the **FS Score** (0-100).

| Marker | Weight | Description |
|---|---|---|
| Valuation | 0.20 | P/E, P/B, P/S ratios |
| Financial Health | 0.20 | D/E ratio, current ratio |
| Growth Potential | 0.20 | Revenue/EPS growth |
| Efficiency | 0.15 | ROE, profit margins |
| Historical Trend | 0.15 | Price momentum |
| Capital Return | 0.10 | Dividend yield, buybacks |

Dividend trap detection applies a penalty when yield > 8%.

### HistoryService (`shared/services/history_service.dart`)

Fetches company history from **Wikipedia** via REST API.

- `fetchSummary(companyName)` → first paragraph of Wikipedia article
- `parseHistory(wikiData)` → `CompanyHistory` model (name, summary, year, founders)

---

## 8. Theme & Design System

### Colors

| Token | Hex | Usage |
|---|---|---|
| `background` | `#0B1018` | Scaffold background (deep navy-black) |
| `card` | `#141B26` | Card/surface background |
| `cardDark` | `#1A2235` | Darker variant (nav bar, tabs) |
| `accentBlue` | `#00B4D8` | Primary accent, buttons, links |
| `dangerRed` | `#FF4D6A` | Errors, destructive actions |
| `textDim` | `#6B7A99` | Secondary/subtitle/helper text |
| `shieldGreen` | `#2ECC71` | Positive: price up, good score |
| `shieldYellow` | `#F1C40F` | Neutral: market flat |
| `shieldRed` | `#E74C3C` | Negative: price down, bad score |

### Text Styles

- **Font:** Inter (via `google_fonts`)
- `titleLarge`: 22px, bold, white
- `titleMedium`: 18px, semi-bold, white
- `bodyLarge`: 16px, normal, white
- `bodyMedium`: 14px, normal, 70% white
- `bodySmall`: 12px, normal, `textDim`
- Cards use uppercase labels (e.g. "WATCHLIST") with 13px, w700, `textDim`, letter-spacing 1.2

### Component Styles

| Component | Styling |
|---|---|
| **AppBar** | Centered title, transparent bg, no elevation |
| **Card** | `card` bg, 20px radius (`WidgetContainer`) or 12px radius (default Card) |
| **Bottom Nav** | `cardDark` bg, `accentBlue` selected icon, fixed type |
| **ElevatedButton** | Full-width, 52px height, 12px radius, `accentBlue` bg |
| **Input field** | Filled `card` bg, 12px radius, blue focus border |

---

## 9. Widget Architecture

### WidgetContainer (Revolut-style card)

A reusable card component used across all home screen widgets.

```
┌─────────────────────────────────────┐
│  TITLE                    ›         │  ← Header (InkWell, tap navigates)
├─────────────────────────────────────┤
│  Item 1                             │  ← Child widget
├ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─│  ← Divider (indent: 16, endIndent: 16)
│  Item 2                             │
├─────────────────────────────────────┤
│              Еще                    │  ← Footer button (hidden if ≤2 items)
└─────────────────────────────────────┘
```

**Parameters:**
| Param | Type | Default | Description |
|---|---|---|---|
| `title` | `String` | required | Uppercase label |
| `onTap` | `VoidCallback` | required | Tap handler (header + footer) |
| `children` | `List<Widget>` | `[]` | Content items |
| `footerText` | `String` | `'Еще'` | Footer button label |
| `showFooter` | `bool` | `true` | Auto-hide footer when ≤2 items |
| `emptyText` | `String?` | `null` | Centered fallback when empty |

### Home Screen Widgets

| Widget | File | Data Source | Show Footer? | Empty State |
|---|---|---|---|---|
| `ShieldSignalWidget` | `widgets/shield_signal_widget.dart` | `shieldSignalProvider` | — | Always visible |
| `MarketsWidget` | `widgets/markets_widget.dart` | `marketIndicesProvider` | — | Zero fallback |
| `WatchlistWidget` | `widgets/watchlist_widget.dart` | `watchlistQuotesProvider` | `>2 items` | `emptyText` |
| `UpcomingEventsWidget` | `widgets/upcoming_events_widget.dart` | `calendarEventsProvider` | `>2 items` | `emptyText` |

### Full Screen Pages

| Page | File | Content |
|---|---|---|
| `WatchlistFullScreen` | `screens/watchlist_full_screen.dart` | All companies, expandable cards, add (+) button |
| `EventsFullScreen` | `screens/events_full_screen.dart` | All events, expandable cards with EPS/amount details |

### Company Detail (5 tabs)

| Tab | Widget | Description |
|---|---|---|
| **Overview** | `_OverviewTab` | Business description, price chart (1M/6M/1Y/5Y/All), key stats |
| **FS Audit** | `_FsAuditTab` | FS Score gauge, radar chart, 6 marker details |
| **History** | `_HistoryTab` | Wikipedia company history |
| **News** | `_NewsTab` | Latest company news from Finnhub |
| **Add Portfolio** | `_AddPortfolioTab` | Buy/Sell transaction form |

---

## 10. Persistence Layer

### Storage Strategy

| Data | Storage | Key Format | TTL |
|---|---|---|---|
| Watchlist symbols | SharedPreferences | `watchlist_symbols` | Forever |
| Portfolios (JSON) | SharedPreferences | `portfolios` | Forever |
| is_logged_in flag | SharedPreferences | `is_logged_in` | Forever |
| Accepted disclaimers | SharedPreferences | `accepted_versions` | Forever |
| Saved credentials | FlutterSecureStorage | `saved_email` / `saved_password` | Until logout |
| Market data | In-memory (Riverpod) | `MarketCache` | 4 hours |
| Calendar events | In-memory (Riverpod) | `EventsCache` | 12 hours |
| Watchlist quotes | In-memory (Riverpod) | `WatchlistQuoteCache` | 4 hours (per symbol) |
| Company details | In-memory (Riverpod) | `CompanyCacheManager` | 4 hours (per ticker) |
| Supabase session | Supabase SDK | — | Until logout/expiry |

### Cache Architecture

All caches follow the same pattern:

```dart
class MarketCache {
  Map<String, dynamic>? data;
  DateTime? timestamp;
  bool get isValid => timestamp != null && 
    DateTime.now().difference(timestamp!) < Duration(hours: 4);
}
```

Manual cache invalidation is triggered by the **refresh button** in the Home AppBar, calling `_onRefresh()` which invalidates all related providers.

---

## 11. Authentication Flow

### Flow Diagram

```
Splash (/)
  │
  ├─► Check savedCredentialsProvider (Remember Me)
  │    ├─► Have credentials → signInWithPassword()
  │    │    ├─► Success → check disclaimer → /home or /disclaimer
  │    │    └─► Error → clear credentials → show Start button
  │    │
  │    └─► No credentials → check Supabase session
  │         ├─► Has session → /home or /disclaimer
  │         └─► No session → wait 2.5s → /auth
  │
Auth (/auth)
  ├─► Sign In (email + password)
  ├─► Sign Up (email + password + confirm password)
  ├─► "Remember me" checkbox
  └─► Pre-check: before signUp, try signIn first
       ├─► Success → user already exists → show error
       └─► Error → proceed with signUp

Sign Out (/profile)
  ├─► Clear is_logged_in flag
  ├─► Clear saved credentials
  ├─► Supabase signOut()
  └─► Navigate directly to /auth (skip splash)
```

### Security Notes

- **PIN system**: Was removed in favor of Supabase auth only
- **Biometrics**: Removed (no local_auth dependency)
- **Remember Me**: Email + password encrypted in FlutterSecureStorage
- **Registration**: Pre-check prevents duplicate accounts

---

## 12. API Integration (Finnhub)

### Configuration

```env
FINNHUB_API_KEY=d8l3qgpr01qut1f8r240d8l3qgpr01qut1f8r24g
```

Base URL: `https://finnhub.io/api/v1`

### Rate Limiting

Finnhub free tier has rate limits. Mitigations:
- **4-hour cache** on all data endpoints
- **1-second delay** between sequential symbol fetches
- **Debouncer** (1s) on user interactions (search, navigation)

### Dio Interceptor

```dart
// Every request/response/error must call handler.next()
onRequest: (options, handler) { handler.next(options); ... }
onResponse: (response, handler) { handler.next(response); ... }
onError: (error, handler) { handler.next(error); ... }
```

**Critical:** Missing `handler.next()` in any callback causes the request to hang forever (infinite loading).

### Data Parsing Notes

- `/search` returns `{"count": N, "result": [...]}` — extract `result`
- `/calendar/earnings` returns `{"earningsCalendar": [...]}` — extract `earningsCalendar`
- `/quote` returns flat object with `c` (current), `d` (change), `dp` (percent), `h` (high), `l` (low), `o` (open), `pc` (prev close)
- All errors include `{"error": "..."}` field — checked before returning

---

## 13. Caching Strategy

### Cache TTL Summary

| Data | TTL | Cache Type | Invalidated By |
|---|---|---|---|
| Market indices | 4h | In-memory | Manual refresh |
| Watchlist quotes | 4h (per symbol) | In-memory | Manual refresh |
| Company details | 4h (per ticker) | In-memory | Auto-expiry |
| Calendar events | 12h | In-memory | Manual refresh |
| User watchlist | Forever | SharedPreferences | User edits |
| Portfolios | Forever | SharedPreferences | User edits |

### Manual Refresh

The Home screen AppBar has a **refresh button** (`Icons.refresh_rounded`) that:
1. Invalidates `marketCacheProvider`
2. Invalidates `eventsCacheProvider`
3. Invalidates `watchlistQuoteCacheProvider`
4. Calls `ref.invalidate(watchlistQuotesProvider)`
5. Calls `ref.invalidate(calendarEventsProvider)`

All providers then re-fetch fresh data from the API.

---

## Appendix: Recent UI Improvements (2026-06-23)

### WidgetContainer — 4 Micro-Improvements

| # | Change | Detail |
|---|---|---|
| 1 | **Dividers** | `Divider` now uses `indent: 16, endIndent: 16` instead of `Padding` wrapper |
| 2 | **Footer logic** | Added `showFooter` param — hidden when ≤2 children |
| 3 | **Splash effect** | Footer `InkWell` clips to bottom card corners via `borderRadius.only(bottomLeft: 20, bottomRight: 20)` |
| 4 | **Empty state** | Added `emptyText` param — shows centered muted text "Здесь пока ничего нет" when children empty |
