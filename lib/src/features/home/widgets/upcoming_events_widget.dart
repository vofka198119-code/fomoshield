import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/theme_v2.dart';
import '../../../core/theme/typography_helpers.dart';
import '../../../shared/widgets/widget_container.dart';
import '../home_providers.dart';

// ---------------------------------------------------------------------------
// Upcoming Events Widget — Compact (Revolut style)
// ---------------------------------------------------------------------------

class UpcomingEventsWidget extends ConsumerWidget {
  const UpcomingEventsWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventsAsync = ref.watch(calendarEventsProvider);

    return eventsAsync.when(
      loading: () => _container(context, [
        const Padding(
          padding: EdgeInsets.all(20),
          child: Row(
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: ThemeV2.primary,
                ),
              ),
              SizedBox(width: 12),
              Text(
                'Loading events...',
                style: TextStyle(
                  fontSize: 14,
                  color: ThemeV2.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ]),
      error: (_, _) => WidgetContainer(
        title: 'UPCOMING EVENTS',
        onTap: () => context.push('/watchlist'),
        showFooter: false,
        emptyText: 'Nothing here yet',
      ),
      data: (events) {
        if (events.isEmpty) {
          return WidgetContainer(
            title: 'UPCOMING EVENTS',
            onTap: () => context.push('/watchlist'),
            showFooter: false,
            emptyText: 'Nothing here yet',
          );
        }

        // Show only first 2
        final preview = events.take(2).toList();

        return WidgetContainer(
          title: 'UPCOMING EVENTS',
          onTap: () => context.push('/watchlist'),
          showFooter: events.length > 2,
          children: preview.map((e) => _EventTile(event: e)).toList(),
        );
      },
    );
  }

  Widget _container(BuildContext context, List<Widget> children) {
    return WidgetContainer(
      title: 'UPCOMING EVENTS',
      onTap: () => context.push('/watchlist'),
      showFooter: false,
      children: children,
    );
  }
}

// ---------------------------------------------------------------------------
// Event Tile — Compact (no accordion)
// ---------------------------------------------------------------------------

class _EventTile extends StatelessWidget {
  final CalendarEvent event;
  const _EventTile({required this.event});

  Future<void> _openArticle() async {
    final url = event.url;
    if (url == null) return;
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEarnings = event.type == 'earnings';
    final isNews = event.type == 'news';
    final accent = isNews
        ? ThemeV2.warning
        : (isEarnings ? ThemeV2.primary : ThemeV2.success);

    return InkWell(
      onTap: isNews
          ? _openArticle
          : () => context.push('/company/${event.symbol}'),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // Icon
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                isNews
                    ? Icons.newspaper_rounded
                    : (isEarnings
                        ? Icons.bar_chart_rounded
                        : Icons.payments_rounded),
                size: 18,
                color: accent,
              ),
            ),
            const SizedBox(width: 12),
            // Ticker + Date
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        event.symbol,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: ThemeV2.textPrimary,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          event.title,
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            color: ThemeV2.textSecondary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Text(
                        DateFormat('MMM d, yyyy').format(event.date),
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: ThemeV2.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (event.hour != null) ...[
                        const SizedBox(width: 6),
                        _HourBadge(hour: event.hour!),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Type badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                isNews ? 'NEWS' : (isEarnings ? 'EAR' : 'DIV'),
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: accent,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Hour Badge
// ---------------------------------------------------------------------------

class _HourBadge extends StatelessWidget {
  final String hour;
  const _HourBadge({required this.hour});

  @override
  Widget build(BuildContext context) {
    String label;
    Color color;
    IconData icon;

    switch (hour) {
      case 'bmo':
        label = 'BMO';
        color = ThemeV2.primary;
        icon = Icons.wb_sunny_rounded;
      case 'amc':
        label = 'AMC';
        color = ThemeV2.warning;
        icon = Icons.nights_stay_rounded;
      case 'dmh':
        label = 'DMH';
        color = ThemeV2.success;
        icon = Icons.business_center_rounded;
      default:
        label = hour.toUpperCase();
        color = ThemeV2.textSecondary;
        icon = Icons.schedule_rounded;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: color),
          const SizedBox(width: 3),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}



