# FOMO Shield Design Bible

> Полная дизайн-спецификация продукта — 12 частей.
> **Дата**: 2026-07-04
> **Статус**: ✅ Утверждено архитектором. Ожидание реализации.

---

## Содержание

| Часть | Тема | Описание |
|-------|------|----------|
| 1 | `variables.css` | Цветовая система, токены дизайна |
| 2 | `index.html` | Каркас главного экрана |
| 3 | `typography.css` | Типографика |
| 4 | `layout.css` | Геометрия + Hero-блок |
| 5 | `guardian.css` | State Machine Guardian |
| 6 | `guardian.svg` | Векторная архитектура |
| 7 | `cards.css` | Система карточек |
| 8 | `animations.css` | Анимации |
| 9 | Explainable Cards | Why Engine UI |
| 10 | Emotional UX | Guardian Intelligence |
| 11 | Product Constitution | 15 неприкосновенных принципов |
| 12 | Legacy & Future | Vision 2035 |

---

# ЧАСТЬ 1 — variables.css (глобальные токены)

**Правило**: никаких цветов напрямую — только через CSS-переменные.

```css
:root {
  /* BACKGROUND */
  --bg: #F6F1E7;
  --bg-card: #FFFDF9;
  --bg-secondary: #EFE8DA;

  /* TEXT */
  --text: #2B2A28;
  --text-light: #726B63;
  --text-muted: #9B958C;

  /* BRAND */
  --primary: #355C7D;
  --primary-dark: #24415B;
  --shield: #3F7CFF;

  /* MARKET */
  --bull: #43B97F;
  --bear: #C94D4D;
  --sideways: #D7AE42;
  --recovery: #7ACB7A;
  --volatility: #E88D2D;
  --blackSwan: #463D55;
  --crash: #962D2D;

  /* PSYCHOLOGY */
  --discipline: #3C8D60;
  --patience: #5078E1;
  --panic: #C74D4D;
  --strategy: #E0A42F;

  /* GUARDIAN */
  --guardian-body: #4E6D8D;
  --guardian-face: #F4F1E7;
  --guardian-shadow: #27415D;
  --guardian-eye: #6EE7FF;
  --guardian-glow: #A6D8FF;

  /* SUCCESS */
  --positive: #37B86B;
  --negative: #D04E4E;

  /* SHADOWS */
  --shadow-soft: 0 8px 20px rgba(0,0,0,.06);
  --shadow-medium: 0 12px 30px rgba(0,0,0,.10);
  --shadow-heavy: 0 18px 50px rgba(0,0,0,.18);

  /* BORDER */
  --border: #E8E1D5;

  /* RADIUS */
  --radius-xs: 8px;
  --radius-sm: 14px;
  --radius: 22px;
  --radius-xl: 34px;

  /* SPACING */
  --space-4: 4px;
  --space-8: 8px;
  --space-12: 12px;
  --space-16: 16px;
  --space-20: 20px;
  --space-24: 24px;
  --space-32: 32px;
  --space-40: 40px;

  /* FONT */
  --font-main: "Inter", sans-serif;

  /* FONT SIZES */
  --fs-title: 34px;
  --fs-h1: 28px;
  --fs-h2: 22px;
  --fs-card: 18px;
  --fs-body: 15px;
  --fs-small: 13px;
  --fs-caption: 11px;

  /* ANIMATION */
  --fast: 160ms;
  --normal: 260ms;
  --slow: 420ms;
  --breath: 4s;
  --blink: 7s;
  --pulse: 2.4s;
}
```

### Запрещено
- Чистый белый, чистый чёрный
- Кислотные цвета, Material Blue, серый Android
- Любые `color: #...` напрямую

### Разрешено
- Кремовые оттенки, тёплый серый
- Насыщенный синий, глубокий зелёный, тёплый красный

### Эмоциональная палитра
**Financial Times + Apple + Blizzard** = фин. серьёзность + эмоциональный персонаж

### Правило №1
Guardian — не украшение, а часть аналитики. Пользователь смотрит сначала на него, потом на цифры.

---

# ЧАСТЬ 2 — index.html (каркас главного экрана)

```html
<div class="app">
  <header class="topBar">
    <div class="brand">
      <span class="logoShield"></span>
      <span class="brandTitle">FOMO Shield</span>
    </div>
    <button class="settingsButton"></button>
  </header>

  <section class="marketStatusCard">
    <div class="marketLeft">
      <div class="marketPhase">BULL MARKET</div>
      <div class="marketTemperature">Calm • Optimistic</div>
    </div>
    <div class="marketRight">
      <div class="fearGreedGauge">71</div>
    </div>
  </section>

  <section class="guardianCard">
    <div class="guardianAura"></div>
    <div class="guardianCharacter"></div>
    <p class="guardianMessage">Stay disciplined.</p>
  </section>

  <section class="portfolioCard">...</section>
  <section class="shieldCard">...</section>
  <section class="psychologyCard">...</section>
  <section class="timelineCard">...</section>
  <section class="holdingsCard">...</section>
  <section class="analysisCard">...</section>
  <section class="verdictCard">...</section>
</div>
```

### Структура
1. **Header**: brand (лого + "FOMO Shield") + settings button
2. **Market Status**: фаза рынка + температура + Fear/Greed Gauge
3. **Guardian**: анимация + сообщение
4. **Portfolio**: заголовок, стоимость, Profit, canvas для кольца
5. **Shield Status**: круг + число + текст
6. **Psychology**: Discipline, Patience, Panic Resistance, Strategy
7. **Timeline**: Market Timeline
8. **Holdings**: список позиций
9. **Analysis**: "Why did portfolio move?"
10. **Verdict**: Guardian Verdict
11. **Bottom Nav**: Home, Stress Test, Portfolio, Analytics

### Правила агенту
- Guardian — центр экрана
- Не использовать Material Layout
- Карточки: 22px radius + soft shadow + тонкая граница
- gap 24px между карточками
- 32px между Guardian и Portfolio
- Внутри карточек минимум 20px воздуха

### Flutter Mapping
`Scaffold → SafeArea → GuardianWidget, ShieldScoreWidget, PsychologyWidget, PortfolioWidget, TimelineWidget, ListView.builder, ExplainableWidget, VerdictWidget`

### Ключевое
В центре не график, а психология инвестора.

---

# ЧАСТЬ 3 — typography.css (типографика)

```css
html {
  font-family: var(--font-main);
  font-size: 16px;
  color: var(--text);
  background: var(--bg);
}

.brandTitle { font-size: 28px; font-weight: 800; letter-spacing: -1px; }
.cardTitle { font-size: 15px; font-weight: 700; uppercase; color: var(--text-light); margin-bottom: 18px; }
.portfolioValue { font-size: 42px; font-weight: 800; line-height: 1; letter-spacing: -2px; }
.portfolioProfit { margin-top: 10px; font-size: 19px; font-weight: 700; }
.marketPhase { font-size: 18px; font-weight: 800; uppercase; letter-spacing: 1px; }
.marketTemperature { margin-top: 6px; font-size: 14px; font-weight: 500; color: var(--text-light); }
.guardianMessage { margin-top: 18px; font-size: 18px; font-weight: 600; line-height: 1.6; text-align: center; max-width: 320px; }
.shieldValue { font-size: 48px; font-weight: 900; letter-spacing: -2px; }
.shieldText { margin-top: 6px; font-size: 16px; font-weight: 600; color: var(--text-light); }
.psychologyItem { font-size: 15px; font-weight: 600; }
.holdingSymbol { font-size: 20px; font-weight: 800; }
.holdingCompany { font-size: 14px; }
.holdingValue { font-size: 20px; font-weight: 700; }
.holdingPercent { font-size: 15px; font-weight: 700; }
.timelineDate { font-size: 12px; font-weight: 600; }
.timelineTitle { font-size: 16px; font-weight: 700; }
.timelineText { font-size: 14px; }
.verdictText { font-size: 17px; line-height: 1.8; font-weight: 500; }
.analysisTitle { font-size: 16px; font-weight: 700; }
.analysisBody { font-size: 14px; }
```

### Правила
- Числа: `tabular-nums`, `tnum`
- Инвестор не читает, а сканирует взглядом — экран считывается за 3-4 сек
- Сумма портфеля — основным цветом текста, изменение (+/-) — зелёным/красным
- Не красить всё в зелёный/красный

---

# ЧАСТЬ 4 — layout.css (геометрия и компоновка)

> **Архитектурное правило**: Воздух — это не пустое место. Воздух помогает мозгу быстрее понимать информацию.

```css
.app { max-width: 430px; flex-direction: column; gap: 24px; padding: 24px; }
```

### Карточки
- bg: var(--bg-card)
- radius: var(--radius)
- border: 1px solid var(--border)
- shadow: var(--shadow-soft)
- padding: 22px
- hover: translateY(-3px) + shadow-medium

### Guardian card
- padding-top: 34px, padding-bottom: 30px
- flex column, center
- aura: 250×250, circle, margin-bottom 16px

### Bottom nav
- Sticky bottom, blur backdrop, radius 24px

### Правила геометрии
1. Никогда не растягивать карточки на всю ширину — ощущение бумаги на столе
2. Воздух: между карточками 24px, внутри 22px, вокруг Guardian 32px, заголовок-контент 18px
3. Карточки никогда не прилипают друг к другу
4. Всё имеет скругления (даже графики, кнопки, индикаторы)
5. Тень почти незаметная — человек не видит, но ощущает

### 🔥 Ключевое архитектурное решение
**Объединить Market Status + Guardian в единый Hero-блок:**

```
┌──────────────────────┐
│    BULL MARKET       │
│  Calm • Optimistic   │
│                      │
│      Guardian        │
│                      │
│ "Stay disciplined."  │
└──────────────────────┘
```

Под Hero: Portfolio, Shield Score, Psychology, Holdings, Timeline, Analysis, Verdict.

Это визитная карточка FOMO Shield.

---

# ЧАСТЬ 5 — guardian.css (архитектура состояний Guardian)

### Архитектурное правило
- **У Guardian нет рта** — эмоции передаются только через глаза, брови и щит
- Guardian — **State Machine**: `GuardianWidget(state: MarketPhase)`
- Состояния: `Bull | Sideways | Bear | Volatility | BlackSwan | Crash | Recovery`

### Компоненты Guardian
| Компонент | Описание | Поведение |
|-----------|----------|-----------|
| body | Тело (голова+торс), единая фигура без швов | Дыхание |
| horns | Рога | Меняют свечение |
| eyes | Глаза (sclera+iris+pupil+highlight) | Моргание, направление взгляда |
| pupils | Зрачки | Двигаются независимо |
| brows | Брови | Угол наклона (спокойствие/тревога) |
| shield | Щит | Размер, яркость, позиция |
| aura | Аура вокруг | Цвет, интенсивность, радиус |
| shadow | Тень | Глубина, размытие |

### Реакции на действия пользователя
- `panicSell`: Guardian опускает взгляд на 2 секунды
- `boughtOnHype`: наклон головы ("Ты уверен?")
- `followsStrategy`: плавное синее свечение несколько секунд
- `heldDrawdown`: щит +15% яркости
- `highFSScore`: Guardian +3% роста, щит увеличивается, аура насыщеннее

### 🚫 Запрещено
- Смена выражений лица (нет рта)
- Вращение Guardian или щита
- Прыжки, быстрые покачивания
- Хаотичное мерцание
- Эффекты "новогодней ёлки"

---

# ЧАСТЬ 6 — guardian.svg (векторная архитектура)

### Параметры полотна
- `viewBox="0 0 512 512"`, центр композиции X=256, Y=260
- Всегда квадрат, никаких других размеров

### Component Tree (30+ named parts)
```
guardianRoot
├── aura
├── shadow
├── body (240×235, форма капли, без острых углов)
│   ├── bodyGradient
│   ├── bodyShadow
│   └── bodyHighlight
├── leftHorn / rightHorn (высота 56px, ширина 28px, угол ±18°)
├── leftEar / rightEar
├── face (голова НЕ отделяется от тела — единая фигура)
├── leftEye / rightEye (диаметр 40px, расстояние 54px)
│   ├── sclera
│   ├── iris
│   ├── pupil (15px, двигается независимо)
│   └── highlight (7px)
├── leftBrow / rightBrow
├── shield (180×150, ~42% Guardian)
│   ├── shieldBody
│   ├── shieldGradient
│   ├── shieldBorder
│   ├── shieldHighlight
│   ├── shieldGlow
│   └── shieldLogo
└── particles (8 частиц, 2–6px, медленно двигаются)
```

### Состояния
- **Bull**: +25% glow, глаза широкие, брови приподняты
- **Sideways**: почти без движения, спокойное дыхание
- **Bear**: брови ниже, щит темнее, глаза слегка сужены
- **Volatility**: пульсация ауры, лёгкое дрожание щита
- **BlackSwan**: фиолетовое свечение, трещины на щите
- **Crash**: щит 60% тела, красная дымка, глаза прикрыты
- **Recovery**: трещины исчезают, медленный возврат цвета

### Эстетика
Apple × Pixar × GitHub/Discord — гладкие кривые, никакой мультяшности.
Каждая часть — отдельный объект для Flutter-анимации.

---

# ЧАСТЬ 7 — cards.css (система карточек)

> **Архитектурное правило**: Карточка — это не контейнер. Карточка — это отдельная глава истории пользователя.

### Глобальный `.card`
- border-radius: 24px, padding: 24px
- border: 1px solid var(--border)
- box-shadow: var(--shadow-soft)
- hover: translateY(-3px) + shadow-medium
- `::before`: верхняя полоса 5px, градиент #6FA7D6 → #4E6D8D, opacity 0.12

### Типы карточек
| Класс | Назначение | Особенности |
|-------|-----------|-------------|
| `.heroCard` | Hero-блок | padding 34px, min-height 360px, центрированный |
| `.portfolioCard` | Портфель | gap 18px, chart 170px с градиентом |
| `.shieldCard` | Щит | conic-gradient ring, padding 10px, inner circle |
| `.psychologyCard` | Психология | progress bar 12px, radius 999px |
| `.holdings` | Позиции | icon 46×46, radius 14px |
| `.analysisItem` | Аналитика | radius 18px, фон rgba(110,170,255,.05) |
| `.timelineItem` | Таймлайн | вертикальная линия ::after, точки ::before |
| `.verdictCard` | Вердикт | градиентный фон, цитата 18px w600 |
| `.badge` | Бейдж | pill-форма 999px, состояния bull/bear/sideways/crash |

### Философия карточек
- Каждая карточка = один вопрос пользователя
- **Explainable Simulation**: Analysis с разбивкой вкладов (рынок, сектор, новости, волатильность)
- **Verdict**: как вывод главы книги, спокойный совет
- Фундамент: **интерактивный наставник, а не симулятор биржи**

---

# ЧАСТЬ 8 — animations.css (анимации)

> **Архитектурное правило**: Анимация никогда не должна говорить "Посмотри на меня!". Она должна говорить "Я помогу тебе понять происходящее."

### Токены времени
`--fast:180ms; --normal:320ms; --slow:650ms; --breath:5.5s; --pulse:2.6s; --blink:5s;`

### Анимации
| Анимация | Назначение | Длительность |
|----------|-----------|-------------|
| `cardAppear` | Появление карточек | 0.45s |
| `guardianBreath` | Дыхание Guardian | 5.5s |
| `shieldPulse` | Пульсация щита | 2.6s |
| `auraGlow` | Свечение ауры | 4s |
| `blink` | Моргание глаз | 5s |
| `panicShake` | Тревога | 0.5s |
| `successRise` | Успех | 0.8s |
| `fearGlow` | Красное свечение | 1.2s |
| `particleFloat` | Парение частиц | 3s |
| `chartGrow` | Рост графика | 0.6s |
| `valueFlashPositive/Negative` | Вспышка изменения | 0.4s |

### Поведение Guardian по анимациям
- **Bull Market**: guardianBreath + auraGlow (голубое), blink каждые 5s
- **Crash**: panicShake + fearGlow + shieldPulse (красный), брови нахмурены
- **Sideways**: guardianBreath только, почти без движений
- **Recovery**: переход crash → спокойствие за 3s, трещины исчезают
- **Volatility**: shieldPulse ускоренный (1.8s), aura мерцает

---

# ЧАСТЬ 9 — Explainable Cards (Why Engine UI)

> **Главное правило**: Приложение должно ответить "Почему?" раньше, чем пользователь успеет задать этот вопрос.

### Философия
- Большинство приложений: `Apple +3.28%` — конец.
- FOMO Shield: `Apple +3.28%` → Почему? 46% Market, 27% Sector, 18% News, 9% Noise

### Структура карточки
```
┌────────────────────────────────────┐
│          WHY TODAY?                │
│      Apple +3.28%                  │
│ ████████████ 46% Market            │
│ ████████     27% Sector            │
│ █████        18% News              │
│ ██            9% Noise             │
│ Market remained optimistic today.  │
│ Tech sector outperformed.          │
└────────────────────────────────────┘
```

### Цветовая схема факторов
| Фактор | Цвет | Код |
|--------|------|-----|
| Market | Blue | #6FA7D6 |
| Sector | Green | #77C88A |
| Company | Orange | #F0B04F |
| News | Purple | #8A76D6 |
| Noise | Grey | #BFB9AE |

### Flutter-компоненты
- `WhyCard(symbol, TickExplanation)` — точка входа
- Внутри: `Column(ExplanationBars(), ExplanationText(), MarketPhase())`
- Бар: кастомный, не ProgressIndicator — высота 20px, conic-gradient
- Показывать только **Top 3 фактора** + Noise
- Экран вызывается кнопкой "Why?" рядом с каждым изменением цены
- Guardian комментирует после каждого объяснения (макс 1 строка)

---

# ЧАСТЬ 10 — Emotional UX & Guardian Intelligence

> **Главное правило**: Мы не обучаем акциям. Мы обучаем принимать решения.

### Guardian никогда не оценивает человека
- ❌ "You were wrong" / "Bad decision" / "Poor investor"
- ✅ "Fear became stronger than your strategy today."
- ✅ "Momentum looked attractive today. Remember to separate excitement from opportunity."

### Guardian не даёт советов Buy/Sell/Hold
- ❌ "Buy this dip" / "Sell now"
- ✅ "Today's market rewarded patience."
- ✅ "Strong emotions often appear after strong trends."

### Guardian всегда говорит спокойно
- ❌ "WARNING! DANGER! CRASH! SELL NOW!"
- ✅ "The market is experiencing exceptional stress. Focus on your long-term process."

### Guardian имеет память
- Помнит прошлые решения пользователя
- Связывает события: прошлое поведение → текущий результат

### Модуль GuardianIntelligenceEngine
- `guardian_engine.dart` — центральный модуль
- 300+ сообщений в библиотеке (разбиты по состояниям рынка + действиям)
- Выбор фразы: MarketState + UserAction + HistoryContext → финальная фраза
- max 2 строки на экране

### Специальные события
- **50 стресс-тестов**: Guardian отмечает прогресс
- **100 стресс-тестов**: особое сообщение
- **1 год использования**: "You've been training for a year..."

### Экран завершения стресс-теста
1. Guardian (финальное состояние)
2. Щит (анимация завершения)
3. Вердикт Guardian (1-2 предложения)
4. FS Score
5. Главный урок ("What mattered most?")
6. Кнопка "Continue Learning"

---

# ЧАСТЬ 11 — Product Constitution

> **Этот документ нельзя воспринимать как пожелания.**
> Это конституция проекта. Любая новая функция должна соответствовать этим принципам.
> Если противоречит — она не попадает в продукт.

### I. Главная миссия
FOMO Shield создаётся не для того, чтобы помогать выбирать акции. Он создаётся для того, чтобы помогать людям принимать более спокойные инвестиционные решения.

### II. Мы не конкурируем с брокерами
Мы строим **Тренажёр инвестиционного мышления.** Не TradingView, не Bloomberg, не брокерское приложение.

### III. Каждая цифра должна отвечать на вопрос "Почему?"
Если пользователь видит `-18%`, рядом должен быть ответ: *Почему произошло именно это?*

### IV. Пользователь не должен бояться ошибок
Самая ценная ошибка — та, которая произошла в симуляции.

### V. Guardian никогда не унижает пользователя
Guardian — не судья, не преподаватель, не начальник. Guardian — спокойный проводник.

### VI. Интерфейс не должен создавать FOMO
Запрещено: мигающие уведомления, кричащие предупреждения, таймеры "успей купить", элементы давления.

### VII. Обучение через опыт
Каждый стресс-тест — глава книги. Каждый вердикт — вывод главы.

### VIII. Explainable First
Любая механика обязана отвечать: 1) Что произошло? 2) Почему? 3) Что может понять пользователь?

### IX. Минимализм выше количества
Лучше 3 понятных показателя, чем 30 сложных коэффициентов.

### X. Guardian — зеркало дисциплины
Guardian отражает: состояние рынка + психологическую устойчивость + историю решений + опыт.

### XI. FOMO Shield должен стать ненужным
Идеальный пользователь однажды удалит приложение, потому что оно выполнило свою задачу.

### XII. Правило "через пять лет"
*Будет ли эта функция полезна через 5 лет?* Если нет — это временная мода.

### XIII. Никаких манипуляций
Приложение никогда не должно: удерживать пользователя искусственно, эксплуатировать страх.

### XIV. Успех измеряется не временем в приложении
Считать: сколько ошибок удалось избежать, насколько вырос FS Score.

### XV. Последняя мысль
Если однажды пользователь скажет: *"Я больше не открываю приложение каждый день. Теперь я спокойно отношусь к просадкам"* — значит, FOMO Shield достиг своей цели.

### Финальное слово
> **Мы не продаём надежду на быстрые деньги. Мы помогаем людям выработать спокойствие, которое остаётся с ними даже тогда, когда приложение уже больше не нужно.**

---

# ЧАСТЬ 12 — Legacy & Future (Vision 2035)

> **Этот документ запрещено менять под тренды. Его можно дополнять. Но нельзя менять философию.**

### 1. Через год
Guardian помогает пользователю увидеть собственные привычки. Не рынок. А самого себя.

### 2. Через три года
FOMO Shield становится **Личным журналом инвестиционного опыта.**

### 3. Через пять лет
Экран "My Journey" показывает эволюцию FS Score. Человек видит не прибыль — он видит, как изменился он сам.

### 4. Guardian взрослеет вместе с владельцем
Нет уровней. Нет опыта. Есть только **зрелость.** В начале щит почти не светится. Через годы — становится спокойнее. Не ярче. Спокойнее.

### 5. Настоящий график приложения
Не доходность, а изменение дисциплины. Discipline, Fear Resistance, Patience.

### 6. Главный экран будущего
Home: Guardian → Today's Reflection → Portfolio → Discipline → Why? → Journey → Lessons → History. Нет слова "Trading".

### 7. Настоящий смысл Explainable Engine
Он объясняет связь между рынком → действиями → результатом.

### 8. Самая дорогая информация
"Ты уже четвёртый кризис подряд не продаёшь в панике."

### 9. Guardian никогда не становится ИИ
Guardian — не ChatGPT. Не ассистент. Не собеседник. Он — символ.

### 10. Если однажды появится AI
AI объясняет. Guardian наблюдает. AI анализирует. Guardian напоминает. AI умеет разговаривать. Guardian умеет молчать.

### 11. После 100 стресс-тестов
"You no longer fear the market. You understand it." Без медалей. Без конфетти.

### 12. Финальная страница — "Ready"
> *"You came here to understand the market. Along the way, you learned to understand yourself. That was always the real goal."*

Кнопка: **Continue Investing** (не Start, не Trade, не Next).

---

## Заключение архитектора

FOMO Shield трудно будет копировать не потому, что сложно написать движок, а потому, что сложно воспроизвести идею, в которой:

- Guardian — не украшение, а отражение дисциплины
- Explainable Engine отвечает на "Почему?" вместо сухих цифр
- Стресс-тест оценивает не доходность, а поведение
- Конечная цель — чтобы пользователь однажды перестал нуждаться в приложении

> **Лучший пользователь FOMO Shield — тот, кто однажды удалит приложение, потому что оно выполнило свою работу.**
