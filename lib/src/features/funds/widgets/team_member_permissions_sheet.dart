import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/theme_v2.dart';
import '../../../core/theme/themed_button.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../models/employee.dart';
import '../providers/employee_providers.dart';
import '../services/fund_api_service.dart' show FundApiException;
import 'fund_form_fields.dart';

// ---------------------------------------------------------------------------
// Team Member Permissions — the head's per-employee permission editor.
// The design doc's own model ("глава вручную выставляет набор прав каждому
// сотруднику отдельно — галочки"; a role is only the STARTING template)
// was fully supported by the backend and read by every gated action in the
// app, but nothing could ever write it: updateTeamMember had zero callers.
//
// Role and permissions are saved SEPARATELY, on purpose. Server-side,
// setting `role` re-seeds permissions from that role's template
// (fundTeamService.ROLE_PERMISSION_TEMPLATES). Sending both together in one
// request would make the outcome depend on argument order rather than on
// what the head meant, and showing the new role's defaults before saving
// would mean keeping a second copy of those templates on the client, free
// to drift from the server's. So changing a role is its own confirmed
// action that says outright it resets the checkboxes, and the sheet then
// re-reads what the server actually produced.
// ---------------------------------------------------------------------------

// The discretionary budget sits below the switches rather than among them
// because it is the only setting here that is not a yes/no, and because it
// is the one that lets an employee act WITHOUT the head -- it reads as the
// exception it is (docs/ETF_FUND_EMULATION.md, "Роль «Казначей»"). Server
// side: fundDiscretion.js.
//
// canSetTargets last (2026-10-08): it is the newest, and unlike the other
// four it is not about one trade but about the fund's whole plan — the head
// hands it over deliberately, so it reads better at the end of the list than
// mixed in among the trade permissions.
const _permissionKeys = [
  'canPropose',
  'canApprove',
  'canExecute',
  'canFlagRisk',
  'canSetTargets',
];
const _roles = ['analyst', 'co_manager', 'trader', 'risk_manager'];

Future<bool?> showTeamMemberPermissionsSheet({
  required BuildContext context,
  required WidgetRef ref,
  required String fundId,
  required FundTeamMember member,
  required AppPalette palette,
}) {
  return showModalBottomSheet<bool>(
    context: context,
    backgroundColor: palette.card,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    isScrollControlled: true,
    builder: (_) =>
        _PermissionsSheet(fundId: fundId, member: member, palette: palette),
  );
}

/// Whole dollars when the stored number is whole -- "2000", not "2000.00",
/// which it will be every time a head typed it. Cents survive only if the
/// column somehow holds them. One rule, used both by the field below and by
/// the roster line in fund_team_card.dart.
String treasurerBudgetDigits(double amount) => amount == amount.roundToDouble()
    ? amount.toStringAsFixed(0)
    : amount.toStringAsFixed(2);

/// The same number as money, for anywhere it is read rather than edited.
String treasurerBudgetMoney(double amount) =>
    '\$${treasurerBudgetDigits(amount)}';

String roleLabelFor(AppLocalizations l10n, String role) {
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

String _permissionLabel(AppLocalizations l10n, String key) {
  switch (key) {
    case 'canApprove':
      return l10n.etfPermissionApprove;
    case 'canExecute':
      return l10n.etfPermissionExecute;
    case 'canFlagRisk':
      return l10n.etfPermissionFlagRisk;
    case 'canSetTargets':
      return l10n.etfPermissionSetTargets;
    default:
      return l10n.etfPermissionPropose;
  }
}

class _PermissionsSheet extends ConsumerStatefulWidget {
  final String fundId;
  final FundTeamMember member;
  final AppPalette palette;

  const _PermissionsSheet({
    required this.fundId,
    required this.member,
    required this.palette,
  });

  @override
  ConsumerState<_PermissionsSheet> createState() => _PermissionsSheetState();
}

class _PermissionsSheetState extends ConsumerState<_PermissionsSheet> {
  late Map<String, bool> _permissions;
  late String _role;
  final _budgetController = TextEditingController();
  bool _budgetInvalid = false;
  bool _submitting = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _role = widget.member.role;
    _permissions = {
      for (final key in _permissionKeys)
        key: widget.member.permissions[key] ?? false,
    };
    _budgetController.text = _formatBudget(widget.member.treasurerLimitAmount);
  }

  @override
  void dispose() {
    _budgetController.dispose();
    super.dispose();
  }

  static String _formatBudget(double? amount) =>
      amount == null ? '' : treasurerBudgetDigits(amount);

  Future<void> _run(Future<FundTeamMember> Function() action) async {
    final l10n = AppLocalizations.of(context)!;
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      final updated = await action();
      if (!mounted) return;
      setState(() {
        _role = updated.role;
        _permissions = {
          for (final key in _permissionKeys)
            key: updated.permissions[key] ?? false,
        };
        // What the server stored, not what was typed -- a role change
        // re-seeds the switches server-side and this keeps the whole sheet
        // showing one consistent answer.
        _budgetController.text = _formatBudget(updated.treasurerLimitAmount);
      });
    } on FundApiException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } catch (_) {
      if (mounted) setState(() => _error = l10n.etfPermissionsSaveError);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  /// An empty field means no budget at all, which is a value the head can
  /// choose and not the same as "unchanged" -- so it is always sent. A comma
  /// is accepted as the decimal separator: a Russian keyboard offers one.
  double? _parseBudget() {
    final text = _budgetController.text.trim().replaceAll(',', '.');
    if (text.isEmpty) return null;
    final value = double.tryParse(text);
    if (value == null || value < 0 || value.isNaN || value.isInfinite) {
      return double.nan;
    }
    // Zero is stored as no budget at all. It would otherwise be a second
    // spelling of one state -- nothing may go through on this person's own
    // authority either way -- and the roster would read "Alone up to $0",
    // which says the opposite of what it means.
    return value == 0 ? null : value;
  }

  Future<void> _savePermissions() async {
    final l10n = AppLocalizations.of(context)!;
    final budget = _parseBudget();
    if (budget != null && budget.isNaN) {
      setState(() {
        _budgetInvalid = true;
        _error = l10n.etfTreasurerBudgetInvalid;
      });
      return;
    }
    setState(() => _budgetInvalid = false);
    await _run(
      () => ref
          .read(employeeApiServiceProvider)
          .updateTeamMember(
            fundId: widget.fundId,
            userId: widget.member.userId,
            permissions: _permissions,
            setTreasurerLimit: true,
            treasurerLimitAmount: budget,
          ),
    );
    if (!mounted || _error != null) return;
    Navigator.of(context).pop(true);
  }

  Future<void> _changeRole(String role) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.etfPermissionsRoleChangeTitle),
        content: Text(l10n.etfPermissionsRoleChangeBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.orderConfirmCancelButton),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l10n.etfPermissionsRoleChangeConfirm),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await _run(
      () => ref
          .read(employeeApiServiceProvider)
          .updateTeamMember(
            fundId: widget.fundId,
            userId: widget.member.userId,
            role: role,
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final palette = widget.palette;

    // Scrollable since 2026-10-10: the budget field raises the keyboard, and
    // a Column sized to its children had nowhere to put the rest of the
    // sheet once the viewInsets padding grew.
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        left: 20,
        right: 20,
        top: 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.member.nickname ?? l10n.etfRoleAnalyst,
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: palette.textHeader,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              l10n.etfPermissionsSheetIntro,
              style: GoogleFonts.inter(fontSize: 12, color: palette.textBody),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.etfInvitationDetailRoleLabel,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: palette.textBody,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _roles.map((role) {
                final selected = role == _role;
                return ChoiceChip(
                  label: Text(roleLabelFor(l10n, role)),
                  selected: selected,
                  onSelected: _submitting || selected
                      ? null
                      : (_) => _changeRole(role),
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
            const SizedBox(height: 16),
            // Label-left / Switch-right with activeTrackColor, exactly as
            // employee_profile_screen.dart's own toggle — SwitchListTile would
            // have brought Material's default accent in with it and read as a
            // stray blue on every admin theme.
            for (final key in _permissionKeys)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        _permissionLabel(l10n, key),
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: palette.textHeader,
                        ),
                      ),
                    ),
                    Switch(
                      value: _permissions[key] ?? false,
                      onChanged: _submitting
                          ? null
                          : (value) =>
                                setState(() => _permissions[key] = value),
                      activeTrackColor: palette.accentPrimary,
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 16),
            _budgetField(palette, l10n),
            if (_error != null) ...[
              const SizedBox(height: 8),
              Text(
                _error!,
                style: GoogleFonts.inter(fontSize: 12, color: ThemeV2.loss),
              ),
            ],
            const SizedBox(height: 16),
            _saveButton(palette, l10n),
          ],
        ),
      ),
    );
  }

  Widget _budgetField(AppPalette palette, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        fundFieldHeader(palette, l10n.etfTreasurerBudgetLabel),
        fundFieldWrapper(
          palette,
          TextField(
            controller: _budgetController,
            enabled: !_submitting,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: GoogleFonts.inter(fontSize: 14, color: palette.textHeader),
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
          l10n.etfTreasurerBudgetHelp,
          style: GoogleFonts.inter(fontSize: 11, color: palette.textBody),
        ),
      ],
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
            onTap: _submitting ? null : _savePermissions,
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
                      l10n.etfPermissionsSaveButton,
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
