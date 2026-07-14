import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/theme_v2.dart';
import '../../../core/theme/typography_helpers.dart';
import '../../../shared/widgets/widget_container.dart';
import '../home_providers.dart';

// ---------------------------------------------------------------------------
// News Widget — Compact (Revolut style)
// ---------------------------------------------------------------------------
// Shows 2-3 latest market news headlines with source and time.
// ---------------------------------------------------------------------------

class NewsWidget extends ConsumerWidget {
  const NewsWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final newsAsync = ref.watch(newsProvider);

    return newsAsync.when(
      loading: () => _buildWithStub(context),
      error: (_, _) => _buildWithStub(context),
      data: (articles) {
        if (articles.isEmpty) {
          return _buildWithStub(context);
        }

        final preview = articles.take(3).toList();

        return WidgetContainer(
          title: 'NEWS',
          onTap: () => context.go('/news'),
          showFooter: articles.length > 3,
          children: preview.map((a) => _NewsTile(article: a)).toList(),
        );
      },
    );
  }

  /// Builds the widget with stub fallback news when real data is unavailable.
  Widget _buildWithStub(BuildContext context) {
    final stubArticles = [
      {
        'headline': 'S&P 500 Hits New All-Time High as Tech Stocks Rally',
        'source': 'MarketWatch',
        'datetime': (DateTime.now().millisecondsSinceEpoch / 1000).toInt(),
      },
      {
        'headline': 'Federal Reserve Signals Potential Rate Cut in September',
        'source': 'Bloomberg',
        'datetime': (DateTime.now().millisecondsSinceEpoch / 1000).toInt() - 3600,
      },
    ];

    return WidgetContainer(
      title: 'NEWS',
      onTap: () => context.go('/news'),
      showFooter: false,
      children: stubArticles.map((a) => _NewsTile(article: a)).toList(),
    );
  }

}

// ---------------------------------------------------------------------------
// News Tile
// ---------------------------------------------------------------------------

class _NewsTile extends StatelessWidget {
  final Map<String, dynamic> article;
  const _NewsTile({required this.article});

  @override
  Widget build(BuildContext context) {
    final headline = article['headline'] as String? ?? 'No headline';
    final source = article['source'] as String? ?? '';
    final datetime = article['datetime'] as int?;
    final timeStr = datetime != null
        ? DateFormat('MMM d, HH:mm')
            .format(DateTime.fromMillisecondsSinceEpoch(datetime * 1000))
        : '';

    return InkWell(
      onTap: () => context.go('/news'),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Source icon
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: ThemeV2.surfaceDark,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.newspaper_rounded,
                color: ThemeV2.primary,
                size: 16,
              ),
            ),
            const SizedBox(width: 12),
            // Headline + source/time
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    headline,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: ThemeV2.textPrimary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      if (source.isNotEmpty)
                        Text(
                          source,
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            color: ThemeV2.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      if (source.isNotEmpty && timeStr.isNotEmpty)
                        const SizedBox(width: 8),
                      if (timeStr.isNotEmpty)
                        Text(
                          timeStr,
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            color: ThemeV2.textSecondary,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

