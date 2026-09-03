import 'package:intl/intl.dart';

// ---------------------------------------------------------------------------
// App-wide USD formatting standard (2026-08-16 unification audit) — before
// this, the same $ amount could render as "$15,000.00", "$15000.00", or
// "15000.00$" depending on which screen you were on. One standard now:
// "$" prefix, ALWAYS 2 decimals, a SPACE as the thousands separator (not a
// comma) — e.g. formatUsd(15000) == r'$15 000.00', formatUsd(1500.5) ==
// r'$1 500.50'. Use these everywhere a raw dollar amount is displayed;
// don't hand-roll `\$${x.toStringAsFixed(2)}` or NumberFormat('#,##0.00')
// at a call site — that's exactly the drift that caused the original bug.
//
// That separator is a NON-BREAKING space (U+00A0), not a plain one — a
// plain space is a valid line-wrap point, so a formatted amount sitting
// inside a longer sentence (e.g. Set Goal's "Minimum $15 180.00.") could
// wrap mid-number, splitting "$15" onto one line and "180.00." onto the
// next (confirmed on-device 2026-09-03). Visually identical to a regular
// space either way, so this is a no-op everywhere the amount already had
// room to itself.
// ---------------------------------------------------------------------------

final _usdPattern = NumberFormat('#,##0.00', 'en_US');

/// Formats [value] as a plain USD amount: "$1 234.56", "-$1 234.56" for a
/// negative value (sign before the "$", not after the whole string).
String formatUsd(num value) {
  final formatted = _usdPattern.format(value.abs()).replaceAll(',', ' ');
  return '${value < 0 ? '-' : ''}\$$formatted';
}

/// Same as [formatUsd] but always prefixes an explicit +/- sign — for P&L /
/// delta rows that need to show a gain as "+$123.45", not just "$123.45".
String formatUsdSigned(num value) {
  final formatted = _usdPattern.format(value.abs()).replaceAll(',', ' ');
  return '${value >= 0 ? '+' : '-'}\$$formatted';
}
