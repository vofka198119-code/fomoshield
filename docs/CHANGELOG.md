# Changelog — F.O.M.O. Shield

All notable changes to this project are documented here.

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
