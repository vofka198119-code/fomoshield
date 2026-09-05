import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/layout/bottom_clearance.dart';
import '../../core/theme/theme_v2.dart';
import '../../core/theme/app_palette.dart';
import '../../core/theme/theme_variant_provider.dart';
import '../../core/theme/themed_header.dart';
import '../../core/theme/themed_border.dart';
import '../../core/theme/themed_divider.dart';
import '../../shared/widgets/card_frame.dart';
import '../../core/supabase/supabase_providers.dart';
import '../auth/auth_providers.dart';
import '../home/home_providers.dart';
import '../home/widget_order_provider.dart';
import '../portfolio/portfolio_providers.dart';
import '../search/search_counter_provider.dart';
import '../search/search_provider.dart';
import '../company_detail/watchlist_ad_provider.dart';
import '../stress_test/stress_test_engine.dart';
import '../market_clock/market_clock_dial.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../../l10n/gen/app_localizations.dart';
import '../../shared/widgets/disclaimer_footer.dart';
import '../../shared/services/finnhub_service.dart';

/// App version + build number, read from the actual installed build (not
/// hardcoded) — build number auto-increments on every commit, see
/// .git/hooks/pre-commit.
final packageInfoProvider = FutureProvider<PackageInfo>(
  (ref) => PackageInfo.fromPlatform(),
);

Future<void> _openLink(String url) async {
  final uri = Uri.parse(url);
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}

Future<void> _confirmDeleteAccount(BuildContext context, WidgetRef ref) async {
  final l10n = AppLocalizations.of(context)!;
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(
        l10n.profileDeleteAccountTitle,
        style: GoogleFonts.inter(fontWeight: FontWeight.w700),
      ),
      content: Text(
        l10n.profileDeleteAccountBody,
        style: GoogleFonts.inter(fontSize: 14),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(false),
          child: Text(
            l10n.profileCancel,
            style: GoogleFonts.inter(color: ThemeV2.textSecondary),
          ),
        ),
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(true),
          child: Text(
            l10n.profileDelete,
            style: GoogleFonts.inter(
              color: ThemeV2.loss,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    ),
  );
  if (confirmed != true || !context.mounted) return;

  showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (_) =>
        const Center(child: CircularProgressIndicator(color: ThemeV2.primary)),
  );

  try {
    // Schedules deletion 14 days out instead of an immediate hard delete —
    // see finnhub_service.dart's doc comment and accountCleanup.js on the
    // backend for the actual sweep that does the permanent erase.
    await FinnhubService().scheduleAccountDeletion();
    await clearAllSessionData();
    if (!context.mounted) return;
    Navigator.of(context, rootNavigator: true).pop(); // dismiss spinner
    // Same cache invalidation as Sign Out — see that button's comment.
    ref.invalidate(isLoggedInProvider);
    ref.invalidate(hasSupabaseSessionProvider);
    ref.invalidate(watchlistSymbolsProvider);
    ref.invalidate(portfoliosProvider);
    ref.invalidate(homeWidgetsProvider);
    ref.invalidate(searchProvider);
    ref.invalidate(searchCounterProvider);
    if (!context.mounted) return;
    context.go('/auth');
  } catch (_) {
    if (!context.mounted) return;
    Navigator.of(context, rootNavigator: true).pop(); // dismiss spinner
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          l10n.profileDeleteFailed,
          style: GoogleFonts.inter(fontSize: 13),
        ),
        backgroundColor: ThemeV2.loss,
      ),
    );
  }
}

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final user = ref.watch(currentUserProvider);
    final subscriptionTier = ref.watch(subscriptionTierProvider);
    final isAdmin = ref.watch(isAdminProvider);

    // ── Statistics section — was hardcoded '1'/'0'/'0' stub values,
    // never wired to any real data. Days: since account creation (Supabase
    // User.createdAt), floored at 1 so a brand-new account still reads "1"
    // like the old stub did instead of "0". Companies: distinct symbols
    // currently held in the real Portfolio (single-portfolio system — see
    // portfolio_limits_provider.dart). Tests: total Stress Test sessions
    // ever created (any status), not just completed ones.
    final portfolios = ref.watch(portfoliosProvider);
    final companiesHeldCount = portfolios.isEmpty
        ? 0
        : portfolios.first.holdings.length;
    // .length alone undercounts — a completed test is removed from the
    // active `state` list and archived (see stress_test_engine.dart's
    // _completeTest), so a user with any finished tests would show fewer
    // than they've actually run. totalSessionsCreated is the notifier's own
    // lifetime counter, incremented once per session ever created and
    // never decremented — watching stressTestProvider still gives this
    // rebuild on every session create/complete (both mutate `state` too),
    // reading .notifier just picks the current counter value on that
    // rebuild rather than needing its own reactive stream.
    ref.watch(stressTestProvider);
    final testsCount = ref
        .read(stressTestProvider.notifier)
        .totalSessionsCreated;
    final accountCreatedAt = user == null
        ? null
        : DateTime.tryParse(user.createdAt);
    final daysActive = accountCreatedAt == null
        ? 1
        : (DateTime.now().difference(accountCreatedAt).inDays + 1).clamp(
            1,
            1 << 30,
          );

    final email = user?.email ?? l10n.profileNotSignedIn;
    final displayName = email.split('@').first;
    final isPremium = subscriptionTier == SubscriptionTier.premium;
    final palette = resolveAppPalette(ref.watch(themeVariantProvider));

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        centerTitle: true,
        // Bottom-nav tab root (ShellRoute) — see home_screen.dart's
        // matching comment for why this is conditional on canPop.
        leading: Navigator.canPop(context)
            ? themedBackButton(context, palette)
            : null,
        title: themedHeaderText(
          l10n.profileTitle,
          palette,
          GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.5,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── User Info Card ───────────────────────────────────────
          CardFrame(
            padding: const EdgeInsets.all(20),
            palette: palette,
            child: Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: palette.accentPrimary.withValues(
                    alpha: 0.15,
                  ),
                  child: Icon(
                    isAdmin
                        ? Icons.admin_panel_settings_rounded
                        : isPremium
                        ? Icons.workspace_premium_rounded
                        : Icons.person_rounded,
                    color: palette.accentPrimary,
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
                                color: palette.textHeader,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Subscription badge (FREE → no badge)
                          if (subscriptionTier.isPremiumOrAdmin)
                            themedBorder(
                              palette: palette,
                              borderRadius: BorderRadius.circular(6),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: palette.windowGradient != null
                                    ? BoxDecoration(
                                        gradient: palette.windowGradient,
                                        borderRadius: BorderRadius.circular(6),
                                      )
                                    : darkCardDecoration(
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                child: Text(
                                  isAdmin
                                      ? l10n.profileAdminBadge
                                      : l10n.profilePremiumBadge,
                                  style: GoogleFonts.inter(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color:
                                        palette.marketClockAccent ??
                                        dialBrassLight,
                                    letterSpacing: 1,
                                    shadows: [
                                      Shadow(
                                        color:
                                            (palette.marketClockAccent ??
                                                    dialBrassLight)
                                                .withValues(alpha: 0.5),
                                        blurRadius: 6,
                                      ),
                                    ],
                                  ),
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
                          color: palette.textBody,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Premium Status Card (gold, for premium/admin users) ──
          if (subscriptionTier.isPremiumOrAdmin) ...[
            const SizedBox(height: 12),
            _PremiumStatusCard(),
          ],

          // ── Admin Badge ──────────────────────────────────────────
          if (isAdmin) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: palette.accentPrimary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: palette.accentPrimary.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.admin_panel_settings_rounded,
                    color: palette.accentPrimary,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Admin Mode — all premium features unlocked',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: palette.accentPrimary,
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
                gradient: palette.windowGradient,
                color: palette.windowGradient == null
                    ? palette.accentPrimary.withValues(alpha: 0.08)
                    : null,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: palette.accentPrimary.withValues(alpha: 0.2),
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
                      // This box's fill switches to the theme's dark
                      // windowGradient when one is set (see decoration
                      // above) — plain accentPrimary is near-black for
                      // Black & White (tuned for its white outer card) and
                      // would be invisible here, same reasoning as every
                      // other windowGradient-backed text/icon in the app.
                      color: palette.onWindow ?? palette.accentPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _adminButton(
                    palette: palette,
                    icon: Icons.search_rounded,
                    label: 'Reset search counter (→ 15)',
                    onTap: () {
                      ref.read(searchCounterProvider.notifier).resetToFree();
                      _showSnack(context, 'Search counter reset to 15');
                    },
                  ),
                  const SizedBox(height: 8),
                  _adminButton(
                    palette: palette,
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
                    palette: palette,
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
                      ref.read(activePortfolioIdProvider.notifier).state = null;
                      _showSnack(context, 'All portfolios cleared');
                    },
                  ),
                  const SizedBox(height: 8),
                  _adminButton(
                    palette: palette,
                    icon: Icons.ads_click_rounded,
                    label: 'Reset watchlist ad counter',
                    onTap: () {
                      ref.read(watchlistAdProvider.notifier).reset();
                      _showSnack(context, 'Watchlist ad counter reset');
                    },
                  ),
                  const SizedBox(height: 8),
                  _adminButton(
                    palette: palette,
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
          _section(l10n.profilePreferencesSection, palette),
          CardFrame(
            padding: EdgeInsets.zero,
            palette: palette,
            child: ListTile(
              leading: Icon(Icons.language, color: palette.accentPrimary),
              title: Text(
                l10n.languageTitle,
                style: GoogleFonts.inter(color: palette.textHeader),
              ),
              trailing: Icon(Icons.chevron_right, color: palette.textBody),
              onTap: () => context.push('/language'),
            ),
          ),

          // ── Theme (admin-only preview for now) ─────────────────────
          if (isAdmin) ...[
            const SizedBox(height: 12),
            CardFrame(
              padding: EdgeInsets.zero,
              palette: palette,
              child: ListTile(
                leading: Icon(
                  Icons.palette_rounded,
                  color: palette.accentPrimary,
                ),
                title: Text(
                  l10n.themeTitle,
                  style: GoogleFonts.inter(color: palette.textHeader),
                ),
                trailing: Icon(Icons.chevron_right, color: palette.textBody),
                onTap: () => context.push('/theme'),
              ),
            ),
          ],

          const SizedBox(height: 24),

          // ── Statistics ────────────────────────────────────────────
          _section(l10n.profileStatisticsSection, palette),
          CardFrame(
            padding: const EdgeInsets.all(16),
            palette: palette,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _statItem(l10n.profileStatDays, '$daysActive', palette),
                _statItem(
                  l10n.profileStatCompanies,
                  '$companiesHeldCount',
                  palette,
                ),
                _statItem(l10n.profileStatTests, '$testsCount', palette),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // ── Legal ─────────────────────────────────────────────────
          _section(l10n.profileLegalSection, palette),
          CardFrame(
            padding: EdgeInsets.zero,
            palette: palette,
            child: Column(
              children: [
                ListTile(
                  title: Text(
                    l10n.profilePrivacyPolicy,
                    style: GoogleFonts.inter(color: palette.textHeader),
                  ),
                  trailing: Icon(Icons.chevron_right, color: palette.textBody),
                  onTap: () => _openLink('https://fomoshield.app/privacy'),
                ),
                palette.dividerGradient != null
                    ? themedDivider(palette, indent: 0, endIndent: 0)
                    : const Divider(height: 1),
                ListTile(
                  title: Text(
                    l10n.profileTermsOfUse,
                    style: GoogleFonts.inter(color: palette.textHeader),
                  ),
                  trailing: Icon(Icons.chevron_right, color: palette.textBody),
                  onTap: () => _openLink('https://fomoshield.app/terms'),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          Center(
            child: ref
                .watch(packageInfoProvider)
                .when(
                  data: (info) {
                    // Compact "1.0.004" form — major.minor from the version
                    // string, build number zero-padded to 3 digits, instead
                    // of the old "v1.0.0 (build 4)".
                    final versionParts = info.version.split('.');
                    final majorMinor = versionParts.length >= 2
                        ? '${versionParts[0]}.${versionParts[1]}'
                        : info.version;
                    final build = info.buildNumber.padLeft(3, '0');
                    return Text(
                      'v$majorMinor.$build',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: palette.titleGradient != null
                            ? Colors.white
                            : palette.textBody.withValues(alpha: 0.5),
                      ),
                    );
                  },
                  loading: () => const SizedBox.shrink(),
                  error: (_, _) => const SizedBox.shrink(),
                ),
          ),

          const SizedBox(height: 16),

          // ── Sign Out ─────────────────────────────────────────────
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton.icon(
              onPressed: () async {
                // 1) Clear ALL user session data (SharedPrefs + SecureStorage)
                await clearAllSessionData();
                // 2) Invalidate Riverpod providers so they re-load fresh —
                // isLoggedIn/hasSupabaseSession are cached FutureProviders;
                // without this, navigating back to Splash mid-session would
                // read their stale pre-signout value and silently restore
                // the old session (real bug, found 2026-08-14).
                ref.invalidate(isLoggedInProvider);
                ref.invalidate(hasSupabaseSessionProvider);
                ref.invalidate(watchlistSymbolsProvider);
                ref.invalidate(portfoliosProvider);
                ref.invalidate(homeWidgetsProvider);
                ref.invalidate(searchProvider);
                ref.invalidate(searchCounterProvider);
                // 3) Navigate instantly to login (skip Splash's loading delay)
                if (!context.mounted) return;
                context.go('/auth');
              },
              icon: const Icon(Icons.logout_rounded, color: ThemeV2.loss),
              label: Text(
                l10n.profileSignOut,
                style: GoogleFonts.inter(color: ThemeV2.loss, fontSize: 15),
              ),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: ThemeV2.loss.withValues(alpha: 0.3)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // ── Delete Account ───────────────────────────────────────
          // Deliberately lower visual weight than Sign Out (smaller,
          // muted) — rare/dangerous action, shouldn't compete with the
          // common one, but still reachable in one tap per Apple App Store
          // Review Guideline 5.1.1(v) (in-app account deletion required).
          SizedBox(
            width: double.infinity,
            height: 44,
            child: TextButton.icon(
              onPressed: () => _confirmDeleteAccount(context, ref),
              icon: Icon(
                Icons.delete_forever_rounded,
                color: ThemeV2.loss.withValues(alpha: 0.55),
                size: 20,
              ),
              label: Text(
                l10n.profileDeleteAccount,
                style: GoogleFonts.inter(
                  color: ThemeV2.loss.withValues(alpha: 0.55),
                  fontSize: 13,
                ),
              ),
            ),
          ),

          DisclaimerFooter(palette: palette),
          SizedBox(height: shellBottomClearance(context)),
        ],
      ),
    );
  }

  Widget _adminButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required AppPalette palette,
  }) {
    // Only ever rendered inside the Admin Sandbox panel above, whose fill
    // switches to the theme's dark windowGradient when one is set — see
    // that panel's own comment on why accentPrimary alone isn't safe here.
    final onDark = palette.onWindow ?? palette.accentPrimary;
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 16, color: onDark),
        label: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            color: onDark,
            fontWeight: FontWeight.w500,
          ),
        ),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: palette.accentPrimary.withValues(alpha: 0.3)),
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

  Widget _section(String title, AppPalette palette) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title.toUpperCase(),
        style: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: palette.accentPrimary,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _statItem(String label, String value, AppPalette palette) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: palette.textHeader,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.inter(fontSize: 11, color: palette.textBody),
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
    final l10n = AppLocalizations.of(context)!;
    final details = ref.watch(premiumDetailsProvider);
    final palette = resolveAppPalette(ref.watch(themeVariantProvider));
    // Gold, or this theme's own accent (turquoise under Midnight Sea) — was
    // hardcoded ThemeV2.warning everywhere below regardless of theme.
    final accentColor = palette.marketClockAccent ?? ThemeV2.warning;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        // Same dark-green "instrument panel" role as darkCardGradient()
        // elsewhere, just hand-rolled here — swap in the theme's own
        // windowGradient when one is set (e.g. Black & White's
        // graphite-to-black radial) instead of this hardcoded green.
        gradient:
            palette.windowGradient ??
            const LinearGradient(
              colors: [Color(0xFF002010), Color(0xFF003018), Color(0xFF002010)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accentColor.withValues(alpha: 0.4)),
        boxShadow: [
          BoxShadow(
            color: accentColor.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: details.when(
        data: (data) => _buildContent(l10n, data, accentColor),
        loading: () => _buildShimmer(accentColor),
        error: (_, _) => _buildContent(l10n, null, accentColor),
      ),
    );
  }

  Widget _buildContent(
    AppLocalizations l10n,
    PremiumDetails? details,
    Color accentColor,
  ) {
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
                color: accentColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.workspace_premium_rounded,
                color: accentColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.premiumActive,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: accentColor,
                    ),
                  ),
                  Text(
                    isLifetime
                        ? l10n.premiumLifetime
                        : isExpired
                        ? l10n.premiumExpired
                        : l10n.premiumDaysRemaining(daysLeft),
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: accentColor.withValues(alpha: 0.7),
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
                      ? ThemeV2.loss.withValues(alpha: 0.2)
                      : accentColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isExpired
                        ? ThemeV2.loss.withValues(alpha: 0.3)
                        : accentColor.withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  isExpired
                      ? l10n.premiumExpiredBadge
                      : l10n.premiumDaysBadge(daysLeft),
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: isExpired ? ThemeV2.loss : accentColor,
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
                  color: accentColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: accentColor.withValues(alpha: 0.3)),
                ),
                child: Icon(
                  Icons.all_inclusive_rounded,
                  color: accentColor,
                  size: 18,
                ),
              ),
          ],
        ),
        const SizedBox(height: 14),
        // Benefits list
        _benefitRow(
          Icons.search_rounded,
          l10n.premiumBenefitSearches,
          accentColor,
        ),
        const SizedBox(height: 6),
        _benefitRow(
          Icons.account_balance_rounded,
          l10n.premiumBenefitPortfolios,
          accentColor,
        ),
        const SizedBox(height: 6),
        _benefitRow(
          Icons.monetization_on_rounded,
          l10n.premiumBenefitCapital,
          accentColor,
        ),
        const SizedBox(height: 6),
        _benefitRow(
          Icons.psychology_rounded,
          l10n.premiumBenefitStressTests,
          accentColor,
        ),
        const SizedBox(height: 6),
        _benefitRow(
          Icons.savings_rounded,
          l10n.premiumBenefitWeeklyPayout,
          accentColor,
        ),
        const SizedBox(height: 6),
        _benefitRow(
          Icons.auto_graph_rounded,
          l10n.premiumBenefitStressTestDca,
          accentColor,
        ),
        const SizedBox(height: 6),
        _benefitRow(
          Icons.block_rounded,
          l10n.premiumBenefitAdFree,
          accentColor,
        ),
      ],
    );
  }

  Widget _benefitRow(IconData icon, String text, Color accentColor) {
    return Row(
      children: [
        Icon(icon, size: 14, color: accentColor.withValues(alpha: 0.7)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: accentColor.withValues(alpha: 0.85),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildShimmer(Color accentColor) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: accentColor.withValues(alpha: 0.1),
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
                color: accentColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 4),
            Container(
              width: 80,
              height: 10,
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.07),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
