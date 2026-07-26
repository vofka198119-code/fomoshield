import 'dart:math' show pi;

// ---------------------------------------------------------------------------
// Market Clock engine — pure Dart, no network/UI. Computes NYSE trading
// phases, the 9 copy "windows", and the US market holiday calendar.
//
// Times below are always America/New_York wall-clock time ("ET"), computed
// manually (US DST: 2nd Sunday of March – 1st Sunday of November) rather
// than via a timezone-database package, since that's the only zone this
// feature ever needs and the DST rule has been stable since 2007.
// ---------------------------------------------------------------------------

enum MarketPhase { closed, preMarket, marketOpen, afterHours }

class MarketWindow {
  final String id;
  final String emoji;
  final String shortHeadline;
  final String shortDetail;
  final String fullTitle;
  final String timeRangeLabel;
  final MarketPhase phase;
  final int startMinute;
  final int endMinute;
  final String whatHappens;
  final String whyItMatters;
  final String? dangerForBeginner;
  final String whatToDo;

  const MarketWindow({
    required this.id,
    required this.emoji,
    required this.shortHeadline,
    required this.shortDetail,
    required this.fullTitle,
    required this.timeRangeLabel,
    required this.phase,
    required this.startMinute,
    required this.endMinute,
    required this.whatHappens,
    required this.whyItMatters,
    this.dangerForBeginner,
    required this.whatToDo,
  });
}

const List<MarketWindow> marketWindows = [
  MarketWindow(
    id: 'early-pre-market',
    emoji: '🌙',
    shortHeadline: 'Ранний премаркет',
    shortDetail: 'Низкая ликвидность, опасные спреды',
    fullTitle: 'Ранний премаркет (Early Pre-Market)',
    timeRangeLabel: '04:00 – 07:00',
    phase: MarketPhase.preMarket,
    startMinute: 240,
    endMinute: 420,
    whatHappens:
        'Открываются первые электронные торги для крупных фондов и ранних трейдеров. Параллельно открываются биржи в Европе.',
    whyItMatters:
        'На рынке очень мало денег и участников (низкая ликвидность). Из-за этого разница между ценой покупки и продажи (спред) может быть огромной.',
    dangerForBeginner:
        'Если вы купите акцию «по рыночной цене» (Market Order), система исполнит сделку по любой доступной цене, и вы можете переплатить несколько процентов на пустом месте.',
    whatToDo:
        'Торгуйте только при крайней необходимости и выставляйте только лимитные ордера (Limit Order) — они гарантируют, что вы не купите дороже указанной вами суммы.',
  ),
  MarketWindow(
    id: 'pre-market-reports',
    emoji: '☕',
    shortHeadline: 'Премаркет и новости',
    shortDetail: 'Высокий риск, публикация отчетов',
    fullTitle: 'Основной премаркет и отчеты (Pre-Market)',
    timeRangeLabel: '07:00 – 09:30',
    phase: MarketPhase.preMarket,
    startMinute: 420,
    endMinute: 570,
    whatHappens:
        'В 08:30 компании часто публикуют квартальные отчеты, а правительство США — важные экономические новости (инфляция, безработица).',
    whyItMatters:
        'Поток заявок увеличивается, начинается резкая смена цен (высокая волатильность). Акции могут взлетать или падать на 10–20% еще до официального открытия торгов.',
    dangerForBeginner:
        'Цена двигается хаотично, реагируя на эмоции трейдеров. В этот период легко совершить ошибку на панике.',
    whatToDo: 'Наблюдайте со стороны. Не пытайтесь угадать направление движения цены на новостях.',
  ),
  MarketWindow(
    id: 'opening-bell',
    emoji: '🔔',
    shortHeadline: 'Открытие биржи',
    shortDetail: 'Пик волатильности, хаос первых минут',
    fullTitle: 'Открытие основной сессии (Opening Bell)',
    timeRangeLabel: '09:30 – 10:30',
    phase: MarketPhase.marketOpen,
    startMinute: 570,
    endMinute: 630,
    whatHappens:
        'Звонит колокол на Нью-Йоркской бирже. К торгам подключаются миллионы обычных инвесторов и автоматические торговые роботы.',
    whyItMatters:
        'Самый активный час за весь день. Срабатывают миллионы заявок, накопившихся за ночь и премаркет. Объемы денег гигантские, но цена совершает резкие скачки в обе стороны.',
    dangerForBeginner:
        'Первые 15–30 минут — это «зона хаоса». Рынок ищет справедливую цену, и вас может выбить из сделки случайным скачком.',
    whatToDo:
        'Лучше подождать 20–30 минут после открытия, пока спадёт первая волна эмоций и сформируется понятное направление.',
  ),
  MarketWindow(
    id: 'morning-session',
    emoji: '📈',
    shortHeadline: 'Утренний тренд',
    shortDetail: 'Лучшее время для спокойных сделок',
    fullTitle: 'Утренний тренд (Morning Session)',
    timeRangeLabel: '10:30 – 12:00',
    phase: MarketPhase.marketOpen,
    startMinute: 630,
    endMinute: 720,
    whatHappens:
        'Утренний хаос улегся. Крупные игроки определились с планами на день и начали планомерно покупать или продавать активы.',
    whyItMatters:
        'Идеальный баланс: на рынке много денег (высокая ликвидность), а движения цен становятся предсказуемыми и плавными. Спреды минимальны.',
    dangerForBeginner: 'Минимальная за весь день.',
    whatToDo: 'Это самое безопасное и комфортное время для совершения запланированных покупок или продаж.',
  ),
  MarketWindow(
    id: 'lunch-hour',
    emoji: '🥪',
    shortHeadline: 'Обеденный перерыв',
    shortDetail: 'Затишье, низкая активность',
    fullTitle: 'Обеденное затишье (Lunch Hour)',
    timeRangeLabel: '12:00 – 14:00',
    phase: MarketPhase.marketOpen,
    startMinute: 720,
    endMinute: 840,
    whatHappens:
        'Управляющие фондами и трейдеры в Нью-Йорке уходят на обед. В Европе в это время торги завершаются и биржи закрываются.',
    whyItMatters:
        'Объемы торгов заметно падают. Графики цен «засыпают» и начинают двигаться в узком боковом коридоре без четкого направления.',
    dangerForBeginner: 'Попытка найти активное движение там, где его нет. Импульсивные сделки от скуки.',
    whatToDo:
        'Отдохнуть от графика. Если нужно просто купить акцию в долгий срок — делать это можно, но сильных трендов в эти часы ждать не стоит.',
  ),
  MarketWindow(
    id: 'mid-afternoon',
    emoji: '📊',
    shortHeadline: 'Дневная сессия',
    shortDetail: 'Стабильные торги, реакция на ФРС',
    fullTitle: 'Дневная сессия (Mid-Afternoon)',
    timeRangeLabel: '14:00 – 15:30',
    phase: MarketPhase.marketOpen,
    startMinute: 840,
    endMinute: 930,
    whatHappens:
        'Трейдеры возвращаются на места. Если на этот день запланированы важные заявления ФРС США (Центробанка), их публикуют ровно в 14:00.',
    whyItMatters:
        'Объемы торгов снова растут. Если вышли новости по процентным ставкам — рынок испытывает мощный всплеск активности. В обычные дни идет спокойное продолжение утреннего тренда.',
    dangerForBeginner: 'Высокая волатильность в дни заседаний ФРС (обычно 8 раз в год).',
    whatToDo:
        'Хорошее время для спокойных сделок в обычные дни. В дни новостей ФРС — не входить в рынок за 15 минут до и после 14:00.',
  ),
  MarketWindow(
    id: 'power-hour',
    emoji: '⚡',
    shortHeadline: 'Час пик (Power Hour)',
    shortDetail: 'Финал дня, крупные объемы',
    fullTitle: 'Час пик и закрытие (Power Hour)',
    timeRangeLabel: '15:30 – 16:00',
    phase: MarketPhase.marketOpen,
    startMinute: 930,
    endMinute: 960,
    whatHappens:
        'Финальные 30–60 минут перед закрытием биржи. Дневные трейдеры спешно закрывают позиции, а крупные фонды сбалансируют свои портфели.',
    whyItMatters:
        'Второй по мощности всплеск активности за день. Цены двигаются быстро и решительно, часто переписывая максимумы или минимумы дня.',
    dangerForBeginner: 'Быстрые развороты цен прямо перед самым закрытием.',
    whatToDo: 'Отличное время, чтобы зафиксировать прибыль по сделкам, открытым утром, или докупить акции на закрытии.',
  ),
  MarketWindow(
    id: 'after-hours',
    emoji: '🌙',
    shortHeadline: 'Постмаркет',
    shortDetail: 'Рынок закрыт, вечерние отчеты',
    fullTitle: 'Постмаркет (After-Hours)',
    timeRangeLabel: '16:00 – 20:00',
    phase: MarketPhase.afterHours,
    startMinute: 960,
    endMinute: 1200,
    whatHappens:
        'Основная биржа закрывается в 16:00. Начинается вечерняя сессия. В 16:05 многие технологические гиганты (Apple, Amazon, Google) публикуют свои квартальные отчеты.',
    whyItMatters:
        'Крайне низкая ликвидность сочетается с сильнейшими новостями. Акция может взлететь или упасть на 15–20% всего за пару минут на единичных сделках.',
    dangerForBeginner: 'Очень высокая. Широкие спреды и риск купить по неадекватной цене.',
    whatToDo:
        'Не торговать. Используйте это время только для чтения отчетов и анализа того, как рынок откроется завтра.',
  ),
  MarketWindow(
    id: 'closed',
    emoji: '🛑',
    shortHeadline: 'Биржа закрыта',
    shortDetail: 'Торги не ведутся',
    fullTitle: 'Биржа закрыта (Night Off-Hours)',
    timeRangeLabel: '20:00 – 04:00',
    phase: MarketPhase.closed,
    startMinute: 1200,
    endMinute: 1440 + 240, // wraps past midnight to 04:00 next day
    whatHappens: 'Торги полностью остановлены. Сервера биржи обрабатывают дневные операции.',
    whyItMatters: 'Рынок отдыхает. Никакие заявки не исполняются до наступления 04:00.',
    whatToDo: 'Готовиться к следующему торговому дню, анализировать графики и новости.',
  ),
];

/// Shown all day on weekends/holidays instead of the nightly `closed`
/// window above — that one's `timeRangeLabel` ("20:00 – 04:00") is only
/// accurate for the overnight gap on a normal trading day and reads as
/// wrong/confusing if shown at, say, 11:00 AM on a Sunday (real bug caught
/// by the user 2026-07-26: dial correctly showed 11:29 ET but the copy said
/// "20:00 – 04:00"). This window's label covers the whole day instead.
const weekendClosedWindow = MarketWindow(
  id: 'weekend-closed',
  emoji: '📅',
  shortHeadline: 'Биржа закрыта',
  shortDetail: 'Нерабочий день — торгов нет весь день',
  fullTitle: 'Нерабочий день (Weekend / Holiday)',
  timeRangeLabel: 'Весь день',
  phase: MarketPhase.closed,
  startMinute: 0,
  endMinute: 1440,
  whatHappens: 'Сегодня выходной или биржевой праздник — торги не проводятся весь день.',
  whyItMatters: 'Никакие заявки не исполняются, цены не двигаются до открытия премаркета в следующий рабочий день (04:00 ET).',
  whatToDo: 'Использовать время для анализа портфеля и планирования сделок на следующую сессию.',
);

/// Shown instead of the normal Market-Open sub-windows on an early-close day
/// (Black Friday / Christmas Eve), covering the compressed 12:00–13:00 ET
/// stretch right before the 1:00 PM close. This is a v1 simplification —
/// the 5 normal sub-windows don't fit the shortened session, see
/// docs/MARKET_CLOCK_SPEC.md.
const earlyCloseWindow = MarketWindow(
  id: 'early-close-session',
  emoji: '⏳',
  shortHeadline: 'Сокращённый день',
  shortDetail: 'Биржа закроется в 13:00 ET',
  fullTitle: 'Сокращённая сессия (Early Close)',
  timeRangeLabel: '12:00 – 13:00',
  phase: MarketPhase.marketOpen,
  startMinute: 720,
  endMinute: 780,
  whatHappens: 'Сегодня биржа работает по укороченному расписанию и закроется в 13:00 ET вместо 16:00.',
  whyItMatters: 'Меньше времени на исполнение заявок — активность и объёмы сжимаются в укороченное окно.',
  dangerForBeginner: 'Легко забыть о раннем закрытии и выставить заявку, которая не исполнится сегодня.',
  whatToDo: 'Планируйте сделки заранее и не оставляйте важные ордера на вторую половину дня.',
);

MarketWindow? findWindowById(String id) {
  if (id == earlyCloseWindow.id) return earlyCloseWindow;
  if (id == weekendClosedWindow.id) return weekendClosedWindow;
  for (final w in marketWindows) {
    if (w.id == id) return w;
  }
  return null;
}

// ---------------------------------------------------------------------------
// Date/time helpers
// ---------------------------------------------------------------------------

DateTime nowInNewYork() {
  final utcNow = DateTime.now().toUtc();
  final offsetHours = _isEasternDaylightTime(utcNow) ? -4 : -5;
  return utcNow.add(Duration(hours: offsetHours));
}

bool _isEasternDaylightTime(DateTime utc) {
  final year = utc.year;
  final dstStartUtc = DateTime.utc(year, 3, _nthWeekdayDay(year, 3, DateTime.sunday, 2), 7);
  final dstEndUtc = DateTime.utc(year, 11, _nthWeekdayDay(year, 11, DateTime.sunday, 1), 6);
  return !utc.isBefore(dstStartUtc) && utc.isBefore(dstEndUtc);
}

int _nthWeekdayDay(int year, int month, int weekday, int n) {
  final first = DateTime(year, month, 1);
  final firstWeekdayOffset = (weekday - first.weekday + 7) % 7;
  return 1 + firstWeekdayOffset + (n - 1) * 7;
}

int _lastWeekdayDay(int year, int month, int weekday) {
  final firstOfNextMonth = month == 12 ? DateTime(year + 1, 1, 1) : DateTime(year, month + 1, 1);
  final lastDay = firstOfNextMonth.subtract(const Duration(days: 1));
  final diff = (lastDay.weekday - weekday + 7) % 7;
  return lastDay.day - diff;
}

/// Anonymous Gregorian algorithm (Meeus/Jones/Butcher).
DateTime _easterSunday(int year) {
  final a = year % 19;
  final b = year ~/ 100;
  final c = year % 100;
  final d = b ~/ 4;
  final e = b % 4;
  final f = (b + 8) ~/ 25;
  final g = (b - f + 1) ~/ 3;
  final h = (19 * a + b - d - g + 15) % 30;
  final i = c ~/ 4;
  final k = c % 4;
  final l = (32 + 2 * e + 2 * i - h - k) % 7;
  final m = (a + 11 * h + 22 * l) ~/ 451;
  final month = (h + l - 7 * m + 114) ~/ 31;
  final day = ((h + l - 7 * m + 114) % 31) + 1;
  return DateTime(year, month, day);
}

DateTime _observedFixed(DateTime date) {
  if (date.weekday == DateTime.saturday) return date.subtract(const Duration(days: 1));
  if (date.weekday == DateTime.sunday) return date.add(const Duration(days: 1));
  return date;
}

bool _isSameDate(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;

bool isWeekend(DateTime dateEt) => dateEt.weekday == DateTime.saturday || dateEt.weekday == DateTime.sunday;

/// Full-closure NYSE holidays. Nth-weekday and Easter-derived dates are
/// recomputed for [dateEt]'s year, not hardcoded — see docs/MARKET_CLOCK_SPEC.md
/// for the source list. Deliberately does NOT include Columbus Day / Veterans
/// Day — NYSE trades normally on those (bond-market-only holidays).
bool isFullClosureHoliday(DateTime dateEt) {
  final y = dateEt.year;
  final holidays = <DateTime>[
    _observedFixed(DateTime(y, 1, 1)), // New Year's Day
    DateTime(y, 1, _nthWeekdayDay(y, 1, DateTime.monday, 3)), // MLK Day
    DateTime(y, 2, _nthWeekdayDay(y, 2, DateTime.monday, 3)), // Presidents' Day
    _easterSunday(y).subtract(const Duration(days: 2)), // Good Friday
    DateTime(y, 5, _lastWeekdayDay(y, 5, DateTime.monday)), // Memorial Day
    _observedFixed(DateTime(y, 6, 19)), // Juneteenth
    _observedFixed(DateTime(y, 7, 4)), // Independence Day
    DateTime(y, 9, _nthWeekdayDay(y, 9, DateTime.monday, 1)), // Labor Day
    DateTime(y, 11, _nthWeekdayDay(y, 11, DateTime.thursday, 4)), // Thanksgiving
    _observedFixed(DateTime(y, 12, 25)), // Christmas Day
  ];
  return holidays.any((d) => _isSameDate(d, dateEt));
}

/// Black Friday + Christmas Eve (skipped if Dec 24 itself lands on a
/// weekend — approximates the "may not apply" caveat from the source list).
bool isEarlyCloseDay(DateTime dateEt) {
  final y = dateEt.year;
  final thanksgiving = DateTime(y, 11, _nthWeekdayDay(y, 11, DateTime.thursday, 4));
  final blackFriday = thanksgiving.add(const Duration(days: 1));
  final christmasEve = DateTime(y, 12, 24);
  if (_isSameDate(dateEt, blackFriday)) return true;
  if (_isSameDate(dateEt, christmasEve) && !isWeekend(christmasEve)) return true;
  return false;
}

class MarketClockState {
  final DateTime nowEt;
  final MarketPhase phase;
  final MarketWindow window;
  final bool isHoliday;
  final bool isEarlyCloseDay;

  const MarketClockState({
    required this.nowEt,
    required this.phase,
    required this.window,
    required this.isHoliday,
    required this.isEarlyCloseDay,
  });
}

MarketClockState resolveMarketClockState(DateTime nowEt) {
  final minuteOfDay = nowEt.hour * 60 + nowEt.minute;
  final holiday = isWeekend(nowEt) || isFullClosureHoliday(nowEt);

  if (holiday) {
    return MarketClockState(
      nowEt: nowEt,
      phase: MarketPhase.closed,
      window: weekendClosedWindow,
      isHoliday: true,
      isEarlyCloseDay: false,
    );
  }

  final earlyClose = isEarlyCloseDay(nowEt);

  if (earlyClose) {
    if (minuteOfDay < 240 || minuteOfDay >= 1200) {
      return MarketClockState(
        nowEt: nowEt,
        phase: MarketPhase.closed,
        window: marketWindows.last,
        isHoliday: false,
        isEarlyCloseDay: true,
      );
    }
    if (minuteOfDay < 570) {
      final w = minuteOfDay < 420 ? marketWindows[0] : marketWindows[1];
      return MarketClockState(nowEt: nowEt, phase: w.phase, window: w, isHoliday: false, isEarlyCloseDay: true);
    }
    if (minuteOfDay < 630) {
      return MarketClockState(
        nowEt: nowEt,
        phase: MarketPhase.marketOpen,
        window: marketWindows[2],
        isHoliday: false,
        isEarlyCloseDay: true,
      );
    }
    if (minuteOfDay < 720) {
      return MarketClockState(
        nowEt: nowEt,
        phase: MarketPhase.marketOpen,
        window: marketWindows[3],
        isHoliday: false,
        isEarlyCloseDay: true,
      );
    }
    if (minuteOfDay < 780) {
      return MarketClockState(
        nowEt: nowEt,
        phase: MarketPhase.marketOpen,
        window: earlyCloseWindow,
        isHoliday: false,
        isEarlyCloseDay: true,
      );
    }
    return MarketClockState(
      nowEt: nowEt,
      phase: MarketPhase.afterHours,
      window: marketWindows[7],
      isHoliday: false,
      isEarlyCloseDay: true,
    );
  }

  for (final w in marketWindows) {
    if (w.id == 'closed') continue;
    if (minuteOfDay >= w.startMinute && minuteOfDay < w.endMinute) {
      return MarketClockState(nowEt: nowEt, phase: w.phase, window: w, isHoliday: false, isEarlyCloseDay: false);
    }
  }

  return MarketClockState(
    nowEt: nowEt,
    phase: MarketPhase.closed,
    window: marketWindows.last,
    isHoliday: false,
    isEarlyCloseDay: false,
  );
}

// ---------------------------------------------------------------------------
// Ring geometry — 24h circular mapping, midnight at the top, clockwise.
// Returns a plain angle; callers with a Flutter BuildContext use their own
// Offset/cos/sin (via dart:math, already imported here for reference).
// ---------------------------------------------------------------------------

double angleForMinuteOfDay(int minute) => (minute / 1440) * 2 * pi - pi / 2;
