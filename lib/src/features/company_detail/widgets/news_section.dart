import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/theme_v2.dart';
import '../../../core/theme/fomo_shield_theme.dart';

// ===========================================================================
// News Section (inline, no tab)
// ===========================================================================

class NewsSection extends StatelessWidget {
  final String symbol;
  final List<dynamic>? news;
  final bool isLoading;

  const NewsSection({
    super.key,
    required this.symbol,
    this.news,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(FomoShieldTheme.cardPadding),
        decoration: FomoShieldTheme.cardDecoration,
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'NEWS',
            style: FomoShieldTheme.cardTitle(),
          ),
          const SizedBox(height: 10),
          Divider(height: 1, color: Colors.black.withValues(alpha: 0.06)),
          const SizedBox(height: 12),
          if (isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: CircularProgressIndicator(color: ThemeV2.primary),
              ),
            )
          else if (news == null || news!.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'No news available',
                  style: GoogleFonts.inter(
                    color: ThemeV2.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ),
            )
          else
            ...List.generate(news!.length.clamp(0, 5), (i) {
              final article = news![i] as Map<String, dynamic>;
              final headline = article['headline'] as String? ?? 'No title';
              final source = article['source'] as String? ?? '';
              final imageUrl = article['image'] as String?;
              final datetime = (article['datetime'] as num?)?.toInt() ?? 0;
              final dateStr = datetime > 0
                  ? _formatDate(
                      DateTime.fromMillisecondsSinceEpoch(datetime * 1000),
                    )
                  : '';

              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: ThemeV2.surfaceDark,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                          const SizedBox(height: 6),
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
                              if (source.isNotEmpty && dateStr.isNotEmpty)
                                Text(
                                  ' · ',
                                  style: GoogleFonts.inter(
                                    fontSize: 11,
                                    color: ThemeV2.textSecondary,
                                  ),
                                ),
                              if (dateStr.isNotEmpty)
                                Text(
                                  dateStr,
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
                    if (imageUrl != null && imageUrl.isNotEmpty)
                      Container(
                        width: 60,
                        height: 60,
                        margin: const EdgeInsets.only(left: 10),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => const SizedBox.shrink(),
                          ),
                        ),
                      ),
                  ],
                ),
              );
            }),
        ],
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${dt.month}/${dt.day}';
  }
}
