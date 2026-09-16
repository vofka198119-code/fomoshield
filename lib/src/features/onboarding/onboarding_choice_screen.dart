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
// Both buttons lead to the nickname screen next — a nickname is required
// either way (matches Migration 017's original "gates /home" intent). The
// tutorial content itself doesn't exist yet (a later phase); for now this
// screen only records the choice so a future tutorial phase can route a
// "tour" pick into real step-by-step content instead of straight past
// nickname to /home, without this screen needing to change again.
// ---------------------------------------------------------------------------

class OnboardingChoiceScreen extends StatelessWidget {
  const OnboardingChoiceScreen({super.key});

  void _choose(BuildContext context, {required bool wantsTutorial}) {
    // TODO(onboarding-phase-3): once real tutorial content ships, a
    // wantsTutorial=true pick should route into it here instead of
    // straight to nickname. Recording the choice happens where the
    // nickname write already goes (choose_nickname_screen.dart) once
    // that storage is needed — no persistence required yet since both
    // paths converge on the same next screen today.
    context.go('/choose-nickname');
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
                  color: ThemeV2.textSecondary,
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
