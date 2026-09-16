import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/theme_v2.dart';
import '../../l10n/gen/app_localizations.dart';

// ---------------------------------------------------------------------------
// App Tour — the real content behind OnboardingChoiceScreen's "take the
// tour" pick (Phase 2 of the master-branch first-run onboarding plan).
// Same sequential, button-driven PageView shape as the ETF branch's
// FundOnboardingScreen (swiping disabled on purpose, back button steps
// back a page before popping) but hardcoded to ThemeV2/standard, like
// every other screen in this onboarding sequence — no palette awareness.
// Ends on /choose-nickname, same destination the "skip" path already
// goes to directly.
// ---------------------------------------------------------------------------

class AppTourScreen extends StatefulWidget {
  const AppTourScreen({super.key});

  @override
  State<AppTourScreen> createState() => _AppTourScreenState();
}

class _AppTourScreenState extends State<AppTourScreen> {
  final _pageController = PageController();
  int _page = 0;

  static const _stepCount = 5;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _next() {
    if (_page < _stepCount - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    }
  }

  void _back() {
    if (_page > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    } else {
      context.go('/onboarding-choice');
    }
  }

  void _finish() {
    context.go('/choose-nickname');
  }

  List<(String, String, String)> _steps(AppLocalizations l10n) => [
    (
      l10n.onboardingTourStep1Title,
      l10n.onboardingTourStep1Body,
      l10n.onboardingTourContinueButton,
    ),
    (
      l10n.onboardingTourStep2Title,
      l10n.onboardingTourStep2Body,
      l10n.onboardingTourContinueButton,
    ),
    (
      l10n.onboardingTourStep3Title,
      l10n.onboardingTourStep3Body,
      l10n.onboardingTourContinueButton,
    ),
    (
      l10n.onboardingTourStep4Title,
      l10n.onboardingTourStep4Body,
      l10n.onboardingTourContinueButton,
    ),
    (
      l10n.onboardingTourStep5Title,
      l10n.onboardingTourStep5Body,
      l10n.onboardingTourStep5Button,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final steps = _steps(l10n);
    final isLast = _page == _stepCount - 1;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: ThemeV2.textPrimary),
          onPressed: _back,
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (i) => setState(() => _page = i),
                itemCount: _stepCount,
                itemBuilder: (context, index) {
                  final (title, body, _) = steps[index];
                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(28),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: GoogleFonts.inter(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: ThemeV2.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          body,
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            height: 1.5,
                            color: ThemeV2.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(28, 0, 28, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(_stepCount, (i) {
                      final active = i == _page;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: active ? 20 : 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: active
                              ? ThemeV2.primary
                              : ThemeV2.textSecondary.withValues(alpha: 0.4),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: isLast ? _finish : _next,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ThemeV2.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Text(
                        steps[_page].$3,
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
