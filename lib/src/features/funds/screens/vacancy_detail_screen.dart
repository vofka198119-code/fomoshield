import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/overlay/app_banner.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/theme_v2.dart';
import '../../../core/theme/theme_variant_provider.dart';
import '../../../core/theme/themed_header.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../models/fund_vacancy.dart';
import '../providers/employee_providers.dart';
import '../services/fund_api_service.dart' show FundApiException;
import '../widgets/fund_form_fields.dart';
import '../widgets/role_picker_field.dart';
import '../widgets/vacancy_action_buttons.dart';

// ---------------------------------------------------------------------------
// One advert's own screen — the way in from the fund's vacancies card
// (2026-10-10, to his design): the words live here, not in the list.
//
// Save only wakes up once something has actually changed, and every button
// -- save, cancel, delete, pause -- takes you back a step, because all four
// are endings.
// ---------------------------------------------------------------------------

class VacancyDetailScreen extends ConsumerStatefulWidget {
  final String fundId;
  final String vacancyId;

  const VacancyDetailScreen({
    super.key,
    required this.fundId,
    required this.vacancyId,
  });

  @override
  ConsumerState<VacancyDetailScreen> createState() =>
      _VacancyDetailScreenState();
}

class _VacancyDetailScreenState extends ConsumerState<VacancyDetailScreen> {
  final _pitchController = TextEditingController();
  final _budgetController = TextEditingController();
  String? _role;
  bool _budgetInvalid = false;
  bool _busy = false;

  /// What the advert looked like when it was opened, to tell a real edit from
  /// a screen that was merely visited.
  FundVacancy? _original;

  @override
  void dispose() {
    _pitchController.dispose();
    _budgetController.dispose();
    super.dispose();
  }

  void _adopt(FundVacancy vacancy) {
    _original = vacancy;
    _role = vacancy.role;
    _pitchController.text = vacancy.pitch ?? '';
    final limit = vacancy.offeredLimitAmount;
    _budgetController.text = limit == null || limit <= 0
        ? ''
        : (limit == limit.roundToDouble()
              ? limit.toStringAsFixed(0)
              : limit.toStringAsFixed(2));
  }

  double? _parseBudget() {
    final text = _budgetController.text.trim().replaceAll(',', '.');
    if (text.isEmpty) return null;
    final value = double.tryParse(text);
    if (value == null || value < 0 || value.isNaN || value.isInfinite) {
      return double.nan;
    }
    return value == 0 ? null : value;
  }

  bool get _dirty {
    final original = _original;
    if (original == null) return false;
    final budget = _parseBudget();
    final originalBudget = (original.offeredLimitAmount ?? 0) > 0
        ? original.offeredLimitAmount
        : null;
    return _role != original.role ||
        _pitchController.text.trim() != (original.pitch ?? '').trim() ||
        ((budget == null || budget.isNaN) ? null : budget) != originalBudget;
  }

  /// Every action here ends the visit, so they share one shape: do the thing,
  /// say what happened, refresh both lists, step back.
  Future<void> _run(
    Future<void> Function() action,
    String doneMessage,
    AppLocalizations l10n,
  ) async {
    setState(() => _busy = true);
    try {
      await action();
      ref.invalidate(fundVacanciesProvider(widget.fundId));
      ref.invalidate(vacancyBoardProvider);
      showAppBanner(doneMessage, tone: AppBannerTone.success);
      if (mounted) Navigator.of(context).pop();
    } on FundApiException catch (e) {
      showAppBanner(_errorFor(l10n, e), tone: AppBannerTone.failure);
    } catch (_) {
      showAppBanner(l10n.etfVacancyErrorGeneric, tone: AppBannerTone.failure);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
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

  Future<void> _save(AppLocalizations l10n) async {
    final budget = _parseBudget();
    if (budget != null && budget.isNaN) {
      setState(() => _budgetInvalid = true);
      showAppBanner(
        l10n.etfTreasurerBudgetInvalid,
        tone: AppBannerTone.failure,
      );
      return;
    }
    setState(() => _budgetInvalid = false);
    await _run(
      () => ref
          .read(employeeApiServiceProvider)
          .updateVacancy(
            fundId: widget.fundId,
            vacancyId: widget.vacancyId,
            role: _role,
            pitch: _pitchController.text.trim(),
            setOfferedLimit: true,
            offeredLimitAmount: budget,
          )
          .then((_) {}),
      l10n.etfVacancySavedMessage,
      l10n,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final palette = resolveAppPalette(ref.watch(themeVariantProvider));
    final vacancies = ref.watch(fundVacanciesProvider(widget.fundId));
    final vacancy = vacancies.valueOrNull
        ?.where((v) => v.id == widget.vacancyId)
        .firstOrNull;

    if (vacancy != null && _original?.id != vacancy.id) _adopt(vacancy);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        centerTitle: true,
        leading: themedBackButton(context, palette),
        title: themedHeaderText(
          l10n.etfVacancyEditTitle,
          palette,
          GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            letterSpacing: 1,
          ),
        ),
      ),
      body: SafeArea(
        child: vacancy == null
            ? Center(
                child: vacancies.isLoading
                    ? CircularProgressIndicator(color: palette.accentPrimary)
                    : Text(
                        l10n.etfVacancyErrorGeneric,
                        style: GoogleFonts.inter(color: palette.textBody),
                      ),
              )
            : ListView(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
                children: [
                  _statusLine(vacancy, l10n, palette),
                  const SizedBox(height: 18),
                  fundFieldHeader(palette, l10n.etfVacancyPostRoleLabel),
                  RolePickerField(
                    palette: palette,
                    value: _role,
                    onChanged: (role) => setState(() => _role = role),
                  ),
                  fundFieldHeader(palette, l10n.etfVacancyPostPitchLabel),
                  fundFieldWrapper(
                    palette,
                    TextField(
                      controller: _pitchController,
                      enabled: !_busy,
                      maxLines: 5,
                      maxLength: 500,
                      onChanged: (_) => setState(() {}),
                      style: GoogleFonts.inter(
                        fontSize: 16,
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
                      enabled: !_busy,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      onChanged: (_) => setState(() {}),
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        color: palette.textHeader,
                      ),
                      decoration:
                          fundFieldDecoration(
                            palette,
                            hint: l10n.etfTreasurerBudgetHint,
                          ).copyWith(
                            prefixText: '\$',
                            prefixStyle: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: palette.textHeader,
                            ),
                          ),
                    ),
                    hasError: _budgetInvalid,
                  ),
                  Text(
                    l10n.etfVacancyPostBudgetHelp,
                    style: GoogleFonts.inter(
                      fontSize: 12.5,
                      height: 1.35,
                      color: palette.textBody,
                    ),
                  ),
                  const SizedBox(height: 24),
                  VacancyActionButtons(
                    palette: palette,
                    l10n: l10n,
                    paused: vacancy.isPaused,
                    canSave: _dirty && !_busy,
                    busy: _busy,
                    onSave: () => _save(l10n),
                    onCancel: () => Navigator.of(context).pop(),
                    onDelete: () => _run(
                      () => ref
                          .read(employeeApiServiceProvider)
                          .deleteVacancy(widget.fundId, widget.vacancyId),
                      l10n.etfVacancyDeletedMessage,
                      l10n,
                    ),
                    onTogglePause: () => _run(
                      () => ref
                          .read(employeeApiServiceProvider)
                          .setVacancyPaused(
                            fundId: widget.fundId,
                            vacancyId: widget.vacancyId,
                            paused: !vacancy.isPaused,
                          )
                          .then((_) {}),
                      vacancy.isPaused
                          ? l10n.etfVacancyResumedMessage
                          : l10n.etfVacancyPausedMessage,
                      l10n,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _statusLine(
    FundVacancy vacancy,
    AppLocalizations l10n,
    AppPalette palette,
  ) {
    final active = vacancy.isOpen;
    final color = active ? ThemeV2.success : ThemeV2.loss;
    return Row(
      children: [
        Icon(
          active ? Icons.circle : Icons.pause_circle_filled_rounded,
          size: active ? 10 : 16,
          color: color,
        ),
        const SizedBox(width: 8),
        Text(
          active ? l10n.etfVacancyStatusActive : l10n.etfVacancyStatusPaused,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ],
    );
  }
}
