import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/app_notification.dart';
import '../../../core/notifications/notification_providers.dart';
import '../../../core/overlay/app_notification_popup.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../../shared/utils/currency_format.dart';
import '../../portfolio/portfolio_providers.dart';
import '../models/fund_liquidation_payout.dart';
import 'employee_providers.dart';

// ---------------------------------------------------------------------------
// Fund Liquidation Payout catch-up — the client-side half of Phase A (see
// fomoshield_etf_bankruptcy_flow_spec memory). Real Portfolio cash has no
// server write path, so a bankruptcy settlement sits in
// fund_liquidation_payouts (unclaimed) until the recipient's own client
// picks it up here, same opportunistic "call this on Portfolio open + its
// periodic timer, alongside checkWeeklyPayout" shape as
// weekly_payout_provider.dart.
//
// Claim-then-credit, not credit-then-claim: the claim endpoint is called
// FIRST and its response (the confirmed, server-marked-claimed row) is
// what actually gets credited locally. A claim call that fails leaves the
// payout untouched server-side, to be retried next check-in -- crediting
// first and claiming after would risk a double-credit if the claim call
// failed post-credit (same failure class as
// [[fomoshield_weekly_payout_double_credit_fix]]).
// ---------------------------------------------------------------------------

Future<void> checkFundLiquidationPayouts(
  WidgetRef ref,
  AppLocalizations l10n,
) async {
  final portfolios = ref.read(portfoliosProvider);
  if (portfolios.isEmpty) return;
  // Single-portfolio system, same assumption weekly_payout_provider.dart
  // already makes.
  final portfolio = portfolios.first;

  final api = ref.read(employeeApiServiceProvider);
  List<FundLiquidationPayout> unclaimed;
  try {
    unclaimed = await api.getMyLiquidationPayouts();
  } catch (_) {
    // Opportunistic network call -- just retry on the next check-in.
    return;
  }
  if (unclaimed.isEmpty) return;

  final notifier = ref.read(notificationsProvider.notifier);

  for (final pending in unclaimed) {
    final String payoutId = pending.id;
    try {
      final claimed = await api.claimLiquidationPayout(payoutId);

      ref
          .read(portfoliosProvider.notifier)
          .creditCapital(portfolio.id, claimed.amount);

      final fundLabel = claimed.fundName ?? claimed.fundTicker ?? '';
      pushAppNotification(
        notifier,
        AppNotification(
          id: 'notif_${DateTime.now().microsecondsSinceEpoch}_liq_$payoutId',
          type: AppNotificationType.fundLiquidation,
          portfolioKind: NotificationPortfolioKind.real,
          portfolioId: portfolio.id,
          portfolioLabel: portfolio.displayName(l10n),
          title: l10n.fundLiquidationNotifTitle,
          detail: l10n.fundLiquidationNotifDetail(
            fundLabel,
            formatUsd(claimed.amount),
          ),
          createdAt: DateTime.now(),
          payoutAmount: claimed.amount,
          fundLiquidationFundName: claimed.fundName,
          fundLiquidationRecipientType: claimed.recipientType,
          fundLiquidationAssetsSoldValue: claimed.assetsSoldValue,
          fundLiquidationUnitsHeld: claimed.unitsHeld,
          fundLiquidationBrokerCommission: claimed.brokerCommission,
          fundLiquidationNeustoika: claimed.neustoika,
        ),
      );
    } catch (_) {
      // This one payout failed to claim (e.g. a network blip, or another
      // device already claimed it first) -- move on, it'll be re-offered
      // next check-in if it's genuinely still unclaimed.
      continue;
    }
  }
}
