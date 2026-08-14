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

  final String title;
  final String detail;
  final DateTime createdAt;
  final bool read;

  const AppNotification({
    required this.id,
    required this.type,
    required this.portfolioKind,
    this.portfolioId,
    this.portfolioLabel,
    this.symbol,
    this.companyName,
    this.logoUrl,
    required this.title,
    required this.detail,
    required this.createdAt,
    this.read = false,
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
    title: title,
    detail: detail,
    createdAt: createdAt,
    read: read ?? this.read,
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
    'title': title,
    'detail': detail,
    'createdAt': createdAt.toIso8601String(),
    'read': read,
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
      title: json['title'] as String,
      detail: json['detail'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      read: json['read'] as bool? ?? false,
    );
  }
}
