import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/theme_v2.dart';
import '../../../core/theme/theme_variant_provider.dart';
import '../../../core/theme/themed_header.dart';
import '../../../core/theme/themed_border.dart';
import '../../../core/theme/themed_button.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../providers/fund_providers.dart';
import '../sector_labels.dart';
import '../services/fund_api_service.dart';

// ---------------------------------------------------------------------------
// Create Fund — ETF Fund Emulation, Phase 1. Ticker generation/uniqueness
// and English-only-name/sector validation are enforced server-side
// (fundService.js); this form mirrors those rules client-side just for
// immediate feedback, the server is still the source of truth.
// ---------------------------------------------------------------------------

// Starting capital is a flat rule for every fund now, not a user choice —
// see _CreateFundScreenState's own doc note above the capital section.
const double _fixedStartingCapital = 150000;
final _nameEnglishOnly = RegExp(r"^[A-Za-z0-9 .,&'-]+$");
// Same character class as _nameEnglishOnly but unanchored, for a
// character-level TextInputFormatter — silently drops anything outside it
// (Cyrillic included) the instant it's typed, rather than letting it in
// and only complaining on submit. Belt-and-suspenders with the
// TextInputType.visiblePassword hint below (which nudges most on-screen
// keyboards, Gboard included, to a plain Latin layout with no IME
// suggestions) — neither alone is a real guarantee across every keyboard,
// together they are for the actual character stream.
final _nameAllowedChars = RegExp(r"[A-Za-z0-9 .,&'-]");

// ---------------------------------------------------------------------------
// Ticker — user-chosen, not auto-generated. FS is a fixed, non-editable
// prefix (locked in the UI, re-checked server-side); the user types 1-5
// more uppercase letters. Was auto-generated from the name with a numeric
// suffix tacked on for any collision (e.g. a second "FSTGF" silently
// became "FSTGF2") — confirmed live 2026-09-08 that landing an unexpected
// digit on a ticker the user didn't choose read as broken, not helpful.
// Same "taken" rejection the name field already uses instead: server
// checks uniqueness and returns 'ticker_taken' rather than ever mutating
// what was typed.
//
// Still auto-SUGGESTS a starting point from the name (initials, same
// algorithm fundService.js's old auto-generator used) so most funds don't
// need to think one up from scratch — but only until the user actually
// edits the ticker field themselves (_tickerManuallyEdited below), same
// "auto-fill a slug until touched" pattern common in web forms.
// ---------------------------------------------------------------------------
const _tickerPrefix = 'FS';
const _maxTickerSuffixLength = 5;
final _tickerSuffixAllowedChars = RegExp('[A-Za-z]');

String _suggestedTickerSuffix(String name) {
  final initials = name
      .split(RegExp(r'\s+'))
      .map((word) {
        final letters = word.replaceAll(RegExp(r'[^A-Za-z]'), '');
        return letters.isEmpty ? '' : letters[0];
      })
      .where((c) => c.isNotEmpty)
      .join()
      .toUpperCase();
  if (initials.isEmpty) return '';
  return initials.length > _maxTickerSuffixLength
      ? initials.substring(0, _maxTickerSuffixLength)
      : initials;
}

class CreateFundScreen extends ConsumerStatefulWidget {
  const CreateFundScreen({super.key});

  @override
  ConsumerState<CreateFundScreen> createState() => _CreateFundScreenState();
}

class _CreateFundScreenState extends ConsumerState<CreateFundScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _tickerSuffixController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _strategyController = TextEditingController();
  final Set<String> _selectedSectors = {};
  bool _submitting = false;
  // Stops the name->ticker auto-suggest once the user has typed into the
  // ticker field themselves — see _suggestedTickerSuffix's own doc comment.
  bool _tickerManuallyEdited = false;
  // Server-only validation errors (things a client-side validator can't
  // know, like name/ticker uniqueness) — fed into each field's own
  // validator below so Flutter highlights it exactly like any other
  // invalid field, rather than a plain SnackBar with no indication of
  // which input is wrong.
  String? _serverNameError;
  String? _serverTickerError;

  @override
  void dispose() {
    _nameController.dispose();
    _tickerSuffixController.dispose();
    _descriptionController.dispose();
    _strategyController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context)!;
    if (!_formKey.currentState!.validate()) return;
    if (_selectedSectors.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.etfCreateFundSelectAtLeastOneSector)),
      );
      return;
    }

    setState(() => _submitting = true);
    try {
      final fund = await ref
          .read(fundApiServiceProvider)
          .createFund(
            name: _nameController.text.trim(),
            ticker: '$_tickerPrefix${_tickerSuffixController.text.trim()}',
            description: _descriptionController.text.trim().isEmpty
                ? null
                : _descriptionController.text.trim(),
            strategy: _strategyController.text.trim().isEmpty
                ? null
                : _strategyController.text.trim(),
            sectors: _selectedSectors.toList(),
            startingCapital: _fixedStartingCapital,
          );
      ref.invalidate(fundsListProvider);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.etfCreateFundSuccessMessage)));
      context.pushReplacement('/funds/${fund.id}');
    } on FundApiException catch (e) {
      if (!mounted) return;
      switch (e.code) {
        case 'name_taken':
          setState(() => _serverNameError = l10n.etfCreateFundNameTakenError);
          _formKey.currentState!.validate();
          break;
        case 'name_not_english':
          setState(
            () => _serverNameError = l10n.etfCreateFundNameEnglishOnlyError,
          );
          _formKey.currentState!.validate();
          break;
        case 'ticker_taken':
          setState(
            () => _serverTickerError = l10n.etfCreateFundTickerTakenError,
          );
          _formKey.currentState!.validate();
          break;
        case 'ticker_invalid':
        case 'ticker_required':
          setState(
            () => _serverTickerError = l10n.etfCreateFundTickerInvalidError,
          );
          _formKey.currentState!.validate();
          break;
        case 'sectors_empty':
        case 'sectors_invalid':
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.etfCreateFundSelectAtLeastOneSector)),
          );
          break;
        default:
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.etfCreateFundErrorGeneric),
              backgroundColor: ThemeV2.loss,
            ),
          );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.etfCreateFundErrorGeneric),
          backgroundColor: ThemeV2.loss,
        ),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  // A real header above each field, not a floating labelText shrunk into
  // the field itself — the small floating label read as unclear/hard to
  // read at a glance (found live 2026-09-08). Same weight/size as the
  // Sectors section's own label further down, so every field in this form
  // now shares one header style.
  Widget _fieldHeader(AppPalette palette, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: palette.textHeader,
        ),
      ),
    );
  }

  // filled: false is required here — the app-wide InputDecorationTheme
  // (theme_v2.dart) defaults every text field to filled:true with an
  // opaque WHITE fillColor. Without this override, that white fill paints
  // straight over _fieldWrapper's own themed Container background,
  // making every field look flat white regardless of theme (found live
  // 2026-09-06 on Luxury Gold — fields looked "very white").
  InputDecoration _decoration(AppPalette palette, {String? hint}) {
    return InputDecoration(
      filled: false,
      hintText: hint,
      hintStyle: GoogleFonts.inter(
        color: palette.textHeader.withValues(alpha: 0.5),
        fontSize: 13,
      ),
      border: InputBorder.none,
      enabledBorder: InputBorder.none,
      focusedBorder: InputBorder.none,
    );
  }

  // hasError draws a plain red border instead of the theme's gradient one —
  // TextFormField's OWN border is intentionally InputBorder.none in every
  // state (see _decoration above, so the themed Container below is the only
  // border anyone sees), which means Flutter's usual automatic red
  // error-border never had anywhere to paint. Without this override, a
  // server-side error (e.g. name taken) only ever showed as red helper text
  // underneath with no visible highlight on the field itself — the app
  // convention "как в приложениях" of highlighting the invalid field
  // outright (found live 2026-09-06).
  Widget _fieldWrapper(
    AppPalette palette,
    Widget child, {
    bool hasError = false,
  }) {
    final content = Container(
      decoration: BoxDecoration(
        gradient: palette.windowGradient,
        color: palette.windowGradient == null ? palette.card : null,
        borderRadius: ThemeV2.borderRadiusMedium,
        border: hasError ? Border.all(color: ThemeV2.loss, width: 1.5) : null,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      child: child,
    );
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: hasError
          ? content
          : themedBorder(
              palette: palette,
              borderRadius: ThemeV2.borderRadiusMedium,
              child: content,
            ),
    );
  }

  // Back should feel soft, not abrupt: if the keyboard is open, the first
  // back press only dismisses it — a second press (keyboard already
  // closed) actually leaves the screen. Checks the KEYBOARD'S actual
  // on-screen presence (viewInsets.bottom), not FocusScope.focusedChild —
  // that field can stay non-null even after the keyboard visibly closes
  // (no other widget claims focus), which made back permanently a no-op
  // after the first use (found live 2026-09-06, second real device bug in
  // this same fix).
  void _handleBackPress(BuildContext context) {
    final keyboardVisible = MediaQuery.of(context).viewInsets.bottom > 0;
    if (keyboardVisible) {
      FocusScope.of(context).unfocus();
    } else {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final palette = resolveAppPalette(ref.watch(themeVariantProvider));
    final sectorsAsync = ref.watch(fundSectorsProvider);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) _handleBackPress(context);
      },
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          centerTitle: true,
          leading: themedBackButton(
            context,
            palette,
            onPressed: () => _handleBackPress(context),
          ),
          title: themedHeaderText(
            l10n.etfCreateFundTitle,
            palette,
            GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w800),
          ),
        ),
        body: SafeArea(
          child: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _fieldHeader(palette, l10n.etfCreateFundNameLabel),
                _fieldWrapper(
                  palette,
                  hasError: _serverNameError != null,
                  TextFormField(
                    controller: _nameController,
                    maxLength: 60,
                    style: GoogleFonts.inter(color: palette.textHeader),
                    // visiblePassword nudges most on-screen keyboards
                    // (Gboard included) to a plain Latin layout with no
                    // IME word suggestions — combined with the
                    // character-level inputFormatters below (the real
                    // guarantee), a Cyrillic keypress never actually lands
                    // in this field instead of being typed and only
                    // rejected on submit. Found live 2026-09-08: nothing
                    // stopped Russian input before this.
                    keyboardType: TextInputType.visiblePassword,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(_nameAllowedChars),
                    ],
                    // Clears a stale server-side error (e.g. "name taken")
                    // the moment the user edits the name — otherwise it'd
                    // linger and show as still-invalid even after a fix.
                    // Also re-suggests the ticker suffix, but only until
                    // the user has edited that field themselves — see
                    // _suggestedTickerSuffix's own doc comment.
                    onChanged: (value) {
                      if (_serverNameError != null) {
                        setState(() => _serverNameError = null);
                      }
                      if (!_tickerManuallyEdited) {
                        _tickerSuffixController.text = _suggestedTickerSuffix(
                          value,
                        );
                      }
                    },
                    decoration: _decoration(
                      palette,
                      hint: l10n.etfCreateFundNameHint,
                    ),
                    validator: (value) {
                      final v = (value ?? '').trim();
                      if (v.isEmpty) return l10n.etfCreateFundNameLabel;
                      if (!_nameEnglishOnly.hasMatch(v)) {
                        return l10n.etfCreateFundNameEnglishOnlyError;
                      }
                      if (_serverNameError != null) return _serverNameError;
                      return null;
                    },
                  ),
                ),
                _fieldHeader(palette, l10n.etfCreateFundTickerLabel),
                _fieldWrapper(
                  palette,
                  hasError: _serverTickerError != null,
                  Row(
                    children: [
                      // FS is fixed — shown inline, never editable. Server
                      // re-validates this prefix regardless (see
                      // fundService.js's TICKER_PATTERN), this is just the
                      // UI reflecting that it's not a real choice.
                      Text(
                        _tickerPrefix,
                        style: GoogleFonts.inter(
                          color: palette.textHeader.withValues(alpha: 0.5),
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                          letterSpacing: 1,
                        ),
                      ),
                      Expanded(
                        child: TextFormField(
                          controller: _tickerSuffixController,
                          maxLength: _maxTickerSuffixLength,
                          style: GoogleFonts.inter(
                            color: palette.accentPrimary,
                            fontWeight: FontWeight.w800,
                            fontSize: 15,
                            letterSpacing: 1,
                          ),
                          textCapitalization: TextCapitalization.characters,
                          keyboardType: TextInputType.visiblePassword,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                              _tickerSuffixAllowedChars,
                            ),
                            TextInputFormatter.withFunction(
                              (oldValue, newValue) => newValue.copyWith(
                                text: newValue.text.toUpperCase(),
                              ),
                            ),
                          ],
                          onChanged: (_) {
                            _tickerManuallyEdited = true;
                            if (_serverTickerError != null) {
                              setState(() => _serverTickerError = null);
                            }
                          },
                          decoration: _decoration(
                            palette,
                            hint: 'TGF',
                          ).copyWith(counterText: ''),
                          validator: (value) {
                            final v = (value ?? '').trim();
                            if (v.isEmpty) {
                              return l10n.etfCreateFundTickerInvalidError;
                            }
                            if (_serverTickerError != null) {
                              return _serverTickerError;
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                _fieldHeader(palette, l10n.etfCreateFundDescriptionLabel),
                _fieldWrapper(
                  palette,
                  TextFormField(
                    controller: _descriptionController,
                    maxLines: 3,
                    maxLength: 500,
                    style: GoogleFonts.inter(color: palette.textHeader),
                    decoration: _decoration(palette),
                  ),
                ),
                _fieldHeader(palette, l10n.etfCreateFundStrategyLabel),
                _fieldWrapper(
                  palette,
                  TextFormField(
                    controller: _strategyController,
                    maxLines: 3,
                    maxLength: 500,
                    style: GoogleFonts.inter(color: palette.textHeader),
                    decoration: _decoration(palette),
                  ),
                ),
                _fieldHeader(palette, l10n.etfCreateFundCapitalLabel),
                _fieldWrapper(
                  palette,
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Row(
                      children: [
                        Text(
                          // Fixed value, formatted as a literal rather than
                          // computed — not worth pulling in intl's
                          // NumberFormat for one constant.
                          '\$150,000',
                          style: GoogleFonts.inter(
                            color: palette.textHeader,
                            fontWeight: FontWeight.w800,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            l10n.etfCreateFundCapitalFixedNote,
                            style: GoogleFonts.inter(
                              color: palette.textHeader.withValues(alpha: 0.6),
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.etfCreateFundSectorsLabel,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: palette.textBody,
                  ),
                ),
                const SizedBox(height: 8),
                sectorsAsync.when(
                  loading: () => Center(
                    child: CircularProgressIndicator(
                      color: palette.accentPrimary,
                    ),
                  ),
                  error: (_, _) => Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: allowedSectorCodes(
                      l10n,
                    ).map((code) => _sectorChip(palette, l10n, code)).toList(),
                  ),
                  data: (codes) => Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: codes
                        .map((code) => _sectorChip(palette, l10n, code))
                        .toList(),
                  ),
                ),
                const SizedBox(height: 28),
                _submitButton(palette, l10n),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Same recipe as set_goal_screen.dart's _saveButton / the onboarding
  // screen's _ctaButton — never paint a CTA with palette.accentPrimary as a
  // flat fill (Graphite/Black & White collapse accentPrimary and onButton
  // to the same color, making the label invisible; found live 2026-09-06).
  Widget _submitButton(AppPalette palette, AppLocalizations l10n) {
    final radius = BorderRadius.circular(ThemeV2.buttonRadius);
    return SizedBox(
      width: double.infinity,
      height: ThemeV2.buttonHeight,
      child: Material(
        type: MaterialType.transparency,
        child: themedDarkCtaButtonShell(
          palette: palette,
          borderRadius: radius,
          standardDecoration: BoxDecoration(
            color: ThemeV2.primary,
            borderRadius: radius,
          ),
          child: InkWell(
            borderRadius: radius,
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
                      l10n.etfCreateFundSubmitButton,
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
    );
  }

  Widget _sectorChip(AppPalette palette, AppLocalizations l10n, String code) {
    final selected = _selectedSectors.contains(code);
    return FilterChip(
      label: Text(sectorLabel(l10n, code)),
      selected: selected,
      onSelected: (value) {
        setState(() {
          if (value) {
            _selectedSectors.add(code);
          } else {
            _selectedSectors.remove(code);
          }
        });
      },
      selectedColor: palette.accentPrimary.withValues(alpha: 0.2),
      checkmarkColor: palette.accentPrimary,
      labelStyle: GoogleFonts.inter(
        fontSize: 12,
        color: selected ? palette.accentPrimary : palette.textBody,
        fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
      ),
      backgroundColor: palette.card,
      side: BorderSide(color: palette.textBody.withValues(alpha: 0.2)),
    );
  }
}
