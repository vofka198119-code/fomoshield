# FOMO Shield — Agent Instructions

> **Архитектор**: vofka198119@gmail.com
> **Проект**: ScanCo (FOMO Shield — тренажёр инвестиционного мышления)
> **Flutter SDK**: `D:\flutter\bin\flutter.bat`
> **Важно**: Никогда не запускать `flutter build`, `flutter run` — только сообщить, что изменения готовы.

---

## 📜 ВЕРХОВНЫЙ ЗАКОН — FOMO Shield Design Bible

**Ты ОБЯЗАН действовать согласно ТЗ из `docs/FOMO_SHIELD_DESIGN_BIBLE.md`.**

Этот документ — конституция проекта. Любая новая функция, любой UI-компонент, любая строка кода проверяются на соответствие этому документу перед реализацией.

### 12 частей Design Bible (краткий обзор)

| Часть | Содержание |
|-------|-----------|
| 1 | `variables.css` — цветовая система, токены (--bg: #F6F1E7, --primary: #355C7D, --shield: #3F7CFF) |
| 2 | `index.html` — каркас: 11 секций, Guardian в центре |
| 3 | `typography.css` — сканирование за 3-4 сек, tabular-nums |
| 4 | `layout.css` — max-width 430px, gap 24px, Hero-блок Market+Guardian |
| 5 | `guardian.css` — 7 состояний, нет рта, State Machine |
| 6 | `guardian.svg` — 30+ named parts, viewBox 512×512 |
| 7 | `cards.css` — 9 типов карточек, radius 24px, padding 24px |
| 8 | `animations.css` — 11 анимаций, duration tokens |
| 9 | Explainable Cards — 5 факторов (Market #6FA7D6, Sector #77C88A, Company #F0B04F, News #8A76D6, Noise #BFB9AE) |
| 10 | Emotional UX — GuardianIntelligenceEngine, 300+ сообщений, память |
| 11 | Product Constitution — 15 immutable принципов |
| 12 | Vision 2035 — "App should become unnecessary" |

### 🔥 Главные архитектурные решения

1. **Guardian** — центр экрана, не график. Нет рта. 7 состояний (Bull/Sideways/Bear/Volatility/BlackSwan/Crash/Recovery)
2. **Hero-блок**: Market Status + Guardian объединены вертикально
3. **Воздух** — инструмент дизайна. Карточки никогда не касаются друг друга
4. **Нет чистого белого, чёрного, Material Blue** — только кремовая палитра #F6F1E7
5. **App-цель**: стать ненужным — пользователь учится дисциплине и удаляет приложение
6. **Никогда** не использовать compact currency (`4.67K`, `1.5M`), только полный формат `$X,XXX.XX`
7. **Explainable First** — каждая цифра отвечает на "Почему?" через 5 факторов

### Product Constitution (15 принципов — нельзя нарушать)

- I. Миссия: помогать принимать спокойные решения, не выбирать акции
- II. Не конкурировать с брокерами — это тренажёр мышления
- III. Каждая цифра отвечает на "Почему?"
- IV. Не бояться ошибок — они ценны в симуляции
- V. Guardian не унижает, не судит, не даёт Buy/Sell/Hold
- VI. Интерфейс не создаёт FOMO — запрещены мигания, таймеры, давление
- VII. Обучение через опыт (стресс-тест = глава книги)
- VIII. Explainable First: Что → Почему → Что понял пользователь
- IX. 3 понятных показателя лучше 30 коэффициентов
- X. Guardian = зеркало: рынок + психология + история + опыт
- XI. Приложение должно стать ненужным
- XII. Правило "через 5 лет": будет ли функция полезна через 5 лет?
- XIII. Никаких манипуляций
- XIV. Успех = сколько ошибок избежал, не время в приложении
- XV. Цель: "Я спокойно отношусь к просадкам"

---

## 🛠 КРИТИЧЕСКИЕ ПРАВИЛА РАБОТЫ

### SDK и пути (ТОЛЬКО D:\)
- **Flutter**: `D:\flutter\bin\flutter.bat` — использовать ВСЕГДА, не `flutter` из PATH
- **Android SDK**: `D:\android-sdk` или `D:\Android`
- **Java JDK**: `D:\Java` или `D:\jdk`
- **Никогда** не искать SDK на `C:\`

### Запрещено делать
- ❌ **Не запускать** `flutter build`, `flutter run`, установку на телефон
- ❌ Не писать код без уточняющих вопросов пользователю
- ❌ Не использовать compact currency formatting (`4.67K`, `1.5M`)
- ❌ Не использовать Material Blue, чистый белый/чёрный
- ❌ Не давать Guardian рот, не делать его мультяшным

### Форматирование валют (100% обязательно)
```dart
NumberFormat.currency(locale: 'en_US', symbol: r'$').format(v)  // со знаком $
NumberFormat('#,##0.00', 'en_US').format(v)                      // без знака $
```

### Tier-условия (всегда проверять)
```dart
final tier = ref.watch(subscriptionTierProvider);
final isPremium = tier == SubscriptionTier.premium || tier == SubscriptionTier.admin;
```
- Premium/Admin — полный доступ, Free — есть ограничения
- Всегда предусматривать поведение для free tier

### Анализ перед кодом
ПЕРЕД любой правкой или написанием кода:
1. Задать уточняющие вопросы пользователю
2. Полностью понять требования
3. Проверить соответствие Design Bible и Product Constitution
4. Только потом писать код

---

## 📁 КЛЮЧЕВЫЕ ФАЙЛЫ ПРОЕКТА

| Файл | Назначение |
|------|-----------|
| `docs/FOMO_SHIELD_DESIGN_BIBLE.md` | **Главное ТЗ** — 12 частей дизайн-системы |
| `lib/main.dart` | Точка входа |
| `lib/src/` | Исходный код (фичи, виджеты, провайдеры) |
| `lib/src/features/` | Экраны: stress_test, portfolio, assets, orders, etc. |
| `test/` | Тесты: 45 engine + 20 portfolio math + 12 order + 6 widget = 83 |

### Техстек
- **State Management**: Riverpod (StateNotifierProvider, StateProvider)
- **Routing**: GoRouter
- **Хранилище**: SharedPreferences + Supabase
- **Дизайн-система**: Editoral Heritage (#F5F2EB bg, #1B365D accent, #4A5D23 stressAccent)

---

## 💾 ПАМЯТЬ СЕССИИ

Полный архив всех 12 частей Design Bible (434 строки) хранится в session memory:
`/memories/session/fomo_shield_design_parts.md`

При открытии новой сессии — прочти этот файл и `docs/FOMO_SHIELD_DESIGN_BIBLE.md` для получения полного контекста.
