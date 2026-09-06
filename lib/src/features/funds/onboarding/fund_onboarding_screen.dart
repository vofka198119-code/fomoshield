import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/theme_variant_provider.dart';
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

  Future<void> _accept() async {
    await ref
        .read(fundOnboardingSeenProvider(widget.branch).notifier)
        .markSeen();
    if (!mounted) return;
    Navigator.of(context).pop(true);
  }

  List<(String, String)> _steps(AppLocalizations l10n) {
    final isHead = widget.branch == FundOnboardingBranch.head;
    return [
      isHead
          ? (l10n.etfOnboardingStep1TitleHead, l10n.etfOnboardingStep1BodyHead)
          : (
              l10n.etfOnboardingStep1TitleAnalyst,
              l10n.etfOnboardingStep1BodyAnalyst,
            ),
      isHead
          ? (l10n.etfOnboardingStep2TitleHead, l10n.etfOnboardingStep2BodyHead)
          : (
              l10n.etfOnboardingStep2TitleAnalyst,
              l10n.etfOnboardingStep2BodyAnalyst,
            ),
      (l10n.etfOnboardingStep3Title, l10n.etfOnboardingStep3Body),
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
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (i) => setState(() => _page = i),
                itemCount: _stepCount,
                itemBuilder: (context, index) {
                  final (title, body) = steps[index];
                  return Padding(
                    padding: const EdgeInsets.all(28),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
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
                            color: palette.textBody,
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
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: isLast ? _accept : _next,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: palette.accentPrimary,
                        foregroundColor: palette.onButton ?? Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Text(
                        isLast ? l10n.etfOnboardingAccept : l10n.etfOnboardingNext,
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
