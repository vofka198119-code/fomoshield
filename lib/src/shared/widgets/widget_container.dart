import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/theme_v2.dart';
import '../../core/theme/app_palette.dart';
import '../../core/theme/themed_header.dart';
import '../../core/theme/themed_divider.dart';
import '../../l10n/gen/app_localizations.dart';
import 'card_frame.dart';

// ---------------------------------------------------------------------------
// Widget Container — Card wrapper
// ---------------------------------------------------------------------------
// Renders a titled card with a chevron header, compact item list,
// thin dividers between items, and a "More" footer button.
// ---------------------------------------------------------------------------

class WidgetContainer extends StatelessWidget {
  final String title;
  // Null means "this header doesn't navigate anywhere" — no chevron, no
  // tap ripple. Passing a no-op `() {}` used to render a chevron that
  // promised navigation and did nothing, which read as a stray artifact.
  final VoidCallback? onTap;
  final List<Widget> children;
  // Null falls back to the localized "More" (see build()) — most callers
  // don't need a custom footer label, only portfolio_trade_history_widget
  // overrides it with a count.
  final String? footerText;
  final bool showFooter;
  final String? emptyText;
  // Optional header-right action (e.g. a "+" add button), shown before the
  // chevron. Has its own tap target — safe to combine with [onTap].
  final Widget? trailing;

  // Null (the default) is a complete no-op — every existing call site is
  // unaffected unless it opts in by passing a palette. See ShieldSignalWidget
  // for the reference pattern this mirrors (CardFrame + themedHeaderText +
  // themedDivider).
  final AppPalette? palette;

  const WidgetContainer({
    super.key,
    required this.title,
    this.onTap,
    this.children = const [],
    this.footerText,
    this.showFooter = true,
    this.emptyText,
    this.trailing,
    this.palette,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final hasTap = onTap != null;
    final resolvedFooterText = footerText ?? l10n.commonMore;
    final effectivePalette = palette ?? AppPalette.standard;
    final titleStyle = GoogleFonts.inter(
      fontSize: 13,
      fontWeight: FontWeight.w700,
      letterSpacing: 1.2,
    );
    return CardFrame(
      padding: EdgeInsets.zero,
      palette: palette,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- Header ---
          InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(22, 14, 22, 14),
              child: Row(
                children: [
                  themedHeaderText(title, effectivePalette, titleStyle),
                  const Spacer(),
                  if (trailing != null) ...[
                    trailing!,
                    if (hasTap) const SizedBox(width: 8),
                  ],
                  if (hasTap)
                    Icon(
                      Icons.chevron_right_rounded,
                      color: palette?.textBody ?? ThemeV2.textSecondary,
                      size: 20,
                    ),
                ],
              ),
            ),
          ),

          // --- Title/content separator (matches TRADE HISTORY reference) ---
          if (children.isNotEmpty || emptyText != null)
            themedDivider(effectivePalette),

          // --- Items with thin dividers (indented) ---
          if (children.isNotEmpty)
            ...List.generate(children.length * 2 - 1, (i) {
              if (i.isOdd) {
                return themedDivider(effectivePalette);
              }
              return children[i ~/ 2];
            }),

          // --- Footer "More" button ---
          if (children.isNotEmpty && showFooter && hasTap)
            Column(
              children: [
                themedDivider(effectivePalette, indent: 0, endIndent: 0),
                InkWell(
                  onTap: onTap,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Center(
                      child: Text(
                        resolvedFooterText,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: palette?.accentPrimary ?? ThemeV2.primary,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),

          // --- Empty state fallback ---
          if (children.isEmpty && emptyText != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
              child: Center(
                child: Text(
                  emptyText!,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: palette?.textBody ?? ThemeV2.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
