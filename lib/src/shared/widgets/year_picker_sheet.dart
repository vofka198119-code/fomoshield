import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_palette.dart';
import '../../core/theme/fomo_shield_theme.dart';
import '../../core/theme/themed_divider.dart';
import '../../core/theme/themed_header.dart';
import '../../l10n/gen/app_localizations.dart';
import 'card_frame.dart';

// ---------------------------------------------------------------------------
// Year picker bottom sheet — for any chart's YearPill header (2026-09-13,
// first built for the fund Investors screen's two flow charts, now shared
// with Fund Management's balance chart too). Same "pick one value from a
// short list" bottom-sheet convention as portfolio_screen.dart's own
// action sheets (handle bar + themedHeaderText + themedDivider + rows),
// not a raw PopupMenuButton, which can't render the app's themed
// gradient-border/fill look at all.
// ---------------------------------------------------------------------------

/// Shows a bottom sheet listing calendar years from [firstYear] through
/// the current year (descending). Resolves to the tapped year, or null if
/// dismissed without a selection.
Future<int?> showYearPickerSheet({
  required BuildContext context,
  required AppPalette palette,
  required int selectedYear,
  required int firstYear,
}) {
  final l10n = AppLocalizations.of(context)!;
  final currentYear = DateTime.now().year;
  final years = [for (var y = currentYear; y >= firstYear; y--) y];

  return showModalBottomSheet<int>(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: CardFrame(
          decoration: FomoShieldTheme.cardDecoration,
          palette: palette,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 14),
                  decoration: BoxDecoration(
                    color: palette.textBody.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              themedHeaderText(
                l10n.etfInvestorsYearPickerTitle,
                palette,
                FomoShieldTheme.cardTitle(),
              ),
              const SizedBox(height: 10),
              themedDivider(palette, indent: 0, endIndent: 0),
              for (final year in years)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    '$year',
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: year == selectedYear
                          ? FontWeight.w800
                          : FontWeight.w500,
                      color: year == selectedYear
                          ? palette.accentPrimary
                          : palette.textHeader,
                    ),
                  ),
                  onTap: () => Navigator.of(sheetContext).pop(year),
                ),
            ],
          ),
        ),
      ),
    ),
  );
}
