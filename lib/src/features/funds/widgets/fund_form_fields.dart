import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/theme_v2.dart';
import '../../../core/theme/themed_border.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../sector_labels.dart';

// ---------------------------------------------------------------------------
// Fund form field chrome — extracted from create_fund_screen.dart (2026-09-29)
// when the fund EDIT form needed the same look. Deliberately extracted rather
// than copied: every one of these carries a fix found on a real device, and a
// second hand-made copy would drift away from them the moment one is touched.
// Both forms now share one implementation.
// ---------------------------------------------------------------------------

/// A real header above the field rather than a floating `labelText` shrunk
/// into it — the small floating label read as unclear at a glance (found
/// live 2026-09-08). Same weight/size as the Sectors section's own label,
/// so every field in a fund form shares one header style.
Widget fundFieldHeader(AppPalette palette, String text) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(
      text,
      style: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: palette.textHeader,
      ),
    ),
  );
}

/// `filled: false` is required: the app-wide InputDecorationTheme
/// (theme_v2.dart) defaults EVERY text field to filled:true with an opaque
/// WHITE fillColor. Without this override that white fill paints straight
/// over [fundFieldWrapper]'s themed background, making the field look flat
/// white whatever the theme (found live 2026-09-06 on Luxury Gold). The
/// same root cause bit two more fund fields on 2026-09-15 — reach for this
/// helper rather than writing a bare InputDecoration.
InputDecoration fundFieldDecoration(AppPalette palette, {String? hint}) {
  return InputDecoration(
    filled: false,
    hintText: hint,
    hintStyle: GoogleFonts.inter(
      color: palette.textHeader.withValues(alpha: 0.5),
      fontSize: 13,
    ),
    border: InputBorder.none,
    enabledBorder: InputBorder.none,
    focusedBorder: InputBorder.none,
  );
}

/// [hasError] draws a plain red border instead of the theme's gradient one.
/// The field's OWN border is InputBorder.none in every state (see
/// [fundFieldDecoration]), so this wrapper is the only border anyone sees,
/// and Flutter's automatic red error border had nowhere to paint: a
/// server-side rejection showed only as red helper text with the offending
/// field itself unmarked (found live 2026-09-06).
Widget fundFieldWrapper(
  AppPalette palette,
  Widget child, {
  bool hasError = false,
}) {
  final content = Container(
    decoration: BoxDecoration(
      gradient: palette.windowGradient,
      color: palette.windowGradient == null ? palette.card : null,
      borderRadius: ThemeV2.borderRadiusMedium,
      border: hasError ? Border.all(color: ThemeV2.loss, width: 1.5) : null,
    ),
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
    child: child,
  );
  return Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: hasError
        ? content
        : themedBorder(
            palette: palette,
            borderRadius: ThemeV2.borderRadiusMedium,
            child: content,
          ),
  );
}

/// One selectable sector chip. Stateless on purpose — the owning form keeps
/// the selected set, so this works the same for creating a fund and for
/// editing one.
Widget fundSectorChip({
  required AppPalette palette,
  required AppLocalizations l10n,
  required String code,
  required bool selected,
  required ValueChanged<bool> onSelected,
}) {
  return FilterChip(
    label: Text(sectorLabel(l10n, code)),
    selected: selected,
    onSelected: onSelected,
    selectedColor: palette.accentPrimary.withValues(alpha: 0.2),
    checkmarkColor: palette.accentPrimary,
    labelStyle: GoogleFonts.inter(
      fontSize: 12,
      color: selected ? palette.accentPrimary : palette.textBody,
      fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
    ),
    backgroundColor: palette.card,
    side: BorderSide(color: palette.textBody.withValues(alpha: 0.2)),
  );
}
