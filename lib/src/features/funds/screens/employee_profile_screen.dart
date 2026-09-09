import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/fomo_shield_theme.dart';
import '../../../core/theme/theme_v2.dart';
import '../../../core/theme/theme_variant_provider.dart';
import '../../../core/theme/themed_header.dart';
import '../../../core/theme/themed_border.dart';
import '../../../core/theme/themed_button.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../../shared/widgets/card_frame.dart';
import '../models/employee.dart';
import '../providers/employee_providers.dart';
import '../services/fund_api_service.dart' show FundApiException;

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
  final _nicknameController = TextEditingController();
  final _bioController = TextEditingController();
  final _languageController = TextEditingController();
  bool _availableForHire = true;
  bool _submitting = false;
  bool _loadedOnce = false;
  String? _serverNicknameError;
  String? _serverBioError;

  @override
  void dispose() {
    _nicknameController.dispose();
    _bioController.dispose();
    _languageController.dispose();
    super.dispose();
  }

  void _applyProfile(EmployeeProfile profile) {
    _nicknameController.text = profile.nickname;
    _bioController.text = profile.bio ?? '';
    _languageController.text = profile.language ?? '';
    _availableForHire = profile.availableForHire;
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context)!;
    if (!_formKey.currentState!.validate()) return;

    setState(() => _submitting = true);
    try {
      await ref
          .read(employeeApiServiceProvider)
          .saveMyProfile(
            nickname: _nicknameController.text.trim(),
            bio: _bioController.text.trim().isEmpty
                ? null
                : _bioController.text.trim(),
            language: _languageController.text.trim().isEmpty
                ? null
                : _languageController.text.trim(),
            availableForHire: _availableForHire,
          );
      ref.invalidate(myEmployeeProfileProvider);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.etfEmployeeProfileSavedSnackbar)),
      );
    } on FundApiException catch (e) {
      if (!mounted) return;
      switch (e.code) {
        case 'nickname_required':
          setState(
            () => _serverNicknameError = l10n.etfEmployeeProfileNicknameRequired,
          );
          _formKey.currentState!.validate();
          break;
        case 'nickname_no_email':
          setState(
            () => _serverNicknameError = l10n.etfEmployeeProfileNicknameNoEmail,
          );
          _formKey.currentState!.validate();
          break;
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
          content: Text(l10n.etfEmployeeProfileSavedSnackbar),
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

  Widget _statsCard(
    AppPalette palette,
    AppLocalizations l10n,
    EmployeeProfile profile,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: CardFrame(
        decoration: FomoShieldTheme.cardDecoration,
        palette: palette,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            themedHeaderText(
              l10n.etfEmployeeProfileStatsTitle,
              palette,
              FomoShieldTheme.cardTitle(),
            ),
            const SizedBox(height: 12),
            _statRow(
              palette,
              l10n.etfEmployeeProfileStatsApproved,
              '${profile.approvedProposalsCount}',
            ),
            const SizedBox(height: 8),
            _statRow(
              palette,
              l10n.etfEmployeeProfileStatsRejected,
              '${profile.rejectedProposalsCount}',
            ),
            const SizedBox(height: 8),
            _statRow(
              palette,
              l10n.etfEmployeeProfileStatsFundsChanged,
              '${profile.fundsChangedCount}',
            ),
            const SizedBox(height: 8),
            _statRow(
              palette,
              l10n.etfEmployeeProfileStatsRating,
              profile.rating != null
                  ? profile.rating!.toStringAsFixed(1)
                  : l10n.etfEmployeeProfileRatingPending,
            ),
          ],
        ),
      ),
    );
  }

  Widget _statRow(AppPalette palette, String label, String value) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(
        label,
        style: GoogleFonts.inter(fontSize: 13, color: palette.textBody),
      ),
      Text(
        value,
        style: GoogleFonts.inter(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: palette.textHeader,
        ),
      ),
    ],
  );

  Widget _invitationsButton(AppPalette palette, AppLocalizations l10n) {
    final invitationsAsync = ref.watch(myInvitationsProvider);
    final count = invitationsAsync.valueOrNull?.length ?? 0;
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: OutlinedButton(
        onPressed: () => context.push('/funds/invitations'),
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(double.infinity, 48),
          side: BorderSide(color: palette.accentPrimary),
        ),
        child: Text(
          l10n.etfEmployeeProfileInvitationsButton(count),
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            color: palette.accentPrimary,
          ),
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
          GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w800),
        ),
      ),
      body: SafeArea(
        child: profileAsync.when(
          loading: () => Center(
            child: CircularProgressIndicator(color: palette.accentPrimary),
          ),
          error: (_, _) => _buildForm(context, palette, l10n, null),
          data: (profile) {
            if (profile != null && !_loadedOnce) {
              _loadedOnce = true;
              _applyProfile(profile);
            }
            return _buildForm(context, palette, l10n, profile);
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
          if (profile != null) ...[
            _statsCard(palette, l10n, profile),
            _invitationsButton(palette, l10n),
          ],
          _fieldHeader(palette, l10n.etfEmployeeProfileNicknameLabel),
          _fieldWrapper(
            palette,
            hasError: _serverNicknameError != null,
            TextFormField(
              controller: _nicknameController,
              maxLength: 30,
              style: GoogleFonts.inter(color: palette.textHeader),
              onChanged: (_) {
                if (_serverNicknameError != null) {
                  setState(() => _serverNicknameError = null);
                }
              },
              decoration: _decoration(
                palette,
                hint: l10n.etfEmployeeProfileNicknameHint,
              ),
              validator: (value) {
                final v = (value ?? '').trim();
                if (v.isEmpty) {
                  return l10n.etfEmployeeProfileNicknameRequired;
                }
                return _serverNicknameError;
              },
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
