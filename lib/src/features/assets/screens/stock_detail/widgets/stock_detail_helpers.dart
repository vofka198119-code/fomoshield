import 'package:intl/intl.dart';

// ---------------------------------------------------------------------------
// Shared formatting helpers for the Stress Test stock detail screen's
// widget files — split out of the old monolithic stock_detail_screen.dart
// verbatim, no logic changes. Naming/sector lookups (stressTestCompanyName
// etc.) moved out to ../../../stress_test/stress_test_naming.dart 2026-08-09
// — those are domain data consumed well beyond this screen, these are not.
// ---------------------------------------------------------------------------

/// Full currency format — NEVER compact (4.67K, 1.5M). Always $X,XXX.XX
String fmtFullCurrency(double v) =>
    NumberFormat.currency(locale: 'en_US', symbol: r'$').format(v);

/// Date formatter: "Jan 15"
String fmtTradeDate(DateTime d) => DateFormat('MMM d').format(d);

/// Time formatter: "14:30"
String fmtTradeTime(DateTime d) => DateFormat('HH:mm').format(d);
