// ---------------------------------------------------------------------------
// Language Picker — reached from Profile → Preferences → Language.
// System Default (locale: null) + every language the app actually ships
// translations for (language_provider.dart's supportedLanguageCodes).
// ---------------------------------------------------------------------------

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/localization/language_provider.dart';
import '../../core/theme/theme_v2.dart';
import '../../l10n/gen/app_localizations.dart';

class LanguagePickerScreen extends ConsumerWidget {
  const LanguagePickerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final current = ref.watch(languageProvider);

    final options = <_LanguageOption>[
      _LanguageOption(locale: null, label: l10n.languageSystemDefault),
      _LanguageOption(locale: const Locale('en'), label: l10n.languageEnglish),
      _LanguageOption(locale: const Locale('ru'), label: l10n.languageRussian),
    ];

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: ThemeV2.textPrimary,
            size: 22,
          ),
          onPressed: () => context.pop(),
        ),
        title: Text(
          l10n.languageTitle.toUpperCase(),
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: ThemeV2.primary,
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
                l10n.languagePickerSubtitle,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: ThemeV2.textSecondary,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Card(
              child: Column(
                children: [
                  for (int i = 0; i < options.length; i++) ...[
                    if (i > 0) const Divider(height: 1),
                    _LanguageRow(
                      option: options[i],
                      selected: options[i].locale?.languageCode ==
                          current?.languageCode,
                      onTap: () =>
                          ref.read(languageProvider.notifier).setLanguage(
                                options[i].locale,
                              ),
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

class _LanguageOption {
  final Locale? locale;
  final String label;
  const _LanguageOption({required this.locale, required this.label});
}

class _LanguageRow extends StatelessWidget {
  final _LanguageOption option;
  final bool selected;
  final VoidCallback onTap;

  const _LanguageRow({
    required this.option,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        option.label,
        style: GoogleFonts.inter(color: ThemeV2.textPrimary),
      ),
      trailing: selected
          ? const Icon(Icons.check_rounded, color: ThemeV2.primary)
          : null,
      onTap: onTap,
    );
  }
}
