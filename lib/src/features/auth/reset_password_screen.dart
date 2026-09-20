import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/theme/theme_v2.dart';
import '../../core/supabase/supabase_client.dart';
import '../../l10n/gen/app_localizations.dart';
import 'auth_providers.dart';
import 'password_recovery.dart';

// ---------------------------------------------------------------------------
// Reset Password — the landing screen for the com.scanco.scanco://
// login-callback deep link when it was opened via the "Forgot password"
// email specifically (AuthChangeEvent.passwordRecovery, see
// password_recovery.dart). Supabase's recovery link already leaves the
// user with a real, live session by the time this screen builds — this
// screen's only job is collecting the new password and calling
// auth.updateUser, then signing back out so the user re-authenticates
// explicitly with the new password rather than being silently carried
// into the app on the temporary recovery session.
// ---------------------------------------------------------------------------

class ResetPasswordScreen extends ConsumerStatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  ConsumerState<ResetPasswordScreen> createState() =>
      _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen> {
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _obscurePassword = true;
  bool _submitting = false;
  bool _done = false;
  String? _errorText;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context)!;
    final password = _passwordController.text;
    final confirm = _confirmController.text;

    if (password.isEmpty) {
      setState(() => _errorText = l10n.resetPasswordScreenEnterPassword);
      return;
    }
    if (password != confirm) {
      setState(() => _errorText = l10n.resetPasswordScreenMismatch);
      return;
    }

    setState(() {
      _submitting = true;
      _errorText = null;
    });
    try {
      await SupabaseConfig.client.auth.updateUser(
        UserAttributes(password: password),
      );
      // The recovery session did its one job — sign out so the user comes
      // back in explicitly with the new password, same reasoning as every
      // other sign-out path in the app (invalidate first, see
      // invalidateSessionScopedProviders's own doc comment).
      invalidateSessionScopedProviders(ref);
      await clearAllSessionData();
      isInPasswordRecovery = false;
      if (!mounted) return;
      setState(() {
        _done = true;
        _submitting = false;
      });
    } on AuthException catch (e) {
      if (!mounted) return;
      setState(() {
        _errorText = e.message;
        _submitting = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _errorText = l10n.resetPasswordScreenGenericError;
        _submitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 32),
              Icon(
                _done ? Icons.check_circle_rounded : Icons.lock_reset_rounded,
                color: _done ? ThemeV2.success : ThemeV2.primary,
                size: 40,
              ),
              const SizedBox(height: 16),
              Text(
                _done
                    ? l10n.resetPasswordScreenDoneTitle
                    : l10n.resetPasswordScreenTitle,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: ThemeV2.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                _done
                    ? l10n.resetPasswordScreenDoneSubtitle
                    : l10n.resetPasswordScreenSubtitle,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: ThemeV2.textBody,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),
              if (!_done) ...[
                TextField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  onChanged: (_) {
                    if (_errorText != null) setState(() => _errorText = null);
                  },
                  decoration: InputDecoration(
                    hintText: l10n.resetPasswordScreenNewPasswordHint,
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
                const SizedBox(height: 16),
                TextField(
                  controller: _confirmController,
                  obscureText: _obscurePassword,
                  onChanged: (_) {
                    if (_errorText != null) setState(() => _errorText = null);
                  },
                  decoration: InputDecoration(
                    hintText: l10n.resetPasswordScreenConfirmPasswordHint,
                    prefixIcon: const Icon(
                      Icons.lock_outlined,
                      color: ThemeV2.textSecondary,
                    ),
                  ),
                ),
                if (_errorText != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    _errorText!,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(fontSize: 13, color: ThemeV2.loss),
                  ),
                ],
                const SizedBox(height: 24),
                SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _submitting ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ThemeV2.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: _submitting
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            l10n.resetPasswordScreenSubmitButton,
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
              ] else ...[
                SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () => context.go('/auth'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ThemeV2.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      l10n.resetPasswordScreenBackToSignIn,
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
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
