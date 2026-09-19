import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/theme_v2.dart';
import '../../core/supabase/supabase_client.dart';
import '../../l10n/gen/app_localizations.dart';
import '../auth/auth_providers.dart' show resolvePostAuthRoute;

import 'disclaimer_providers.dart';

class DisclaimerScreen extends ConsumerStatefulWidget {
  const DisclaimerScreen({super.key});

  @override
  ConsumerState<DisclaimerScreen> createState() => _DisclaimerScreenState();
}

class _DisclaimerScreenState extends ConsumerState<DisclaimerScreen> {
  bool _isChecked = false;

  Future<void> _openLink(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.disclaimerScreenLinkFailed),
          backgroundColor: ThemeV2.loss,
        ),
      );
    }
  }

  Future<void> _handleAccept() async {
    if (!_isChecked) return;
    try {
      final remoteVersions = await ref.read(remoteVersionsProvider.future);
      await ref.read(acceptedVersionsProvider.notifier).accept(remoteVersions);
      // isDisclaimerAcceptedProvider is a plain (non-autoDispose)
      // FutureProvider — it caches its resolved value forever until
      // invalidated. resolvePostAuthRoute() (called below) reads it, so
      // without this invalidation it keeps returning the stale pre-accept
      // `false` it resolved to on Splash, sending the user right back to
      // /disclaimer on every tap despite the write above having succeeded.
      ref.invalidate(isDisclaimerAcceptedProvider);

      // Mark setup as complete in Supabase users table
      final user = SupabaseConfig.client.auth.currentUser;
      if (user != null) {
        await SupabaseConfig.client.from('users').upsert({
          'id': user.id,
          'email': user.email,
          'is_setup_complete': true,
          'is_biometrics_enabled': false,
          'disclaimer_accepted_version': remoteVersions.disclaimerVersion,
          'updated_at': DateTime.now().toUtc().toIso8601String(),
        });
      }

      if (!mounted) return;
      final resolved = await resolvePostAuthRoute(ref);
      if (mounted) context.go(resolved.route, extra: resolved.extra);
    } catch (_) {
      if (!mounted) return;
      // Re-resolve even on a failed write — isDisclaimerAcceptedProvider
      // reads SharedPreferences fresh, so if acceptedVersionsProvider's
      // own write above didn't reach this point, this correctly sends
      // the user back to /disclaimer instead of a stale hardcoded /home
      // that used to skip the nickname gate outright (found live
      // 2026-09-16 — accepting the disclaimer always landed straight on
      // /home regardless of nickname status).
      final resolved = await resolvePostAuthRoute(ref);
      if (mounted) context.go(resolved.route, extra: resolved.extra);
    }
  }

  @override
  Widget build(BuildContext context) {
    final geoAsync = ref.watch(geoCheckProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: geoAsync.when(
          loading: () => const Center(
            child: CircularProgressIndicator(color: ThemeV2.primary),
          ),
          error: (_, _) => _buildContent(isBlocked: false),
          data: (geo) =>
              _buildContent(isBlocked: geo.isBlocked, reason: geo.reason),
        ),
      ),
    );
  }

  Widget _buildContent({required bool isBlocked, String? reason}) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
          child: Column(
            children: [
              const Icon(
                Icons.info_outline_rounded,
                color: ThemeV2.primary,
                size: 40,
              ),
              const SizedBox(height: 12),
              Text(
                l10n.disclaimerScreenTitle,
                style: GoogleFonts.inter(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: ThemeV2.textPrimary,
                ),
              ),
              if (!isBlocked) ...[
                const SizedBox(height: 8),
                Text(
                  l10n.disclaimerScreenIntro,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: ThemeV2.textBody,
                    height: 1.4,
                  ),
                ),
              ],
            ],
          ),
        ),

        if (isBlocked)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.gpp_bad_rounded,
                    color: ThemeV2.loss,
                    size: 64,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    reason ?? l10n.disclaimerScreenAccessRestricted,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      color: ThemeV2.textBody,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () =>
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                l10n.disclaimerScreenAppWillClose,
                              ),
                              backgroundColor: ThemeV2.loss,
                            ),
                          ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ThemeV2.loss,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Text(
                        l10n.disclaimerScreenCloseAppButton,
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
          )
        else
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              children: [
                _section(
                  Icons.videogame_asset_rounded,
                  l10n.disclaimerScreenNoRealMoneyTitle,
                  l10n.disclaimerScreenNoRealMoneyBody,
                ),
                const SizedBox(height: 16),
                _section(
                  Icons.school_rounded,
                  l10n.disclaimerScreenImportantNoticeTitle,
                  l10n.disclaimerScreenImportantNoticeBody,
                ),
                const SizedBox(height: 16),
                _section(
                  Icons.insights_rounded,
                  l10n.disclaimerScreenFsScoresTitle,
                  l10n.disclaimerScreenFsScoresBody,
                ),
                const SizedBox(height: 16),
                _section(
                  Icons.dns_rounded,
                  l10n.disclaimerScreenDataSourcesTitle,
                  l10n.disclaimerScreenDataSourcesBody,
                ),
                const SizedBox(height: 16),
                _section(
                  Icons.lock_outline_rounded,
                  l10n.disclaimerScreenPrivacyTitle,
                  l10n.disclaimerScreenPrivacyBody,
                ),
                const SizedBox(height: 16),
                _section(
                  Icons.update_rounded,
                  l10n.disclaimerScreenTermsUpdatesTitle,
                  l10n.disclaimerScreenTermsUpdatesBody,
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),

        // Bottom: checkbox + accept button
        if (!isBlocked)
          Container(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
            decoration: BoxDecoration(
              color: Colors.transparent,
              border: Border(
                top: BorderSide(color: Colors.black.withValues(alpha: 0.06)),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: Checkbox(
                          value: _isChecked,
                          onChanged: (val) =>
                              setState(() => _isChecked = val ?? false),
                          activeColor: ThemeV2.primary,
                          checkColor: Colors.white,
                          side: const BorderSide(color: ThemeV2.textSecondary),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: ThemeV2.textBody,
                            height: 1.5,
                          ),
                          children: [
                            TextSpan(
                              text: l10n.disclaimerScreenAcceptPrefix,
                            ),
                            WidgetSpan(
                              alignment: PlaceholderAlignment.baseline,
                              baseline: TextBaseline.alphabetic,
                              child: GestureDetector(
                                onTap: () =>
                                    _openLink('https://fomoshield.app/terms'),
                                child: Container(
                                  decoration: const BoxDecoration(
                                    border: Border(
                                      bottom: BorderSide(
                                        color: ThemeV2.primary,
                                        width: 0.5,
                                      ),
                                    ),
                                  ),
                                  child: Text(
                                    l10n.disclaimerScreenTermsOfServiceLink,
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      color: ThemeV2.primary,
                                      height: 1.0,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            TextSpan(text: l10n.disclaimerScreenAcceptAndThe),
                            WidgetSpan(
                              alignment: PlaceholderAlignment.baseline,
                              baseline: TextBaseline.alphabetic,
                              child: GestureDetector(
                                onTap: () => _openLink(
                                  'https://fomoshield.app/privacy',
                                ),
                                child: Container(
                                  decoration: const BoxDecoration(
                                    border: Border(
                                      bottom: BorderSide(
                                        color: ThemeV2.primary,
                                        width: 0.5,
                                      ),
                                    ),
                                  ),
                                  child: Text(
                                    l10n.disclaimerScreenPrivacyPolicyLink,
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      color: ThemeV2.primary,
                                      height: 1.0,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const TextSpan(text: '.'),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _isChecked ? _handleAccept : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isChecked
                          ? ThemeV2.primary
                          : ThemeV2.surface,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: ThemeV2.surface,
                      disabledForegroundColor: ThemeV2.textSecondary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      l10n.disclaimerScreenAcceptButton,
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
    );
  }

  Widget _section(IconData icon, String title, String body) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: ThemeV2.primary, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: ThemeV2.primary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          body,
          style: GoogleFonts.inter(
            fontSize: 13,
            color: ThemeV2.textBody,
            height: 1.6,
          ),
        ),
      ],
    );
  }
}
