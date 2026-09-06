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

// ---------------------------------------------------------------------------
// Create Fund — ETF Fund Emulation, Phase 1. Ticker generation/uniqueness
// and English-only-name/sector validation are enforced server-side
// (fundService.js); this form mirrors those rules client-side just for
// immediate feedback, the server is still the source of truth.
// ---------------------------------------------------------------------------

const double _maxStartingCapital = 150000;
final _nameEnglishOnly = RegExp(r"^[A-Za-z0-9 .,&'-]+$");

class CreateFundScreen extends ConsumerStatefulWidget {
  const CreateFundScreen({super.key});

  @override
  ConsumerState<CreateFundScreen> createState() => _CreateFundScreenState();
}

class _CreateFundScreenState extends ConsumerState<CreateFundScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _strategyController = TextEditingController();
  final _capitalController = TextEditingController(text: '150000');
  final Set<String> _selectedSectors = {};
  bool _submitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _strategyController.dispose();
    _capitalController.dispose();
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
      final fund = await ref.read(fundApiServiceProvider).createFund(
            name: _nameController.text.trim(),
            description: _descriptionController.text.trim().isEmpty
                ? null
                : _descriptionController.text.trim(),
            strategy: _strategyController.text.trim().isEmpty
                ? null
                : _strategyController.text.trim(),
            sectors: _selectedSectors.toList(),
            startingCapital: double.parse(_capitalController.text),
          );
      ref.invalidate(fundsListProvider);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.etfCreateFundSuccessMessage)),
      );
      context.pushReplacement('/funds/${fund.id}');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e is Exception ? e.toString().replaceFirst('Exception: ', '') : l10n.etfCreateFundErrorGeneric,
          ),
          backgroundColor: ThemeV2.loss,
        ),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  InputDecoration _decoration(AppPalette palette, String label, {String? hint}) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      labelStyle: GoogleFonts.inter(color: palette.textBody, fontSize: 13),
      hintStyle: GoogleFonts.inter(color: palette.textBody.withValues(alpha: 0.6), fontSize: 13),
      border: InputBorder.none,
      enabledBorder: InputBorder.none,
      focusedBorder: InputBorder.none,
    );
  }

  Widget _fieldWrapper(AppPalette palette, Widget child) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: themedBorder(
        palette: palette,
        borderRadius: ThemeV2.borderRadiusMedium,
        child: Container(
          decoration: BoxDecoration(
            gradient: palette.windowGradient,
            color: palette.windowGradient == null ? palette.card : null,
            borderRadius: ThemeV2.borderRadiusMedium,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          child: child,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final palette = resolveAppPalette(ref.watch(themeVariantProvider));
    final sectorsAsync = ref.watch(fundSectorsProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        centerTitle: true,
        leading: themedBackButton(context, palette),
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
              _fieldWrapper(
                palette,
                TextFormField(
                  controller: _nameController,
                  maxLength: 60,
                  style: GoogleFonts.inter(color: palette.textHeader),
                  decoration: _decoration(
                    palette,
                    l10n.etfCreateFundNameLabel,
                    hint: l10n.etfCreateFundNameHint,
                  ),
                  validator: (value) {
                    final v = (value ?? '').trim();
                    if (v.isEmpty) return l10n.etfCreateFundNameLabel;
                    if (!_nameEnglishOnly.hasMatch(v)) {
                      return l10n.etfCreateFundNameEnglishOnlyError;
                    }
                    return null;
                  },
                ),
              ),
              _fieldWrapper(
                palette,
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 3,
                  maxLength: 500,
                  style: GoogleFonts.inter(color: palette.textHeader),
                  decoration: _decoration(palette, l10n.etfCreateFundDescriptionLabel),
                ),
              ),
              _fieldWrapper(
                palette,
                TextFormField(
                  controller: _strategyController,
                  maxLines: 3,
                  maxLength: 500,
                  style: GoogleFonts.inter(color: palette.textHeader),
                  decoration: _decoration(palette, l10n.etfCreateFundStrategyLabel),
                ),
              ),
              _fieldWrapper(
                palette,
                TextFormField(
                  controller: _capitalController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: false),
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  style: GoogleFonts.inter(color: palette.textHeader),
                  decoration: _decoration(palette, l10n.etfCreateFundCapitalLabel),
                  validator: (value) {
                    final v = double.tryParse(value ?? '');
                    if (v == null || v <= 0 || v > _maxStartingCapital) {
                      return l10n.etfCreateFundCapitalLabel;
                    }
                    return null;
                  },
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
                  child: CircularProgressIndicator(color: palette.accentPrimary),
                ),
                error: (_, _) => Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: allowedSectorCodes(l10n)
                      .map((code) => _sectorChip(palette, l10n, code))
                      .toList(),
                ),
                data: (codes) => Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children:
                      codes.map((code) => _sectorChip(palette, l10n, code)).toList(),
                ),
              ),
              const SizedBox(height: 28),
              _submitButton(palette, l10n),
            ],
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
          standardDecoration: BoxDecoration(color: ThemeV2.primary, borderRadius: radius),
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
