import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/theme/theme_v2.dart';
import '../../core/theme/typography_helpers.dart';
import '../../core/supabase/supabase_client.dart';
import '../../shared/services/user_data_service.dart';
import '../disclaimer/disclaimer_providers.dart';
import 'auth_providers.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLogin = true;
  bool _obscurePassword = true;
  bool _isLoading = false;
  bool _rememberMe = false;
  String? _errorText;

  // ── Rate Limiting (brute-force protection) ──────────────────────
  int _failedAttempts = 0;
  DateTime? _blockedUntil;

  bool get _isBlocked =>
      _blockedUntil != null && DateTime.now().isBefore(_blockedUntil!);

  String? get _blockRemaining {
    if (!_isBlocked) return null;
    final remaining = _blockedUntil!.difference(DateTime.now()).inSeconds;
    return 'Too many attempts. Try again in $remaining seconds.';
  }

  void _recordFailedAttempt() {
    _failedAttempts++;
    if (_failedAttempts >= 3) {
      // Block: 30s → 5min → 15min → 30min
      final durations = [30, 300, 900, 1800];
      final level = (_failedAttempts - 3) % durations.length;
      final seconds = durations[level];
      _blockedUntil = DateTime.now().add(Duration(seconds: seconds));
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    // ── Check rate limit ──────────────────────────────────────────
    if (_isBlocked) {
      setState(() => _errorText = _blockRemaining);
      return;
    }

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      setState(() => _errorText = 'Please fill in all fields');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorText = null;
    });

    try {
      if (_isLogin) {
        // ── Sign In ───────────────────────────────────────────────
        await SupabaseConfig.client.auth.signInWithPassword(
          email: email,
          password: password,
        );
        // Success → reset failed attempts counter
        _failedAttempts = 0;
        _blockedUntil = null;
      } else {
        // ── Sign Up — check for duplicate email first ────────────
        // Try signing in first — if it succeeds, email is already taken
        try {
          await SupabaseConfig.client.auth.signInWithPassword(
            email: email,
            password: password,
          );
          // Sign in succeeded → user already exists with this email+password
          if (!mounted) return;
          setState(() {
            _errorText = 'A user with this email is already registered.';
            _isLoading = false;
          });
          return;
        } on AuthException {
          // Sign in failed — good, user doesn't exist or wrong password
        }

        // Now proceed with sign up
        final response = await SupabaseConfig.client.auth.signUp(
          email: email,
          password: password,
        );

        // If no session (e.g. email confirmation mode), don't auto-sign-in
        if (response.session == null) {
          if (!mounted) return;
          setState(() {
            _errorText = 'Please check your email to confirm registration.';
            _isLoading = false;
          });
          return;
        }

        // Sign up success → reset failed attempts
        _failedAttempts = 0;
        _blockedUntil = null;
      }

      if (!mounted) return;

      // ── Save credentials + is_logged_in flag if "Remember Me" ──
      if (_rememberMe) {
        await ref.read(rememberMeProvider.notifier).save(email, password);
        await setIsLoggedIn(true);
      } else {
        await setIsLoggedIn(false);
      }

      if (!mounted) return;

      // ── Sync user data from Supabase ────────────────────────────
      await ref.read(userDataSyncProvider.future);

      if (!mounted) return;

      // ── Navigate based on sign-in vs sign-up ──────────────────
      if (_isLogin) {
        // Existing user signing in → check disclaimer status
        final disclaimerAccepted =
            await ref.read(isDisclaimerAcceptedProvider.future);
        if (!mounted) return;
        context.go(disclaimerAccepted ? '/home' : '/disclaimer');
      } else {
        // New registration → always show disclaimer first
        context.go('/disclaimer');
      }
    } on AuthException catch (e) {
      if (!mounted) return;
      _recordFailedAttempt();
      setState(() {
        _errorText = _isBlocked ? _blockRemaining : e.message;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      _recordFailedAttempt();
      setState(() {
        _errorText = _isBlocked
            ? _blockRemaining!
            : 'Something went wrong. Please try again.';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),

              // Back
              IconButton(
                icon: const Icon(Icons.arrow_back_rounded, color: ThemeV2.textPrimary),
                onPressed: () => context.go('/'),
              ),

              const SizedBox(height: 24),

              // Title
              Text(
                _isLogin ? 'Welcome back' : 'Create account',
                style: GoogleFonts.inter(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: ThemeV2.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _isLogin
                    ? 'Sign in to continue investing with discipline'
                    : 'Start your journey to disciplined investing',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: ThemeV2.textSecondary,
                ),
              ),

              const SizedBox(height: 40),

              // Error
              if (_errorText != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(
                    _errorText!,
                    style: GoogleFonts.inter(fontSize: 13, color: ThemeV2.loss),
                  ),
                ),

              // Email
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  hintText: 'Email',
                  prefixIcon: Icon(Icons.email_outlined, color: ThemeV2.textSecondary),
                ),
              ),

              const SizedBox(height: 16),

              // Password
              TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  hintText: 'Password',
                  prefixIcon: const Icon(Icons.lock_outlined, color: ThemeV2.textSecondary),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                      color: ThemeV2.textSecondary,
                    ),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Forgot Password link (sign-in mode only)
              if (_isLogin)
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => context.push('/forgot-password'),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 4, vertical: 8),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      'Forgot Password?',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: ThemeV2.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),

              const SizedBox(height: 4),

              // Remember Me checkbox
              Row(
                children: [
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: Checkbox(
                      value: _rememberMe,
                      onChanged: (val) => setState(() => _rememberMe = val ?? false),
                      activeColor: ThemeV2.primary,
                      checkColor: Colors.white,
                      side: const BorderSide(color: ThemeV2.textSecondary),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Remember me',
                    style: GoogleFonts.inter(fontSize: 13, color: ThemeV2.textSecondary),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Submit button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: (_isLoading || _isBlocked) ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ThemeV2.primary,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: ThemeV2.surface,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: ThemeV2.textPrimary,
                          ),
                        )
                      : Text(
                          _isLogin ? 'Sign In' : 'Create Account',
                          style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                ),
              ),

              const SizedBox(height: 16),

              // Toggle login / register
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _isLogin ? "Don't have an account?" : 'Already have an account?',
                    style: GoogleFonts.inter(color: ThemeV2.textSecondary, fontSize: 13),
                  ),
                  TextButton(
                    onPressed: () => setState(() {
                      _isLogin = !_isLogin;
                      _errorText = null;
                    }),
                    child: Text(
                      _isLogin ? 'Sign Up' : 'Sign In',
                      style: GoogleFonts.inter(color: ThemeV2.primary, fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

