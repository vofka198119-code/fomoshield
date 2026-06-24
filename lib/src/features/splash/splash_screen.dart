import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/theme/app_theme.dart';
import '../../core/supabase/supabase_client.dart';
import '../disclaimer/disclaimer_providers.dart';
import '../auth/auth_providers.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<double> _fadeAnimation;
  bool _navigated = false;

  @override
  void initState() {
    super.initState();

    // Fade-in animation (800ms)
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeIn,
    );
    _animController.forward();

    // 2.5s splash display → auto-navigate
    Future.delayed(const Duration(milliseconds: 2500), () {
      if (mounted && !_navigated) _checkAuthState();
    });
  }

  Future<void> _checkAuthState() async {
    try {
      // ── Step 1: Is there an is_logged_in flag? ─────────────────
      final isLoggedIn = await ref.read(isLoggedInProvider.future);
      if (!mounted) return;

      if (!isLoggedIn) {
        _navigated = true;
        // Force-clear any lingering Supabase session
        if (SupabaseConfig.client.auth.currentSession != null) {
          await SupabaseConfig.client.auth.signOut();
        }
        if (!mounted) return;
        context.go('/auth');
        return;
      }

      // ── Step 2: is_logged_in == true → auto-login ─────────────
      final savedCreds = await ref.read(savedCredentialsProvider.future);
      if (!mounted) return;

      if (savedCreds == null) {
        _navigated = true;
        if (SupabaseConfig.client.auth.currentSession != null) {
          await SupabaseConfig.client.auth.signOut();
        }
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('is_logged_in', false);
        if (!mounted) return;
        context.go('/auth');
        return;
      }

      try {
        await SupabaseConfig.client.auth.signInWithPassword(
          email: savedCreds.email,
          password: savedCreds.password,
        );
      } catch (_) {
        _navigated = true;
        if (SupabaseConfig.client.auth.currentSession != null) {
          await SupabaseConfig.client.auth.signOut();
        }
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('is_logged_in', false);
        await ref.read(rememberMeProvider.notifier).clear();
        if (!mounted) return;
        context.go('/auth');
        return;
      }

      if (!mounted) return;
      _navigated = true;
      final disclaimerAccepted =
          await ref.read(isDisclaimerAcceptedProvider.future);
      if (!mounted) return;
      context.go(disclaimerAccepted ? '/home' : '/disclaimer');
    } catch (_) {
      _navigated = true;
      if (mounted) context.go('/auth');
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo — scaled up 10% (120 → 132)
              Container(
                width: 132,
                height: 132,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.card,
                  border: Border.all(color: AppTheme.accentBlue, width: 2),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(66),
                  child: Image.asset(
                    'assets/images/logo.png',
                    width: 132,
                    height: 132,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const Icon(
                      Icons.shield_rounded,
                      size: 62,
                      color: AppTheme.accentBlue,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Tagline
              Text(
                'Invest with discipline,\nnot emotion.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  color: AppTheme.textDim,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 60),
            ],
          ),
        ),
      ),
    );
  }
}
