import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/theme_v2.dart';
import '../../core/supabase/supabase_providers.dart';
import '../../l10n/gen/app_localizations.dart';

// ---------------------------------------------------------------------------
// Choose Nickname (Migration 017) — mandatory, one-time global account
// handle. Slotted into resolvePostAuthRoute() (auth_providers.dart) right
// after the onboarding choice screen, so it catches every account that
// doesn't have one yet. Hardcoded to ThemeV2 (the standard palette) rather
// than palette-aware — this is first-run content shown before a theme
// choice is ever meaningful, same convention as auth_screen.dart and
// disclaimer_screen.dart. No back button — this is a gate the user can't
// skip, not a screen they navigate to.
//
// Uniqueness is checked by attempting the write and reading back Postgres's
// unique-violation (see setMyNickname's NicknameTakenException) rather than
// a separate availability-check call — no check-then-write race.
// ---------------------------------------------------------------------------

class ChooseNicknameScreen extends ConsumerStatefulWidget {
  const ChooseNicknameScreen({super.key});

  @override
  ConsumerState<ChooseNicknameScreen> createState() =>
      _ChooseNicknameScreenState();
}

class _ChooseNicknameScreenState extends ConsumerState<ChooseNicknameScreen> {
  final _controller = TextEditingController();
  bool _submitting = false;
  String? _errorText;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context)!;
    final value = _controller.text.trim();
    if (value.isEmpty) {
      setState(() => _errorText = l10n.chooseNicknameRequired);
      return;
    }
    if (!nicknamePattern.hasMatch(value)) {
      setState(() => _errorText = l10n.chooseNicknameInvalidChars);
      return;
    }

    setState(() {
      _submitting = true;
      _errorText = null;
    });
    try {
      await setMyNickname(value);
      // myNicknameProvider isn't autoDispose, so its very first read (from
      // before a nickname existed) would otherwise sit cached as null
      // forever — invalidate so Profile etc. pick up the new value right
      // away instead of still showing "no nickname" after a successful save.
      ref.invalidate(myNicknameProvider);
      if (mounted) context.go('/home');
    } on NicknameTakenException {
      if (!mounted) return;
      setState(() => _errorText = l10n.chooseNicknameTakenError);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.chooseNicknameGenericError),
          backgroundColor: ThemeV2.loss,
        ),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
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
              const Icon(Icons.badge_rounded, color: ThemeV2.primary, size: 40),
              const SizedBox(height: 16),
              Text(
                l10n.chooseNicknameTitle,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: ThemeV2.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                l10n.chooseNicknameSubtitle,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: ThemeV2.textBody,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),
              Container(
                decoration: BoxDecoration(
                  color: ThemeV2.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: _errorText != null
                      ? Border.all(color: ThemeV2.loss, width: 1.5)
                      : null,
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  controller: _controller,
                  maxLength: 25,
                  autofocus: true,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: ThemeV2.textPrimary,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp('[A-Za-z0-9_]')),
                  ],
                  onChanged: (_) {
                    if (_errorText != null) {
                      setState(() => _errorText = null);
                    }
                  },
                  decoration: InputDecoration(
                    hintText: l10n.chooseNicknameHint,
                    hintStyle: GoogleFonts.inter(color: ThemeV2.textSecondary),
                    counterText: '',
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                  ),
                ),
              ),
              // Manual, centered error text — TextFormField's own built-in
              // errorText always renders left-aligned regardless of the
              // field's own textAlign (a Flutter InputDecorator layout
              // constraint, not something a style property can override),
              // which looked visually off on a screen where every other
              // element is centered. Found live 2026-09-20.
              if (_errorText != null) ...[
                const SizedBox(height: 8),
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
                          l10n.chooseNicknameContinueButton,
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
      ),
    );
  }
}
