import 'package:flutter/material.dart';
import '../../l10n/gen/app_localizations.dart';

// ---------------------------------------------------------------------------
// User-facing notices for a rewarded ad that failed to load/show (AdMob
// no-fill, network error, ad blocker). Never shown when the user dismissed
// the ad themselves — only for RewardedAdOutcome.failed.
//
// Without these, a no-fill is indistinguishable from a broken app: the user
// accepts the ad offer, nothing happens, and the action they asked for
// silently doesn't occur.
// ---------------------------------------------------------------------------

/// For gates that let the action through anyway (fail-open) — currently the
/// order placement gate only, where blocking would kill the app's core
/// action for hours.
void showAdLetThroughNotice(BuildContext context) =>
    _notice(context, (l10n) => l10n.adUnavailableFallback);

/// For gates that stay closed when the ad fails, so the user knows their tap
/// wasn't the problem and can just retry. Used where failing open would hand
/// unlimited free access to anyone running an ad blocker.
void showAdRetryNotice(BuildContext context) =>
    _notice(context, (l10n) => l10n.adUnavailableRetry);

void _notice(BuildContext context, String Function(AppLocalizations) message) {
  final l10n = AppLocalizations.of(context);
  if (l10n == null) return;
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message(l10n)),
      behavior: SnackBarBehavior.floating,
    ),
  );
}
