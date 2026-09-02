import '../../l10n/gen/app_localizations.dart';
import '../models/app_notification.dart';
import 'news_scenario_l10n.dart';

// ---------------------------------------------------------------------------
// Notification display text — locale-aware resolution
// ---------------------------------------------------------------------------
// AppNotification.title/detail are the English fallback, set once at fire
// time deep in engine code with no BuildContext (see project memory's
// "notification text has no BuildContext" note). For the two types that
// carry the structured params to redo this properly (news, priceSwing),
// resolve a localized title/detail here instead — every render site
// (notifications screen, the live popup) should go through these two
// functions rather than reading `.title`/`.detail` directly.
// ---------------------------------------------------------------------------

// [AppNotificationType.stressTestCompleted]'s duration is stored as the
// [TestDuration] enum's own name (e.g. 'week1') rather than the enum
// itself — see AppNotification.stressTestDurationKey's doc comment for
// why. Re-derives the label from the same ARB keys TestDuration.
// localizedLabel uses (features/stress_test/stress_test_models.dart), so
// the translated text itself isn't duplicated, just this small mapping.
String _stressTestDurationLabel(AppLocalizations l10n, String? key) {
  switch (key) {
    case 'week1':
      return l10n.testDuration1Week;
    case 'month1':
      return l10n.testDuration1Month;
    case 'months3':
      return l10n.testDuration3Months;
    case 'infinite':
      return l10n.testDurationInfinite;
    case 'custom':
      return l10n.testDurationCustom;
    default:
      return key ?? '';
  }
}

String notificationTitle(AppNotification n, AppLocalizations l10n) {
  if (n.type == AppNotificationType.news && n.newsScenarioIndex != null) {
    return newsScenarioHeadline(l10n, n.newsScenarioIndex!);
  }
  if (n.type == AppNotificationType.stressTestCompleted) {
    return l10n.notificationsStressTestCompletedTitle;
  }
  if (n.type == AppNotificationType.priceSwing &&
      n.priceSwingIsUp != null &&
      n.priceSwingChangePercent != null) {
    final name = n.companyName ?? n.symbol ?? '';
    final pct = n.priceSwingChangePercent!.toStringAsFixed(1);
    return n.priceSwingIsUp!
        ? l10n.notificationsPriceSwingTitleUp(name, pct)
        : l10n.notificationsPriceSwingTitleDown(name, pct);
  }
  return n.title;
}

String notificationDetail(AppNotification n, AppLocalizations l10n) {
  if (n.type == AppNotificationType.news && n.newsScenarioIndex != null) {
    return newsScenarioDescription(l10n, n.newsScenarioIndex!);
  }
  if (n.type == AppNotificationType.stressTestCompleted &&
      n.stressTestPnlPercent != null) {
    final sign = n.stressTestPnlPercent! >= 0 ? '+' : '';
    final pct = '$sign${n.stressTestPnlPercent!.toStringAsFixed(2)}';
    final duration = _stressTestDurationLabel(l10n, n.stressTestDurationKey);
    return l10n.notificationsStressTestCompletedDetail(duration, pct);
  }
  if (n.type == AppNotificationType.priceSwing &&
      n.priceSwingIsUp != null &&
      n.priceSwingChangePercent != null &&
      n.priceSwingWindowMinutes != null &&
      n.portfolioLabel != null) {
    final sign = n.priceSwingIsUp! ? '+' : '-';
    final pct = '$sign${n.priceSwingChangePercent!.toStringAsFixed(1)}';
    // portfolioLabel is always built as 'Market Simulation — {duration}' (see
    // noise_engine.dart et al.) — strip the prefix so {duration} in the
    // template below reads as just "1 Month", not the whole label
    // doubled up with "Stress Test —" already baked into the sentence.
    const prefix = 'Market Simulation — ';
    final duration = n.portfolioLabel!.startsWith(prefix)
        ? n.portfolioLabel!.substring(prefix.length)
        : n.portfolioLabel!;
    return l10n.notificationsPriceSwingDetail(
      duration,
      n.symbol ?? '',
      pct,
      n.priceSwingWindowMinutes!,
    );
  }
  return n.detail;
}
