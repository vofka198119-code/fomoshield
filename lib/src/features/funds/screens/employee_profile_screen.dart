import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/fomo_shield_theme.dart';
import '../../../core/theme/theme_v2.dart';
import '../../../core/theme/theme_variant_provider.dart';
import '../../../core/theme/themed_header.dart';
import '../../../core/theme/themed_border.dart';
import '../../../core/theme/themed_button.dart';
import '../../../core/supabase/supabase_providers.dart' show myNicknameProvider;
import '../../../l10n/gen/app_localizations.dart';
import '../../../shared/widgets/card_frame.dart';
import '../models/employee.dart';
import '../providers/employee_providers.dart';
import '../services/fund_api_service.dart' show FundApiException;
import '../widgets/employee_identity_card.dart';

// ---------------------------------------------------------------------------
// Employee Profile — ETF Fund Emulation, Phase 3. The analyst's public
// "resume" (docs/ETF_FUND_EMULATION.md's "Ветка «Инвестиционный
// помощник»"): created on first save, edited freely afterward. Same
// screen either way — there's no separate "create" vs "edit" route.
// Career-stat fields are algorithm-written (Phase 4 populates them from
// real trade-proposal activity) — shown here read-only.
// ---------------------------------------------------------------------------

class EmployeeProfileScreen extends ConsumerStatefulWidget {
  const EmployeeProfileScreen({super.key});

  @override
  ConsumerState<EmployeeProfileScreen> createState() =>
      _EmployeeProfileScreenState();
}

class _EmployeeProfileScreenState
    extends ConsumerState<EmployeeProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _bioController = TextEditingController();
  final _languageController = TextEditingController();
  bool _availableForHire = true;
  bool _submitting = false;
  bool _loadedOnce = false;
  // The form's own source of truth once loaded — a successful save updates
  // this directly from saveMyProfile's response instead of relying on
  // ref.invalidate(myEmployeeProfileProvider) to re-render the screen:
  // invalidating alone would flash the whole screen back to a full-page
  // loading spinner on every save (AsyncValue.when's loading branch has no
  // memory of the data it just had), wiping the form and reading as
  // "did my save even work?" — confirmed live 2026-09-09.
  EmployeeProfile? _profile;
  String? _serverBioError;

  @override
  void dispose() {
    _bioController.dispose();
    _languageController.dispose();
    super.dispose();
  }

  void _applyProfile(EmployeeProfile profile) {
    _bioController.text = profile.bio ?? '';
    _languageController.text = profile.language ?? '';
    _availableForHire = profile.availableForHire;
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context)!;
    if (!_formKey.currentState!.validate()) return;

    setState(() => _submitting = true);
    try {
      // Account nickname (Migration 017) is guaranteed set by this point —
      // ChooseNicknameScreen gates every screen behind it before /home is
      // ever reachable.
      final nickname = ref.read(myNicknameProvider).valueOrNull ?? '';
      final saved = await ref
          .read(employeeApiServiceProvider)
          .saveMyProfile(
            nickname: nickname,
            bio: _bioController.text.trim().isEmpty
                ? null
                : _bioController.text.trim(),
            language: _languageController.text.trim().isEmpty
                ? null
                : _languageController.text.trim(),
            availableForHire: _availableForHire,
          );
      // Keeps the provider's cache correct for the next screen that reads
      // it (e.g. reopening this screen later) without forcing a refetch
      // right now — this screen already has the freshest data (`saved`).
      ref.invalidate(myEmployeeProfileProvider);
      if (!mounted) return;
      setState(() {
        _profile = saved;
        _loadedOnce = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.etfEmployeeProfileSavedSnackbar)),
      );
    } on FundApiException catch (e) {
      if (!mounted) return;
      switch (e.code) {
        case 'bio_no_email':
          setState(() => _serverBioError = l10n.etfEmployeeProfileBioNoEmail);
          _formKey.currentState!.validate();
          break;
        default:
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.message), backgroundColor: ThemeV2.loss),
          );
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.etfEmployeeProfileSaveError),
          backgroundColor: ThemeV2.loss,
        ),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

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

  Widget _availabilityCard(AppPalette palette, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: CardFrame(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: FomoShieldTheme.cardDecoration,
        palette: palette,
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.etfEmployeeProfileAvailableLabel,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: palette.textHeader,
                    ),
                  ),
                  Text(
                    l10n.etfEmployeeProfileAvailableBody,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: palette.textBody,
                    ),
                  ),
                ],
              ),
            ),
            Switch(
              value: _availableForHire,
              onChanged: (v) => setState(() => _availableForHire = v),
              activeTrackColor: palette.accentPrimary,
            ),
          ],
        ),
      ),
    );
  }

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
                      l10n.etfEmployeeProfileSaveButton,
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final palette = resolveAppPalette(ref.watch(themeVariantProvider));
    // Only consulted for the very FIRST load — once _loadedOnce flips true
    // (either from this provider's own data arriving, or from a save),
    // the form renders straight from local state below and never goes
    // through AsyncValue.when's loading branch again, so a save (which
    // does invalidate this provider, just for cache correctness) can never
    // flash the whole screen back to a spinner.
    final profileAsync = ref.watch(myEmployeeProfileProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        centerTitle: true,
        leading: themedBackButton(context, palette),
        title: themedHeaderText(
          l10n.etfEmployeeProfileTitle,
          palette,
          GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.5,
          ),
        ),
      ),
      body: SafeArea(
        child: _loadedOnce
            ? _buildForm(context, palette, l10n, _profile)
            : profileAsync.when(
                loading: () => Center(
                  child: CircularProgressIndicator(
                    color: palette.accentPrimary,
                  ),
                ),
                error: (_, _) => _buildForm(context, palette, l10n, null),
                data: (profile) {
                  _loadedOnce = true;
                  if (profile != null) {
                    _profile = profile;
                    _applyProfile(profile);
                  }
                  return _buildForm(context, palette, l10n, _profile);
                },
              ),
      ),
    );
  }

  Widget _buildForm(
    BuildContext context,
    AppPalette palette,
    AppLocalizations l10n,
    EmployeeProfile? profile,
  ) {
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          EmployeeIdentityCard(palette: palette),
          _fieldHeader(palette, l10n.etfEmployeeProfileNicknameLabel),
          // Read-only — this is the global account nickname (Migration
          // 017), chosen once at ChooseNicknameScreen and never editable
          // again, not a per-profile free-text field anymore.
          _fieldWrapper(
            palette,
            Text(
              ref.watch(myNicknameProvider).valueOrNull ?? '—',
              style: GoogleFonts.inter(
                color: palette.textHeader,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          _fieldHeader(palette, l10n.etfEmployeeProfileBioLabel),
          _fieldWrapper(
            palette,
            hasError: _serverBioError != null,
            TextFormField(
              controller: _bioController,
              maxLength: 300,
              minLines: 3,
              maxLines: 5,
              style: GoogleFonts.inter(color: palette.textHeader),
              onChanged: (_) {
                if (_serverBioError != null) {
                  setState(() => _serverBioError = null);
                }
              },
              decoration: _decoration(
                palette,
                hint: l10n.etfEmployeeProfileBioHint,
              ),
              validator: (_) => _serverBioError,
            ),
          ),
          _fieldHeader(palette, l10n.etfEmployeeProfileLanguageLabel),
          _fieldWrapper(
            palette,
            TextFormField(
              controller: _languageController,
              maxLength: 30,
              style: GoogleFonts.inter(color: palette.textHeader),
              decoration: _decoration(
                palette,
                hint: l10n.etfEmployeeProfileLanguageHint,
              ),
            ),
          ),
          _availabilityCard(palette, l10n),
          _submitButton(palette, l10n),
        ],
      ),
    );
  }
}
