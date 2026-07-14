# FOMO Shield — Design Tokens Reference
>
> Рабочий справочник токенов для правок UI.
> Источник: ThemeV2 (`theme_v2.dart`), `guardian_data.dart`, существующий код.
>
> **Обновлён**: 2026-07-14

---

## 1. ЦВЕТА (из ThemeV2)

| Токен | HEX | Где используется |
|-------|-----|-----------------|
| `background` | `#F8F5EC` | Фон экранов |
| `surface` | `#FFFFFF` | Карточки |
| `primary` | `#355C7D` | Акцентный текст, иконки |
| `primaryBg` | `#EBF0F5` | Фон акцентных зон |
| `textPrimary` | `#1B365D` | Основной текст |
| `textSecondary` | `#6B7B8D` | Второстепенный текст |
| `textDim` | `#9AA5B1` | Приглушённый |
| `divider` | `#E8E5DF` | Разделители |
| `success` | `#2D8C4A` | Рост, прибыль |
| `loss` | `#C0392B` | Падение, убыток |
| `warning` | `#D4A843` | Предупреждения |

---

## 2. ГРАДИЕНТЫ

### Фоновый градиент (применяется ВЕЗДЕ)
- Источник: `ThemeV2.backgroundGradient` в `theme_v2.dart`
- Наносится: через `Container` с `BoxDecoration(gradient: ThemeV2.backgroundGradient)` в `main.dart`
- Где используется: **все экраны** — Home, Stress Test, Auth, Disclaimer, Profile, Settings, History, News, Scanner, Search, Portfolio, Assets, Company Detail, Events, Watchlist, Order Entry, Splash, Monetization
- **Правило**: все Scaffold и AppBar должны иметь `backgroundColor: Colors.transparent`, чтобы не перекрывать этот градиент
- **Состав**:
  ```dart
  LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFFFDFBF5), // верх — 3 тона светлее #F8F5EC
      Color(0xFFC8BFA8), // низ — средне-тёмный бежевыйее #F8F5EC + серый отлив
    ],
  );
  ```

### Guardian RadialGradient (тень)
```dart
RadialGradient(
  center: Alignment.center,
  radius: 0.8,
  colors: [
    Colors.black.withValues(alpha: 0.35),
    Colors.black.withValues(alpha: 0.15),
    Colors.transparent,
  ],
  stops: [0.0, 0.4, 1.0],
)
```

### Карточка — верхняя декоративная полоса (CardFrame)
```dart
LinearGradient(
  colors: [Color(0xFF6FA7D6), Color(0xFF4E6D8D)],
  // opacity: 0.12 на всём градиенте
)
// Размер: 5px высота, полная ширина карточки
```

---

## 3. КАРТОЧКИ

| Параметр | Значение |
|----------|---------|
| `borderRadius` | `24px` |
| `padding` | `24px` (все стороны) |
| `boxShadow` | `0 2px 12px rgba(0,0,0,0.04)` — cardShadow |
| `color` | `surface` (#FFFFFF) |
| Декоративная полоса | `5px` высота, градиент (см. выше), opacity 0.12 |

### Варианты padding
| Тип карточки | padding |
|-------------|---------|
| Стандартная | 24px |
| Chart Card | 20px |
| Summary Card | 24px + левая полоса 5px |

---

## 4. РАДИУСЫ

| Элемент | Радиус |
|---------|--------|
| `radiusSmall` | `8px` |
| `radiusMedium` | `14px` |
| `radiusLarge` | `24px` |
| `radiusXL` | `34px` |

---

## 5. ТЕНИ

| Токен | Значение |
|-------|---------|
| `cardShadow` | `0 2px 12px rgba(0,0,0,0.04)` |
| `mediumShadow` | `0 4px 24px rgba(0,0,0,0.08)` |
| `heavyShadow` | `0 8px 40px rgba(0,0,0,0.12)` |

---

## 6. ТИПОГРАФИКА

| Стиль | font | size | weight |
|-------|------|------|--------|
| `displayXL` | Playfair Display | 32 | w800 |
| `display` | Playfair Display | 24 | w700 |
| `h1` | Inter | 22 | w700 |
| `h2` | Inter | 18 | w700 |
| `body` | Inter | 15 | w400 |
| `caption` | Inter | 13 | w500 |
| `small` | Inter | 11 | w400 |
| `section` | Inter | 13 | w700 / UPPERCASE / letterSpacing: 1.2 |

---

## 7. ЦВЕТА ФАКТОРОВ (Explainable Cards)

| Фактор | HEX |
|--------|-----|
| Market | `#6FA7D6` |
| Sector | `#77C88A` |
| Company | `#F0B04F` |
| News | `#8A76D6` |
| Noise | `#BFB9AE` |

---

## 8. ЦВЕТА ФАЗ GUARDIAN (щит + аура)

| Состояние | HEX щита | HEX ауры |
|-----------|---------|---------|
| Bull | `#2D8C4A` | `#2D8C4A` |
| Sideways | `#8B9DAF` | `#8B9DAF` |
| Bear | `#C0392B` | `#C0392B` |
| Volatility | `#D4A843` | `#D4A843` |
| BlackSwan | `#6C3483` | `#6C3483` |
| Crash | `#922B21` | `#922B21` |
| Recovery | `#1ABC9C` | `#1ABC9C` |

---

## 9. АНИМАЦИИ

| Токен | ms |
|-------|-----|
| `animFast` | 180 |
| `animNormal` | 320 |
| `animSlow` | 650 |
| `animCardAppear` | 450 |
| `animChartGrow` | 600 |
| `animValueFlash` | 400 |
| `animSuccessRise` | 800 |
| `animFearGlow` | 1200 |

---

## 10. ОТСТУПЫ

| Элемент | Значение |
|---------|---------|
| Горизонтальный отступ экрана | `16px` |
| Зазор между карточками | `12px` |
| AppBar height | `64px` |
| AppBar leading padding left | `22px` |
