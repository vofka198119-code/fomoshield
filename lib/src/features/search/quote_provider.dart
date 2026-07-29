import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/services/finnhub_service.dart';

// ---------------------------------------------------------------------------
// Quote provider — thin Riverpod wrapper so widgets can `ref.watch` a
// live price instead of managing their own FutureBuilder. FinnhubService
// already caches internally (4h general TTL / 15s REST-fallback on the
// backend for non-hot symbols), so this stays cheap to re-watch.
// ---------------------------------------------------------------------------

final quoteProvider = FutureProvider.family<Map<String, dynamic>, String>(
  (ref, symbol) => FinnhubService().quote(symbol),
);
