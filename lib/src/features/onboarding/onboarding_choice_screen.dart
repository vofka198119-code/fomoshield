import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/theme_v2.dart';
import '../../l10n/gen/app_localizations.dart';

// ---------------------------------------------------------------------------
// Onboarding Choice — first-run fork right after the disclaimer gate:
// "take the tour" vs. "I'll figure it out myself". Hardcoded to ThemeV2
// (the standard palette), same convention as disclaimer_screen.dart and
// choose_nickname_screen.dart — this is pre-theme-choice first-run content.
//
// "I'll figure it out" skips straight to the nickname screen (mandatory
// either way — matches Migration 017's original "gates /home" intent).
// "Take the tour" goes through AppTourScreen first, which itself ends on
// the same nickname screen.
// ---------------------------------------------------------------------------

class OnboardingChoiceScreen extends StatelessWidget {
  const OnboardingChoiceScreen({super.key});

  void _choose(BuildContext context, {required bool wantsTutorial}) {
    context.go(wantsTutorial ? '/app-tour' : '/choose-nickname');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
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
                Icons.waving_hand_rounded,
                color: ThemeV2.primary,
                size: 48,
              ),
              const SizedBox(height: 20),
              Text(
                l10n.onboardingChoiceTitle,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: ThemeV2.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                l10n.onboardingChoiceSubtitle,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: ThemeV2.textBody,
                  height: 1.5,
                ),
              ),
              const Spacer(),
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: () => _choose(context, wantsTutorial: true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ThemeV2.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    l10n.onboardingChoiceTutorialButton,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 52,
                child: OutlinedButton(
                  onPressed: () => _choose(context, wantsTutorial: false),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: ThemeV2.textPrimary,
                    side: const BorderSide(color: ThemeV2.textSecondary),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    l10n.onboardingChoiceSkipButton,
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
