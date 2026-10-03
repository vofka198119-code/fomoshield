import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/supabase/supabase_providers.dart';
import '../../shared/services/user_data_service.dart';

// ---------------------------------------------------------------------------
// Portfolio value history — one point per day
// ---------------------------------------------------------------------------
// The Portfolio screen computes everything live from current prices, so until
// this existed there was no answer to "what was this worth last week". Asked
// for 2026-10-03; the decision was to start accumulating from the update
// rather than reconstruct the past from trade history plus historical candles
// — that is possible, but approximate, and far more work for a chart that
// fills itself in within a fortnight anyway.
//
// Device copy in SharedPreferences, durable copy in
// user_data.portfolio_value_history (Migration 033) — same arrangement as the
// stress-test funding flags, and for the same reason: a reinstall must not
// erase it. The merge on restore takes the union by day, preferring the
// later-written value for a day both copies know.
// ---------------------------------------------------------------------------

/// Hard cap on stored points. A year of daily values is plenty of chart, and
/// it stops a JSONB column from growing without bound.
const int portfolioHistoryMaxPoints = 365;

class PortfolioValuePoint {
  final DateTime at;
  final double value;

  const PortfolioValuePoint({required this.at, required this.value});

  /// Calendar day key — the granularity the whole store works at.
  String get dayKey =>
      '${at.year}-${at.month.toString().padLeft(2, '0')}-'
      '${at.day.toString().padLeft(2, '0')}';

  Map<String, dynamic> toJson() => {
    'at': at.toIso8601String(),
    'value': value,
  };

  static PortfolioValuePoint? fromJson(Map<String, dynamic> json) {
    final at = DateTime.tryParse(json['at'] as String? ?? '');
    final value = (json['value'] as num?)?.toDouble();
    if (at == null || value == null) return null;
    return PortfolioValuePoint(at: at, value: value);
  }
}

String _prefsKey(String? uid) =>
    uid != null ? 'portfolio_value_history_$uid' : 'portfolio_value_history';

Future<List<PortfolioValuePoint>> loadPortfolioHistory(String? uid) async {
  final prefs = await SharedPreferences.getInstance();
  final raw = prefs.getString(_prefsKey(uid));
  if (raw == null) return [];
  try {
    return _decode(jsonDecode(raw) as List<dynamic>);
  } catch (_) {
    return [];
  }
}

List<PortfolioValuePoint> _decode(List<dynamic> raw) {
  final out = <PortfolioValuePoint>[];
  for (final e in raw) {
    if (e is Map) {
      final p = PortfolioValuePoint.fromJson(Map<String, dynamic>.from(e));
      if (p != null) out.add(p);
    }
  }
  out.sort((a, b) => a.at.compareTo(b.at));
  return out;
}

Future<void> _save(String? uid, List<PortfolioValuePoint> points) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString(
    _prefsKey(uid),
    jsonEncode(points.map((p) => p.toJson()).toList()),
  );
}

/// Records [value] as today's point, replacing today's if one already exists.
///
/// Called on every fresh total the Portfolio screen computes, which is often —
/// hence the replace-not-append: ten app opens in a day still leave one point,
/// carrying the most recent value for that day.
Future<void> recordPortfolioValue(WidgetRef ref, double value) async {
  if (!value.isFinite || value < 0) return;
  final uid = ref.read(currentUserProvider)?.id;
  final points = await loadPortfolioHistory(uid);
  final now = DateTime.now();
  final today = PortfolioValuePoint(at: now, value: value);

  final existingToday = points.isNotEmpty && points.last.dayKey == today.dayKey;
  // Nothing to write if today's stored value hasn't moved — saves a pointless
  // Supabase round trip on every screen refresh of an idle portfolio.
  if (existingToday && (points.last.value - value).abs() < 0.005) return;

  if (existingToday) {
    points[points.length - 1] = today;
  } else {
    points.add(today);
  }
  while (points.length > portfolioHistoryMaxPoints) {
    points.removeAt(0);
  }

  await _save(uid, points);
  if (uid != null) {
    await ref
        .read(userDataServiceProvider)
        .savePortfolioValueHistory(
          uid,
          points.map((p) => p.toJson()).toList(),
        );
  }
  ref.invalidate(portfolioValueHistoryProvider);
}

/// Merges the server's copy into the device's, on login. For a day both know,
/// the server's value wins — it is the one that survived whatever wiped the
/// device copy, and a day's exact intraday value matters far less than having
/// the day at all.
Future<void> applyPortfolioHistoryFromSupabase(
  String uid,
  List<dynamic> raw,
) async {
  final incoming = _decode(raw);
  if (incoming.isEmpty) return;
  final mine = await loadPortfolioHistory(uid);
  final byDay = {for (final p in mine) p.dayKey: p};
  for (final p in incoming) {
    byDay[p.dayKey] = p;
  }
  final merged = byDay.values.toList()..sort((a, b) => a.at.compareTo(b.at));
  while (merged.length > portfolioHistoryMaxPoints) {
    merged.removeAt(0);
  }
  await _save(uid, merged);
}

final portfolioValueHistoryProvider =
    FutureProvider<List<PortfolioValuePoint>>((ref) async {
      final uid = ref.watch(currentUserProvider)?.id;
      return loadPortfolioHistory(uid);
    });
