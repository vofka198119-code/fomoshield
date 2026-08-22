import 'dart:math' show pi;

import '../../l10n/gen/app_localizations.dart';

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
  final String? fomoShieldTip;
  // Shown only on non-trading windows (weekend/holiday) — nudges the user
  // toward Stress Test while the real market is closed.
  final String? stressTestPromoTitle;
  final String? stressTestPromoBody;

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
    this.fomoShieldTip,
    this.stressTestPromoTitle,
    this.stressTestPromoBody,
  });
}

List<MarketWindow> marketWindowsFor(AppLocalizations l10n) => [
  MarketWindow(
    id: 'early-pre-market',
    emoji: '🌙',
    shortHeadline: l10n.marketClockWindowEarlyPreMarketShortHeadline,
    shortDetail: l10n.marketClockWindowEarlyPreMarketShortDetail,
    fullTitle: l10n.marketClockWindowEarlyPreMarketFullTitle,
    timeRangeLabel: '04:00 – 07:00',
    phase: MarketPhase.preMarket,
    startMinute: 240,
    endMinute: 420,
    whatHappens: l10n.marketClockWindowEarlyPreMarketWhatHappens,
    whyItMatters: l10n.marketClockWindowEarlyPreMarketWhyItMatters,
    dangerForBeginner: l10n.marketClockWindowEarlyPreMarketDangerForBeginner,
    whatToDo: l10n.marketClockWindowEarlyPreMarketWhatToDo,
    fomoShieldTip: l10n.marketClockWindowEarlyPreMarketFomoShieldTip,
  ),
  MarketWindow(
    id: 'pre-market-reports',
    emoji: '☕',
    shortHeadline: l10n.marketClockWindowPreMarketReportsShortHeadline,
    shortDetail: l10n.marketClockWindowPreMarketReportsShortDetail,
    fullTitle: l10n.marketClockWindowPreMarketReportsFullTitle,
    timeRangeLabel: '07:00 – 09:30',
    phase: MarketPhase.preMarket,
    startMinute: 420,
    endMinute: 570,
    whatHappens: l10n.marketClockWindowPreMarketReportsWhatHappens,
    whyItMatters: l10n.marketClockWindowPreMarketReportsWhyItMatters,
    dangerForBeginner: l10n.marketClockWindowPreMarketReportsDangerForBeginner,
    whatToDo: l10n.marketClockWindowPreMarketReportsWhatToDo,
    fomoShieldTip: l10n.marketClockWindowPreMarketReportsFomoShieldTip,
  ),
  MarketWindow(
    id: 'opening-bell',
    emoji: '🔔',
    shortHeadline: l10n.marketClockWindowOpeningBellShortHeadline,
    shortDetail: l10n.marketClockWindowOpeningBellShortDetail,
    fullTitle: l10n.marketClockWindowOpeningBellFullTitle,
    timeRangeLabel: '09:30 – 10:30',
    phase: MarketPhase.marketOpen,
    startMinute: 570,
    endMinute: 630,
    whatHappens: l10n.marketClockWindowOpeningBellWhatHappens,
    whyItMatters: l10n.marketClockWindowOpeningBellWhyItMatters,
    dangerForBeginner: l10n.marketClockWindowOpeningBellDangerForBeginner,
    whatToDo: l10n.marketClockWindowOpeningBellWhatToDo,
    fomoShieldTip: l10n.marketClockWindowOpeningBellFomoShieldTip,
  ),
  MarketWindow(
    id: 'morning-session',
    emoji: '📈',
    shortHeadline: l10n.marketClockWindowMorningSessionShortHeadline,
    shortDetail: l10n.marketClockWindowMorningSessionShortDetail,
    fullTitle: l10n.marketClockWindowMorningSessionFullTitle,
    timeRangeLabel: '10:30 – 12:00',
    phase: MarketPhase.marketOpen,
    startMinute: 630,
    endMinute: 720,
    whatHappens: l10n.marketClockWindowMorningSessionWhatHappens,
    whyItMatters: l10n.marketClockWindowMorningSessionWhyItMatters,
    dangerForBeginner: l10n.marketClockWindowMorningSessionDangerForBeginner,
    whatToDo: l10n.marketClockWindowMorningSessionWhatToDo,
    fomoShieldTip: l10n.marketClockWindowMorningSessionFomoShieldTip,
  ),
  MarketWindow(
    id: 'lunch-hour',
    emoji: '🥪',
    shortHeadline: l10n.marketClockWindowLunchHourShortHeadline,
    shortDetail: l10n.marketClockWindowLunchHourShortDetail,
    fullTitle: l10n.marketClockWindowLunchHourFullTitle,
    timeRangeLabel: '12:00 – 14:00',
    phase: MarketPhase.marketOpen,
    startMinute: 720,
    endMinute: 840,
    whatHappens: l10n.marketClockWindowLunchHourWhatHappens,
    whyItMatters: l10n.marketClockWindowLunchHourWhyItMatters,
    dangerForBeginner: l10n.marketClockWindowLunchHourDangerForBeginner,
    whatToDo: l10n.marketClockWindowLunchHourWhatToDo,
    fomoShieldTip: l10n.marketClockWindowLunchHourFomoShieldTip,
  ),
  MarketWindow(
    id: 'mid-afternoon',
    emoji: '📊',
    shortHeadline: l10n.marketClockWindowMidAfternoonShortHeadline,
    shortDetail: l10n.marketClockWindowMidAfternoonShortDetail,
    fullTitle: l10n.marketClockWindowMidAfternoonFullTitle,
    timeRangeLabel: '14:00 – 15:30',
    phase: MarketPhase.marketOpen,
    startMinute: 840,
    endMinute: 930,
    whatHappens: l10n.marketClockWindowMidAfternoonWhatHappens,
    whyItMatters: l10n.marketClockWindowMidAfternoonWhyItMatters,
    dangerForBeginner: l10n.marketClockWindowMidAfternoonDangerForBeginner,
    whatToDo: l10n.marketClockWindowMidAfternoonWhatToDo,
    fomoShieldTip: l10n.marketClockWindowMidAfternoonFomoShieldTip,
  ),
  MarketWindow(
    id: 'power-hour',
    emoji: '⚡',
    shortHeadline: l10n.marketClockWindowPowerHourShortHeadline,
    shortDetail: l10n.marketClockWindowPowerHourShortDetail,
    fullTitle: l10n.marketClockWindowPowerHourFullTitle,
    timeRangeLabel: '15:30 – 16:00',
    phase: MarketPhase.marketOpen,
    startMinute: 930,
    endMinute: 960,
    whatHappens: l10n.marketClockWindowPowerHourWhatHappens,
    whyItMatters: l10n.marketClockWindowPowerHourWhyItMatters,
    dangerForBeginner: l10n.marketClockWindowPowerHourDangerForBeginner,
    whatToDo: l10n.marketClockWindowPowerHourWhatToDo,
    fomoShieldTip: l10n.marketClockWindowPowerHourFomoShieldTip,
  ),
  MarketWindow(
    id: 'after-hours',
    emoji: '🌙',
    shortHeadline: l10n.marketClockWindowAfterHoursShortHeadline,
    shortDetail: l10n.marketClockWindowAfterHoursShortDetail,
    fullTitle: l10n.marketClockWindowAfterHoursFullTitle,
    timeRangeLabel: '16:00 – 20:00',
    phase: MarketPhase.afterHours,
    startMinute: 960,
    endMinute: 1200,
    whatHappens: l10n.marketClockWindowAfterHoursWhatHappens,
    whyItMatters: l10n.marketClockWindowAfterHoursWhyItMatters,
    dangerForBeginner: l10n.marketClockWindowAfterHoursDangerForBeginner,
    whatToDo: l10n.marketClockWindowAfterHoursWhatToDo,
    fomoShieldTip: l10n.marketClockWindowAfterHoursFomoShieldTip,
  ),
  MarketWindow(
    id: 'closed',
    emoji: '🛑',
    shortHeadline: l10n.marketClockWindowClosedShortHeadline,
    shortDetail: l10n.marketClockWindowClosedShortDetail,
    fullTitle: l10n.marketClockWindowClosedFullTitle,
    timeRangeLabel: '20:00 – 04:00',
    phase: MarketPhase.closed,
    startMinute: 1200,
    endMinute: 1440 + 240, // wraps past midnight to 04:00 next day
    whatHappens: l10n.marketClockWindowClosedWhatHappens,
    whyItMatters: l10n.marketClockWindowClosedWhyItMatters,
    dangerForBeginner: l10n.marketClockWindowClosedDangerForBeginner,
    whatToDo: l10n.marketClockWindowClosedWhatToDo,
    fomoShieldTip: l10n.marketClockWindowClosedFomoShieldTip,
  ),
];

/// Shown all day on weekends instead of the nightly `closed` window above —
/// that one's `timeRangeLabel` ("20:00 – 04:00") is only accurate for the
/// overnight gap on a normal trading day and reads as wrong/confusing if
/// shown at, say, 11:00 AM on a Sunday (real bug caught by the user
/// 2026-07-26: dial correctly showed 11:29 ET but the copy said
/// "20:00 – 04:00"). This window's label covers the whole day instead.
/// Split from a combined weekend/holiday window into its own entry so the
/// copy can speak specifically about the weekend — see [marketHolidayWindowFor]
/// for the exchange-holiday counterpart.
MarketWindow weekendClosedWindowFor(AppLocalizations l10n) => MarketWindow(
  id: 'weekend-closed',
  emoji: '📅',
  shortHeadline: l10n.marketClockWindowWeekendClosedShortHeadline,
  shortDetail: l10n.marketClockWindowWeekendClosedShortDetail,
  fullTitle: l10n.marketClockWindowWeekendClosedFullTitle,
  timeRangeLabel: l10n.marketClockWindowWeekendClosedTimeRangeLabel,
  phase: MarketPhase.closed,
  startMinute: 0,
  endMinute: 1440,
  whatHappens: l10n.marketClockWindowWeekendClosedWhatHappens,
  whyItMatters: l10n.marketClockWindowWeekendClosedWhyItMatters,
  dangerForBeginner: l10n.marketClockWindowWeekendClosedDangerForBeginner,
  whatToDo: l10n.marketClockWindowWeekendClosedWhatToDo,
  fomoShieldTip: l10n.marketClockWindowWeekendClosedFomoShieldTip,
  stressTestPromoTitle: l10n.marketClockWindowWeekendClosedStressTestPromoTitle,
  stressTestPromoBody: l10n.marketClockWindowWeekendClosedStressTestPromoBody,
);

/// Shown all day on a full-closure exchange holiday (New Year's, MLK Day,
/// Independence Day, Thanksgiving, Christmas, etc.) — split out from
/// [weekendClosedWindowFor] so the copy can address a holiday specifically
/// rather than lumping it in with an ordinary weekend.
MarketWindow marketHolidayWindowFor(AppLocalizations l10n) => MarketWindow(
  id: 'market-holiday',
  emoji: '🎉',
  shortHeadline: l10n.marketClockWindowMarketHolidayShortHeadline,
  shortDetail: l10n.marketClockWindowMarketHolidayShortDetail,
  fullTitle: l10n.marketClockWindowMarketHolidayFullTitle,
  timeRangeLabel: l10n.marketClockWindowMarketHolidayTimeRangeLabel,
  phase: MarketPhase.closed,
  startMinute: 0,
  endMinute: 1440,
  whatHappens: l10n.marketClockWindowMarketHolidayWhatHappens,
  whyItMatters: l10n.marketClockWindowMarketHolidayWhyItMatters,
  dangerForBeginner: l10n.marketClockWindowMarketHolidayDangerForBeginner,
  whatToDo: l10n.marketClockWindowMarketHolidayWhatToDo,
  fomoShieldTip: l10n.marketClockWindowMarketHolidayFomoShieldTip,
  stressTestPromoTitle: l10n.marketClockWindowMarketHolidayStressTestPromoTitle,
  stressTestPromoBody: l10n.marketClockWindowMarketHolidayStressTestPromoBody,
);

/// Shown instead of the normal Market-Open sub-windows on an early-close day
/// (Black Friday / Christmas Eve), covering the compressed 12:00–13:00 ET
/// stretch right before the 1:00 PM close. This is a v1 simplification —
/// the 5 normal sub-windows don't fit the shortened session, see
/// docs/MARKET_CLOCK_SPEC.md.
MarketWindow earlyCloseWindowFor(AppLocalizations l10n) => MarketWindow(
  id: 'early-close-session',
  emoji: '⏳',
  shortHeadline: l10n.marketClockWindowEarlyCloseSessionShortHeadline,
  shortDetail: l10n.marketClockWindowEarlyCloseSessionShortDetail,
  fullTitle: l10n.marketClockWindowEarlyCloseSessionFullTitle,
  timeRangeLabel: '12:00 – 13:00',
  phase: MarketPhase.marketOpen,
  startMinute: 720,
  endMinute: 780,
  whatHappens: l10n.marketClockWindowEarlyCloseSessionWhatHappens,
  whyItMatters: l10n.marketClockWindowEarlyCloseSessionWhyItMatters,
  dangerForBeginner: l10n.marketClockWindowEarlyCloseSessionDangerForBeginner,
  whatToDo: l10n.marketClockWindowEarlyCloseSessionWhatToDo,
  stressTestPromoTitle:
      l10n.marketClockWindowEarlyCloseSessionStressTestPromoTitle,
  stressTestPromoBody:
      l10n.marketClockWindowEarlyCloseSessionStressTestPromoBody,
);

MarketWindow? findWindowById(AppLocalizations l10n, String id) {
  final earlyClose = earlyCloseWindowFor(l10n);
  if (id == earlyClose.id) return earlyClose;
  final weekend = weekendClosedWindowFor(l10n);
  if (id == weekend.id) return weekend;
  final holiday = marketHolidayWindowFor(l10n);
  if (id == holiday.id) return holiday;
  for (final w in marketWindowsFor(l10n)) {
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
  final dstStartUtc = DateTime.utc(
    year,
    3,
    _nthWeekdayDay(year, 3, DateTime.sunday, 2),
    7,
  );
  final dstEndUtc = DateTime.utc(
    year,
    11,
    _nthWeekdayDay(year, 11, DateTime.sunday, 1),
    6,
  );
  return !utc.isBefore(dstStartUtc) && utc.isBefore(dstEndUtc);
}

int _nthWeekdayDay(int year, int month, int weekday, int n) {
  final first = DateTime(year, month, 1);
  final firstWeekdayOffset = (weekday - first.weekday + 7) % 7;
  return 1 + firstWeekdayOffset + (n - 1) * 7;
}

int _lastWeekdayDay(int year, int month, int weekday) {
  final firstOfNextMonth = month == 12
      ? DateTime(year + 1, 1, 1)
      : DateTime(year, month + 1, 1);
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
  if (date.weekday == DateTime.saturday)
    return date.subtract(const Duration(days: 1));
  if (date.weekday == DateTime.sunday) return date.add(const Duration(days: 1));
  return date;
}

bool _isSameDate(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

bool isWeekend(DateTime dateEt) =>
    dateEt.weekday == DateTime.saturday || dateEt.weekday == DateTime.sunday;

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
    DateTime(
      y,
      11,
      _nthWeekdayDay(y, 11, DateTime.thursday, 4),
    ), // Thanksgiving
    _observedFixed(DateTime(y, 12, 25)), // Christmas Day
  ];
  return holidays.any((d) => _isSameDate(d, dateEt));
}

/// Black Friday + Christmas Eve (skipped if Dec 24 itself lands on a
/// weekend — approximates the "may not apply" caveat from the source list).
bool isEarlyCloseDay(DateTime dateEt) {
  final y = dateEt.year;
  final thanksgiving = DateTime(
    y,
    11,
    _nthWeekdayDay(y, 11, DateTime.thursday, 4),
  );
  final blackFriday = thanksgiving.add(const Duration(days: 1));
  final christmasEve = DateTime(y, 12, 24);
  if (_isSameDate(dateEt, blackFriday)) return true;
  if (_isSameDate(dateEt, christmasEve) && !isWeekend(christmasEve))
    return true;
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

MarketClockState resolveMarketClockState(AppLocalizations l10n, DateTime nowEt) {
  final minuteOfDay = nowEt.hour * 60 + nowEt.minute;

  if (isWeekend(nowEt)) {
    return MarketClockState(
      nowEt: nowEt,
      phase: MarketPhase.closed,
      window: weekendClosedWindowFor(l10n),
      isHoliday: true,
      isEarlyCloseDay: false,
    );
  }

  if (isFullClosureHoliday(nowEt)) {
    return MarketClockState(
      nowEt: nowEt,
      phase: MarketPhase.closed,
      window: marketHolidayWindowFor(l10n),
      isHoliday: true,
      isEarlyCloseDay: false,
    );
  }

  final earlyClose = isEarlyCloseDay(nowEt);
  final windows = marketWindowsFor(l10n);

  if (earlyClose) {
    if (minuteOfDay < 240 || minuteOfDay >= 1200) {
      return MarketClockState(
        nowEt: nowEt,
        phase: MarketPhase.closed,
        window: windows.last,
        isHoliday: false,
        isEarlyCloseDay: true,
      );
    }
    if (minuteOfDay < 570) {
      final w = minuteOfDay < 420 ? windows[0] : windows[1];
      return MarketClockState(
        nowEt: nowEt,
        phase: w.phase,
        window: w,
        isHoliday: false,
        isEarlyCloseDay: true,
      );
    }
    if (minuteOfDay < 630) {
      return MarketClockState(
        nowEt: nowEt,
        phase: MarketPhase.marketOpen,
        window: windows[2],
        isHoliday: false,
        isEarlyCloseDay: true,
      );
    }
    if (minuteOfDay < 720) {
      return MarketClockState(
        nowEt: nowEt,
        phase: MarketPhase.marketOpen,
        window: windows[3],
        isHoliday: false,
        isEarlyCloseDay: true,
      );
    }
    if (minuteOfDay < 780) {
      return MarketClockState(
        nowEt: nowEt,
        phase: MarketPhase.marketOpen,
        window: earlyCloseWindowFor(l10n),
        isHoliday: false,
        isEarlyCloseDay: true,
      );
    }
    return MarketClockState(
      nowEt: nowEt,
      phase: MarketPhase.afterHours,
      window: windows[7],
      isHoliday: false,
      isEarlyCloseDay: true,
    );
  }

  for (final w in windows) {
    if (w.id == 'closed') continue;
    if (minuteOfDay >= w.startMinute && minuteOfDay < w.endMinute) {
      return MarketClockState(
        nowEt: nowEt,
        phase: w.phase,
        window: w,
        isHoliday: false,
        isEarlyCloseDay: false,
      );
    }
  }

  return MarketClockState(
    nowEt: nowEt,
    phase: MarketPhase.closed,
    window: windows.last,
    isHoliday: false,
    isEarlyCloseDay: false,
  );
}

/// Locale-independent phase lookup — for callers that only need the current
/// NYSE [MarketPhase] (e.g. order_model.dart's session tagging,
/// price_header.dart's open/closed glow) and have no [AppLocalizations] to
/// pass, since they don't render any window copy. Mirrors the same
/// boundaries [resolveMarketClockState] uses, just without building a
/// [MarketWindow].
MarketPhase resolveMarketPhase(DateTime nowEt) {
  if (isWeekend(nowEt) || isFullClosureHoliday(nowEt)) {
    return MarketPhase.closed;
  }

  final minuteOfDay = nowEt.hour * 60 + nowEt.minute;

  if (isEarlyCloseDay(nowEt)) {
    if (minuteOfDay < 240 || minuteOfDay >= 1200) return MarketPhase.closed;
    if (minuteOfDay < 570) return MarketPhase.preMarket;
    if (minuteOfDay < 780) return MarketPhase.marketOpen;
    return MarketPhase.afterHours;
  }

  if (minuteOfDay >= 240 && minuteOfDay < 570) return MarketPhase.preMarket;
  if (minuteOfDay >= 570 && minuteOfDay < 960) return MarketPhase.marketOpen;
  if (minuteOfDay >= 960 && minuteOfDay < 1200) return MarketPhase.afterHours;
  return MarketPhase.closed;
}

// ---------------------------------------------------------------------------
// Ring geometry — 24h circular mapping, midnight at the top, clockwise.
// Returns a plain angle; callers with a Flutter BuildContext use their own
// Offset/cos/sin (via dart:math, already imported here for reference).
// ---------------------------------------------------------------------------

double angleForMinuteOfDay(int minute) => (minute / 1440) * 2 * pi - pi / 2;
