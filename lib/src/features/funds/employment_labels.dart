import '../../l10n/gen/app_localizations.dart';
import 'models/employee.dart';

// ---------------------------------------------------------------------------
// Employment labels — how long a stint lasted and how it ended, formatted
// for display. Same split as sector_labels.dart: the record's own values
// stay as the backend stores them, this only localizes what's shown.
//
// Both the Employee Hub's short list and the full Companies screen render
// the same rows, so the formatting lives here rather than in either of
// them — a résumé that disagreed with itself between two screens would be
// worse than one that's plain.
// ---------------------------------------------------------------------------

/// Compact tenure: "1 y 2 mo", "5 mo", "12 d". Deliberately avoids ICU
/// plurals — Russian would need three forms per unit for a string nobody
/// reads as a sentence, and the abbreviated units read the same at every
/// count.
String employmentTenureLabel(AppLocalizations l10n, EmploymentRecord record) {
  final end = record.leftAt ?? DateTime.now();
  final days = end.difference(record.joinedAt).inDays;
  // A stint that ends the day it starts is still a real stint, so the
  // floor is one day rather than an empty label.
  final safeDays = days < 1 ? 1 : days;

  // Calendar months vary; 30 is close enough for a résumé line and keeps
  // this a pure function of two dates, with no locale calendar involved.
  final months = safeDays ~/ 30;
  if (months < 1) return l10n.etfEmploymentTenureDays(safeDays);
  final years = months ~/ 12;
  if (years < 1) return l10n.etfEmploymentTenureMonths(months);
  return l10n.etfEmploymentTenureYearsMonths(years, months % 12);
}

/// How the stint ended, or that it hasn't. `fund_closed` arrives with
/// Migration 031; anything unrecognized falls back to the neutral "left"
/// wording rather than showing a raw database value to a user.
String employmentOutcomeLabel(AppLocalizations l10n, EmploymentRecord record) {
  if (record.isActive) return l10n.etfEmploymentOutcomeActive;
  switch (record.leaveType) {
    case 'resigned':
      return l10n.etfEmploymentOutcomeResigned;
    case 'terminated':
      return l10n.etfEmploymentOutcomeTerminated;
    case 'fund_closed':
      return l10n.etfEmploymentOutcomeFundClosed;
    default:
      return l10n.etfEmploymentOutcomeLeft;
  }
}
