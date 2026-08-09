part of 'stress_test_engine.dart';

// ---------------------------------------------------------------------------
// Why Diagnostics — persistent whole-period accumulator, admin-only.
// ---------------------------------------------------------------------------
// Own file/mechanism, deliberately isolated from StressTestSession itself:
// that model gets manually reconstructed field-by-field at ~15 call sites
// across this engine (no copyWith), and one of those sites already caused a
// real bug once from a field silently missing from the reconstruction —
// adding new persisted fields there means auditing every one of those
// sites. This lives on StressTestNotifier instead (same pattern as
// _sessionRandom), with its own SharedPreferences key, so it can be added
// without touching the session reconstruction dance at all.
//
// Why fold every tick instead of deriving from explanationLog afterwards:
// explanationLog is capped at 50 entries per symbol (see
// _maxExplanationLogEntries) and trimmed from the front — for anything
// past a ~16-minute window it no longer has the earlier ticks at all, and
// a single catch-up burst can process up to 900 sub-ticks in one call,
// trimming most of them before a periodic reader would ever see them. This
// accumulator instead folds each tick the instant it's computed (right
// where explanationLog itself is appended to, in noise_engine.dart's tick
// loop), so it never misses one — it's the only source of a TRUE
// whole-period aggregate, not just "whatever's still in the capped log".
//
// Persistence: local-only (this device's SharedPreferences, keyed by
// userId like the rest of this file's storage) — no Supabase sync. Writing
// is gated by admin status in the caller (stress_test_screen.dart's
// periodic timer), not here — this file has no opinion on who's admin,
// it just folds ticks and saves/loads whatever's asked of it. Raw ticks
// themselves are never persisted, only the running aggregate — fixed
// small size regardless of how long a test runs.
// ---------------------------------------------------------------------------

const int _maxWhyEpisodesKept = 100;

class WhyDiagnosticsEpisode {
  final int startEpoch;
  final int endEpoch;
  final bool isUp;
  final double netPercent;

  const WhyDiagnosticsEpisode({
    required this.startEpoch,
    required this.endEpoch,
    required this.isUp,
    required this.netPercent,
  });

  Map<String, dynamic> toJson() => {
        'startEpoch': startEpoch,
        'endEpoch': endEpoch,
        'isUp': isUp,
        'netPercent': netPercent,
      };

  factory WhyDiagnosticsEpisode.fromJson(Map<String, dynamic> json) => WhyDiagnosticsEpisode(
        startEpoch: json['startEpoch'] as int,
        endEpoch: json['endEpoch'] as int,
        isUp: json['isUp'] as bool,
        netPercent: (json['netPercent'] as num).toDouble(),
      );
}

class WhyDiagnosticsAccumulator {
  double weightedMarket = 0;
  double weightedSector = 0;
  double weightedNews = 0;
  double weightedHype = 0;
  double weightedNoise = 0;
  double totalWeight = 0;
  int tickCount = 0;

  int? _newsStartEpoch;
  double? _newsStartPrice;
  int? _newsLastEpoch;
  double? _newsLastPrice;

  int? _hypeStartEpoch;
  double? _hypeStartPrice;
  int? _hypeLastEpoch;
  double? _hypeLastPrice;

  final List<WhyDiagnosticsEpisode> newsEpisodes = [];
  final List<WhyDiagnosticsEpisode> hypeEpisodes = [];

  /// Whole-period average contribution per factor, weighted by each
  /// tick's own price move (bigger swings count more).
  PriceContribution get averaged {
    if (totalWeight <= 0) {
      return const PriceContribution(marketPct: 0, sectorPct: 0, newsPct: 0, noisePct: 0);
    }
    return PriceContribution(
      marketPct: weightedMarket / totalWeight,
      sectorPct: weightedSector / totalWeight,
      newsPct: weightedNews / totalWeight,
      hypePct: weightedHype / totalWeight,
      noisePct: weightedNoise / totalWeight,
    );
  }

  void fold(TickExplanation t) {
    final w = t.changePercent.abs();
    final effectiveW = w > 0 ? w : 0.0001;
    weightedMarket += t.contributions.marketPct * effectiveW;
    weightedSector += t.contributions.sectorPct * effectiveW;
    weightedNews += t.contributions.newsPct * effectiveW;
    weightedHype += t.contributions.hypePct * effectiveW;
    weightedNoise += t.contributions.noisePct * effectiveW;
    totalWeight += effectiveW;
    tickCount++;

    final newsActive = t.newsRaw != null && t.newsRaw!.abs() > 0.0001;
    if (newsActive) {
      _newsStartEpoch ??= t.epochIndex;
      _newsStartPrice ??= t.priceBefore;
      _newsLastEpoch = t.epochIndex;
      _newsLastPrice = t.priceAfter;
    } else if (_newsStartEpoch != null) {
      _closeEpisode(newsEpisodes, _newsStartEpoch, _newsStartPrice, _newsLastEpoch, _newsLastPrice);
      _newsStartEpoch = null;
      _newsStartPrice = null;
      _newsLastEpoch = null;
      _newsLastPrice = null;
    }

    final hypeActive = t.hypeRaw != null && t.hypeRaw!.abs() > 0.0001;
    if (hypeActive) {
      _hypeStartEpoch ??= t.epochIndex;
      _hypeStartPrice ??= t.priceBefore;
      _hypeLastEpoch = t.epochIndex;
      _hypeLastPrice = t.priceAfter;
    } else if (_hypeStartEpoch != null) {
      _closeEpisode(hypeEpisodes, _hypeStartEpoch, _hypeStartPrice, _hypeLastEpoch, _hypeLastPrice);
      _hypeStartEpoch = null;
      _hypeStartPrice = null;
      _hypeLastEpoch = null;
      _hypeLastPrice = null;
    }
  }

  void _closeEpisode(
    List<WhyDiagnosticsEpisode> into,
    int? startEpoch,
    double? startPrice,
    int? lastEpoch,
    double? lastPrice,
  ) {
    if (startEpoch == null || startPrice == null || lastEpoch == null || lastPrice == null) {
      return;
    }
    final net = startPrice > 0 ? ((lastPrice - startPrice) / startPrice) * 100 : 0.0;
    into.add(
      WhyDiagnosticsEpisode(
        startEpoch: startEpoch,
        endEpoch: lastEpoch,
        isUp: net >= 0,
        netPercent: net,
      ),
    );
    if (into.length > _maxWhyEpisodesKept) into.removeAt(0);
  }

  Map<String, dynamic> toJson() => {
        'weightedMarket': weightedMarket,
        'weightedSector': weightedSector,
        'weightedNews': weightedNews,
        'weightedHype': weightedHype,
        'weightedNoise': weightedNoise,
        'totalWeight': totalWeight,
        'tickCount': tickCount,
        'newsStartEpoch': _newsStartEpoch,
        'newsStartPrice': _newsStartPrice,
        'newsLastEpoch': _newsLastEpoch,
        'newsLastPrice': _newsLastPrice,
        'hypeStartEpoch': _hypeStartEpoch,
        'hypeStartPrice': _hypeStartPrice,
        'hypeLastEpoch': _hypeLastEpoch,
        'hypeLastPrice': _hypeLastPrice,
        'newsEpisodes': newsEpisodes.map((e) => e.toJson()).toList(),
        'hypeEpisodes': hypeEpisodes.map((e) => e.toJson()).toList(),
      };

  static WhyDiagnosticsAccumulator fromJson(Map<String, dynamic> json) {
    final acc = WhyDiagnosticsAccumulator()
      ..weightedMarket = (json['weightedMarket'] as num?)?.toDouble() ?? 0
      ..weightedSector = (json['weightedSector'] as num?)?.toDouble() ?? 0
      ..weightedNews = (json['weightedNews'] as num?)?.toDouble() ?? 0
      ..weightedHype = (json['weightedHype'] as num?)?.toDouble() ?? 0
      ..weightedNoise = (json['weightedNoise'] as num?)?.toDouble() ?? 0
      ..totalWeight = (json['totalWeight'] as num?)?.toDouble() ?? 0
      ..tickCount = json['tickCount'] as int? ?? 0
      .._newsStartEpoch = json['newsStartEpoch'] as int?
      .._newsStartPrice = (json['newsStartPrice'] as num?)?.toDouble()
      .._newsLastEpoch = json['newsLastEpoch'] as int?
      .._newsLastPrice = (json['newsLastPrice'] as num?)?.toDouble()
      .._hypeStartEpoch = json['hypeStartEpoch'] as int?
      .._hypeStartPrice = (json['hypeStartPrice'] as num?)?.toDouble()
      .._hypeLastEpoch = json['hypeLastEpoch'] as int?
      .._hypeLastPrice = (json['hypeLastPrice'] as num?)?.toDouble();
    acc.newsEpisodes.addAll(
      (json['newsEpisodes'] as List<dynamic>? ?? [])
          .map((e) => WhyDiagnosticsEpisode.fromJson(e as Map<String, dynamic>)),
    );
    acc.hypeEpisodes.addAll(
      (json['hypeEpisodes'] as List<dynamic>? ?? [])
          .map((e) => WhyDiagnosticsEpisode.fromJson(e as Map<String, dynamic>)),
    );
    return acc;
  }
}

String _whyDiagnosticsKey(String? uid) =>
    uid != null ? 'stress_test_why_diagnostics_$uid' : 'stress_test_why_diagnostics';

extension WhyDiagnosticsEngine on StressTestNotifier {
  /// Folds one freshly-computed tick into this session+symbol's running
  /// accumulator. Called directly from the tick loop (noise_engine.dart),
  /// not derived from explanationLog afterwards — see file header.
  void _foldWhyDiagnostics(String sessionId, String symbol, TickExplanation expl) {
    final bySymbol = _whyDiagnostics.putIfAbsent(sessionId, () => {});
    final acc = bySymbol.putIfAbsent(symbol, () => WhyDiagnosticsAccumulator());
    acc.fold(expl);
  }

  /// Read-only accessor for the UI — null if nothing accumulated yet for
  /// this session+symbol.
  WhyDiagnosticsAccumulator? whyDiagnosticsFor(String sessionId, String symbol) =>
      _whyDiagnostics[sessionId]?[symbol];

  Future<void> _loadWhyDiagnostics() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_whyDiagnosticsKey(_userId));
    if (raw == null) return;
    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      for (final sessionEntry in decoded.entries) {
        final bySymbol = <String, WhyDiagnosticsAccumulator>{};
        for (final symbolEntry in (sessionEntry.value as Map<String, dynamic>).entries) {
          bySymbol[symbolEntry.key] =
              WhyDiagnosticsAccumulator.fromJson(symbolEntry.value as Map<String, dynamic>);
        }
        _whyDiagnostics[sessionEntry.key] = bySymbol;
      }
    } catch (_) {
      // Corrupt/old-format cache — ignore, starts fresh rather than crash.
    }
  }

  /// Persists the current accumulator state to this device's local cache.
  /// The caller is responsible for admin-gating (see stress_test_screen
  /// .dart's periodic timer) — this method has no opinion on who's admin.
  Future<void> saveWhyDiagnostics() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = <String, dynamic>{
      for (final sessionEntry in _whyDiagnostics.entries)
        sessionEntry.key: {
          for (final symbolEntry in sessionEntry.value.entries)
            symbolEntry.key: symbolEntry.value.toJson(),
        },
    };
    await prefs.setString(_whyDiagnosticsKey(_userId), jsonEncode(encoded));
  }
}
