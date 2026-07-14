// ---------------------------------------------------------------------------
// Market Cycle Manager — Lifecycle Phase Engine (standalone)
// ---------------------------------------------------------------------------
// Изолированный класс управления фазами рынка. НЕ зависит от UI и других
// экосистем приложения. 1 тик = 1 неделя.
//
// Жизненный цикл: 7 фаз с настраиваемыми параметрами длительности, дрифта
// и волатильности. Управляющие переменные: marketTemperature (-90..+90),
// phaseFatigue (0.0..1.0), consecutiveBear.
// ---------------------------------------------------------------------------

import 'dart:math';

// ═══════════════════════════════════════════════════════════════════════════
// 1. Модель фазы рынка
// ═══════════════════════════════════════════════════════════════════════════

/// Семь фаз рыночного цикла.
enum MarketPhase {
  bull,
  sideways,
  bear,
  volatility,
  blackSwan,
  crash,
  recovery,
}

/// Конфигурация одной фазы: минимальная/максимальная длительность (недель),
/// базовый дрифт и базовая волатильность за 1 недельный тик.
class MarketPhaseConfig {
  final int minWeeks;
  final int maxWeeks;
  final double baseDrift;      // недельный drift (0.005 = +0.5%)
  final double baseVolatility; // недельная volatility (0.015 = 1.5%)

  const MarketPhaseConfig({
    required this.minWeeks,
    required this.maxWeeks,
    required this.baseDrift,
    required this.baseVolatility,
  });
}

// ═══════════════════════════════════════════════════════════════════════════
// 2. Параметры фаз
// ═══════════════════════════════════════════════════════════════════════════

const Map<MarketPhase, MarketPhaseConfig> _phaseConfigs = {
  MarketPhase.bull: MarketPhaseConfig(
    minWeeks: 4,
    maxWeeks: 24,
    baseDrift: 0.005,
    baseVolatility: 0.015,
  ),
  MarketPhase.sideways: MarketPhaseConfig(
    minWeeks: 2,
    maxWeeks: 30,
    baseDrift: 0.0005,
    baseVolatility: 0.006,
  ),
  MarketPhase.bear: MarketPhaseConfig(
    minWeeks: 4,
    maxWeeks: 20,
    baseDrift: -0.004,
    baseVolatility: 0.02,
  ),
  MarketPhase.volatility: MarketPhaseConfig(
    minWeeks: 2,
    maxWeeks: 8,
    baseDrift: 0.001,
    baseVolatility: 0.045,
  ),
  MarketPhase.blackSwan: MarketPhaseConfig(
    minWeeks: 1,
    maxWeeks: 2,
    baseDrift: -0.04,
    baseVolatility: 0.08,
  ),
  MarketPhase.crash: MarketPhaseConfig(
    minWeeks: 1,
    maxWeeks: 4,
    baseDrift: -0.025,
    baseVolatility: 0.06,
  ),
  MarketPhase.recovery: MarketPhaseConfig(
    minWeeks: 2,
    maxWeeks: 16,
    baseDrift: 0.003,
    baseVolatility: 0.018,
  ),
};

// ═══════════════════════════════════════════════════════════════════════════
// 3. Матрица переходов (from → to → weight)
// ═══════════════════════════════════════════════════════════════════════════
// weight = 0 — переход невозможен.
// Чем больше weight, тем выше шанс перехода при смене фазы.

const Map<MarketPhase, Map<MarketPhase, int>> _transitionWeights = {
  MarketPhase.bull: {
    MarketPhase.bull: 0,
    MarketPhase.sideways: 40,
    MarketPhase.bear: 20,
    MarketPhase.volatility: 30,
    MarketPhase.blackSwan: 5,
    MarketPhase.crash: 5,
    MarketPhase.recovery: 0,
  },
  MarketPhase.sideways: {
    MarketPhase.bull: 40,
    MarketPhase.sideways: 0,
    MarketPhase.bear: 30,
    MarketPhase.volatility: 25,
    MarketPhase.blackSwan: 3,
    MarketPhase.crash: 2,
    MarketPhase.recovery: 0,
  },
  MarketPhase.bear: {
    MarketPhase.bull: 10,
    MarketPhase.sideways: 15,
    MarketPhase.bear: 0,
    MarketPhase.volatility: 30,
    MarketPhase.blackSwan: 25,
    MarketPhase.crash: 20,
    MarketPhase.recovery: 0,
  },
  MarketPhase.volatility: {
    MarketPhase.bull: 25,
    MarketPhase.sideways: 20,
    MarketPhase.bear: 30,
    MarketPhase.volatility: 0,
    MarketPhase.blackSwan: 15,
    MarketPhase.crash: 10,
    MarketPhase.recovery: 0,
  },
  MarketPhase.blackSwan: {
    MarketPhase.crash: 50,
    MarketPhase.recovery: 50,
    MarketPhase.bull: 0,
    MarketPhase.sideways: 0,
    MarketPhase.bear: 0,
    MarketPhase.volatility: 0,
    MarketPhase.blackSwan: 0,
  },
  MarketPhase.crash: {
    MarketPhase.recovery: 70,
    MarketPhase.sideways: 20,
    MarketPhase.bull: 10,
    MarketPhase.bear: 0,
    MarketPhase.volatility: 0,
    MarketPhase.blackSwan: 0,
    MarketPhase.crash: 0,
  },
  MarketPhase.recovery: {
    MarketPhase.bull: 45,
    MarketPhase.sideways: 35,
    MarketPhase.volatility: 20,
    MarketPhase.bear: 0,
    MarketPhase.blackSwan: 0,
    MarketPhase.crash: 0,
    MarketPhase.recovery: 0,
  },
};

// ═══════════════════════════════════════════════════════════════════════════
// 4. Market Cycle Manager
// ═══════════════════════════════════════════════════════════════════════════

/// Управляет жизненным циклом рыночных фаз.
/// Изолирован: никакой зависимости от Flutter/Riverpod/UI.
class MarketCycleManager {
  // ── Управляющие переменные состояния ──────────────────────────

  /// Текущая фаза рынка.
  MarketPhase currentPhase;

  /// Количество недель (тиков) в текущей фазе.
  int weeksInCurrentPhase;

  /// Рыночная температура: -90 (паника/страх) … +90 (эйфория).
  double marketTemperature;

  /// Усталость текущей фазы: 0.0 (только начали) … 1.0 (пора менять).
  double phaseFatigue;

  /// Счётчик последовательных недель в Bear.
  /// При достижении >= 2 срабатывает принудительное переключение.
  int consecutiveBear;

  /// Счётчик эпох восстановления после катастрофы (BlackSwan/Crash → Recovery).
  /// 1..3 — активен, >3 — восстановление завершено.
  int recoveryEpoch;

  /// Количество накопленных часов для определения момента недельного тика.
  /// Зависит от режима теста:
  ///   12  — для недельного (1W)
  ///   24  — для месячного (1M)
  ///   168 — для длинных/бесконечных (3M, ∞, Custom)
  int hoursPerMarketTick;

  final Random _random;

  // ── Конструктор ───────────────────────────────────────────────

  MarketCycleManager({
    Random? random,
    MarketPhase startPhase = MarketPhase.bull,
    this.hoursPerMarketTick = 168,
  })  : _random = random ?? Random(),
        currentPhase = startPhase,
        weeksInCurrentPhase = 0,
        marketTemperature = 0.0,
        phaseFatigue = 0.0,
        consecutiveBear = 0,
        recoveryEpoch = 0;

  // ── Геттер текущей конфигурации ───────────────────────────────

  MarketPhaseConfig get config => _phaseConfigs[currentPhase]!;

  // ── Основной тик ──────────────────────────────────────────────

  /// Выполняет один недельный тик жизненного цикла.
  ///
  /// 1. Увеличивает [weeksInCurrentPhase].
  /// 2. Обновляет [phaseFatigue].
  /// 3. Обновляет [marketTemperature].
  /// 4. Обновляет [consecutiveBear].
  /// 5. Проверяет необходимость смены фазы.
  /// 6. Если смена запущена — выбирает следующую фазу по матрице.
  void executeWeeklyTick() {
    // Шаг 1: увеличиваем счётчик недель
    weeksInCurrentPhase++;

    // Шаг 2: обновляем усталость фазы
    _updatePhaseFatigue();

    // Шаг 3: температура рынка
    _updateMarketTemperature();

    // Шаг 4: счётчик bear
    _updateBearCounter();

    // ── Recovery epoch: каждая неделя в Recovery инкрементит счётчик ──
    if (currentPhase == MarketPhase.recovery && recoveryEpoch > 0) {
      recoveryEpoch++;
    }

    // Шаг 5-6: проверка смены фазы
    _tryTransition();
  }

  // ── Расчёт усталости фазы ─────────────────────────────────────

  /// Формула усталости (квадратичная):
  /// ```
  ///                         / weeksInPhase - minWeeks \ 2
  /// phaseFatigue = clamp(  | ──────────────────────── |  , 0.0, 1.0 )
  ///                         \ maxWeeks - minWeeks    /
  /// ```
  /// - Пока не достигнут minWeeks → fatigue = 0.0 (фаза стабильна).
  /// - Между minWeeks и maxWeeks — квадратичный рост (лавинообразный перегрев).
  /// - После maxWeeks → fatigue = 1.0 (фаза обязана смениться).
  void _updatePhaseFatigue() {
    final config = this.config;
    if (weeksInCurrentPhase < config.minWeeks) {
      phaseFatigue = 0.0;
    } else {
      final progress = (weeksInCurrentPhase - config.minWeeks) /
          (config.maxWeeks - config.minWeeks);
      phaseFatigue = (progress * progress).clamp(0.0, 1.0);
    }
  }

  // ── Температура рынка ─────────────────────────────────────────

  /// Обновляет [marketTemperature] в зависимости от текущей фазы.
  /// Bull/Recovery → толкают вверх, Bear/Crash/BlackSwan → вниз.
  void _updateMarketTemperature() {
    final step = switch (currentPhase) {
      MarketPhase.bull       => 1.5,
      MarketPhase.recovery   => 1.0,
      MarketPhase.sideways   => 0.2,
      MarketPhase.volatility => -0.5,
      MarketPhase.bear       => -2.0,
      MarketPhase.crash      => -5.0,
      MarketPhase.blackSwan  => -8.0,
    };
    marketTemperature = (marketTemperature + step).clamp(-90.0, 90.0);
  }

  // ── Bear-счётчик ──────────────────────────────────────────────

  /// Если текущая фаза — Bear, инкрементим consecutiveBear.
  /// При выходе из Bear сбрасываем.
  void _updateBearCounter() {
    if (currentPhase == MarketPhase.bear) {
      consecutiveBear++;
    } else {
      consecutiveBear = 0;
    }
  }

  // ── Логика смены фазы ─────────────────────────────────────────

  /// Решает, пора ли менять фазу, и если да — выполняет переход.
  void _tryTransition() {
    // Запоминаем фазу ДО возможного перехода (для recovery-детекта).
    final previousPhase = currentPhase;

    // Шанс удержать фазу: 100% при fatigue=0, падает до 30% при fatigue=1.
    final holdChance = 1.0 - phaseFatigue * 0.7;
    if (_random.nextDouble() < holdChance) {
      return; // остаёмся в текущей фазе
    }

    // ---- Принудительное правило: Bear 2 цикла подряд ----
    // Если мы в Bear и consecutiveBear >= 2 → Bull (60%) или Sideways (40%).
    if (currentPhase == MarketPhase.bear && consecutiveBear >= 2) {
      currentPhase = _random.nextDouble() < 0.6
          ? MarketPhase.bull
          : MarketPhase.sideways;
      _resetPhaseState();
      // Температура после принудительного выхода из bear: небольшой отскок
      marketTemperature = (marketTemperature + 10.0).clamp(-90.0, 90.0);
      _checkRecoveryEntry(previousPhase);
      return;
    }

    // ---- Нормальная смена по матрице весов ----
    final nextPhase = _rollNextPhase();
    currentPhase = nextPhase;
    _resetPhaseState();
    _checkRecoveryEntry(previousPhase);
  }

  /// Если переход произошёл из BlackSwan/Crash → Recovery,
  /// инициализируем recoveryEpoch = 1 (активирует восстановительный дрифт).
  void _checkRecoveryEntry(MarketPhase previousPhase) {
    if ((previousPhase == MarketPhase.blackSwan ||
         previousPhase == MarketPhase.crash) &&
        currentPhase == MarketPhase.recovery) {
      recoveryEpoch = 1;
    } else {
      recoveryEpoch = 0;
    }
  }

  /// Выбирает следующую фазу на основе матрицы переходов.
  MarketPhase _rollNextPhase() {
    final weights = _transitionWeights[currentPhase]!;
    final pool = <MarketPhase>[];
    final weightList = <int>[];
    for (final entry in weights.entries) {
      if (entry.value > 0) {
        pool.add(entry.key);
        weightList.add(entry.value);
      }
    }
    if (pool.isEmpty) {
      // safety fallback — такого быть не должно
      return MarketPhase.sideways;
    }
    final totalWeight = weightList.fold(0, (a, b) => a + b);
    int roll = _random.nextInt(totalWeight);
    for (int i = 0; i < pool.length; i++) {
      roll -= weightList[i];
      if (roll < 0) return pool[i];
    }
    return pool.last;
  }

  /// Сбрасывает состояние при переходе в новую фазу.
  void _resetPhaseState() {
    weeksInCurrentPhase = 0;
    phaseFatigue = 0.0;
    // consecutiveBear не сбрасывается здесь —
    // он управляется _updateBearCounter на следующем тике.
  }

  // ── Вспомогательные геттеры ───────────────────────────────────

  /// Относительная сила фазы (0.0 … 1.0) — обратная усталости.
  double get phaseStrength => 1.0 - phaseFatigue;

  /// Текущие weekly drift/volatility с поправкой на температуру.
  /// (будет использоваться при интеграции с ценами акций)
  double get effectiveDrift =>
      config.baseDrift * (1.0 + marketTemperature / 300.0);

  double get effectiveVolatility =>
      config.baseVolatility * (1.0 + marketTemperature.abs() / 150.0);

  /// Человекочитаемое описание текущей температуры.
  String get temperatureLabel {
    if (marketTemperature >= 60) return 'Euphoria';
    if (marketTemperature >= 30) return 'Greed';
    if (marketTemperature >= 10) return 'Optimism';
    if (marketTemperature >= -10) return 'Neutral';
    if (marketTemperature >= -30) return 'Anxiety';
    if (marketTemperature >= -60) return 'Fear';
    return 'Panic';
  }

  // ════════════════════════════════════════════════════════════
  //  DASHBOARD METRICS (используются FOMO Shield UI)
  // ════════════════════════════════════════════════════════════

  /// Fear Index: 0 (extreme greed) … 100 (extreme fear).
  ///
  /// Производная от marketTemperature:
  /// - +90 → 0 (extreme greed)
  /// - 0   → 50 (neutral)
  /// - -90 → 100 (extreme fear)
  int get fearIndex {
    // map -90..+90 → 100..0
    final raw = 100 - ((marketTemperature + 90) / 1.8);
    return raw.round().clamp(0, 100);
  }

  /// Recovery progress as percentage of expected recovery period.
  ///
  /// recoveryEpoch: 0 = inactive, 1..4 = active recovery,
  /// >4 = recovery complete.
  double get recoveryProgressPercent {
    if (currentPhase != MarketPhase.recovery || recoveryEpoch <= 0) {
      return 0.0;
    }
    // Recovery typically lasts up to 4-5 epochs
    return ((recoveryEpoch / 5.0) * 100).clamp(0.0, 100.0);
  }

  /// Человекочитаемый уровень волатильности.
  String get volatilityLabel {
    final vol = effectiveVolatility;
    if (vol >= 0.06) return 'Extreme';
    if (vol >= 0.035) return 'High';
    if (vol >= 0.02) return 'Elevated';
    if (vol >= 0.01) return 'Normal';
    return 'Low';
  }

  // ════════════════════════════════════════════════════════════
  //  JSON Serialization (для per-session persistence)
  // ════════════════════════════════════════════════════════════

  Map<String, dynamic> toJson() => {
    'currentPhase': currentPhase.name,
    'weeksInCurrentPhase': weeksInCurrentPhase,
    'marketTemperature': marketTemperature,
    'phaseFatigue': phaseFatigue,
    'consecutiveBear': consecutiveBear,
    'recoveryEpoch': recoveryEpoch,
    'hoursPerMarketTick': hoursPerMarketTick,
  };

  factory MarketCycleManager.fromJson(Map<String, dynamic> json, {Random? random}) {
    final mgr = MarketCycleManager(
      random: random,
      startPhase: MarketPhase.values.firstWhere(
        (p) => p.name == (json['currentPhase'] as String? ?? 'bull'),
      ),
      hoursPerMarketTick: json['hoursPerMarketTick'] as int? ?? 168,
    );
    mgr.weeksInCurrentPhase = json['weeksInCurrentPhase'] as int? ?? 0;
    mgr.marketTemperature = (json['marketTemperature'] as num?)?.toDouble() ?? 0;
    mgr.phaseFatigue = (json['phaseFatigue'] as num?)?.toDouble() ?? 0;
    mgr.consecutiveBear = json['consecutiveBear'] as int? ?? 0;
    mgr.recoveryEpoch = json['recoveryEpoch'] as int? ?? 0;
    return mgr;
  }

  /// Multiplier for visual volatility indicator (1.0 = baseline).
  double get volatilityMultiplier {
    final baseVol = config.baseVolatility;
    if (baseVol == 0) return 1.0;
    return (effectiveVolatility / baseVol).clamp(0.5, 5.0);
  }

  /// Описание ближайшего события рынка для нижней панели метрик.
  ///
  /// Возвращает кортеж (название события, дней до события).
  /// Например ('Phase Shift', 3) или ('IPO Window', 5).
  (String event, int days) get nextEventInfo {
    // Если фаза близка к смене (fatigue > 0.6) — предупреждаем
    if (phaseFatigue > 0.6) {
      final fatigueDays = ((1.0 - phaseFatigue) * 14).round().clamp(1, 14);
      return ('Phase Shift', fatigueDays);
    }
    // Если recovery активен — показываем прогресс
    if (currentPhase == MarketPhase.recovery && recoveryEpoch > 0) {
      return ('Recovery', (5 - recoveryEpoch).clamp(1, 5));
    }
    // Если температура экстремальная — предупреждение
    if (marketTemperature >= 60) return ('Overheat', 3);
    if (marketTemperature <= -60) return ('Risk Zone', 2);
    // По умолчанию — стабильность
    return ('Stable', 7);
  }
}
