import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/theme_v2.dart';
import '../../../core/theme/typography_helpers.dart';
import '../../../core/theme/fomo_shield_theme.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/themed_header.dart';
import '../../../core/theme/themed_divider.dart';
import '../../../shared/widgets/card_frame.dart';
import '../../../shared/widgets/more_less_pill.dart';
import '../../../core/cache/logo_providers.dart';
import '../../../shared/utils/currency_format.dart';
import '../../../shared/widgets/company_logo.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../models/fund.dart';

// ---------------------------------------------------------------------------
// FundManagementHoldingsCard — the head/team-facing "HOLDINGS" widget,
// modeled directly on Portfolio's own PortfolioHoldingsWidget (2026-09-12
// ask: study that widget's row/pagination before building this one), NOT a
// reuse of the simpler percent-only FundHoldingsCard that's already on the
// PUBLIC FundDetailScreen — dropping that same card in here read as a
// duplicate of the public card instead of a real management-panel widget.
// Same 72px ring-bordered-logo row and "More (N)/Less" 10-row preview
// pagination as Portfolio; dollar value + P&L on the right, same as
// Portfolio's own row — the fund's weighted-average cost basis
// (Migration 021, fund_holdings.avg_cost) makes that possible. A holding
// bought before that migration ran reports avgCost 0; shown as "—" rather
// than a made-up 100% gain.
// ---------------------------------------------------------------------------
class FundManagementHoldingsCard extends StatefulWidget {
  final FundDetail fund;
  final AppPalette palette;
  final void Function(FundHolding holding) onHoldingTap;

  const FundManagementHoldingsCard({
    super.key,
    required this.fund,
    required this.palette,
    required this.onHoldingTap,
  });

  @override
  State<FundManagementHoldingsCard> createState() =>
      _FundManagementHoldingsCardState();
}

class _FundManagementHoldingsCardState
    extends State<FundManagementHoldingsCard> {
  static const int _previewLimit = 10;
  bool _showAll = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final palette = widget.palette;
    final sorted = [...widget.fund.holdings]
      ..sort((a, b) => b.value.compareTo(a.value));
    final display = _showAll ? sorted : sorted.take(_previewLimit).toList();

    return CardFrame(
      padding: EdgeInsets.zero,
      decoration: FomoShieldTheme.cardDecoration,
      palette: palette,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 14, 22, 14),
            child: Align(
              alignment: Alignment.centerLeft,
              child: themedHeaderText(
                l10n.etfFundDetailHoldingsTitle,
                palette,
                FomoShieldTheme.cardTitle(),
              ),
            ),
          ),
          if (sorted.isEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Text(
                l10n.etfFundDetailHoldingsEmpty,
                style: GoogleFonts.inter(fontSize: 13, color: palette.textBody),
              ),
            )
          else ...[
            themedDivider(palette),
            for (int i = 0; i < display.length; i++)
              _Row(
                holding: display[i],
                showDivider: i < display.length - 1,
                palette: palette,
                onTap: () => widget.onHoldingTap(display[i]),
              ),
            if (sorted.length > _previewLimit)
              MoreLessPill(
                label: _showAll
                    ? l10n.commonLess
                    : l10n.commonMoreCount(sorted.length - _previewLimit),
                onTap: () => setState(() => _showAll = !_showAll),
                palette: palette,
              )
            else
              const SizedBox(height: 8),
          ],
        ],
      ),
    );
  }
}

class _Row extends ConsumerWidget {
  final FundHolding holding;
  final bool showDivider;
  final AppPalette palette;
  final VoidCallback onTap;

  const _Row({
    required this.holding,
    required this.showDivider,
    required this.palette,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logoUrl = ref.watch(cachedLogoProvider(holding.symbol)).valueOrNull;
    final name =
        ref.watch(resolvedCompanyNameProvider(holding.symbol)).valueOrNull ??
        holding.symbol;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.opaque,
          child: Container(
            constraints: const BoxConstraints(minHeight: 72),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: palette.accentPrimary,
                      width: 1.5,
                    ),
                  ),
                  padding: const EdgeInsets.all(1.5),
                  child: ClipOval(
                    child: SizedBox(
                      width: 36,
                      height: 36,
                      child: CompanyLogo(
                        ticker: holding.symbol,
                        logoUrl: logoUrl,
                        radius: 18,
                        resolveIfMissing: false,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: palette.textHeader,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        holding.symbol,
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: palette.textBody,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        AppLocalizations.of(
                          context,
                        )!.sharesCount(holding.quantity.toStringAsFixed(2)),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: palette.textBody,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: themedPriceText(
                        formatUsd(holding.value),
                        palette,
                        interNums(fontSize: 14, fontWeight: FontWeight.w700),
                      ),
                    ),
                    const SizedBox(height: 2),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: holding.avgCost <= 0
                          ? Text(
                              '—',
                              style: interNums(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: ThemeV2.textSecondary,
                              ),
                            )
                          : Text(
                              '${formatUsdSigned(holding.pnl)} '
                              '(${holding.pnl >= 0 ? '+' : ''}${holding.pnlPercent.toStringAsFixed(2)}%)',
                              style: interNums(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: holding.pnl >= 0
                                    ? ThemeV2.success
                                    : ThemeV2.loss,
                              ),
                            ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        if (showDivider) themedRowDivider(palette),
      ],
    );
  }
}
