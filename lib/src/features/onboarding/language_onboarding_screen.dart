import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/theme_v2.dart';
import '../../core/localization/language_provider.dart';
import '../../l10n/gen/app_localizations.dart';
import '../auth/auth_providers.dart';

// ---------------------------------------------------------------------------
// Language Onboarding — the very first screen a fresh install can reach,
// ahead of even /auth, so the login/signup screen itself already renders in
// whatever language gets picked here. Gated by hasChosenLanguageProvider
// (language_provider.dart), checked in SplashScreen before anything else.
//
// Hardcoded to ThemeV2, same convention as every other pre-theme-choice
// first-run screen (disclaimer_screen.dart, onboarding_choice_screen.dart,
// choose_nickname_screen.dart) — no palette exists to read yet this early.
//
// Existing installs upgrading into this flag for the first time land here
// too (SharedPreferences never had it before), possibly already signed in
// with a nickname and disclaimer accepted — Continue resolves onward via
// resolveEntryRoute() rather than hardcoding /auth, so they land back on
// /home instead of being bounced through login again.
// ---------------------------------------------------------------------------

class LanguageOnboardingScreen extends ConsumerStatefulWidget {
  const LanguageOnboardingScreen({super.key});

  @override
  ConsumerState<LanguageOnboardingScreen> createState() =>
      _LanguageOnboardingScreenState();
}

class _LanguageOnboardingScreenState
    extends ConsumerState<LanguageOnboardingScreen> {
  bool _continuing = false;

  Future<void> _continue() async {
    setState(() => _continuing = true);
    await markLanguageOnboardingSeen();
    final resolved = await resolveEntryRoute(ref);
    if (!mounted) return;
    context.go(resolved.route, extra: resolved.extra);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final current = ref.watch(languageProvider);

    final options = <_LanguageOption>[
      _LanguageOption(locale: null, label: l10n.languageSystemDefault),
      _LanguageOption(locale: const Locale('en'), label: l10n.languageEnglish),
      _LanguageOption(locale: const Locale('ru'), label: l10n.languageRussian),
    ];

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              const Icon(
                Icons.language_rounded,
                color: ThemeV2.primary,
                size: 48,
              ),
              const SizedBox(height: 20),
              Text(
                l10n.languageOnboardingTitle,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: ThemeV2.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                l10n.languageOnboardingSubtitle,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: ThemeV2.textBody,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 28),
              Container(
                decoration: BoxDecoration(
                  color: ThemeV2.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: ThemeV2.divider),
                ),
                child: Column(
                  children: [
                    for (int i = 0; i < options.length; i++) ...[
                      if (i > 0) Divider(height: 1, color: ThemeV2.divider),
                      ListTile(
                        title: Text(
                          options[i].label,
                          style: GoogleFonts.inter(
                            color: ThemeV2.textPrimary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        trailing:
                            options[i].locale?.languageCode ==
                                current?.languageCode
                            ? const Icon(
                                Icons.check_rounded,
                                color: ThemeV2.primary,
                              )
                            : null,
                        onTap: () => ref
                            .read(languageProvider.notifier)
                            .setLanguage(options[i].locale),
                      ),
                    ],
                  ],
                ),
              ),
              const Spacer(),
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: _continuing ? null : _continue,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ThemeV2.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: _continuing
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.4,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          l10n.languageOnboardingContinueButton,
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
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
