import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_palette.dart';
import '../../core/theme/theme_v2.dart';
import '../../core/theme/theme_variant_provider.dart';
import '../../core/theme/themed_border.dart';
import '../../core/theme/themed_button.dart';
import '../../core/supabase/supabase_providers.dart';
import '../../l10n/gen/app_localizations.dart';

// ---------------------------------------------------------------------------
// Choose Nickname (Migration 017) — mandatory, one-time global account
// handle. Slotted into resolvePostAuthRoute() (auth_providers.dart) right
// after the disclaimer gate, so it catches both a brand-new signup and any
// already-existing account that doesn't have one yet — including one that
// already picked a dark admin theme, so (unlike disclaimer_screen.dart,
// which only ever runs before a theme choice matters) this MUST be
// palette-aware, not hardcoded ThemeV2 colors: a dark-on-dark title was
// confirmed live 2026-09-10 on an existing account with a dark theme
// active. No back button — this is a gate the user can't skip, not a
// screen they navigate to.
//
// Uniqueness is checked by attempting the write and reading back Postgres's
// unique-violation (see setMyNickname's NicknameTakenException) rather than
// a separate availability-check call — no check-then-write race, same
// "attempt, map the error" precedent as fund name/ticker uniqueness.
// ---------------------------------------------------------------------------

class ChooseNicknameScreen extends ConsumerStatefulWidget {
  const ChooseNicknameScreen({super.key});

  @override
  ConsumerState<ChooseNicknameScreen> createState() =>
      _ChooseNicknameScreenState();
}

class _ChooseNicknameScreenState extends ConsumerState<ChooseNicknameScreen> {
  final _formKey = GlobalKey<FormState>();
  final _controller = TextEditingController();
  bool _submitting = false;
  String? _serverError;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context)!;
    if (!_formKey.currentState!.validate()) return;

    setState(() => _submitting = true);
    try {
      await setMyNickname(_controller.text.trim());
      // myNicknameProvider isn't autoDispose (it must survive navigation
      // the same way fundsListProvider does — see that provider's own
      // doc comment) so its very first read, from before a nickname
      // existed, would otherwise sit cached as null forever. Confirmed
      // live 2026-09-10: without this, "Мой профиль" kept showing "—"
      // for the nickname after a successful save.
      ref.invalidate(myNicknameProvider);
      if (mounted) context.go('/home');
    } on NicknameTakenException {
      if (!mounted) return;
      setState(() => _serverError = l10n.chooseNicknameTakenError);
      _formKey.currentState!.validate();
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
    final palette = resolveAppPalette(ref.watch(themeVariantProvider));
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 32),
                Icon(
                  Icons.badge_rounded,
                  color: palette.accentPrimary,
                  size: 40,
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.chooseNicknameTitle,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: palette.textHeader,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  l10n.chooseNicknameSubtitle,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: palette.textBody,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 32),
                themedBorder(
                  palette: palette,
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: palette.windowGradient,
                      color: palette.windowGradient == null
                          ? palette.card
                          : null,
                      borderRadius: BorderRadius.circular(14),
                      border: _serverError != null
                          ? Border.all(color: ThemeV2.loss, width: 1.5)
                          : null,
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: TextFormField(
                      controller: _controller,
                      maxLength: 25,
                      autofocus: true,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: palette.textHeader,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp('[A-Za-z0-9_]'),
                        ),
                      ],
                      onChanged: (_) {
                        if (_serverError != null) {
                          setState(() => _serverError = null);
                        }
                      },
                      decoration: InputDecoration(
                        filled: false,
                        hintText: l10n.chooseNicknameHint,
                        hintStyle: GoogleFonts.inter(
                          color: palette.textHeader.withValues(alpha: 0.5),
                        ),
                        counterText: '',
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                      ),
                      validator: (value) {
                        final v = (value ?? '').trim();
                        if (v.isEmpty) return l10n.chooseNicknameRequired;
                        if (!nicknamePattern.hasMatch(v)) {
                          return l10n.chooseNicknameInvalidChars;
                        }
                        return _serverError;
                      },
                    ),
                  ),
                ),
                if (_serverError != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    _serverError!,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: ThemeV2.loss,
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                SizedBox(
                  height: 52,
                  child: Material(
                    type: MaterialType.transparency,
                    child: themedDarkCtaButtonShell(
                      palette: palette,
                      borderRadius: BorderRadius.circular(14),
                      standardDecoration: BoxDecoration(
                        color: ThemeV2.primary,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(14),
                        onTap: _submitting ? null : _submit,
                        child: Center(
                          child: _submitting
                              ? SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: themedDarkCtaContentColor(palette),
                                  ),
                                )
                              : Text(
                                  l10n.chooseNicknameContinueButton,
                                  style: GoogleFonts.inter(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: themedDarkCtaContentColor(palette),
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
