// ---------------------------------------------------------------------------
// AppNotification — one entry in the app-wide notification system (bell
// icon on Home). Covers trades (both portfolio kinds), limit order
// lifecycle, News events, and stress-test completion.
// ---------------------------------------------------------------------------

enum AppNotificationType {
  buy,
  sell,
  limitOrderPlaced,
  limitOrderFilled,
  news,
  stressTestCompleted,
  priceSwing,
  goalUpdated,
  // Premium/admin weekly auto-deposit (Portfolio: +$180, Stress Test
  // Custom-duration DCA: +$200) — see weekly_payout_provider.dart.
  weeklyPayout,
  // Fired once when a weekly payout stream stops because the subscription
  // wasn't renewed (as opposed to every missed week — see
  // weekly_payout_provider.dart's tier-transition tracking).
  weeklyPayoutPaused,
  // Fired on any free↔premium transition, independent of the payout
  // mechanic above.
  subscriptionStatusChanged,
}

/// Which of the app's two separate portfolio systems this notification
/// belongs to — real (features/portfolio + features/orders) or a specific
/// Stress Test session.
enum NotificationPortfolioKind { real, stressTest }

class AppNotification {
  final String id;
  final AppNotificationType type;
  final NotificationPortfolioKind portfolioKind;

  /// Real portfolio id, or Stress Test session id — whichever `portfolioKind`
  /// says. Used to resolve where to navigate on tap.
  final String? portfolioId;

  /// Resolved display label at the moment this notification was created
  /// (e.g. a stress-test duration label, or a real portfolio's name) — not
  /// re-derived later, since the source session/portfolio may not exist by
  /// the time the user opens their notification history.
  final String? portfolioLabel;

  final String? symbol;
  final String? companyName;
  final String? logoUrl;

  /// Set only for [AppNotificationType.buy]/[sell] on a real portfolio —
  /// the fill's [Transaction.orderId], so tapping the notification can
  /// jump to that exact trade's detail screen instead of just the
  /// company page.
  final String? orderId;

  /// Set only for [AppNotificationType.buy]/[sell] on a Stress Test
  /// session — the fill's own [StressTestTrade.date] (that model has no
  /// id of its own), so tapping can find that exact trade in the
  /// session's trade list instead of just jumping to the company page.
  final DateTime? tradeTimestamp;

  /// English fallback text — still what any consumer without richer i18n
  /// support uses as-is (e.g. an OS-level push). Screens with real
  /// AppLocalizations access (notifications screen/popup) prefer the
  /// structured fields below when present, re-localizing at render time,
  /// since the engine code that fires these has no BuildContext to
  /// resolve a locale from (see project memory).
  final String title;
  final String detail;
  final DateTime createdAt;
  final bool read;

  /// Set only for [AppNotificationType.news] — this event's index into
  /// news_event.dart's `newsScenarios`, resolved via
  /// news_scenario_l10n.dart instead of reading [title]/[detail] above.
  final int? newsScenarioIndex;

  /// Set only for [AppNotificationType.priceSwing] — lets the render
  /// side rebuild a localized title/detail instead of reading the
  /// English [title]/[detail] above.
  final bool? priceSwingIsUp;
  final double? priceSwingChangePercent;
  final int? priceSwingWindowMinutes;

  /// Set only for [AppNotificationType.weeklyPayout] — the raw credited
  /// amount, so its detail screen can show a real "Amount" row instead of
  /// re-parsing it back out of the locale-formatted [detail] string. Null
  /// for every other type and for payout notifications saved before this
  /// field existed.
  final double? payoutAmount;

  /// Set only for [AppNotificationType.stressTestCompleted] — the
  /// session's [TestDuration] enum name (e.g. 'week1', 'month1') rather
  /// than the enum itself, so this core model doesn't have to import a
  /// features/stress_test type (same reasoning as [newsScenarioIndex]
  /// re-deriving text locally instead of importing the news feature's
  /// scenario model — see news_scenario_l10n.dart). Paired with
  /// [stressTestPnlPercent] so the render side can rebuild a localized
  /// title/detail instead of reading the English [title]/[detail] above.
  final String? stressTestDurationKey;
  final double? stressTestPnlPercent;

  /// Set only for [AppNotificationType.limitOrderFilled] — lets the render
  /// side rebuild a localized title/detail instead of reading the English
  /// [title]/[detail] above. Needed because both fire sites (order_provider.dart's
  /// onFill, stress_test_pending_orders_provider.dart's fill check) are
  /// background price-tick callbacks with no BuildContext to localize
  /// through at the moment the order actually fills — unlike
  /// limitOrderPlaced, which always fires from a screen that has one.
  final bool? fillIsBuy;
  final double? fillQuantity;
  final double? fillPrice;

  const AppNotification({
    required this.id,
    required this.type,
    required this.portfolioKind,
    this.portfolioId,
    this.portfolioLabel,
    this.symbol,
    this.companyName,
    this.logoUrl,
    this.orderId,
    this.tradeTimestamp,
    required this.title,
    required this.detail,
    required this.createdAt,
    this.read = false,
    this.newsScenarioIndex,
    this.priceSwingIsUp,
    this.priceSwingChangePercent,
    this.priceSwingWindowMinutes,
    this.payoutAmount,
    this.stressTestDurationKey,
    this.stressTestPnlPercent,
    this.fillIsBuy,
    this.fillQuantity,
    this.fillPrice,
  });

  AppNotification copyWith({bool? read}) => AppNotification(
    id: id,
    type: type,
    portfolioKind: portfolioKind,
    portfolioId: portfolioId,
    portfolioLabel: portfolioLabel,
    symbol: symbol,
    companyName: companyName,
    logoUrl: logoUrl,
    orderId: orderId,
    tradeTimestamp: tradeTimestamp,
    title: title,
    detail: detail,
    createdAt: createdAt,
    read: read ?? this.read,
    newsScenarioIndex: newsScenarioIndex,
    priceSwingIsUp: priceSwingIsUp,
    priceSwingChangePercent: priceSwingChangePercent,
    priceSwingWindowMinutes: priceSwingWindowMinutes,
    payoutAmount: payoutAmount,
    stressTestDurationKey: stressTestDurationKey,
    stressTestPnlPercent: stressTestPnlPercent,
    fillIsBuy: fillIsBuy,
    fillQuantity: fillQuantity,
    fillPrice: fillPrice,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type.name,
    'portfolioKind': portfolioKind.name,
    'portfolioId': portfolioId,
    'portfolioLabel': portfolioLabel,
    'symbol': symbol,
    'companyName': companyName,
    'logoUrl': logoUrl,
    'orderId': orderId,
    'tradeTimestamp': tradeTimestamp?.toIso8601String(),
    'title': title,
    'detail': detail,
    'createdAt': createdAt.toIso8601String(),
    'read': read,
    'newsScenarioIndex': newsScenarioIndex,
    'priceSwingIsUp': priceSwingIsUp,
    'priceSwingChangePercent': priceSwingChangePercent,
    'priceSwingWindowMinutes': priceSwingWindowMinutes,
    'payoutAmount': payoutAmount,
    'stressTestDurationKey': stressTestDurationKey,
    'stressTestPnlPercent': stressTestPnlPercent,
    'fillIsBuy': fillIsBuy,
    'fillQuantity': fillQuantity,
    'fillPrice': fillPrice,
  };

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'] as String,
      type: AppNotificationType.values.firstWhere(
        (t) => t.name == json['type'],
        orElse: () => AppNotificationType.buy,
      ),
      portfolioKind: NotificationPortfolioKind.values.firstWhere(
        (k) => k.name == json['portfolioKind'],
        orElse: () => NotificationPortfolioKind.real,
      ),
      portfolioId: json['portfolioId'] as String?,
      portfolioLabel: json['portfolioLabel'] as String?,
      symbol: json['symbol'] as String?,
      companyName: json['companyName'] as String?,
      logoUrl: json['logoUrl'] as String?,
      orderId: json['orderId'] as String?,
      tradeTimestamp: json['tradeTimestamp'] == null
          ? null
          : DateTime.parse(json['tradeTimestamp'] as String),
      title: json['title'] as String,
      detail: json['detail'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      read: json['read'] as bool? ?? false,
      newsScenarioIndex: json['newsScenarioIndex'] as int?,
      priceSwingIsUp: json['priceSwingIsUp'] as bool?,
      priceSwingChangePercent: (json['priceSwingChangePercent'] as num?)
          ?.toDouble(),
      priceSwingWindowMinutes: json['priceSwingWindowMinutes'] as int?,
      payoutAmount: (json['payoutAmount'] as num?)?.toDouble(),
      stressTestDurationKey: json['stressTestDurationKey'] as String?,
      stressTestPnlPercent: (json['stressTestPnlPercent'] as num?)?.toDouble(),
      fillIsBuy: json['fillIsBuy'] as bool?,
      fillQuantity: (json['fillQuantity'] as num?)?.toDouble(),
      fillPrice: (json['fillPrice'] as num?)?.toDouble(),
    );
  }
}
