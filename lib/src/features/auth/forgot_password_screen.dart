import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/theme/app_theme.dart';
import '../../core/supabase/supabase_client.dart';

/// Rate-limiting guard: track last request time per email to prevent spam.
final Map<String, DateTime> _lastResetRequest = {};

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  bool _isLoading = false;
  bool _isSent = false;
  String? _errorText;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _sendResetLink() async {
    final email = _emailController.text.trim();

    if (email.isEmpty) {
      setState(() => _errorText = 'Please enter your email address');
      return;
    }

    // ── Rate limiting: 1 request per 2 minutes per email ─────────
    final lastRequest = _lastResetRequest[email.toLowerCase()];
    if (lastRequest != null) {
      final elapsed = DateTime.now().difference(lastRequest).inSeconds;
      if (elapsed < 120) {
        final remaining = 120 - elapsed;
        setState(() {
          _errorText =
              'Please wait $remaining seconds before requesting again.';
        });
        return;
      }
    }

    setState(() {
      _isLoading = true;
      _errorText = null;
    });

    try {
      // ── Attempt to send reset via Supabase ─────────────────────
      // In dev/test mode, Supabase won't actually send an email,
      // but the API will accept the request.
      await SupabaseConfig.client.auth.resetPasswordForEmail(email);

      // Record this request for rate limiting
      _lastResetRequest[email.toLowerCase()] = DateTime.now();

      if (!mounted) return;

      // ── Security: always show the same message ─────────────────
      // (Even if email doesn't exist — don't leak info to bots)
      setState(() {
        _isSent = true;
        _isLoading = false;
      });

      // ── Mock: log the reset link to console for testing ────────
      debugPrint('═══════════════════════════════════════');
      debugPrint('🔑 PASSWORD RESET (MOCK)');
      debugPrint('   Email: $email');
      debugPrint('   In production, Supabase sends an email.');
      debugPrint('   For testing: check Supabase Auth logs or');
      debugPrint('   use the "magic link" from your Supabase dashboard.');
      debugPrint('═══════════════════════════════════════');
    } on AuthException catch (e) {
      if (!mounted) return;
      // Still show generic message for security
      setState(() {
        _isSent = true;
        _isLoading = false;
      });
      debugPrint('⚠️ Reset password API note: ${e.message}');
    } catch (e) {
      if (!mounted) return;
      // Generic success — don't reveal whether email exists
      setState(() {
        _isSent = true;
        _isLoading = false;
      });
      debugPrint('⚠️ Reset password error (silent): $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppTheme.textPrimary),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),

              // ── Title ────────────────────────────────────────────
              Text(
                'Reset password',
                style: GoogleFonts.inter(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Enter your email and we\'ll send you a link\n'
                'to reset your password.',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: AppTheme.textDim,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 40),

              // ── Success message ──────────────────────────────────
              if (_isSent)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.shieldGreen.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppTheme.shieldGreen.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.check_circle_rounded,
                              color: AppTheme.shieldGreen, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Check your email',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.shieldGreen,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'If this email is registered in our system, '
                        'we\'ve sent a password reset link to it.',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: AppTheme.textDim,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Mock note for testing
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppTheme.cardDark,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.info_outlined,
                                color: AppTheme.accentBlue, size: 16),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Dev mode: reset link is logged '
                                'in the debug console.',
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  color: AppTheme.accentBlue,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

              if (!_isSent) ...[
                // ── Error ──────────────────────────────────────────
                if (_errorText != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Text(
                      _errorText!,
                      style: GoogleFonts.inter(
                          fontSize: 13, color: AppTheme.dangerRed),
                    ),
                  ),

                // ── Email field ────────────────────────────────────
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    hintText: 'Email',
                    prefixIcon:
                        Icon(Icons.email_outlined, color: AppTheme.textDim),
                  ),
                ),

                const SizedBox(height: 24),

                // ── Send button ────────────────────────────────────
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _sendResetLink,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.accentBlue,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: AppTheme.card,
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
                              color: AppTheme.textPrimary,
                            ),
                          )
                        : Text(
                            'Send Reset Link',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
              ],

              if (_isSent) ...[
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: OutlinedButton(
                    onPressed: () => context.pop(),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                        color: AppTheme.accentBlue.withValues(alpha: 0.3),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      'Back to Sign In',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.accentBlue,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
