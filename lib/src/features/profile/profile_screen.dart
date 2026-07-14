import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../core/supabase/supabase_providers.dart';
import '../auth/auth_providers.dart';
import '../home/home_providers.dart';
import '../home/widget_order_provider.dart';
import '../portfolio/portfolio_providers.dart';
import '../search/search_counter_provider.dart';
import '../search/search_provider.dart';
import '../company_detail/watchlist_ad_provider.dart';
import '../stress_test/stress_test_engine.dart';
import '../../shared/widgets/disclaimer_footer.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final subscriptionTier = ref.watch(subscriptionTierProvider);
    final isAdmin = ref.watch(isAdminProvider);

    final email = user?.email ?? 'Not signed in';
    final displayName = email.split('@').first;
    final isPremium = subscriptionTier == SubscriptionTier.premium;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Profile',
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: AppTheme.accentBlue,
            letterSpacing: 1.5,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── User Info Card ───────────────────────────────────────
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: () {
                      if (isAdmin)
                        return AppTheme.accentBlue.withValues(alpha: 0.15);
                      if (isPremium)
                        return AppTheme.premiumGreen.withValues(alpha: 0.15);
                      return AppTheme.accentBlue.withValues(alpha: 0.15);
                    }(),
                    child: Icon(
                      isAdmin
                          ? Icons.admin_panel_settings_rounded
                          : isPremium
                          ? Icons.workspace_premium_rounded
                          : Icons.person_rounded,
                      color: isAdmin
                          ? AppTheme.accentBlue
                          : isPremium
                          ? AppTheme.premiumGreen
                          : AppTheme.accentBlue,
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                displayName,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.inter(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Subscription badge (FREE → no badge)
                            if (isPremium || isAdmin)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: isAdmin
                                      ? AppTheme.accentBlue.withValues(
                                          alpha: 0.15,
                                        )
                                      : AppTheme.premiumGreen.withValues(
                                          alpha: 0.15,
                                        ),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: isAdmin
                                        ? AppTheme.accentBlue.withValues(
                                            alpha: 0.5,
                                          )
                                        : AppTheme.premiumGreen.withValues(
                                            alpha: 0.5,
                                          ),
                                  ),
                                ),
                                child: Text(
                                  isAdmin ? 'ADMIN' : 'PREMIUM',
                                  style: GoogleFonts.inter(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: isAdmin
                                        ? AppTheme.accentBlue
                                        : AppTheme.premiumGreen,
                                    letterSpacing: 1,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          email,
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: AppTheme.textDim,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Premium Status Card (gold, for premium users) ────────
          if (isPremium) ...[const SizedBox(height: 12), _PremiumStatusCard()],

          // ── Admin Badge ──────────────────────────────────────────
          if (isAdmin) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppTheme.accentBlue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: AppTheme.accentBlue.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.admin_panel_settings_rounded,
                    color: AppTheme.accentBlue,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Admin Mode — all premium features unlocked',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: AppTheme.accentBlue,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],

          // ── Admin Sandbox ────────────────────────────────────────
          if (isAdmin) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.premiumGreen.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppTheme.premiumGreen.withValues(alpha: 0.2),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '🛠️ Admin Sandbox',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.premiumGreen,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _adminButton(
                    icon: Icons.search_rounded,
                    label: 'Reset search counter (→ 15)',
                    onTap: () {
                      ref.read(searchCounterProvider.notifier).resetToFree();
                      _showSnack(context, 'Search counter reset to 15');
                    },
                  ),
                  const SizedBox(height: 8),
                  _adminButton(
                    icon: Icons.visibility_rounded,
                    label: 'Toggle Premium (24h)',
                    onTap: () {
                      // Toggle via admin: set search to unlimited
                      ref.read(searchCounterProvider.notifier).setUnlimited();
                      _showSnack(
                        context,
                        '🔓 Premium mode activated (session)',
                      );
                    },
                  ),
                  const SizedBox(height: 8),
                  _adminButton(
                    icon: Icons.delete_sweep_rounded,
                    label: 'Clear all portfolios',
                    onTap: () {
                      // Delete all portfolios via the notifier
                      final portfolios = ref.read(portfoliosProvider);
                      for (final p in portfolios) {
                        ref
                            .read(portfoliosProvider.notifier)
                            .deletePortfolio(p.id);
                      }
                      _showSnack(context, 'All portfolios cleared');
                    },
                  ),
                  const SizedBox(height: 8),
                  _adminButton(
                    icon: Icons.ads_click_rounded,
                    label: 'Reset watchlist ad counter',
                    onTap: () {
                      ref.read(watchlistAdProvider.notifier).reset();
                      _showSnack(context, 'Watchlist ad counter reset');
                    },
                  ),
                  const SizedBox(height: 8),
                  _adminButton(
                    icon: Icons.psychology_rounded,
                    label: 'Reset all stress tests',
                    onTap: () {
                      ref.read(stressTestProvider.notifier).deleteAllSessions();
                      _showSnack(context, 'All stress tests cleared');
                    },
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 24),

          // ── Language ─────────────────────────────────────────────
          _section('Preferences'),
          Card(
            child: ListTile(
              leading: const Icon(Icons.language, color: AppTheme.accentBlue),
              title: Text(
                'Language',
                style: GoogleFonts.inter(color: AppTheme.textPrimary),
              ),
              trailing: const Icon(
                Icons.chevron_right,
                color: AppTheme.textDim,
              ),
              onTap: () {},
            ),
          ),

          const SizedBox(height: 24),

          // ── Statistics ────────────────────────────────────────────
          _section('Statistics'),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _statItem('Days', '1'),
                  _statItem('Companies', '0'),
                  _statItem('Tests', '0'),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // ── Legal ─────────────────────────────────────────────────
          _section('Legal'),
          Card(
            child: Column(
              children: [
                ListTile(
                  title: Text(
                    'Privacy Policy',
                    style: GoogleFonts.inter(color: AppTheme.textPrimary),
                  ),
                  trailing: const Icon(
                    Icons.chevron_right,
                    color: AppTheme.textDim,
                  ),
                  onTap: () {},
                ),
                const Divider(height: 1),
                ListTile(
                  title: Text(
                    'Terms of Use',
                    style: GoogleFonts.inter(color: AppTheme.textPrimary),
                  ),
                  trailing: const Icon(
                    Icons.chevron_right,
                    color: AppTheme.textDim,
                  ),
                  onTap: () {},
                ),
                const Divider(height: 1),
                ListTile(
                  title: Text(
                    'Methodology',
                    style: GoogleFonts.inter(color: AppTheme.textPrimary),
                  ),
                  trailing: const Icon(
                    Icons.chevron_right,
                    color: AppTheme.textDim,
                  ),
                  onTap: () {},
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // ── Sign Out ─────────────────────────────────────────────
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton.icon(
              onPressed: () async {
                // 1) Clear ALL user session data (SharedPrefs + SecureStorage)
                await clearAllSessionData();
                // 2) Invalidate Riverpod providers so they re-load fresh
                ref.invalidate(watchlistSymbolsProvider);
                ref.invalidate(portfoliosProvider);
                ref.invalidate(homeWidgetsProvider);
                ref.invalidate(searchProvider);
                ref.invalidate(searchCounterProvider);
                // 3) Navigate instantly to login (skip Splash 2.5s delay)
                if (!context.mounted) return;
                context.go('/auth');
              },
              icon: const Icon(Icons.logout_rounded, color: AppTheme.dangerRed),
              label: Text(
                'Sign Out',
                style: GoogleFonts.inter(
                  color: AppTheme.dangerRed,
                  fontSize: 15,
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: BorderSide(
                  color: AppTheme.dangerRed.withValues(alpha: 0.3),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),

          const DisclaimerFooter(),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _adminButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 16, color: AppTheme.premiumGreen),
        label: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            color: AppTheme.premiumGreen,
            fontWeight: FontWeight.w500,
          ),
        ),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: AppTheme.premiumGreen.withValues(alpha: 0.3)),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }

  void _showSnack(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('🔧 $message'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Widget _section(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title.toUpperCase(),
        style: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: AppTheme.accentBlue,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _statItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.inter(fontSize: 11, color: AppTheme.textDim),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Premium Status Card — gold card with days remaining counter
// ---------------------------------------------------------------------------

class _PremiumStatusCard extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final details = ref.watch(premiumDetailsProvider);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF002010), Color(0xFF003018), Color(0xFF002010)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.premiumGreen.withValues(alpha: 0.4)),
        boxShadow: [
          BoxShadow(
            color: AppTheme.premiumGreen.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: details.when(
        data: (data) => _buildContent(data),
        loading: () => _buildShimmer(),
        error: (_, _) => _buildContent(null),
      ),
    );
  }

  Widget _buildContent(PremiumDetails? details) {
    final isLifetime = details?.isLifetime ?? false;
    final daysLeft = details?.daysRemaining ?? 0;
    final isExpired = details?.isExpired ?? false;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header row
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppTheme.premiumGreen.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.workspace_premium_rounded,
                color: AppTheme.premiumGreen,
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Premium Active',
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.premiumGreen,
                    ),
                  ),
                  Text(
                    isLifetime
                        ? 'Lifetime subscription'
                        : isExpired
                        ? 'Subscription expired'
                        : '${daysLeft}d remaining',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: AppTheme.premiumGreen.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
            // Days badge
            if (!isLifetime)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: isExpired
                      ? AppTheme.dangerRed.withValues(alpha: 0.2)
                      : AppTheme.premiumGreen.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isExpired
                        ? AppTheme.dangerRed.withValues(alpha: 0.3)
                        : AppTheme.premiumGreen.withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  isExpired ? 'EXPIRED' : '${daysLeft}d',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: isExpired
                        ? AppTheme.dangerRed
                        : AppTheme.premiumGreen,
                  ),
                ),
              )
            else
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.premiumGreen.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppTheme.premiumGreen.withValues(alpha: 0.3),
                  ),
                ),
                child: Icon(
                  Icons.all_inclusive_rounded,
                  color: AppTheme.premiumGreen,
                  size: 18,
                ),
              ),
          ],
        ),
        const SizedBox(height: 14),
        // Benefits list
        _benefitRow(Icons.search_rounded, 'Unlimited daily searches'),
        const SizedBox(height: 6),
        _benefitRow(Icons.account_balance_rounded, 'Up to 6 portfolios'),
        const SizedBox(height: 6),
        _benefitRow(Icons.monetization_on_rounded, '\$15,000 starting capital'),
        const SizedBox(height: 6),
        _benefitRow(Icons.psychology_rounded, 'Up to 5 stress tests'),
        const SizedBox(height: 6),
        _benefitRow(Icons.block_rounded, 'Ad-free experience'),
      ],
    );
  }

  Widget _benefitRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(
          icon,
          size: 14,
          color: AppTheme.premiumGreen.withValues(alpha: 0.7),
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: GoogleFonts.inter(
            fontSize: 12,
            color: AppTheme.premiumGreen.withValues(alpha: 0.85),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildShimmer() {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: AppTheme.premiumGreen.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 120,
              height: 14,
              decoration: BoxDecoration(
                color: AppTheme.premiumGreen.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 4),
            Container(
              width: 80,
              height: 10,
              decoration: BoxDecoration(
                color: AppTheme.premiumGreen.withValues(alpha: 0.07),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
