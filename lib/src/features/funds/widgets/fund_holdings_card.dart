import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/cache/logo_providers.dart';
import '../../../core/theme/fomo_shield_theme.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/themed_header.dart';
import '../../../core/theme/themed_divider.dart';
import '../../../core/theme/typography_helpers.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../../shared/widgets/card_frame.dart';
import '../../../shared/widgets/company_logo.dart';
import '../../../shared/widgets/donut_ring_painter.dart';
import '../models/fund.dart';

// Same card/row chrome as Portfolio's PortfolioHoldingsWidget (light-card
// skin, ring-bordered logo, name/ticker left) — percent-of-fund on the
// right instead of value/P&L, since a fund holding has no per-user cost
// basis.
class FundHoldingsCard extends StatelessWidget {
  final FundDetail fund;
  final AppPalette palette;

  const FundHoldingsCard({
    super.key,
    required this.fund,
    required this.palette,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final total = fund.holdings.fold<double>(0, (sum, h) => sum + h.value);
    final sorted = [...fund.holdings]
      ..sort((a, b) => b.value.compareTo(a.value));

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
          themedDivider(palette),
          if (sorted.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Text(
                l10n.etfFundDetailHoldingsEmpty,
                style: GoogleFonts.inter(fontSize: 13, color: palette.textBody),
              ),
            )
          else ...[
            for (int i = 0; i < sorted.length; i++)
              _Row(
                holding: sorted[i],
                percent: total > 0 ? sorted[i].value / total * 100 : 0,
                colorIndex: i,
                showDivider: i < sorted.length - 1,
                palette: palette,
              ),
            const SizedBox(height: 8),
          ],
        ],
      ),
    );
  }
}

class _Row extends ConsumerWidget {
  final FundHolding holding;
  final double percent;
  final int colorIndex;
  final bool showDivider;
  final AppPalette palette;

  const _Row({
    required this.holding,
    required this.percent,
    required this.colorIndex,
    required this.showDivider,
    required this.palette,
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
        // Deliberately not tappable (2026-09-12) -- this used to push
        // /company/:symbol, but that screen unconditionally shows the
        // viewer's OWN personal "Мои инвестиции" position for that symbol,
        // with zero concept of "this is the fund's holding, not yours" --
        // confusing when the viewer happens to hold the same stock
        // personally too. This row is informational only, tap or not.
        Container(
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
                    color: donutAllocationColor(
                      colorIndex,
                    ).withValues(alpha: 0.7),
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
                  ],
                ),
              ),
              const SizedBox(width: 8),
              themedPriceText(
                '${percent.toStringAsFixed(1)}%',
                palette,
                interNums(fontSize: 14, fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
        if (showDivider) themedRowDivider(palette),
      ],
    );
  }
}
