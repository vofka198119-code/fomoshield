import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/theme/app_theme.dart';
import '../../core/supabase/supabase_client.dart';
import '../auth/auth_providers.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // User info card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 28,
                    backgroundColor: AppTheme.accentBlue,
                    child: Icon(Icons.person_rounded, color: Colors.white, size: 32),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Investor', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white)),
                      const SizedBox(height: 4),
                      Text('investor@email.com', style: GoogleFonts.inter(fontSize: 13, color: AppTheme.textDim)),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          const SizedBox(height: 24),

          _section('Language'),
          Card(
            child: ListTile(
              leading: const Icon(Icons.language, color: AppTheme.accentBlue),
              title: Text('English', style: GoogleFonts.inter(color: Colors.white)),
              trailing: const Icon(Icons.chevron_right, color: AppTheme.textDim),
              onTap: () {},
            ),
          ),

          const SizedBox(height: 24),

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

          _section('Legal'),
          Card(
            child: Column(
              children: [
                ListTile(
                  title: Text('Privacy Policy', style: GoogleFonts.inter(color: Colors.white)),
                  trailing: const Icon(Icons.chevron_right, color: AppTheme.textDim),
                  onTap: () {},
                ),
                const Divider(height: 1),
                ListTile(
                  title: Text('Terms of Use', style: GoogleFonts.inter(color: Colors.white)),
                  trailing: const Icon(Icons.chevron_right, color: AppTheme.textDim),
                  onTap: () {},
                ),
                const Divider(height: 1),
                ListTile(
                  title: Text('Methodology', style: GoogleFonts.inter(color: Colors.white)),
                  trailing: const Icon(Icons.chevron_right, color: AppTheme.textDim),
                  onTap: () {},
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // Sign Out
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton.icon(
              onPressed: () async {
                // 1) Reset is_logged_in flag (SharedPreferences)
                final prefs = await SharedPreferences.getInstance();
                await prefs.setBool('is_logged_in', false);
                // 2) Clear saved credentials (email+password)
                await ref.read(rememberMeProvider.notifier).clear();
                // 3) Reset Supabase session + force sign out
                await SupabaseConfig.client.auth.signOut();
                // 4) Force-refresh — clear any cached session
                SupabaseConfig.client.auth.currentSession;
                // 5) Navigate instantly to login (skip Splash 2.5s delay)
                if (!context.mounted) return;
                context.go('/auth');
              },
              icon: const Icon(Icons.logout_rounded, color: AppTheme.dangerRed),
              label: Text('Sign Out', style: GoogleFonts.inter(color: AppTheme.dangerRed, fontSize: 15)),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: AppTheme.dangerRed.withValues(alpha: 0.3)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),

          const SizedBox(height: 40),
        ],
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
        Text(value, style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w700, color: Colors.white)),
        const SizedBox(height: 4),
        Text(label, style: GoogleFonts.inter(fontSize: 11, color: AppTheme.textDim)),
      ],
    );
  }
}
