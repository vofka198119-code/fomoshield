// ---------------------------------------------------------------------------
// Stress Test Setup Screen
// ---------------------------------------------------------------------------
// Before the simulation starts, users choose the test duration.
// Companies are managed via the separate search screen.
// ---------------------------------------------------------------------------

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/theme_v2.dart';
import '../../core/theme/typography_helpers.dart';
import '../../core/supabase/supabase_providers.dart';
import '../../l10n/gen/app_localizations.dart';
import '../../shared/utils/currency_format.dart';
import '../../shared/widgets/disclaimer_footer.dart';
import '../monetization/monetization_modal.dart';
import '../monetization/premium_promo_overlay.dart';
import '../market_clock/market_clock_dial.dart';
import '../../shared/guardian/guardian_engine.dart';
import '../../shared/guardian/guardian_providers.dart';
import 'stress_test_models.dart';
import 'stress_test_engine.dart';

// Market Clock ring's gold accent — used for every "PREMIUM" tag on this
// screen.
List<Shadow> _goldGlow(Color color) => [
  Shadow(color: color.withValues(alpha: 0.5), blurRadius: 6),
];

class StressTestSetupScreen extends ConsumerStatefulWidget {
  final String sessionId;

  const StressTestSetupScreen({super.key, required this.sessionId});

  @override
  ConsumerState<StressTestSetupScreen> createState() =>
      _StressTestSetupScreenState();
}

class _StressTestSetupScreenState extends ConsumerState<StressTestSetupScreen> {
  TestDuration _selectedDuration = TestDuration.week1;
  int _customDurationDays = 5; // Only used when _selectedDuration == custom

  StressTestSession? get _session =>
      ref.read(stressTestProvider.notifier).getSession(widget.sessionId);

  void _startTest() async {
    final tier = ref.read(subscriptionTierProvider);
    final isPremium =
        tier == SubscriptionTier.premium || tier == SubscriptionTier.admin;

    // Safety guard: Free cannot start Infinite or Custom
    if (!isPremium &&
        (_selectedDuration == TestDuration.infinite ||
            _selectedDuration == TestDuration.custom)) {
      return;
    }

    // Show risk disclaimer popup first
    final accepted = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => _RiskDisclaimerModal(
        isPremium: isPremium,
        selectedDuration: _selectedDuration,
      ),
    );

    if (accepted != true || !mounted) return;

    // Check limits
    final sessions = ref.read(stressTestProvider);
    final activeCount = sessions
        .where((s) => s.status == StressTestStatus.active)
        .length;
    final maxSessions = ref.read(maxStressTestSessionsProvider);

    if (activeCount >= maxSessions) {
      final l10n = AppLocalizations.of(context)!;
      if (tier == SubscriptionTier.free) {
        showPremiumPromoOverlay(
          context: context,
          title: l10n.stressTestLimitReachedTitle,
          durationSeconds: 5,
          onComplete: () {
            if (context.mounted) showMonetizationModal(context, ref);
          },
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.stressTestMaxSessionsReached)),
        );
      }
      return;
    }

    final notifier = ref.read(stressTestProvider.notifier);
    // Apply selected duration before starting
    notifier.setSessionDuration(
      widget.sessionId,
      _selectedDuration,
      customDurationDays: _selectedDuration == TestDuration.custom
          ? _customDurationDays
          : null,
    );
    notifier.startTest(widget.sessionId);

    // Record test start for Guardian intelligence
    ref.read(guardianEngineProvider).whenData((engine) {
      engine.recordAction(UserAction.startedTest);
    });

    if (mounted) {
      context.push('/stress-test/${widget.sessionId}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = _session;
    final l10n = AppLocalizations.of(context)!;
    if (session == null) {
      return Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: Text(
            l10n.navStressTest,
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: ThemeV2.primary,
            ),
          ),
        ),
        body: Center(child: Text(l10n.stressTestSessionNotFound)),
      );
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(
          l10n.stressTestSetupTitle,
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: ThemeV2.primary,
          ),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: ThemeV2.textPrimary,
          ),
          onPressed: () => context.go('/stress-test-hub'),
        ),
      ),
      body: SafeArea(
        bottom: true,
        top: false,
        left: false,
        right: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Cash Balance ────────────────────────────────────
              _buildBalanceCard(session),
              const SizedBox(height: 24),

              // ── Duration Selector ────────────────────────────────
              Text(
                l10n.stressTestDurationSectionTitle,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: ThemeV2.primary,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 12),
              _buildDurationSelector(),
              const SizedBox(height: 24),

              // ── Premium Badge (for free users) ──────────────────
              _buildPremiumBadge(),
              const SizedBox(height: 12),

              // ── Start Button ────────────────────────────────────
              SizedBox(
                width: double.infinity,
                child: Material(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(14),
                  child: Ink(
                    decoration: darkCardDecoration(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: InkWell(
                      onTap: _startTest,
                      borderRadius: BorderRadius.circular(14),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Center(
                          child: Text(
                            l10n.stressTestStartButton,
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // ── Disclaimer ─────────────────────────────────────
              const DisclaimerFooter(),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPremiumBadge() {
    final tier = ref.watch(subscriptionTierProvider);
    if (tier == SubscriptionTier.premium || tier == SubscriptionTier.admin) {
      return const SizedBox.shrink();
    }
    // Which concurrent slot this session (still in setup, not yet
    // counted as active) will occupy once started — slot 1 is always
    // ad-free, slot 2 is the ad-gated extra (no ad integration yet, so
    // just a "Go Premium" nudge for now).
    final activeCount = ref
        .read(stressTestProvider)
        .where((s) => s.status == StressTestStatus.active)
        .length;
    final isFirst = activeCount == 0;
    final l10n = AppLocalizations.of(context)!;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: ThemeV2.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: ThemeV2.primary.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: darkCardDecoration(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              l10n.profilePremiumBadge,
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: dialBrassLight,
                letterSpacing: 1.5,
                shadows: _goldGlow(dialBrassLight),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              isFirst ? l10n.stressTestSlot1Free : l10n.stressTestSlot2Free,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: ThemeV2.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceCard(StressTestSession session) {
    final tier = ref.watch(subscriptionTierProvider);
    final isPremium =
        tier == SubscriptionTier.premium || tier == SubscriptionTier.admin;
    final l10n = AppLocalizations.of(context)!;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isPremium
              ? [ThemeV2.primary, const Color(0xFF002E18)]
              : [ThemeV2.primary, const Color(0xFF0F2440)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                l10n.stressTestAvailableCash,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: Colors.white70,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (isPremium) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    l10n.profilePremiumBadge,
                    style: GoogleFonts.inter(
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      color: dialBrassLight,
                      letterSpacing: 1.2,
                      shadows: _goldGlow(dialBrassLight),
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 4),
          Text(
            formatUsd(session.cash),
            style: interNums(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.stressTestOfTotal(formatUsd(session.startingCash)),
            style: interNums(fontSize: 12, color: Colors.white60),
          ),
        ],
      ),
    );
  }

  Widget _buildDurationSelector() {
    final tier = ref.watch(subscriptionTierProvider);
    final isPremium =
        tier == SubscriptionTier.premium || tier == SubscriptionTier.admin;
    final accentColor = isPremium
        ? const Color(0xFFD4AF37) // Gold for Premium/Admin
        : ThemeV2.textSecondary; // Gray for Free

    // Always show all 5 options; Free gets lock on Infinite & Custom
    final durations = TestDuration.values;
    final l10n = AppLocalizations.of(context)!;

    return Container(
      decoration: BoxDecoration(
        color: ThemeV2.surface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: durations.map((d) {
          final selected = _selectedDuration == d;
          final isPremiumLocked =
              !isPremium &&
              (d == TestDuration.infinite || d == TestDuration.custom);
          final isCustomRow = d == TestDuration.custom;
          final isInfiniteRow = d == TestDuration.infinite;
          final rowColor = isPremium ? const Color(0xFFD4AF37) : accentColor;

          return InkWell(
            key: ValueKey(d.name),
            onTap: () {
              if (isPremiumLocked) {
                _showPremiumUpsell();
              } else if (isCustomRow) {
                _showCustomDurationPicker();
              } else {
                setState(() => _selectedDuration = d);
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: selected
                    ? rowColor.withValues(alpha: 0.1)
                    : Colors.transparent,
                border: Border(
                  bottom: BorderSide(
                    color: Colors.black.withValues(alpha: 0.06),
                  ),
                ),
              ),
              child: Row(
                children: [
                  // Icon: lock for premium-locked, crown for Premium infinite/custom, radio otherwise
                  Icon(
                    isPremiumLocked
                        ? Icons.lock_rounded
                        : (isCustomRow || isInfiniteRow) && isPremium
                        ? Icons.workspace_premium_rounded
                        : selected
                        ? Icons.radio_button_checked_rounded
                        : Icons.radio_button_unchecked_rounded,
                    color: isPremiumLocked
                        ? ThemeV2.textSecondary
                        : (selected || isCustomRow || isInfiniteRow)
                        ? rowColor
                        : ThemeV2.textSecondary,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      isCustomRow && isPremium
                          ? l10n.stressTestCustomDays(_customDurationDays)
                          : isInfiniteRow && isPremium
                          ? l10n.stressTestInfiniteMinWeeks
                          : d.localizedLabel(l10n),
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: isPremiumLocked
                            ? ThemeV2.textSecondary.withValues(alpha: 0.5)
                            : selected || isCustomRow || isInfiniteRow
                            ? rowColor
                            : ThemeV2.textSecondary,
                        fontWeight: selected
                            ? FontWeight.w600
                            : FontWeight.w400,
                      ),
                    ),
                  ),
                  // Badge or label
                  if (isPremiumLocked)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: darkCardDecoration(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        l10n.profilePremiumBadge,
                        style: GoogleFonts.inter(
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          color: dialBrassLight,
                          letterSpacing: 1.2,
                          shadows: _goldGlow(dialBrassLight),
                        ),
                      ),
                    )
                  else if ((isCustomRow || isInfiniteRow) && isPremium)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: darkCardDecoration(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        l10n.profilePremiumBadge,
                        style: GoogleFonts.inter(
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          color: dialBrassLight,
                          letterSpacing: 1.2,
                          shadows: _goldGlow(dialBrassLight),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  /// Prompts a Free user to subscribe when tapping a locked feature.
  void _showPremiumUpsell() {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: ThemeV2.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.workspace_premium_rounded,
                size: 56,
                color: const Color(0xFFD4AF37),
              ),
              const SizedBox(height: 16),
              Text(
                l10n.stressTestPremiumFeatureTitle,
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: ThemeV2.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                l10n.stressTestPremiumFeatureBody,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: ThemeV2.textSecondary,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    showMonetizationModal(context, ref);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD4AF37),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    l10n.stressTestUpgradeToPremium,
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: Text(
                  l10n.stressTestNotNow,
                  style: GoogleFonts.inter(
                    color: ThemeV2.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Opens a bottom sheet to pick custom duration (5–365 days).
  /// Free users are redirected to [_showPremiumUpsell] instead.
  void _showCustomDurationPicker() {
    final isPremium =
        ref.read(subscriptionTierProvider) == SubscriptionTier.premium ||
        ref.read(subscriptionTierProvider) == SubscriptionTier.admin;
    if (!isPremium) {
      _showPremiumUpsell();
      return;
    }

    int tempDays = _customDurationDays;
    final l10n = AppLocalizations.of(context)!;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: ThemeV2.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 24,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Handle
                  Center(
                    child: Container(
                      width: 36,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.black26,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  Text(
                    l10n.stressTestCustomDurationTitle,
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: ThemeV2.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Non-interruptible warning
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD4AF37).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFFD4AF37).withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.warning_amber_rounded,
                          size: 18,
                          color: const Color(0xFFD4AF37),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            l10n.stressTestCustomDurationWarning,
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: ThemeV2.textSecondary,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Day count display
                  Center(
                    child: Text(
                      l10n.stressTestDaysCount(tempDays),
                      style: interNums(
                        fontSize: 36,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFFD4AF37),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Slider
                  Slider(
                    value: tempDays.toDouble(),
                    min: 5,
                    max: 365,
                    divisions: 360,
                    activeColor: const Color(0xFFD4AF37),
                    inactiveColor: const Color(
                      0xFFD4AF37,
                    ).withValues(alpha: 0.2),
                    label: l10n.stressTestDaysCount(tempDays),
                    onChanged: (v) {
                      setSheetState(() => tempDays = v.round());
                    },
                  ),
                  const SizedBox(height: 4),

                  // Min / Max labels
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        l10n.stressTestMinDays,
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: ThemeV2.textSecondary,
                        ),
                      ),
                      Text(
                        l10n.stressTestMaxDays,
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: ThemeV2.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Buttons
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 48,
                          child: OutlinedButton(
                            onPressed: () => Navigator.of(ctx).pop(),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: ThemeV2.textSecondary,
                              side: BorderSide(
                                color: ThemeV2.textSecondary.withValues(
                                  alpha: 0.3,
                                ),
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              l10n.profileCancel,
                              style: GoogleFonts.inter(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: SizedBox(
                          height: 48,
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _selectedDuration = TestDuration.custom;
                                _customDurationDays = tempDays;
                              });
                              Navigator.of(ctx).pop();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFD4AF37),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              l10n.commonApply,
                              style: GoogleFonts.inter(
                                fontWeight: FontWeight.w800,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Risk Disclaimer Modal
// ---------------------------------------------------------------------------
// Shown before every stress test start. "I Agree" button unlocks only after
// the user scrolls through the entire disclaimer text.
// ---------------------------------------------------------------------------

class _RiskDisclaimerModal extends StatefulWidget {
  final bool isPremium;
  final TestDuration selectedDuration;

  const _RiskDisclaimerModal({
    required this.isPremium,
    required this.selectedDuration,
  });

  @override
  State<_RiskDisclaimerModal> createState() => _RiskDisclaimerModalState();
}

class _RiskDisclaimerModalState extends State<_RiskDisclaimerModal> {
  final _scrollController = ScrollController();
  bool _hasScrolledToBottom = false;

  /// Gold for Premium, brand green for Free
  Color get _accentColor =>
      widget.isPremium ? const Color(0xFFD4AF37) : ThemeV2.primary;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    if (currentScroll >= maxScroll - 10 && !_hasScrolledToBottom) {
      setState(() => _hasScrolledToBottom = true);
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  /// Handles the "I Agree" action:
  /// - Free + Infinite → pops false and triggers a premium upsell instead
  /// - Otherwise → pops true to proceed
  void _handleAgree() {
    final isFreeInfinite =
        !widget.isPremium && widget.selectedDuration == TestDuration.infinite;
    if (isFreeInfinite) {
      Navigator.of(context).pop(false);
      // The caller (_startTest) will detect this case and show the promo.
      return;
    }
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final isFreeInfinite =
        !widget.isPremium && widget.selectedDuration == TestDuration.infinite;
    final l10n = AppLocalizations.of(context)!;

    return Dialog(
      backgroundColor: ThemeV2.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.black26,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Title
            Text(
              isFreeInfinite
                  ? l10n.stressTestPremiumFeatureAllCaps
                  : l10n.stressTestRiskDisclaimerTitle,
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: isFreeInfinite ? _accentColor : ThemeV2.textPrimary,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 16),

            // ── Body ──────────────────────────────────────────────
            if (isFreeInfinite)
              _buildInfiniteUpsell()
            else
              _buildDisclaimerBody(),

            const SizedBox(height: 16),

            // ── Bottom indicator ──────────────────────────────────
            if (isFreeInfinite)
              const SizedBox.shrink()
            else if (!_hasScrolledToBottom)
              Row(
                children: [
                  Icon(
                    Icons.arrow_downward_rounded,
                    size: 14,
                    color: ThemeV2.textSecondary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    l10n.stressTestScrollToAgree,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: ThemeV2.textSecondary,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              )
            else
              Row(
                children: [
                  Icon(
                    Icons.check_circle_rounded,
                    size: 14,
                    color: ThemeV2.success,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    l10n.stressTestReadFullDisclaimer,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: ThemeV2.success,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 16),

            // ── Buttons ───────────────────────────────────────────
            Row(
              children: [
                // Cancel
                Expanded(
                  child: SizedBox(
                    height: 48,
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: ThemeV2.textSecondary,
                        side: BorderSide(
                          color: ThemeV2.textSecondary.withValues(alpha: 0.3),
                        ),
                        backgroundColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        l10n.profileCancel,
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // I Agree / Upgrade
                Expanded(
                  flex: 2,
                  child: SizedBox(
                    height: 48,
                    child: ElevatedButton(
                      onPressed: isFreeInfinite
                          ? _handleAgree
                          : (_hasScrolledToBottom ? _handleAgree : null),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _hasScrolledToBottom || isFreeInfinite
                            ? _accentColor
                            : ThemeV2.textSecondary.withValues(alpha: 0.3),
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: ThemeV2.textSecondary
                            .withValues(alpha: 0.2),
                        disabledForegroundColor: Colors.white38,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        isFreeInfinite
                            ? l10n.stressTestUpgradeToPremium
                            : l10n.stressTestIAgreeStart,
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Full disclaimer scrollable body (shown to all users except free+Infinite)
  Widget _buildDisclaimerBody() {
    final l10n = AppLocalizations.of(context)!;
    return Flexible(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Container(
          color: Colors.transparent,
          child: Scrollbar(
            controller: _scrollController,
            thumbVisibility: true,
            child: SingleChildScrollView(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.stressTestDisclaimerIntro,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: ThemeV2.textPrimary,
                      height: 1.6,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.stressTestDisclaimerAck,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: ThemeV2.textPrimary,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _bulletPoint(l10n.stressTestBulletScenarios),
                  const SizedBox(height: 12),
                  _bulletPoint(l10n.stressTestBulletNotAdvice),
                  const SizedBox(height: 12),
                  _bulletPoint(l10n.stressTestBulletObjective),
                  const SizedBox(height: 12),
                  _bulletPoint(l10n.stressTestBulletLiability),
                  const SizedBox(height: 12),
                  _bulletPoint(l10n.stressTestBulletPastPerformance),
                  const SizedBox(height: 8),
                  Text(
                    l10n.stressTestEndOfDisclaimer,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: ThemeV2.textSecondary.withValues(alpha: 0.3),
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Upsell shown when a Free user selects Infinite duration
  Widget _buildInfiniteUpsell() {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _accentColor.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(Icons.workspace_premium_rounded, size: 48, color: _accentColor),
          const SizedBox(height: 16),
          Text(
            l10n.stressTestUnlimitedTesting,
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: _accentColor,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            l10n.stressTestInfiniteUpsellBody,
            style: GoogleFonts.inter(
              fontSize: 13,
              color: ThemeV2.textSecondary,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 16),
          _upsellRow(
            Icons.all_inclusive_rounded,
            l10n.stressTestUpsellUnlimitedDuration,
          ),
          const SizedBox(height: 8),
          _upsellRow(
            Icons.speed_rounded,
            l10n.stressTestUpsellFullCrashScenarios,
          ),
          const SizedBox(height: 8),
          _upsellRow(
            Icons.analytics_rounded,
            l10n.stressTestUpsellAdvancedAnalytics,
          ),
          const SizedBox(height: 8),
          _upsellRow(Icons.block_rounded, l10n.premiumBenefitAdFree),
        ],
      ),
    );
  }

  Widget _upsellRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 18, color: _accentColor),
        const SizedBox(width: 10),
        Text(
          text,
          style: GoogleFonts.inter(
            fontSize: 13,
            color: ThemeV2.textPrimary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _bulletPoint(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '•  ',
          style: GoogleFonts.inter(color: ThemeV2.textSecondary, fontSize: 13),
        ),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.inter(
              fontSize: 13,
              color: ThemeV2.textSecondary,
              height: 1.6,
            ),
          ),
        ),
      ],
    );
  }
}
