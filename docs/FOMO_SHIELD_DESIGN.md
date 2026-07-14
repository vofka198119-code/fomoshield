# FOMO Shield Dashboard — Дизайн-система

> Стресс-тест портфель: Trading 212-стиль дашборд с защитным информером.
> Дата: 2026-07-04

---

## 1. Глобальные токены (Theme)

| Токен | Значение | Назначение |
|-------|----------|------------|
| `AppBackground` | `#F8F5EC` | База (основной тон). Поверх неё наложен градиент: `#FDFBF5` → `#C8BFA8` |
| `CardBackground` | `#1E2022` | Глубокий тёмно-графитовый — карточки |
| `CardBorderRadius` | `16.0` | Скругление углов карточек |
| `TextPrimaryDark` | `#1F1F1F` | Основной текст на светлом фоне |
| `TextSecondaryDark` | `#7D7D7D` | Второстепенный текст, заголовки блоков |
| `BullColor` / `ShieldGreen` | `#5AA469` | Зелёный (бычий рынок, щит) |
| `BearColor` / `DangerRed` | `#B95A5A` | Красный (медвежий рынок) |
| `GlowGreen` | `#5AA469` (high alpha → 0) | Радиальное свечение за Beast |

### Типографика

- **Заголовки блоков** (например `MARKET PHASE`, `PSYCHOLOGY METER`): моноширинный/гротеск, `#7D7D7D` / `Colors.white38`, Caps Lock, мелкий кегль.
- **Главные цифры** (`+42`, `$22,413.89`): крупный, уверенный шрифт, хороший tracking.
- **Основной текст внутри карточек**: `#FFFFFF` или `Colors.white70`.

---

## 2. Layout hierarchy (Stress Test Portfolio Screen)

```
├── Dev Trace Bar (Admin only)
├── Header: App Title + Session Meta
├── Center Group (Row)
│   ├── [Left] Market Phase Card
│   │   ├── Bull icon (green)
│   │   ├── "Bull Market" (крупно)
│   │   └── "Optimism" (подстрочник)
│   ├── [Center] FOMO Shield Beast
│   │   ├── Radial gradient glow (#5AA469 → transparent)
│   │   ├── Beast character (центр)
│   │   │   └── Gold shield with "F" logo on chest
│   │   ├── Bottom: Glassmorphic oval badge
│   │   │   ├── "SHIELD STATUS" indicator
│   │   │   └── "STABLE" (green text)
│   │   └── Manifesto text below badge
│   │       └── "Market is in good shape. Stay disciplined."
│   └── [Right] Psychology Meter
│       ├── Donut Chart (4 sectors, rounded caps)
│       │   ├── Sector 1: Blue
│       │   ├── Sector 2: Green
│       │   ├── Sector 3: Teal
│       │   └── Sector 4: Orange
│       └── Center hole: "FS SCORE 66" + "Good"
│       └── 4 sub-index labels around chart
│           ├── Panic Resistance: 72
│           ├── Discipline: 65
│           ├── ...
│           └── ...
├── Middle Group (Row): Bottom Metrics Bar
│   ├── FEAR INDEX    | 34  | Moderate      | speedometer icon
│   ├── FATIGUE       | 48% | Medium        | fire icon
│   ├── RECOVERY      | 0%  | Inactive      | leaf icon
│   ├── VOLATILITY    | 1.2x| Normal        | pulse icon
│   └── NEXT EVENT    | IPO Window | 5 days  | calendar icon
└── Bottom: Portfolio Value Chart + Asset List
```

---

## 3. Молекула: Центральный информер (FOMO Shield Beast)

### Бэкграунд
- `RadialGradient` — мягкое изумрудно-зелёное свечение `#5AA469` → прозрачный
- Растворяется в кремовом `#F8F5EC`

### Сущность
- Персонаж (Beast) строго по центру
- На груди — золотой щит с логотипом `F`

### Нижняя плашка
- Овальный контейнер, `Glassmorphic` эффект (стекло)
- `SHIELD STATUS` — индикатор
- `STABLE` — мягкий зелёный текст
- Под плашкой: манифест в кавычках *“Market is in good shape. Stay disciplined.”*

---

## 4. Молекула: Левая панель (Рыночный контекст)

### Market Phase
- Тёмная карточка
- Иконка быка (зелёный)
- `Bull Market` (крупно)
- `Optimism` (состояние)

### Market Temperature
- Крупное число `+42` (зелёный)
- Горизонтальный слайдер-градусник:
  - Линейный градиент: красный → жёлтый → зелёный
  - Круглый светящийся ползунок (thumb) на отметке +42
- Внизу: `Warm`

---

## 5. Молекула: Правая панель (Psychology Meter)

- Donut Chart, 4 равных сектора
- Цвета: синий, зелёный, бирюзовый, оранжевый
- Углы секторов скруглены
- Центр: `FS SCORE 66` + вердикт `Good`
- 4 выноски суб-индексов с цветовыми маркерами:
  - Panic Resistance: 72
  - Discipline: 65
  - и т.д.

---

## 6. Нижняя подложка (Быстрые метрики)

Узкая горизонтальная тёмная полоса, 5 колонок, разделённых тонкими вертикальными сепараторами:

| # | Метрика | Значение | Статус | Иконка |
|---|---------|----------|--------|--------|
| 1 | FEAR INDEX | 34 | Moderate | speedometer |
| 2 | FATIGUE | 48% | Medium | fire |
| 3 | RECOVERY | 0% | Inactive | leaf |
| 4 | VOLATILITY | 1.2x | Normal | pulse |
| 5 | NEXT EVENT | IPO Window | In 5 days | calendar |

---

## 7. Data sources (предположения)

Поля берутся из `StressTestSession` / `MarketCycleManager`:

| Поле | Источник |
|------|----------|
| `Market Phase` | `session.devMarketPhase` / `MarketCycleManager._currentPhase` |
| `Temperature` | `session.devMarketTemperature` |
| `Fatigue` | `session.devFatigue` |
| `Current Tick` | `session.devCurrentTick` |
| `Fear Index` | Нужно добавить (производная от температуры/фазы?) |
| `Recovery` | Нужно добавить |
| `Volatility` | Из MarketCycleManager (коэффициент волатильности) |
| `Next Event` | Из календаря событий (IPO Window и т.д.) |
| `FS Score` | Композитный (суб-индексы Psychology Meter) |
| `Panic Resistance`, `Discipline` и др. | Композитные метрики (новые поля) |

---

## 8. Статус реализации

- [ ] Ничего не реализовано — только дизайн-спецификация
