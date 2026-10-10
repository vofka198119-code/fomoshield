import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/overlay/app_banner.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/theme_variant_provider.dart';
import '../../../core/theme/themed_button.dart';
import '../../../core/theme/themed_header.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../providers/employee_providers.dart';
import '../services/fund_api_service.dart' show FundApiException;
import '../widgets/fund_form_fields.dart';
import '../widgets/team_member_permissions_sheet.dart' show roleLabelFor;

// ---------------------------------------------------------------------------
// Post Vacancy — the head's side of the exchange (migration 036). A pushed
// screen rather than a sheet, as everything else of this weight in the app
// is (he rejected the sheet version of the balancing screens outright).
//
// Reuses the fund form's own field chrome, so an advert is typed into the
// same boxes a fund is created in.
// ---------------------------------------------------------------------------

const _roles = ['analyst', 'co_manager', 'trader', 'risk_manager'];

class PostVacancyScreen extends ConsumerStatefulWidget {
  final String fundId;

  const PostVacancyScreen({super.key, required this.fundId});

  @override
  ConsumerState<PostVacancyScreen> createState() => _PostVacancyScreenState();
}

class _PostVacancyScreenState extends ConsumerState<PostVacancyScreen> {
  String _role = 'analyst';
  final _pitchController = TextEditingController();
  final _budgetController = TextEditingController();
  bool _budgetInvalid = false;
  bool _submitting = false;

  @override
  void dispose() {
    _pitchController.dispose();
    _budgetController.dispose();
    super.dispose();
  }

  /// Same three-valued read as the permissions sheet's own budget field: an
  /// empty box promises nothing, and zero says the same thing rather than
  /// advertising a budget of nothing.
  double? _parseBudget() {
    final text = _budgetController.text.trim().replaceAll(',', '.');
    if (text.isEmpty) return null;
    final value = double.tryParse(text);
    if (value == null || value < 0 || value.isNaN || value.isInfinite) {
      return double.nan;
    }
    return value == 0 ? null : value;
  }

  String _errorFor(AppLocalizations l10n, FundApiException e) {
    switch (e.code) {
      case 'role_already_open':
        return l10n.etfVacancyErrorRoleOpen;
      case 'no_free_seat':
        return l10n.etfVacancyErrorNoSeat;
      default:
        return l10n.etfVacancyErrorGeneric;
    }
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context)!;
    final budget = _parseBudget();
    if (budget != null && budget.isNaN) {
      setState(() => _budgetInvalid = true);
      showAppBanner(
        l10n.etfTreasurerBudgetInvalid,
        tone: AppBannerTone.failure,
      );
      return;
    }
    setState(() {
      _budgetInvalid = false;
      _submitting = true;
    });
    try {
      await ref
          .read(employeeApiServiceProvider)
          .postVacancy(
            fundId: widget.fundId,
            role: _role,
            pitch: _pitchController.text.trim().isEmpty
                ? null
                : _pitchController.text.trim(),
            offeredLimitAmount: budget,
          );
      ref.invalidate(fundVacanciesProvider(widget.fundId));
      ref.invalidate(vacancyBoardProvider);
      showAppBanner(l10n.etfVacancyPostedMessage, tone: AppBannerTone.success);
      if (mounted) Navigator.of(context).pop();
    } on FundApiException catch (e) {
      showAppBanner(_errorFor(l10n, e), tone: AppBannerTone.failure);
    } catch (_) {
      showAppBanner(l10n.etfVacancyErrorGeneric, tone: AppBannerTone.failure);
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
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        centerTitle: true,
        leading: themedBackButton(context, palette),
        title: themedHeaderText(
          l10n.etfVacancyPostTitle,
          palette,
          GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            letterSpacing: 1,
          ),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          children: [
            fundFieldHeader(palette, l10n.etfVacancyPostRoleLabel),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _roles.map((role) {
                final selected = role == _role;
                return ChoiceChip(
                  label: Text(roleLabelFor(l10n, role)),
                  selected: selected,
                  onSelected: _submitting
                      ? null
                      : (_) => setState(() => _role = role),
                  selectedColor: palette.accentPrimary.withValues(alpha: 0.2),
                  labelStyle: GoogleFonts.inter(
                    fontSize: 12,
                    color: selected ? palette.accentPrimary : palette.textBody,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  ),
                  backgroundColor: palette.card,
                  side: BorderSide(
                    color: palette.textBody.withValues(alpha: 0.2),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            fundFieldHeader(palette, l10n.etfVacancyPostPitchLabel),
            fundFieldWrapper(
              palette,
              TextField(
                controller: _pitchController,
                enabled: !_submitting,
                maxLines: 4,
                maxLength: 500,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: palette.textHeader,
                ),
                decoration: fundFieldDecoration(
                  palette,
                  hint: l10n.etfVacancyPostPitchHint,
                ),
              ),
            ),
            fundFieldHeader(palette, l10n.etfVacancyPostBudgetLabel),
            fundFieldWrapper(
              palette,
              TextField(
                controller: _budgetController,
                enabled: !_submitting,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: palette.textHeader,
                ),
                decoration:
                    fundFieldDecoration(
                      palette,
                      hint: l10n.etfTreasurerBudgetHint,
                    ).copyWith(
                      prefixText: '\$',
                      prefixStyle: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: palette.textHeader,
                      ),
                    ),
              ),
              hasError: _budgetInvalid,
            ),
            Text(
              l10n.etfVacancyPostBudgetHelp,
              style: GoogleFonts.inter(fontSize: 11, color: palette.textBody),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: brandCtaButton(
                palette: palette,
                label: l10n.etfVacancyPostButton,
                onTap: _submitting ? null : _submit,
                busy: _submitting,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
