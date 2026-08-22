import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/theme/theme_v2.dart';
import '../../core/supabase/supabase_client.dart';
import '../../l10n/gen/app_localizations.dart';
import '../../shared/services/user_data_service.dart';
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

  AppLocalizations get _l10n => AppLocalizations.of(context)!;

  bool get _isBlocked =>
      _blockedUntil != null && DateTime.now().isBefore(_blockedUntil!);

  String? get _blockRemaining {
    if (!_isBlocked) return null;
    final remaining = _blockedUntil!.difference(DateTime.now()).inSeconds;
    return _l10n.authTooManyAttempts(remaining);
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

  // ── Email resend cooldown (Supabase anti-abuse limit) ────────────
  // Supabase returns e.g. "For security purposes, you can only request
  // this after 46 seconds." — we parse the number and tick it down live
  // instead of leaving the frozen sentence on screen.
  static final _cooldownPattern = RegExp(
    r'(\d+)\s*seconds?',
    caseSensitive: false,
  );
  static const _googleLogoSvg = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 48 48">
<path fill="#FFC107" d="M43.6 20.5H42V20H24v8h11.3C33.7 32.7 29.3 36 24 36c-6.6 0-12-5.4-12-12s5.4-12 12-12c3.1 0 5.9 1.2 8 3.1l5.7-5.7C34.5 6.5 29.5 4.5 24 4.5 12.7 4.5 3.5 13.7 3.5 25S12.7 45.5 24 45.5c11 0 20.5-8 20.5-20.5 0-1.4-.1-2.7-.4-4Z"/>
<path fill="#FF3D00" d="M6.3 14.7l6.6 4.8C14.6 16 19 13.5 24 13.5c3.1 0 5.9 1.2 8 3.1l5.7-5.7C34.5 7.5 29.5 5.5 24 5.5c-7.6 0-14.1 4.3-17.4 10.6Z"/>
<path fill="#4CAF50" d="M24 44.5c5.4 0 10.3-1.8 14-4.9l-6.5-5.4c-2 1.4-4.6 2.2-7.5 2.2-5.2 0-9.6-3.3-11.3-7.9l-6.5 5C9.7 40.1 16.3 44.5 24 44.5Z"/>
<path fill="#1976D2" d="M43.6 20.5H42V20H24v8h11.3c-.8 2.4-2.4 4.4-4.4 5.8l6.5 5.4C40.7 35.9 44.5 30.9 44.5 24c0-1.2-.1-2.4-.3-3.5Z"/>
</svg>
''';
  Timer? _cooldownTimer;
  int? _cooldownSecondsLeft;

  void _startCooldownFromMessage(String message) {
    final match = _cooldownPattern.firstMatch(message);
    if (match == null) return;
    final seconds = int.parse(match.group(1)!);
    if (seconds <= 0) return;

    _cooldownTimer?.cancel();
    setState(() {
      _cooldownSecondsLeft = seconds;
      _errorText = _l10n.authWaitSeconds(seconds);
    });
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        final left = (_cooldownSecondsLeft ?? 1) - 1;
        if (left <= 0) {
          _cooldownSecondsLeft = null;
          _errorText = null;
          timer.cancel();
        } else {
          _cooldownSecondsLeft = left;
          _errorText = _l10n.authWaitSeconds(left);
        }
      });
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _cooldownTimer?.cancel();
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
      setState(() => _errorText = _l10n.authPleaseFillFields);
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
            _errorText = _l10n.authEmailAlreadyRegistered;
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
          emailRedirectTo: 'com.scanco.scanco://login-callback',
        );

        // If no session (e.g. email confirmation mode), don't auto-sign-in
        if (response.session == null) {
          if (!mounted) return;
          // Supabase returns an obfuscated user with an empty identities
          // list (no email actually sent) when this address is already
          // registered — including via Google — to avoid leaking that
          // fact to an attacker. Surface it honestly to our own user.
          final alreadyRegistered = response.user?.identities?.isEmpty ?? false;
          setState(() {
            _errorText = alreadyRegistered
                ? _l10n.authEmailAlreadyRegisteredGoogle
                : _l10n.authCheckEmailConfirm;
            _isLoading = false;
          });
          return;
        }

        // Sign up success → reset failed attempts
        _failedAttempts = 0;
        _blockedUntil = null;
      }

      if (!mounted) return;

      // ── Record the "Remember Me" choice — Supabase itself already
      // persists the session either way; this only decides whether Splash
      // honors that on next cold start or signs back out ──
      await setIsLoggedIn(_rememberMe);
      ref.invalidate(isLoggedInProvider);
      ref.invalidate(hasSupabaseSessionProvider);

      if (!mounted) return;

      // ── Sync user data from Supabase ────────────────────────────
      await ref.read(userDataSyncProvider.future);

      if (!mounted) return;

      // ── Navigate based on sign-in vs sign-up ──────────────────
      if (_isLogin) {
        // Existing user signing in → check pending-deletion, then disclaimer
        final resolved = await resolvePostAuthRoute(ref);
        if (!mounted) return;
        context.go(resolved.route, extra: resolved.extra);
      } else {
        // New registration → always show disclaimer first
        context.go('/disclaimer');
      }
    } on AuthException catch (e) {
      if (!mounted) return;
      if (_cooldownPattern.hasMatch(e.message)) {
        // Supabase email-send cooldown → live countdown, not a brute-force strike
        setState(() {
          _isLoading = false;
        });
        _startCooldownFromMessage(e.message);
        return;
      }
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
            : _l10n.authSomethingWentWrong;
        _isLoading = false;
      });
    }
  }

  Future<void> _signInWithGoogle() async {
    if (_isBlocked) {
      setState(() => _errorText = _blockRemaining);
      return;
    }

    setState(() {
      _isLoading = true;
      _errorText = null;
    });

    try {
      final account = await GoogleSignIn.instance.authenticate();
      final idToken = account.authentication.idToken;
      if (idToken == null) {
        throw AuthException(_l10n.authGoogleNoIdToken);
      }

      await SupabaseConfig.client.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
      );

      // Same "Remember Me" choice as email/password sign-in — Supabase
      // persists the session for Google accounts too, so there's no reason
      // to special-case this to always sign back out on next cold start.
      await setIsLoggedIn(_rememberMe);
      ref.invalidate(isLoggedInProvider);
      ref.invalidate(hasSupabaseSessionProvider);

      if (!mounted) return;
      await ref.read(userDataSyncProvider.future);

      if (!mounted) return;
      final resolved = await resolvePostAuthRoute(ref);
      if (!mounted) return;
      context.go(resolved.route, extra: resolved.extra);
    } on GoogleSignInException catch (e) {
      if (!mounted) return;
      if (e.code == GoogleSignInExceptionCode.canceled) {
        setState(() => _isLoading = false);
        return;
      }
      _recordFailedAttempt();
      setState(() {
        _errorText = _isBlocked
            ? _blockRemaining
            : _l10n.authGoogleSignInFailed;
        _isLoading = false;
      });
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
            : _l10n.authSomethingWentWrong;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 64),

              // Title
              Text(
                _isLogin ? l10n.authWelcomeBack : l10n.authCreateAccount,
                style: GoogleFonts.inter(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: ThemeV2.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _isLogin
                    ? l10n.authSignInSubtitle
                    : l10n.authSignUpSubtitle,
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
                decoration: InputDecoration(
                  hintText: l10n.authEmailHint,
                  prefixIcon: const Icon(
                    Icons.email_outlined,
                    color: ThemeV2.textSecondary,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Password
              TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  hintText: l10n.authPasswordHint,
                  prefixIcon: const Icon(
                    Icons.lock_outlined,
                    color: ThemeV2.textSecondary,
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: ThemeV2.textSecondary,
                    ),
                    onPressed: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
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
                        horizontal: 4,
                        vertical: 8,
                      ),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      l10n.authForgotPassword,
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
                      onChanged: (val) =>
                          setState(() => _rememberMe = val ?? false),
                      activeColor: ThemeV2.primary,
                      checkColor: Colors.white,
                      side: const BorderSide(color: ThemeV2.textSecondary),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    l10n.authRememberMe,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: ThemeV2.textSecondary,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Submit button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed:
                      (_isLoading || _isBlocked || _cooldownSecondsLeft != null)
                      ? null
                      : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ThemeV2.primary,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: ThemeV2.surface,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
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
                          _isLogin
                              ? l10n.authSignIn
                              : l10n.authCreateAccountButton,
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 20),

              // "or" divider
              Row(
                children: [
                  const Expanded(child: Divider(color: ThemeV2.surface)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      l10n.authOr,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: ThemeV2.textSecondary,
                      ),
                    ),
                  ),
                  const Expanded(child: Divider(color: ThemeV2.surface)),
                ],
              ),

              const SizedBox(height: 20),

              // Continue with Google
              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton(
                  onPressed:
                      (_isLoading || _isBlocked || _cooldownSecondsLeft != null)
                      ? null
                      : _signInWithGoogle,
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.white,
                    side: const BorderSide(color: ThemeV2.surface),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SvgPicture.string(_googleLogoSvg, width: 20, height: 20),
                      const SizedBox(width: 12),
                      Flexible(
                        child: Text(
                          l10n.authContinueWithGoogle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Toggle login / register
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _isLogin ? l10n.authNoAccount : l10n.authHaveAccount,
                    style: GoogleFonts.inter(
                      color: ThemeV2.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                  TextButton(
                    onPressed: () => setState(() {
                      _isLogin = !_isLogin;
                      _errorText = null;
                    }),
                    child: Text(
                      _isLogin ? l10n.authSignUp : l10n.authSignIn,
                      style: GoogleFonts.inter(
                        color: ThemeV2.primary,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
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
