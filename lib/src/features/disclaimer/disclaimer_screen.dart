import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/app_theme.dart';
import '../../core/supabase/supabase_client.dart';

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
    }
  }

  Future<void> _handleAccept() async {
    if (!_isChecked) return;
    try {
      final remoteVersions = await ref.read(remoteVersionsProvider.future);
      await ref.read(acceptedVersionsProvider.notifier).accept(remoteVersions);

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

      if (mounted) context.go('/home');
    } catch (_) {
      if (mounted) context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final geoAsync = ref.watch(geoCheckProvider);

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: geoAsync.when(
          loading: () => const Center(
            child: CircularProgressIndicator(color: AppTheme.accentBlue),
          ),
          error: (_, __) => _buildContent(isBlocked: false),
          data: (geo) => _buildContent(isBlocked: geo.isBlocked, reason: geo.reason),
        ),
      ),
    );
  }

  Widget _buildContent({required bool isBlocked, String? reason}) {
    return Column(
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
          child: Column(
            children: [
              const Icon(Icons.info_outline_rounded, color: AppTheme.accentBlue, size: 40),
              const SizedBox(height: 12),
              Text('Disclaimer', style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w700, color: Colors.white)),
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
                  const Icon(Icons.gpp_bad_rounded, color: AppTheme.dangerRed, size: 64),
                  const SizedBox(height: 24),
                  Text(
                    reason ?? 'Access Restricted',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(fontSize: 16, color: AppTheme.textDim, height: 1.5),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity, height: 52,
                    child: ElevatedButton(
                      onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('The app will now close'), backgroundColor: AppTheme.dangerRed),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.dangerRed, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: Text('Close App', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600)),
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
                _section('Important Notice',
                  'F.O.M.O. Shield is an educational tool designed to help investors understand '
                  'market behavior and their own decision-making patterns. It does not provide '
                  'financial advice, investment recommendations, or any form of financial '
                  'advisory services.'),
                const SizedBox(height: 16),
                _section('Independence of FS Scores',
                  'FS Scores and all related analytical materials are the result of F.O.M.O. Shield\'s '
                  'proprietary analysis based on mathematical models and publicly available data. '
                  'We do not receive compensation from companies for inclusion in the ratings or '
                  'for rating changes. FS Scores are not a recommendation to buy, sell, or hold '
                  'any security.'),
                const SizedBox(height: 16),
                _section('Data Sources',
                  'Market data is provided by Finnhub and Wikipedia APIs. While we strive for '
                  'accuracy, we cannot guarantee that all data is complete, accurate, or '
                  'up-to-date. Past performance is not indicative of future results. Stress test '
                  'scenarios are simulations based on mathematical models and historical patterns.'),
                const SizedBox(height: 16),
                _section('Geographic Restrictions',
                  'This application is available for global use. Russian language support is '
                  'provided for global Russian-speaking communities outside Russia and Belarus. '
                  'Access to this application from Russia and Belarus is strictly prohibited. '
                  'By accepting this disclaimer, you confirm that you are not accessing this '
                  'application from within Russia or Belarus.'),
                const SizedBox(height: 16),
                _section('Privacy',
                  'We collect minimal data necessary for app functionality: email address '
                  '(for account creation), anonymized usage statistics, and device language '
                  'preferences. We do not sell your data to third parties.'),
                const SizedBox(height: 16),
                _section('Terms Updates',
                  'We reserve the right to update this disclaimer, Terms of Service, and Privacy '
                  'Policy. In case of changes, the app will notify you and require re-acceptance '
                  'of the updated terms to continue.'),
                const SizedBox(height: 24),
              ],
            ),
          ),

        // Bottom: checkbox + accept button
        if (!isBlocked)
          Container(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
            decoration: BoxDecoration(
              color: AppTheme.background,
              border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.06))),
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
                        width: 24, height: 24,
                        child: Checkbox(
                          value: _isChecked,
                          onChanged: (val) => setState(() => _isChecked = val ?? false),
                          activeColor: AppTheme.accentBlue,
                          checkColor: Colors.white,
                          side: const BorderSide(color: AppTheme.textDim),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textDim, height: 1.5),
                          children: [
                            const TextSpan(text: 'I confirm that I am at least 18 years old, '
                                'I am not located in Russia or Belarus, and I fully accept '
                                'this Disclaimer, the '),
                            WidgetSpan(
                              alignment: PlaceholderAlignment.baseline,
                              baseline: TextBaseline.alphabetic,
                              child: GestureDetector(
                                onTap: () => _openLink('https://fomoshield.com/terms'),
                                child: Container(
                                  decoration: const BoxDecoration(
                                    border: Border(
                                      bottom: BorderSide(color: AppTheme.accentBlue, width: 0.5),
                                    ),
                                  ),
                                  child: Text(
                                    'Terms of Service',
                                    style: GoogleFonts.inter(fontSize: 12, color: AppTheme.accentBlue, height: 1.0),
                                  ),
                                ),
                              ),
                            ),
                            const TextSpan(text: ', and the '),
                            WidgetSpan(
                              alignment: PlaceholderAlignment.baseline,
                              baseline: TextBaseline.alphabetic,
                              child: GestureDetector(
                                onTap: () => _openLink('https://fomoshield.com/privacy'),
                                child: Container(
                                  decoration: const BoxDecoration(
                                    border: Border(
                                      bottom: BorderSide(color: AppTheme.accentBlue, width: 0.5),
                                    ),
                                  ),
                                  child: Text(
                                    'Privacy Policy',
                                    style: GoogleFonts.inter(fontSize: 12, color: AppTheme.accentBlue, height: 1.0),
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
                  width: double.infinity, height: 52,
                  child: ElevatedButton(
                    onPressed: _isChecked ? _handleAccept : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isChecked ? AppTheme.accentBlue : AppTheme.card,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: AppTheme.card,
                      disabledForegroundColor: AppTheme.textDim,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: Text('I Accept', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _section(String title, String body) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
        const SizedBox(height: 8),
        Text(body, style: GoogleFonts.inter(fontSize: 13, color: AppTheme.textDim, height: 1.6)),
      ],
    );
  }
}


