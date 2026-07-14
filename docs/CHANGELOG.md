# Changelog — F.O.M.O. Shield

All notable changes to this project are documented here.

---

## [1.1.0] — 2026-06-27

### Added

#### Order Engine (Full Trading System)
- **`lib/src/features/orders/order_model.dart`** — Central data model with enums:
  - `MarketSession` (regular / preMarket / afterHours / closed) — determines order eligibility
  - `OrderSide` (buy / sell)
  - `OrderType` (market / limit / stop / stopLimit) — Stop/Stop-Limit code kept, UI hidden
  - `OrderStatus` (pending / partiallyFilled / filled / cancelled / expired)
  - `Order` class with 13 fields, `copyWith()`, `toJson()`/`fromJson()`
  - `currentMarketSession()` helper — determines session from UTC time
- **`lib/src/features/orders/order_execution_service.dart`** — Pure execution engine:
  - `evaluateOrder()` — checks market session, applies order-type rules, returns fill result
  - `processPendingOrders()` — batch execution of all active orders
  - `canTradeInSession()` — per-type session eligibility
  - Spread multipliers: regular 1.0× / pre-market 1.5× / after-hours 1.3× / closed 2.0×
  - Partial fill simulation: 20% chance, 30–80% of remaining quantity
- **`lib/src/features/orders/order_provider.dart`** — Riverpod StateNotifier:
  - `placeOrder()` — Market orders execute immediately in open sessions; go to PENDING in closed sessions
  - `processPendingOrders()` — batch processing for all active orders
  - `cancelOrder()` — cancels active orders
  - Dual persistence: SharedPreferences (local) + Supabase JSONB (remote)
  - `loadFromSupabase()` — restores orders on login

#### Portfolio Order Entry Enhancements
- **Limit price input field**: Auto-filled at ±2% of current price (buy +2%, sell -2%), user-editable, validated before submission
- **Warning dialog for closed market**: `_showMarketClosedWarning()` — shown when placing Market order during closed session, with "Cancel" / "Place Order Anyway" options
- **Stop/Stop-Limit tabs hidden** in UI (code preserved for future activation)

#### Database
- **`docs/supabase_migration.sql`** — Added `orders JSONB NOT NULL DEFAULT '[]'::jsonb` column to `public.user_data` table

#### Tests
- **`test/services/order_execution_test.dart`** — 12 tests covering:
  - Market orders (immediate fill in regular, PENDING in closed)
  - Limit orders (buy/sell at/above/below limit price)
  - Batch processing (multiple orders evaluated together)
  - Market sessions (pre-market, after-hours, closed)
  - Real-world simulation (mixed order types with realistic prices)
  - All 12 tests passing ✅

### Changed

#### UserDataService
- `saveOrders()` method added — saves orders JSONB to Supabase
- `loadAll()` now includes `orders` field in the loaded data map

#### Supabase Schema
- `public.user_data` table extended with `orders JSONB` column

### Fixed

- Market orders no longer attempt immediate execution during closed market sessions — correctly placed as PENDING

---

## [1.0.0] — 2026-06-23

### Added

#### Authentication & Onboarding
- **Splash screen**: Fade-in animation (800ms), auto-navigation after 2.5s, increased logo to 132×132
- **Remember Me**: Email + password saved to FlutterSecureStorage, auto-login on app start
- **Pre-check registration**: Before `signUp`, tries `signInWithPassword` — if success, shows "already registered" error
- **Sign Out**: Full state cleanup — clears SecureStorage, SharedPreferences, Supabase session, navigates directly to `/auth`

#### Home Screen — Revolut-style Redesign
- **Widget grid**: Modular widgets via `_WidgetConfig` array (order, visibility)
- **Gradient header**: "F.O.M.O. SHIELD" with `ShaderMask` (white → cyan `#00BCD4`)
- **ShieldSignalWidget**: Accordion card with SPY price + Fear/Greed signal
- **MarketsWidget**: SPY, QQQ, DIA index cards with expandable details
- **WatchlistWidget**: Compact preview (first 2 items) with `WidgetContainer`
- **UpcomingEventsWidget**: Compact preview (first 2 events) with `WidgetContainer`

#### Full-Screen Pages
- **WatchlistFullScreen** (`/watchlist`): All companies, expandable cards, add button
- **EventsFullScreen** (`/events`): All events, expandable cards, hour badges (BMO/AMC/DMH)

#### Company Detail
- **FS Score**: 6-marker algorithm (0-100) with gauge + radar chart
- **Price charts**: fl_chart line chart with period selector (1M/6M/1Y/5Y/All)
- **Company cache**: Per-ticker 4-hour TTL in-memory cache
- **5 tabs**: Overview, FS Audit, History, News, Add Portfolio

#### Search
- **Debounced search**: 500ms debounce on input, 1s debounce on navigation
- **Bookmark icons**: Visual indicator for watched/unwatched companies

#### Data & API
- **Finnhub integration**: Quotes, search, profile, metrics, candles, news, earnings, dividends
- **Caching system**: 4h TTL for market/watchlist/company data, 12h for events
- **Rate-limit protection**: 1s delay between sequential symbol fetches
- **Dio interceptor**: Logging + error handling for all Finnhub API calls

#### Portfolio Management
- **Multiple portfolios**: Create, select, manage mock portfolios
- **Performance tracking**: Total value, P&L, invested, cash
- **Allocation chart**: fl_chart pie chart

#### UI Components
- **WidgetContainer**: Reusable Revolut-style card with header, dividers, footer
  - Dividers with `indent: 16, endIndent: 16`
  - `showFooter` parameter — hides "More" button when ≤2 items
  - `emptyText` parameter — shows centered muted fallback when empty
  - Footer InkWell with rounded bottom corners for splash effect

### Changed

#### Architecture
- **PIN system removed**: All PIN-related screens, providers, and routes deleted
- **Biometrics removed**: `local_auth` dependency deleted
- **Router refactored**: Added `/watchlist`, `/events` routes; removed `/pin-setup`, `/pin-verify`

#### Theme
- **Header gradient**: Changed from purple (`#8A2BE2`) to cyan (`#00BCD4`)
- **Card radius**: Widget cards use 20px radius (Revolut style)
- **Bottom nav**: `cardDark` background, `accentBlue` selected icon

#### Providers
- `auth_providers.dart`: Added `RememberMeNotifier`, removed PIN/biometrics
- `home_providers.dart`: Added shield signal, market indices, watchlist quotes, calendar events, caches
- `disclaimer_providers.dart`: Added `geoCheckProvider` for country-based eligibility

#### Services
- `finnhub_service.dart`: Complete rewrite with Dio interceptors, error checking, proper JSON parsing
  - **Critical fix**: Added `handler.next()` in all 3 interceptor callbacks (was missing → infinite loading)
  - `search()` now extracts `result` from response object
  - `earningsCalendar()` now extracts `earningsCalendar` from response object

### Fixed

- **Infinite loading** (root cause): Dio interceptor was missing `handler.next()` calls in onRequest, onResponse, onError — all three now call `handler.next()`
- **Android HTTP blocking**: Added `<uses-permission android:name="android.permission.INTERNET"/>` to `AndroidManifest.xml`
- **Search crash**: Finnhub `/search` returns object `{"count": N, "result": [...]}`, not array — fixed parsing
- **Earnings calendar crash**: Finnhub returns `{"earningsCalendar": [...]}` — fixed parsing
- **Race condition**: `isDisclaimerAcceptedProvider` now reads SharedPreferences directly
- **Empty watchlist visual**: Error states show fallback instead of infinite spinner
- **Markets error**: Error state shows zero fallback instead of infinite loader

### Removed

- `lib/src/features/auth/pin_setup_screen.dart`
- `lib/src/features/auth/pin_verify_screen.dart`
- `local_auth: ^3.0.1` dependency from `pubspec.yaml`
- All PIN-related routes and providers

### Security

- API key moved to `.env` (dotenv), `.env` added to `.gitignore`
- Sensitive credentials stored in `FlutterSecureStorage` (not SharedPreferences)
- Registration pre-check prevents duplicate account creation

---

## [0.9.0] — 2026-06-21

### Initial MVP

- Supabase authentication (email + password)
- Basic home screen with hardcoded data
- Disclaimer screen with version checking
- Basic company detail screen
- Search with mock data
- QR scanner (mobile_scanner)
- Settings screen
- Profile screen with Sign Out
- Initial dark theme
