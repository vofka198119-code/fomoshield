import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/theme_v2.dart';
import '../../../core/theme/theme_variant_provider.dart';
import '../../../core/theme/themed_button.dart';
import '../../../core/theme/themed_header.dart';
import '../../../l10n/gen/app_localizations.dart';
import 'fund_onboarding_providers.dart';

// ---------------------------------------------------------------------------
// Fund Onboarding — one-time, 3-step tutorial shown before either ETF entry
// point (fund head / analyst) is used for the first time. Design doc:
// step 1 explains the concept, step 2 what's required, step 3 is the
// simulator/disclaimer step ending in an explicit accept. Shown once per
// branch (see fund_onboarding_providers.dart), never again after that.
// ---------------------------------------------------------------------------

class FundOnboardingScreen extends ConsumerStatefulWidget {
  final FundOnboardingBranch branch;

  const FundOnboardingScreen({super.key, required this.branch});

  @override
  ConsumerState<FundOnboardingScreen> createState() =>
      _FundOnboardingScreenState();
}

class _FundOnboardingScreenState extends ConsumerState<FundOnboardingScreen> {
  final _pageController = PageController();
  int _page = 0;

  static const _stepCount = 3;

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
      Navigator.of(context).pop(false);
    }
  }

  Future<void> _accept() async {
    await ref
        .read(fundOnboardingSeenProvider(widget.branch).notifier)
        .markSeen();
    if (!mounted) return;
    Navigator.of(context).pop(true);
  }

  // (title, body, button label) per step — button label is per-step/per-
  // branch on purpose (e.g. head's step 2 says "Create Fund", analyst's
  // says "Create Profile"), not a generic "Next", per the author's copy.
  List<(String, String, String)> _steps(AppLocalizations l10n) {
    final isHead = widget.branch == FundOnboardingBranch.head;
    return [
      isHead
          ? (
              l10n.etfOnboardingStep1TitleHead,
              l10n.etfOnboardingStep1BodyHead,
              l10n.etfOnboardingContinueButton,
            )
          : (
              l10n.etfOnboardingStep1TitleAnalyst,
              l10n.etfOnboardingStep1BodyAnalyst,
              l10n.etfOnboardingContinueButton,
            ),
      isHead
          ? (
              l10n.etfOnboardingStep2TitleHead,
              l10n.etfOnboardingStep2BodyHead,
              l10n.etfOnboardingStep2ButtonHead,
            )
          : (
              l10n.etfOnboardingStep2TitleAnalyst,
              l10n.etfOnboardingStep2BodyAnalyst,
              l10n.etfOnboardingStep2ButtonAnalyst,
            ),
      (l10n.etfOnboardingStep3Title, l10n.etfOnboardingStep3Body, l10n.etfOnboardingAccept),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final palette = resolveAppPalette(ref.watch(themeVariantProvider));
    final steps = _steps(l10n);
    final isLast = _page == _stepCount - 1;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: themedHeaderIcon(Icons.arrow_back_rounded, palette),
          onPressed: _back,
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                // Sequential, button-driven navigation only — swiping
                // between steps is intentionally disabled, per the author.
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
                            color: palette.textHeader,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          body,
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            height: 1.5,
                            // textHeader, not textBody — this paragraph is
                            // the primary reading content of the screen,
                            // not a secondary caption. textBody resolves to
                            // a deliberately muted tone in some themes
                            // (Luxury Gold's mutedSilver) that reads fine
                            // for short labels but too low-contrast for a
                            // full paragraph (found live 2026-09-06).
                            color: palette.textHeader,
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
                              ? palette.accentPrimary
                              : palette.textBody.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 20),
                  _ctaButton(
                    palette: palette,
                    label: steps[_page].$3,
                    onTap: isLast ? _accept : _next,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Same recipe as set_goal_screen.dart's _saveButton — NEVER paint a CTA
  // button with palette.accentPrimary as a flat fill: under Graphite,
  // accentPrimary AND onButton are both grWhite (white text on a white
  // button); under Black & White both are bwBlack (black on black) — found
  // live 2026-09-06 on a real device, invisible button label. This shell
  // picks the right fill/text combo per theme automatically.
  Widget _ctaButton({
    required AppPalette palette,
    required String label,
    required VoidCallback onTap,
  }) {
    final radius = BorderRadius.circular(ThemeV2.buttonRadius);
    return SizedBox(
      width: double.infinity,
      height: ThemeV2.buttonHeight,
      child: Material(
        type: MaterialType.transparency,
        child: themedDarkCtaButtonShell(
          palette: palette,
          borderRadius: radius,
          standardDecoration: BoxDecoration(color: ThemeV2.primary, borderRadius: radius),
          child: InkWell(
            borderRadius: radius,
            onTap: onTap,
            child: Center(
              child: Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: themedDarkCtaContentColor(palette),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
