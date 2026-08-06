// ---------------------------------------------------------------------------
// Shared tier model for Session Complete's long-form verdict markers
// (Sector Diversification, Safety Marker, ...) — a marker whose "More"
// screen picks one of several title+body states by score/count range
// instead of the generic threshold-based "coming soon" placeholder.
// Rendered by _TierArticle in verdict_marker_detail_screen.dart, same
// visual template as market_period_detail_screen.dart.
// ---------------------------------------------------------------------------

class TierSection {
  final String label;
  final String body;
  const TierSection({required this.label, required this.body});
}

class VerdictTier {
  final String title;
  final String intro;
  final List<TierSection> sections;
  const VerdictTier({
    required this.title,
    required this.intro,
    this.sections = const [],
  });
}
