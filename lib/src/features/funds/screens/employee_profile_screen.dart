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

class _EmployeeProfileScreenState extends ConsumerState<EmployeeProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _bioController = TextEditingController();
  final _languageController = TextEditingController();
  String? _desiredRole;
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
    _desiredRole = profile.desiredRole;
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
            desiredRole: _desiredRole,
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
      // Explicit, not left to Flutter's own default contentPadding
      // calculation (which varies with decoration shape/isDense and isn't
      // something to reason about "from memory") — this is the exact same
      // vertical:12 every other field on this form uses (the read-only
      // nickname box, the desired-role field), so every box comes out the
      // same height regardless of whether it's a plain Text or a
      // TextFormField underneath.
      contentPadding: const EdgeInsets.symmetric(vertical: 12),
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

  // Same role list + label mapping as send_invite_sheet.dart's own role
  // selector (a head choosing a role when inviting someone) — this is the
  // analyst-side wishlist equivalent, so it reuses the exact same
  // employeeRoles list for consistency.
  String _roleLabel(AppLocalizations l10n, String role) {
    switch (role) {
      case 'co_manager':
        return l10n.etfRoleCoManager;
      case 'trader':
        return l10n.etfRoleTrader;
      case 'risk_manager':
        return l10n.etfRoleRiskManager;
      default:
        return l10n.etfRoleAnalyst;
    }
  }

  // A single field, same box as every other field on this form (and the
  // read-only nickname box above) — a value + chevron, tap opens a popup
  // menu anchored under the field, picking an item writes it into the box
  // and closes the popup. Not a multi-chip picker — explicit correction
  // 2026-09-12 after a first pass used ChoiceChips instead.
  Future<void> _showRoleMenu(
    BuildContext fieldContext,
    AppPalette palette,
    AppLocalizations l10n,
  ) async {
    final box = fieldContext.findRenderObject() as RenderBox;
    final overlay =
        Navigator.of(fieldContext).overlay!.context.findRenderObject()
            as RenderBox;
    final position = RelativeRect.fromRect(
      Rect.fromPoints(
        box.localToGlobal(Offset(0, box.size.height), ancestor: overlay),
        box.localToGlobal(box.size.bottomRight(Offset.zero), ancestor: overlay),
      ),
      Offset.zero & overlay.size,
    );
    final selected = await showMenu<String>(
      context: fieldContext,
      position: position,
      color: palette.card,
      items: [
        for (final role in employeeRoles)
          PopupMenuItem<String>(
            value: role,
            child: Text(
              _roleLabel(l10n, role),
              style: GoogleFonts.inter(color: palette.textHeader),
            ),
          ),
      ],
    );
    if (selected != null) setState(() => _desiredRole = selected);
  }

  Widget _desiredRoleField(AppPalette palette, AppLocalizations l10n) {
    return _fieldWrapper(
      palette,
      Builder(
        builder: (fieldContext) => InkWell(
          onTap: () => _showRoleMenu(fieldContext, palette, l10n),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _desiredRole != null
                        ? _roleLabel(l10n, _desiredRole!)
                        : l10n.etfEmployeeProfileDesiredRoleHint,
                    // fontSize matches the Bio/Language TextFormFields'
                    // own rendered size (their unset fontSize falls back
                    // to the input theme's default, 16) — this field reads
                    // as one more entry in the same form, not a plain Text
                    // widget with its own ambient (smaller) default.
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      color: _desiredRole != null
                          ? palette.textHeader
                          : palette.textHeader.withValues(alpha: 0.5),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: palette.textBody,
                ),
              ],
            ),
          ),
        ),
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
    // Cursor/selection-handle color otherwise falls back to the app-wide
    // TextSelectionTheme (green, tied to ThemeV2.primary) regardless of
    // this screen's own palette-aware field colors — same fix
    // portfolio_screen.dart/stress_test_screen.dart already apply to
    // their own text fields, wrapped once here for every field on this
    // form (Bio, Language) instead of repeating it per field.
    return Theme(
      data: Theme.of(context).copyWith(
        textSelectionTheme: TextSelectionThemeData(
          cursorColor: palette.accentPrimary,
          selectionColor: palette.accentPrimary.withValues(alpha: 0.3),
          selectionHandleColor: palette.accentPrimary,
        ),
      ),
      child: Form(
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
              // vertical:12 padding matches the desired-role field's own box
              // height below — a bare Text with only the wrapper's own
              // vertical:4 padding sat noticeably shorter/pill-shaped next to
              // every other (taller) field on this form.
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  ref.watch(myNicknameProvider).valueOrNull ?? '—',
                  style: GoogleFonts.inter(
                    color: palette.textHeader,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            _fieldHeader(palette, l10n.etfEmployeeProfileBioLabel),
            _fieldWrapper(
              palette,
              hasError: _serverBioError != null,
              TextFormField(
                controller: _bioController,
                maxLength: 500,
                // No maxLines cap — grows one line at a time with typed
                // content instead of freezing at a fixed height and
                // scrolling internally (the outer ListView already scrolls
                // the whole form). minLines:1 keeps it from reserving empty
                // height when blank.
                minLines: 1,
                maxLines: null,
                // Exactly FundTextCard's own body-text style
                // (fund_text_card.dart, used for Strategy/Description on the
                // fund card) — the explicit reference for "how long-form
                // text reads in this app."
                style: GoogleFonts.inter(
                  fontSize: 13,
                  height: 1.5,
                  color: palette.textHeader,
                ),
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
                maxLength: 60,
                minLines: 1,
                maxLines: null,
                style: GoogleFonts.inter(color: palette.textHeader),
                decoration: _decoration(
                  palette,
                  hint: l10n.etfEmployeeProfileLanguageHint,
                ),
              ),
            ),
            _fieldHeader(palette, l10n.etfEmployeeProfileDesiredRoleLabel),
            _desiredRoleField(palette, l10n),
            _availabilityCard(palette, l10n),
            _submitButton(palette, l10n),
          ],
        ),
      ),
    );
  }
}
