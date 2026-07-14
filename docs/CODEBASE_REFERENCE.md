# FOMO Shield — Codebase Reference

> Создано: 2026-07-09
> Назначение: Сводное описание ключевых файлов проекта для навигации и фиксов

---

## 1. Роутер / Навигация (GoRouter)

**Файл**: `lib/src/core/router/app_router.dart` (330 строк)

### Архитектура

Проект использует **GoRouter** с комбинацией полных экранов и ShellRoute для нижней навигации.

```dart
// Два навигатора:
static final _rootNavigatorKey = GlobalKey<NavigatorState>();    // полные экраны
static final _shellNavigatorKey = GlobalKey<NavigatorState>();   // shell + bottom nav
```

### Маршруты полных экранов (без bottom nav)

| Путь | Экран | Примечание |
|------|-------|-----------|
| `/` | `SplashScreen` | Точка входа |
| `/auth` | `AuthScreen` | Авторизация |
| `/disclaimer` | `DisclaimerScreen` | Дисклеймер |
| `/company/:symbol` | `CompanyDetailScreen` | Карточка компании |
| `/search` | `SearchScreen` | Поиск (standalone) |
| `/news` | `NewsScreen` | Новости (standalone) |
| `/stress-test/:id` | `StressTestScreen` | **Основной экран теста** |
| `/stress-test/:id/setup` | `StressTestSetupScreen` | Настройка теста |
| `/stress-test/:id/verdict` | `VerdictScreen` | Вердикт |
| `/stress-test/:id/analytics` | `StressTestAnalyticsScreen` | Аналитика |
| `/stress-test/:id/assets` | `AssetsScreen` | Список активов |
| `/stress-test/:id/stock/:symbol` | `StockDetailScreen` | Детали акции |
| `/stress-test/:id/stock/:symbol/order` | `OrderEntryScreen` | Ввод ордера |

### ShellRoute (с bottom nav)

| Путь | Экран | Tab |
|------|-------|-----|
| `/home` | `HomeScreen` | Shield |
| `/portfolio` | `PortfolioScreen` | Account Balance |
| `/profile` | `ProfileScreen` | Person |
| `/stress-test-hub` | `StressTestHubScreen` | Psychology |

### Критичное для гонки состояний

`StressTestScreen` получает `sessionId` через `pathParameters['id']` — это НЕ глобальный стейт, а изолированный параметр URL. Однако экран дополнительно использует глобальный `activeStressTestIdProvider` (см. раздел 2).

**Навигация между экранами**: `context.push()` / `context.go()` — при быстрой навигации два экрана могут существовать одновременно (анимация перехода), что создаёт гонку за `activeStressTestIdProvider`.

---

## 2. Стейт сессии / Engine

### 2.1 Основные файлы

| Файл | Строк | Назначение |
|------|-------|-----------|
| `lib/src/features/stress_test/stress_test_models.dart` | ~1100 | Data models: `StressTestSession`, `MarketScenario`, `CompanySpecEvent`, `EpochRecord`, `TraderPsychologyProfile` |
| `lib/src/features/stress_test/stress_test_engine.dart` | ~2922 | **Центральный engine**: `StressTestNotifier` (StateNotifier), симуляция цен, рулетка эпох, трейдинг, вердикт |
| `lib/src/features/stress_test/stress_test_screen.dart` | ~570 | UI экран теста (ConsumerStatefulWidget) |

### 2.2 Ключевые Provider'ы (конец `stress_test_engine.dart`)

```dart
// Главный StateNotifier — управляет ВСЕМИ сессиями
final stressTestProvider = StateNotifierProvider<StressTestNotifier, List<StressTestSession>>(...)

// ⚠️ ГЛОБАЛЬНЫЙ ID активной сессии — корень гонки состояний
final activeStressTestIdProvider = StateProvider<String?>((ref) => null);

// Реактивный провайдер текущей сессии
final activeStressTestSessionProvider = Provider<StressTestSession?>((ref) {
  final sessionId = ref.watch(activeStressTestIdProvider);
  ...
});

// Триггер обновления цен
final stressTestRefreshProvider = StateProvider<int>((ref) => 0);

// Per-session таймер (изолированный)
final timelineTickProvider = StateProvider.family<int, String>((ref, sessionId) => 0);

// Реактивная аналитика (не мутирует стейт при build)
final stressTestAnalyticsProvider = Provider<StressTestAnalytics>(...);

// Архив вердиктов
final verdictArchiveProvider = Provider<List<VerdictArchiveEntry>>(...)
```

### 2.3 Структура StressTestSession

Ключевая модель (поля описаны в `stress_test_models.dart`):

```
StressTestSession {
  // ── Базовые ──
  id, duration, startingCash, cash, holdings, trades, epochs, status
  createdAt, startedAt, completedAt

  // ── Scoring ──
  boughtAtPeakCount, soldAtBottomCount, maxSingleAssetAllocation
  blackSwanSurvived, hasExperiencedCatastrophe, catastropheCooldown

  // ── Симуляция ──
  companies (Map<String, CompanyStock>)
  psychologyProfile (TraderPsychologyProfile)
  currentPrices, basePrices, epochPriceRanges
  realizedPnl, priceHistory, explanationLog
  simulationSeed (int)

  // ── Sandbox ──
  activeShock (MarketShock?)
  correctionBounceSymbols, catastropheSurvivalRecorded
  diversificationBonusRecorded, soldDuringCatastrophe

  // ── Block 5: Per-Company Spec/Hype Events ──
  specEvents (List<CompanySpecEvent>)
  specEventCooldowns (Map<String, DateTime>)

  // ── Block 6: Casino Wall-Clock ──
  lastEpochRollAt (DateTime?)
  epochHistory (List<EpochRecord>)

  // ── Dev-поля (runtime, не в JSON) ──
  devMarketPhase, devMarketTemperature, devFatigue
  devCurrentTick, devFearIndex, devRecoveryProgress
  devVolatilityMultiplier, devNextEvent, devNextEventDays, devVolatilityLabel

  // ── Финансы ──
  totalValue, profitLoss, profitLossPercent
  unrealizedPnl, positionPnL, positionAllocation
  currentMaxAllocation, holdingCount, canExitInfinite
}
```

### 2.4 Сериализация и персистентность

```dart
// Ключи хранения (user-scoped через SharedPreferences):
String _sessionsKey(uid) => 'active_stress_test_sessions_$uid'  // тяжёлые активные сессии
String _archiveKey(uid) => 'stress_test_verdicts_history_$uid'  // лёгкий архив (FIFO 20)
String _adCounterKey(uid) => 'stress_test_ad_counter_$uid'
String _testCounterKey(uid) => 'stress_test_total_$uid'
String _openCounterKey(uid) => 'stress_test_open_$uid'
```

**Task 1.7 — Separated Cache Architecture**:
- Активные сессии хранятся отдельно от архива вердиктов
- При завершении теста сессия удаляется из активного кэша, вердикт — в архив (FIFO, макс 20)
- `_sessionToJson()` / `_sessionFromJson()` — полная сериализация (включая Block 5+6 поля)

### 2.5 _rollScenario — казино эпох

**Расположение**: `stress_test_engine.dart`, строка ~1387

```dart
MarketScenario _rollScenario(int cooldown, int declineStreak, {
  bool allowCatastrophe = true,
  Map<String, double>? currentWeights,
  required Random rng,
})
```

**Логика**:
1. **Anti-stuck Bear**: 2+ медвежьих эпохи подряд → Recovery (60%) или Bull (40%)
2. **Удалены hype/speculation**: `.where((s) => s != MarketScenario.hype && s != MarketScenario.speculation)` — больше не макро-сценарии
3. **Оставшиеся в рулетке**: bull(45), bear(20), recovery(5), blackSwan(2), crash(2)
4. **Anti-catastrophe**: cooldown или `!allowCatastrophe` → catastrophes удаляются из pool, их вес перераспределяется (60% recovery, 40% bull)
5. **Scenario Fatigue**: активные сценарии теряют вес (`_fatigueDecay = 0.02`), неактивные восстанавливаются (`_fatigueRecovery = 0.005`), пол = `_fatigueMinWeight = 5.0`

---

## 3. Рыночный движок (Market Engine)

**Файл**: `lib/src/features/stress_test/stress_test_engine.dart`

### 3.1 Архитектура симуляции цен

#### Матрица секторов × сценариев

Четыре внутренних макро-режима (`_MacroRegime`):

```dart
enum _MacroRegime { sideways, speculation, bull, bear }
```

**Маппинг MarketScenario → _MacroRegime** (`_toMacroRegime`):

| MarketScenario | _MacroRegime | Примечание |
|---------------|-------------|-----------|
| bull | bull | |
| bear, blackSwan, crash | bear | Все негативные → bear |
| recovery, hype, speculation | **sideways** | Block 5 fix |
| backSwan, crash (catastrophe) | bear | |

**Матрица дрифтов и волатильности** (`_masterMatrix`):

Каждый `_SectorParams` содержит `annualDrift` (μ) и `annualVolatility` (σ) — годовые значения.

Пример для BEAR-режима:
```
techSpeculative:    μ=-0.45, σ=0.50
consumerStaples:    μ=-0.05, σ=0.12
cyclicalConsumer:   μ=-0.30, σ=0.30
realEstateREIT:     μ=-0.15, σ=0.18  ← текущее выделение пользователя
etfBroadMarket:     μ=-0.22, σ=0.20
```

#### Geometric Brownian Motion (GBM)

**Формула**:
```
P_new = P_old × (1 + μ × dt + σ × ε × √dt + microNoise)
```

Где:
- `dt = 0.005` (200 тиков ≈ 1 симулированный период)
- `ε ~ Uniform(-0.5, +0.5)` — нулевое среднее, симметричное
- `microNoise = ±0.3%` — микро-флуктуации для нелинейности графика
- `_sqrtDt = sqrt(0.005)` — предвычислено

#### Clamp Drift (защита от выбросов)

Каждый макро-режим имеет границы per-tick изменения цены:

```dart
const _driftBounds = {
  _MacroRegime.sideways:   _DriftBounds(-0.025, +0.025, max×1.3,  min×0.6),
  _MacroRegime.speculation: _DriftBounds(-0.080, +0.080, max×2.5,  min×0.2),
  _MacroRegime.bull:       _DriftBounds(-0.050, +0.050, max×2.0,  min×0.3),
  _MacroRegime.bear:       _DriftBounds(-0.060, +0.030, max×1.3,  min×0.3),
};
```

Функция `_clampDrift(rawChange, regime)` ограничивает изменение цены за тик.

### 3.2 _simulateCurrentPrices — основной цикл

**Расположение**: `stress_test_engine.dart`, строки ~1711-2145

На каждый вызов (каждые 20 секунд по таймеру):

1. **Определение текущей эпохи**: `_getCurrentEpoch(session, now)` → `MarketEpoch`
2. **Block 6 — _recordEpochTransition**: запись смены эпохи в `epochHistory`
3. **Для каждого holding'а**:
   - `_getAssetSector(symbol)` → сектор
   - `_toMacroRegime(currentEpoch.scenario)` → макро-режим
   - `_masterMatrix[regime][sector]` → годовые μ, σ
   - GBM: `price *= (1 + μ×dt + σ×ε×√dt + microNoise)`
   - **Block 5 — _maybeFireSpecEvent**: 5% шанс на эпоху на компанию
   - **Block 5 — _applySpecEvents**: bell-shape амплитуда
   - **Коррекции**: случайные bounce-коррекции (зависимость от сценария)
   - **MarketShock**: экспоненциальный decay (half-life модель)
   - `_clampDrift(change, regime)` → границы
   - `_clampDrift` + `_getRegimeBounds` → финальные границы цены
4. **Explainable Simulation**: `_explainPriceChange()` → `TickExplanation`
5. **Обновление стейта**: новый `StressTestSession(...)` с новыми ценами

### 3.3 Explainable Cards («Why?»)

**Файл**: `lib/src/shared/widgets/explainable_card.dart` (виджет)

**Расчёт**: `_explainPriceChange()` в engine (строки ~1496-1568)

Факторы разложения:
1. **Market** (макро-рынок) — средний drift по секторам
2. **Sector** — отклонение drift сектора от среднего
3. **Company** — IPO bonus + spec/hype события
4. **News** — коррекции, катастрофы, восстановления
5. **Noise** — случайный шум

Сумма всех 5 факторов всегда = 100%.

### 3.4 CompanySpecEvent (Block 5)

**Модель**: `stress_test_models.dart`, класс `CompanySpecEvent`

Bell-shape формула:
```
amplitude = sin(π × t / duration) × peakAmplitude
```

- **Hype**: чистый bell, пик на 50%, симметричное затухание
- **Speculation**: bell с реверсом после 60% (умножается на -0.7)

Параметры:
- `_specEventChancePerEpoch = 0.05` (5% на эпоху на компанию)
- `_specEventCooldownEpochs = 3` (кулдаун после события)
- Gate: `_specEventCheckedEpochs: Set<String>` — предотвращает повторные проверки в одной эпохе

### 3.5 EpochRecord (Block 6)

**Модель**: `stress_test_models.dart`, класс `EpochRecord`

```dart
class EpochRecord {
  final int index;
  final MarketScenario scenario;
  final DateTime startedAt;    // реальное wall-clock время начала
  final DateTime? endedAt;     // null = эпоха активна
}
```

**`_recordEpochTransition()`**: вызывается каждый тик, закрывает предыдущую запись, открывает новую.

### 3.6 Catch-up механизм

При возврате пользователя в приложение:

1. `_catchUpAll()` → для всех активных сессий
2. `_catchUp(idx)` → `_computeMissedTicks(lastTick, now)` — количество пропущенных тиков
3. Цикл `_simulateCurrentPrices(idx)` × missedTicks
4. Ограничение: макс 20 тиков catch-up за раз

---

## 4. Psychology Meter

### 4.1 Основные файлы

| Файл | Назначение |
|------|-----------|
| `lib/src/shared/widgets/psychology_meter.dart` | Виджет + модель данных `PsychologyMeterData` |
| `lib/src/features/stress_test/stress_test_models.dart` | `TraderPsychologyProfile` — 4 субиндекса |
| `lib/src/shared/services/scoring_engine.dart` | **Другой** `fs_score` — финансовый (6 маркеров) |

### 4.2 Формула Psychology Meter (поведенческая)

```
fsScore = (compositeScore × 100).round().clamp(0, 100)

compositeScore = PR × 0.25 + D × 0.30 + P × 0.25 + SA × 0.20

где:
  PR = panicResistance   (0.0 … 1.0)
  D  = discipline        (0.0 … 1.0)
  P  = patience          (0.0 … 1.0)
  SA = strategyAdherence (0.0 … 1.0)
```

**Это ПОВЕДЕНЧЕСКАЯ метрика** — психология трейдера. НЕ финансовая.

### 4.3 Аккумуляторы субиндексов

Определены в `TraderPsychologyProfile` (models.dart):

| Метод | Эффект | Триггер |
|-------|--------|---------|
| `recordBuyPeak()` | D−0.08, P−0.05 | Покупка на пике |
| `recordSellBottom()` | PR−0.12, D−0.06 | Продажа на дне |
| `recordTradeExecuted()` | D−0.01, P−0.005 | Каждая сделка |
| `recordCatastropheSurvived()` | PR+0.15, P+0.10 | Пережил катастрофу без паники |
| `recordGoodDiversification()` | SA+0.03 | Аллокация ≤50% |
| `recordOverconcentration()` | SA−0.08 | Аллокация >80% |
| `recordProfitTaking()` | P+0.02, SA+0.01 | Прибыльная сделка |
| `recordLossCut()` | D−0.03, P−0.02 | Убыточная сделка |
| `recordBuyLow()` | D+0.15 | Покупка в fear/green зоне |
| `recordBuyHighFomo()` | D−0.20 | Покупка в greed/red зоне |
| `recordPanicSell()` | P−0.25, PR−0.25 | Паническая продажа в fear зоне |
| `recordHeldThroughCatastrophe()` | P+0.20 | Держал во время катастрофы |
| `recordStrategyDiversification(n)` | SA+1.0 (≥3) / SA+0.4 (1-2) | Диверсификация |
| `recordCashBuffer()` | SA+0.1 | Есть кэш-буфер |
| `recordTradeFrequencyDeduction(t, e)` | SA−((t/e−0.5)×0.2) | Частые сделки |

### 4.4 UI отображение

`PsychologyMeter` виджет (`psychology_meter.dart`):
- **FS Score Ring**: CustomPainter, кольцо 100×100, цвет по диапазонам:
  - ≥70: зелёный (positive)
  - 40-69: жёлтый (sideways)
  - <40: красный (negative)
- **4 Progress Bar'а**: Panic Resistance, Discipline, Patience, Strategy
- **Аналитика**: Trade Timing, Diversification, Activity (trades/day)

### 4.5 ДВА разных fsScore (ВАЖНО)

| Контекст | Файл | Формула | Природа |
|----------|------|---------|---------|
| **Psychology Meter** | `psychology_meter.dart` + `stress_test_models.dart` | `compositeScore` (4 субиндекса) | **Поведенческая** |
| **Scoring Engine** | `scoring_engine.dart` | 6 финансовых маркеров (P/E, Debt, Growth, Efficiency, Trend, Capital Return) | **Финансовая** |
| **Verdict** | `stress_test_engine.dart` `_calculateFsScore()` | PnL + penalties (panic, peak, concentration) | **Гибридная** |

**Путаница**: все три используют имя `fsScore`/`fs_score`, но это РАЗНЫЕ показатели. Рекомендовано переименовать Psychology Meter → `psychologyScore` или `traderScore`.

### 4.6 UI-лейблы для Psychology Meter

```dart
// _FsScoreRing._label:
≥80: "Excellent"
≥60: "Good"     ← Panic=90 попадёт сюда (compositeScore ≥ 0.6)
≥40: "Fair"
≥20: "Poor"
<20: "Critical"
```

### 4.7 Scoring Engine (НЕ Psychology Meter)

**Файл**: `lib/src/shared/services/scoring_engine.dart` (~180 строк)

Используется для **аналитики компаний** (не для stress test). 6 маркеров с весами:

| Маркер | Вес | Что измеряет |
|--------|-----|-------------|
| Valuation | 0.20 | P/E vs сектор |
| Financial Health | 0.20 | Debt/Equity, Current Ratio |
| Growth Potential | 0.20 | Revenue & EPS 5Y growth |
| Efficiency | 0.15 | Net Margin, ROE |
| Historical Trend | 0.15 | 5Y CAGR |
| Capital Return | 0.10 | Dividends, Buybacks |

Итог: `totalScore = Σ(marker_i × weight_i)`, с dividend trap penalty.

---

## 5. Ключевые точки для фиксов (Evening Package v1)

### 5.1 Гонка состояний (activeStressTestIdProvider)

**Файл**: `stress_test_screen.dart`

- `activeStressTestIdProvider` — глобальный `StateProvider<String?>` (один на всё приложение)
- При быстрой навигации два экрана бьются за него
- Текущее решение: синхронный try/catch в `initState` + self-healing `addPostFrameCallback` в `build()`
- **Это маскировка, не устранение.** Правильный фикс: Provider.family или отказ от глобального стейта

### 5.2 hype/speculation исключены из _rollScenario

**Файл**: `stress_test_engine.dart`, строка ~1393

```dart
final pool = MarketScenario.values
    .where((s) => s != MarketScenario.hype && s != MarketScenario.speculation)
    .toList();
```

### 5.3 MarketScenario.sideways — не существует

`MarketScenario` enum: `bull, bear, recovery, hype, speculation, blackSwan, crash`. **НЕТ** `sideways`.

`_MacroRegime` enum (внутренний): `sideways, speculation, bull, bear`. **ЕСТЬ** `sideways`.

Fallback в `EpochRecord.fromJson` = `MarketScenario.bull` (исправлено).

### 5.4 10+ конструкций StressTestSession без новых полей

При мутациях сессии (executeTrade, removeAsset, setDuration, etc.) НЕ передаются новые поля:
- `specEvents`, `specEventCooldowns`, `lastEpochRollAt`, `epochHistory`

Это значит, что при торговых операциях накопленные spec-эвенты и история эпох **теряются**. Нужно добавить эти поля во все конструкторы мутации.

---

## 6. Файловая карта (быстрый доступ)

| Путь | Строк | Ключевое содержимое |
|------|-------|-------------------|
| `lib/src/core/router/app_router.dart` | 330 | GoRouter, все маршруты, ShellRoute |
| `lib/src/features/stress_test/stress_test_models.dart` | ~1100 | StressTestSession, MarketScenario, CompanySpecEvent, EpochRecord, TraderPsychologyProfile, StressTestAnalytics |
| `lib/src/features/stress_test/stress_test_engine.dart` | ~2922 | StressTestNotifier, _rollScenario, _simulateCurrentPrices, GBM, _clampDrift, _toMacroRegime, _sessionToJson/FromJson, executeTrade, _catchUp, calculateVerdict, все Provider'ы |
| `lib/src/features/stress_test/stress_test_screen.dart` | ~570 | UI экрана, initState с гонкой, build с self-healing |
| `lib/src/shared/widgets/psychology_meter.dart` | ~400 | PsychologyMeterData, _FsScoreRing, _AnalyticsSection |
| `lib/src/shared/services/scoring_engine.dart` | ~180 | 6-маркерный FS Score (финансовый) |
| `lib/src/shared/guardian/guardian_data.dart` | ? | GuardianState, shieldBrightness, fromString |
