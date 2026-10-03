import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/themed_divider.dart';
import '../models/fund.dart';

// ---------------------------------------------------------------------------
// FundMiniCard — one row inside a Funds browse lane (ETF Fund Emulation).
// Same row chrome as Search's CompanyMiniCard (ring avatar, name + subtitle
// stacked, trailing chevron, thin bottom divider) — see that file's own doc
// comment for the shared recipe, including its "no price here" reasoning.
//
// Used to show NAV/unit + a up/down arrow here, but the arrow compared live
// navPerUnit against a hardcoded $10.00 launch reference — not any real
// prevClose/change — so it was static and misleading regardless of what
// actually happened to the fund (found live 2026-09-16). Rather than wire
// up a real per-row change%, dropped the price here entirely, matching
// CompanyMiniCard's own precedent: a lane full of these rows should never
// carry live-pricing weight — the fund's real, live NAV only shows once the
// user taps into its own detail card.
// ---------------------------------------------------------------------------

class FundMiniCard extends StatelessWidget {
  final Fund fund;
  final AppPalette palette;
  final VoidCallback? onTap;
  final bool showDivider;

  const FundMiniCard({
    super.key,
    required this.fund,
    required this.palette,
    this.onTap,
    this.showDivider = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.opaque,
          child: Container(
            constraints: const BoxConstraints(minHeight: 66),
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 6),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: palette.accentPrimary,
                      width: 1.5,
                    ),
                  ),
                  child: CircleAvatar(
                    radius: 18,
                    backgroundColor: palette.accentPrimary.withValues(
                      alpha: 0.15,
                    ),
                    child: Text(
                      fund.ticker.length > 4
                          ? fund.ticker.substring(0, 4)
                          : fund.ticker,
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: palette.accentPrimary,
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
                        fund.name,
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
                        fund.ticker,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          // Same fix as watchlist_widget.dart's tile — see
                          // its comment.
                          color: palette.titleGradient != null
                              ? Colors.white.withValues(alpha: 0.85)
                              : palette.textBody,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.chevron_right_rounded,
                  color: palette.textBody,
                  size: 20,
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
