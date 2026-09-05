// ---------------------------------------------------------------------------
// Theme Picker — reached from Profile → Preferences → Theme (admin-only for
// now, see profile_screen.dart). Standard (default) + Luxury Gold, the
// admin preview theme being built out molecule by molecule — see
// theme_variant_provider.dart / luxury_gold_theme.dart.
// ---------------------------------------------------------------------------

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_palette.dart';
import '../../core/theme/theme_variant_provider.dart';
import '../../core/theme/themed_header.dart';
import '../../core/theme/themed_divider.dart';
import '../../shared/widgets/card_frame.dart';
import '../../l10n/gen/app_localizations.dart';

/// Localized display name for each variant — the one place to add a case
/// when a future theme is added. The options list itself below is built
/// from [AppThemeVariant.values], so a new enum value just needs a label
/// here to show up in the picker automatically.
String _themeLabel(AppLocalizations l10n, AppThemeVariant variant) =>
    switch (variant) {
      AppThemeVariant.standard => l10n.themeOptionStandard,
      AppThemeVariant.luxuryGold => l10n.themeOptionLuxuryGold,
      AppThemeVariant.blackWhite => l10n.themeOptionBlackWhite,
      AppThemeVariant.graphite => l10n.themeOptionGraphite,
      AppThemeVariant.midnightSea => l10n.themeOptionMidnightSea,
    };

class ThemePickerScreen extends ConsumerWidget {
  const ThemePickerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final current = ref.watch(themeVariantProvider);
    final palette = resolveAppPalette(current);

    final options = [
      for (final variant in AppThemeVariant.values)
        _ThemeOption(variant: variant, label: _themeLabel(l10n, variant)),
    ];

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        centerTitle: true,
        leading: themedBackButton(context, palette, size: 22),
        title: themedHeaderText(
          l10n.themeTitle.toUpperCase(),
          palette,
          GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            letterSpacing: 1,
          ),
        ),
      ),
      body: SafeArea(
        bottom: true,
        top: false,
        left: false,
        right: false,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              child: Text(
                l10n.themePickerSubtitle,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: palette.textBody,
                ),
              ),
            ),
            const SizedBox(height: 8),
            CardFrame(
              padding: EdgeInsets.zero,
              palette: palette,
              child: Column(
                children: [
                  for (int i = 0; i < options.length; i++) ...[
                    if (i > 0)
                      palette.dividerGradient != null
                          ? themedDivider(palette, indent: 0, endIndent: 0)
                          : const Divider(height: 1),
                    _ThemeRow(
                      option: options[i],
                      selected: options[i].variant == current,
                      onTap: () => ref
                          .read(themeVariantProvider.notifier)
                          .setVariant(options[i].variant),
                      palette: palette,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ThemeOption {
  final AppThemeVariant variant;
  final String label;
  const _ThemeOption({required this.variant, required this.label});
}

class _ThemeRow extends StatelessWidget {
  final _ThemeOption option;
  final bool selected;
  final VoidCallback onTap;
  final AppPalette palette;

  const _ThemeRow({
    required this.option,
    required this.selected,
    required this.onTap,
    required this.palette,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        option.label,
        style: GoogleFonts.inter(color: palette.textHeader),
      ),
      trailing: selected
          ? Icon(Icons.check_rounded, color: palette.accentPrimary)
          : null,
      onTap: onTap,
    );
  }
}
