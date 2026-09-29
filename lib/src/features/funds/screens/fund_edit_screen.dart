import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/theme_v2.dart';
import '../../../core/theme/theme_variant_provider.dart';
import '../../../core/theme/themed_button.dart';
import '../../../core/theme/themed_header.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../models/fund.dart';
import '../providers/fund_providers.dart';
import '../sector_labels.dart';
import '../services/fund_api_service.dart' show FundApiException;
import '../widgets/fund_form_fields.dart';

// ---------------------------------------------------------------------------
// Fund Edit — the head's "everything except the name" form (asked for
// 2026-09-16). Reached from Fund Management's shortcut row, head only.
//
// Three fields, matching what the backend's updateFundDetails accepts:
// description, strategy, sectors. The name has its own rename dialog
// (uniqueness checks), and ticker/starting capital are deliberately not
// editable at all — positions are keyed by the ticker string, and the
// capital is already baked into units outstanding. See updateFundDetails
// in the backend's fundService.js for the full reasoning.
//
// Field chrome comes from widgets/fund_form_fields.dart, shared with the
// creation form — those helpers each carry a device-found fix (white fill
// over the themed background, invisible error borders), so a second
// hand-made copy here would quietly lose them.
// ---------------------------------------------------------------------------

class FundEditScreen extends ConsumerStatefulWidget {
  final String fundId;

  const FundEditScreen({super.key, required this.fundId});

  @override
  ConsumerState<FundEditScreen> createState() => _FundEditScreenState();
}

class _FundEditScreenState extends ConsumerState<FundEditScreen> {
  final _descriptionController = TextEditingController();
  final _strategyController = TextEditingController();
  final Set<String> _selectedSectors = {};

  /// The form is filled from the loaded fund exactly once. Without this
  /// latch every provider rebuild (a NAV refresh is enough) would overwrite
  /// whatever the head is halfway through typing.
  bool _seeded = false;
  bool _submitting = false;

  @override
  void dispose() {
    _descriptionController.dispose();
    _strategyController.dispose();
    super.dispose();
  }

  void _seedFrom(Fund fund) {
    if (_seeded) return;
    _seeded = true;
    _descriptionController.text = fund.description ?? '';
    _strategyController.text = fund.strategy ?? '';
    _selectedSectors
      ..clear()
      ..addAll(fund.sectors);
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context)!;
    if (_selectedSectors.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.etfCreateFundSelectAtLeastOneSector)),
      );
      return;
    }
    setState(() => _submitting = true);
    try {
      await ref
          .read(fundApiServiceProvider)
          .updateFundDetails(
            widget.fundId,
            description: _descriptionController.text.trim(),
            strategy: _strategyController.text.trim(),
            sectors: _selectedSectors.toList(),
          );
      // Both the fund's own screens and every browse lane read from these,
      // and the sector lanes in particular are grouped BY the field just
      // edited — without invalidating the list the fund would keep showing
      // under its old sectors until a cold start.
      ref.invalidate(fundDetailProvider(widget.fundId));
      ref.invalidate(fundsListProvider);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.etfFundEditSavedSnackbar)),
      );
      Navigator.of(context).pop();
    } on FundApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_errorText(l10n, e))),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.etfFundEditGenericError)),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  String _errorText(AppLocalizations l10n, FundApiException e) {
    switch (e.code) {
      case 'description_too_long':
      case 'strategy_too_long':
        return l10n.etfFundEditTooLongError;
      case 'sectors_empty':
      case 'sectors_invalid':
        return l10n.etfCreateFundSelectAtLeastOneSector;
      default:
        return e.message;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final palette = resolveAppPalette(ref.watch(themeVariantProvider));
    final fundAsync = ref.watch(fundDetailProvider(widget.fundId));

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        centerTitle: true,
        leading: themedBackButton(context, palette),
        title: themedHeaderText(
          l10n.etfFundEditTitle,
          palette,
          GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.5,
          ),
        ),
      ),
      body: SafeArea(
        child: fundAsync.when(
          loading: () => Center(
            child: CircularProgressIndicator(color: palette.accentPrimary),
          ),
          error: (_, _) => Center(
            child: Text(
              l10n.etfFundEditGenericError,
              style: GoogleFonts.inter(color: palette.textBody),
            ),
          ),
          data: (fund) {
            _seedFrom(fund);
            return ListView(
              padding: const EdgeInsets.all(20),
              children: [
                fundFieldHeader(palette, l10n.etfCreateFundDescriptionLabel),
                fundFieldWrapper(
                  palette,
                  TextField(
                    controller: _descriptionController,
                    maxLines: 4,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: palette.textHeader,
                    ),
                    decoration: fundFieldDecoration(palette),
                  ),
                ),
                fundFieldHeader(palette, l10n.etfCreateFundStrategyLabel),
                fundFieldWrapper(
                  palette,
                  TextField(
                    controller: _strategyController,
                    maxLines: 4,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: palette.textHeader,
                    ),
                    decoration: fundFieldDecoration(palette),
                  ),
                ),
                fundFieldHeader(palette, l10n.etfCreateFundSectorsLabel),
                _sectorPicker(palette, l10n),
                const SizedBox(height: 24),
                _saveButton(palette, l10n),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _sectorPicker(AppPalette palette, AppLocalizations l10n) {
    final sectorsAsync = ref.watch(fundSectorsProvider);
    // Falls back to the app's own bundled sector list when the server's
    // copy can't be fetched — same fallback the creation form uses, so a
    // network hiccup never leaves the head unable to pick anything. While
    // it's still loading the bundled list is shown too rather than a
    // spinner: the form's other fields are already filled in and usable,
    // and the two lists are the same codes anyway.
    final codes = sectorsAsync.valueOrNull ?? allowedSectorCodes(l10n);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: codes
            .map(
              (code) => fundSectorChip(
                palette: palette,
                l10n: l10n,
                code: code,
                selected: _selectedSectors.contains(code),
                onSelected: (value) => setState(() {
                  if (value) {
                    _selectedSectors.add(code);
                  } else {
                    _selectedSectors.remove(code);
                  }
                }),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _saveButton(AppPalette palette, AppLocalizations l10n) {
    final radius = ThemeV2.borderRadiusMedium;
    final contentColor = themedDarkCtaContentColor(palette);
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
            onTap: _submitting ? null : _save,
            child: Center(
              child: _submitting
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: contentColor,
                      ),
                    )
                  : Text(
                      l10n.etfFundEditSaveButton,
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: contentColor,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
