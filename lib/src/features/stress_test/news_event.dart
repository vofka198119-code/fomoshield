// ignore_for_file: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
// `state` is StateNotifier's own protected/visibleForTesting field — see
// the matching comment in speculation_event.dart for why this ignore is
// needed on every `part of` mechanism file.
part of 'stress_test_engine.dart';

// ---------------------------------------------------------------------------
// News — a random single-company headline event.
// ---------------------------------------------------------------------------
// Deliberately its own file, separate from the sibling per-company
// speculation/hype mechanism (speculation_event.dart) — different trigger
// conditions, different shape, different content — per explicit
// instruction to keep each micro-scenario mechanism isolated so any one
// of them can be fixed without touching the others.
//
// Trigger (checked once per epoch, from noise_engine.dart's
// _simulateCurrentPrices, right next to the weekly spec/hype check):
//   - Portfolio needs 8+ holdings, or the mechanism is disabled entirely
//     for that session (a single-company move matters too much in a
//     small, concentrated portfolio).
//   - Skipped if a News event is already active (one at a time).
//   - 5% roll chance when checked.
// If it fires: one random holding, one random headline from
// [newsScenarios] (sign matches the headline's own positive/negative
// list), a signed total move of 10-25%, ramped in over a random
// 2-6 hour window with NO reversal — a real news-driven move mostly
// sticks, it doesn't mechanically snap back to zero the way the
// speculation/hype bell curve does.
// ---------------------------------------------------------------------------

/// One canned headline + its direction. Magnitude is rolled separately
/// (see [_newsAmplitudeMin]/[_newsAmplitudeMax]) — the scenario table only
/// supplies the story and the sign.
class NewsScenario {
  final String headline;
  final String description;
  final bool isPositive;

  const NewsScenario({
    required this.headline,
    required this.description,
    required this.isPositive,
  });
}

/// The 25 confirmed scenarios (12 positive, 13 negative) — user-provided
/// 2026-07-19, see memory note project-fomo-shield-corporate-scenarios-list.
const List<NewsScenario> newsScenarios = [
  // ── Positive ──────────────────────────────────────────────────
  NewsScenario(
    headline: 'Отчет превзошел ожидания',
    description:
        'Компания опубликовала квартальный отчет с выручкой и прибылью выше прогнозов аналитиков.',
    isPositive: true,
  ),
  NewsScenario(
    headline: 'Повышение годового прогноза',
    description:
        'Руководство улучшило прогноз по выручке и прибыли на текущий финансовый год.',
    isPositive: true,
  ),
  NewsScenario(
    headline: 'Крупный контракт',
    description:
        'Компания объявила о заключении многолетнего соглашения с крупным корпоративным клиентом.',
    isPositive: true,
  ),
  NewsScenario(
    headline: 'Обратный выкуп акций',
    description:
        'Совет директоров утвердил масштабную программу обратного выкупа собственных акций.',
    isPositive: true,
  ),
  NewsScenario(
    headline: 'Рост дивидендов',
    description:
        'Компания увеличила размер квартальных дивидендов и подтвердила стабильную дивидендную политику.',
    isPositive: true,
  ),
  NewsScenario(
    headline: 'Успешное завершение сделки',
    description:
        'Получены все необходимые разрешения, сделка по приобретению другой компании официально закрыта.',
    isPositive: true,
  ),
  NewsScenario(
    headline: 'Одобрение нового продукта',
    description:
        'Регулятор одобрил вывод нового продукта на рынок, открывая компании дополнительный источник дохода.',
    isPositive: true,
  ),
  NewsScenario(
    headline: 'Снижение расходов',
    description:
        'Компания объявила о программе оптимизации, которая должна значительно сократить операционные расходы.',
    isPositive: true,
  ),
  NewsScenario(
    headline: 'Погашение долгов',
    description:
        'Компания досрочно погасила часть долговой нагрузки и улучшила структуру баланса.',
    isPositive: true,
  ),
  NewsScenario(
    headline: 'Расширение бизнеса',
    description:
        'Руководство объявило о выходе на новый международный рынок и запуске локальных операций.',
    isPositive: true,
  ),
  NewsScenario(
    headline: 'Рост клиентской базы',
    description:
        'Количество активных клиентов достигло рекордного уровня за всю историю компании.',
    isPositive: true,
  ),
  NewsScenario(
    headline: 'Стратегическое партнерство',
    description:
        'Компания подписала долгосрочное соглашение о сотрудничестве с одним из лидеров отрасли.',
    isPositive: true,
  ),
  // ── Negative ──────────────────────────────────────────────────
  NewsScenario(
    headline: 'Отчет оказался слабее ожиданий',
    description:
        'Компания сообщила результаты ниже прогнозов аналитиков по прибыли и выручке.',
    isPositive: false,
  ),
  NewsScenario(
    headline: 'Понижение прогноза',
    description: 'Руководство ухудшило финансовый прогноз на оставшуюся часть года.',
    isPositive: false,
  ),
  NewsScenario(
    headline: 'Срыв сделки',
    description:
        'Планируемое приобретение другой компании отменено после длительных переговоров.',
    isPositive: false,
  ),
  NewsScenario(
    headline: 'Отзыв продукции',
    description:
        'Компания начала масштабный отзыв продукции из-за выявленных производственных дефектов.',
    isPositive: false,
  ),
  NewsScenario(
    headline: 'Кибератака',
    description:
        'Компания подтвердила факт кибератаки, которая затронула часть внутренних систем.',
    isPositive: false,
  ),
  NewsScenario(
    headline: 'Уход генерального директора',
    description: 'Генеральный директор неожиданно объявил об уходе со своего поста.',
    isPositive: false,
  ),
  NewsScenario(
    headline: 'Судебный иск',
    description:
        'Против компании подан крупный коллективный иск, связанный с основной деятельностью бизнеса.',
    isPositive: false,
  ),
  NewsScenario(
    headline: 'Проблемы с поставками',
    description:
        'Компания предупредила о перебоях в цепочке поставок и возможных задержках производства.',
    isPositive: false,
  ),
  NewsScenario(
    headline: 'Рост долговой нагрузки',
    description:
        'Компания сообщила о значительном увеличении долгов после публикации финансовой отчетности.',
    isPositive: false,
  ),
  NewsScenario(
    headline: 'Проверка регулятора',
    description:
        'Регулятор начал официальное расследование в отношении деятельности компании.',
    isPositive: false,
  ),
  NewsScenario(
    headline: 'Потеря ключевого клиента',
    description: 'Один из крупнейших клиентов отказался продлевать долгосрочный контракт.',
    isPositive: false,
  ),
  NewsScenario(
    headline: 'Приостановка производства',
    description:
        'Работа одного из основных производственных объектов временно остановлена из-за технических проблем.',
    isPositive: false,
  ),
  NewsScenario(
    headline: 'Сокращение персонала',
    description:
        'Компания объявила о масштабной реструктуризации с сокращением части сотрудников.',
    isPositive: false,
  ),
];

/// Minimum portfolio size for the News mechanism to be eligible at all.
const int _newsMinHoldings = 8;

/// Chance per epoch that a News event fires (once eligible).
const double _newsChancePerEpochCheck = 0.05;

/// Total signed price move range — magnitude only, sign comes from the
/// picked [NewsScenario.isPositive].
const double _newsAmplitudeMin = 0.10;
const double _newsAmplitudeMax = 0.25;

/// Ramp duration range — deliberately shorter/sharper than the spec/hype
/// mechanism's full-epoch ramp, per explicit instruction ("более резкий
/// скачок").
const Duration _newsRampMin = Duration(hours: 2);
const Duration _newsRampMax = Duration(hours: 6);

extension NewsEventEngine on StressTestNotifier {
  /// Try to fire a News event for this session. Called once per epoch
  /// (gate lives in noise_engine.dart's lastNewsCheckedEpoch check).
  NewsEvent? _maybeFireNewsEvent(
    StressTestSession session,
    Random rng,
    DateTime now,
  ) {
    if (session.holdings.length < _newsMinHoldings) return null;
    if (rng.nextDouble() >= _newsChancePerEpochCheck) return null;

    final holding = session.holdings[rng.nextInt(session.holdings.length)];
    final scenario = newsScenarios[rng.nextInt(newsScenarios.length)];
    final magnitude =
        _newsAmplitudeMin + rng.nextDouble() * (_newsAmplitudeMax - _newsAmplitudeMin);
    final signedAmplitude = scenario.isPositive ? magnitude : -magnitude;

    final rampMs =
        _newsRampMin.inMilliseconds +
        rng.nextDouble() * (_newsRampMax.inMilliseconds - _newsRampMin.inMilliseconds);
    final rampTicks = (rampMs / 1000 / _tickSeconds).round().clamp(1, 1000000);

    return NewsEvent(
      symbol: holding.symbol,
      headline: scenario.headline,
      isPositive: scenario.isPositive,
      targetAmplitude: signedAmplitude,
      startedAt: now,
      rampDurationTicks: rampTicks,
    );
  }

  /// Apply this tick's slice of the active News event, if [symbol] is the
  /// one it targets. Mutates session.activeNewsEvent in place (advances
  /// currentTick, clears to null on expiry) so multi-tick catch-up
  /// batches progress correctly call-by-call — same pattern as
  /// _applySpecEvents in speculation_event.dart.
  double _applyNewsEvent(StressTestSession session, String symbol) {
    final event = session.activeNewsEvent;
    if (event == null || event.symbol != symbol) return 0.0;
    if (event.isExpired) {
      session.activeNewsEvent = null;
      return 0.0;
    }

    final increment = event.tickIncrement;
    final advanced = event.copy();
    advanced.currentTick++;
    session.activeNewsEvent = advanced.isExpired ? null : advanced;
    return increment;
  }
}
