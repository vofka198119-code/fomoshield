import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/theme_variant_provider.dart';
import '../../../core/theme/themed_header.dart';
import '../../../core/theme/themed_divider.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../../shared/widgets/more_less_pill.dart';
import '../models/fund.dart';
import 'fund_mini_card.dart';

// ---------------------------------------------------------------------------
// FundListScreen — full list behind a Funds browse lane's "see all". Same
// pushed-route-not-sheet + reveal-6-at-a-time pattern as Search's
// CompanyListScreen (see its own doc comment for why) — no per-row network
// cost here to worry about (fund data, including NAV, is already all in
// the list this screen was handed), so the reveal cap is purely about not
// rendering a very long list in one frame, not about capping fetches.
// ---------------------------------------------------------------------------

const int _revealBatchSize = 6;

class FundListScreen extends ConsumerStatefulWidget {
  final String title;
  final List<Fund> funds;
  final void Function(Fund fund) onTapFund;

  const FundListScreen({
    super.key,
    required this.title,
    required this.funds,
    required this.onTapFund,
  });

  @override
  ConsumerState<FundListScreen> createState() => _FundListScreenState();
}

class _FundListScreenState extends ConsumerState<FundListScreen> {
  int _revealedCount = _revealBatchSize;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final palette = resolveAppPalette(ref.watch(themeVariantProvider));
    final revealed = _revealedCount.clamp(0, widget.funds.length);
    final hasMore = revealed < widget.funds.length;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        centerTitle: true,
        leading: themedBackButton(context, palette),
        title: themedHeaderText(
          widget.title,
          palette,
          GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            letterSpacing: 1,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    '${widget.funds.length}',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: palette.textBody,
                    ),
                  ),
                ],
              ),
            ),
            palette.dividerGradient != null
                ? themedDivider(palette, indent: 0, endIndent: 0)
                : const Divider(height: 1, color: Color(0x0F000000)),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(vertical: 4),
                itemCount: revealed + (hasMore ? 1 : 0),
                separatorBuilder: (_, i) => i >= revealed - 1
                    ? const SizedBox.shrink()
                    : palette.dividerGradient != null
                    ? themedDivider(palette, indent: 68, endIndent: 0)
                    : const Divider(
                        height: 1,
                        indent: 68,
                        color: Color(0x0F000000),
                      ),
                itemBuilder: (context, i) {
                  if (i >= revealed) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: MoreLessPill(
                        label: l10n.commonMoreCount(
                          widget.funds.length - revealed,
                        ),
                        onTap: () =>
                            setState(() => _revealedCount += _revealBatchSize),
                        palette: palette,
                        margin: EdgeInsets.zero,
                      ),
                    );
                  }
                  return FundMiniCard(
                    fund: widget.funds[i],
                    palette: palette,
                    onTap: () => widget.onTapFund(widget.funds[i]),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
