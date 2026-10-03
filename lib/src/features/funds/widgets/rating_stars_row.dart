import 'package:flutter/material.dart';
import '../../../core/theme/app_palette.dart';

// ---------------------------------------------------------------------------
// Rating Stars Row — 0-10 star rating with a smooth, continuous fractional
// fill per star (7.8 renders as 7 full stars, an 80%-filled 8th star, and 2
// empty stars) rather than snapping to whole or half stars.
//
// Fill technique: per star, ClipRect(Align(widthFactor: fraction, child:
// Icon)) over an empty-star background — the exact same math Portfolio's own
// TARGET widget segmented bar uses per segment (see
// shared/widgets/segment_gauge_math.dart + target_widget.dart's
// _SegmentedBar: FractionallySizedBox/Align widthFactor = fillFraction),
// just applied per star instead of per bar segment. This is also how
// real-world star-rating widgets (Play Store, App Store, and every
// `flutter_rating_bar`-style package) render a precise partial fill instead
// of jumping between discrete increments.
//
// Colors are theme-aware (explicit ask, "цвета звёзд согласно темам") —
// filled uses palette.accentPrimary (so it reads correctly against every
// admin theme's own accent, not a fixed universal gold), empty uses a muted
// tint of palette.textBody.
//
// A subtle fill-in animation on first build (TweenAnimationBuilder, 0 →
// actual rating) matches the "плавно" ask and the small-polish touch most
// real rating widgets have on first appearance.
// ---------------------------------------------------------------------------

class RatingStarsRow extends StatelessWidget {
  static const int starCount = 10;

  /// 0..10, or null when there isn't enough activity for a rating yet
  /// (renders as 10 empty stars, no animation).
  final double? rating;
  final AppPalette palette;
  final double size;

  const RatingStarsRow({
    super.key,
    required this.rating,
    required this.palette,
    this.size = 20,
  });

  @override
  Widget build(BuildContext context) {
    final target = rating == null
        ? 0.0
        : rating!.clamp(0.0, starCount.toDouble());
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: target),
      duration: const Duration(milliseconds: 700),
      curve: Curves.easeOutCubic,
      builder: (context, value, _) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (int i = 0; i < starCount; i++)
            Padding(
              padding: EdgeInsets.only(right: i == starCount - 1 ? 0 : 3),
              child: _Star(
                fraction: (value - i).clamp(0.0, 1.0),
                size: size,
                palette: palette,
              ),
            ),
        ],
      ),
    );
  }
}

class _Star extends StatelessWidget {
  final double fraction;
  final double size;
  final AppPalette palette;

  const _Star({
    required this.fraction,
    required this.size,
    required this.palette,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.centerLeft,
        children: [
          Icon(
            Icons.star_rounded,
            size: size,
            color: palette.textBody.withValues(alpha: 0.22),
          ),
          if (fraction > 0)
            ClipRect(
              child: Align(
                alignment: Alignment.centerLeft,
                widthFactor: fraction,
                child: Icon(
                  Icons.star_rounded,
                  size: size,
                  color: palette.accentPrimary,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
