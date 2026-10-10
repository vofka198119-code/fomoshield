import '../../l10n/gen/app_localizations.dart';

// ---------------------------------------------------------------------------
// The words and numbers the funds module repeats everywhere: what a role is
// called, and how a discretionary budget is written.
//
// They lived in team_member_permissions_sheet.dart, and five other files
// imported them from there -- a sheet doing duty as a utility module, which
// is how a 400-line file becomes a 1000-line one. Pulled out on 2026-10-10
// while that was still a smell and not yet a problem.
// ---------------------------------------------------------------------------

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

/// Whole dollars when the stored number is whole -- "2000", not "2000.00",
/// which it will be every time a head typed it. Cents survive only if the
/// column somehow holds them.
String treasurerBudgetDigits(double amount) => amount == amount.roundToDouble()
    ? amount.toStringAsFixed(0)
    : amount.toStringAsFixed(2);

/// The same number as money, for anywhere it is read rather than edited.
String treasurerBudgetMoney(double amount) =>
    '\$${treasurerBudgetDigits(amount)}';
