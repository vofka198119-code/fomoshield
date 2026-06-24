import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../home_providers.dart';

// ---------------------------------------------------------------------------
// Events Full Screen — All upcoming events with full cards
// ---------------------------------------------------------------------------

class EventsFullScreen extends ConsumerWidget {
  const EventsFullScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventsAsync = ref.watch(calendarEventsProvider);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(
          'Upcoming Events',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
      body: eventsAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: AppTheme.accentBlue,
          ),
        ),
        error: (_, __) => _emptyState(),
        data: (events) {
          if (events.isEmpty) return _emptyState();
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
            itemCount: events.length,
            itemBuilder: (_, i) {
              final event = events[i];
              final eventKey = '${event.symbol}_${event.date}_${event.hour}';
              return Padding(
                key: ValueKey(eventKey),
                padding: const EdgeInsets.only(bottom: 8),
                child: _EventCard(event: event),
              );
            },
          );
        },
      ),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.calendar_month_rounded,
            color: AppTheme.textDim,
            size: 48,
          ),
          const SizedBox(height: 12),
          Text(
            'No upcoming events',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Add companies to see earnings & dividends',
            style: GoogleFonts.inter(
              fontSize: 13,
              color: AppTheme.textDim,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Event Card — Full accordion version
// ---------------------------------------------------------------------------

class _EventCard extends ConsumerStatefulWidget {
  final CalendarEvent event;
  const _EventCard({required this.event});

  @override
  ConsumerState<_EventCard> createState() => _EventCardState();
}

class _EventCardState extends ConsumerState<_EventCard>
    with SingleTickerProviderStateMixin {
  bool _expanded = false;
  late AnimationController _animController;
  late Animation<double> _heightFactor;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _heightFactor = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() {
      _expanded = !_expanded;
      if (_expanded) {
        _animController.forward();
      } else {
        _animController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final e = widget.event;
    final isEarnings = e.type == 'earnings';

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          // Main card row (tappable)
          InkWell(
            onTap: _toggle,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  // Icon
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color:
                          (isEarnings ? AppTheme.accentBlue : AppTheme.shieldGreen)
                              .withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      isEarnings
                          ? Icons.bar_chart_rounded
                          : Icons.payments_rounded,
                      size: 20,
                      color: isEarnings
                          ? AppTheme.accentBlue
                          : AppTheme.shieldGreen,
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Ticker + Title + Date
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              e.symbol,
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                e.title,
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  color: AppTheme.textDim,
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
                              DateFormat('MMM d, yyyy').format(e.date),
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                color: AppTheme.textDim,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            if (e.hour != null) ...[
                              const SizedBox(width: 8),
                              _HourBadge(hour: e.hour!),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Type badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color:
                          (isEarnings ? AppTheme.accentBlue : AppTheme.shieldGreen)
                              .withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      isEarnings ? 'EAR' : 'DIV',
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: isEarnings
                            ? AppTheme.accentBlue
                            : AppTheme.shieldGreen,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  // Chevron
                  AnimatedRotation(
                    turns: _expanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 300),
                    child: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: AppTheme.textDim,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Expandable details
          SizeTransition(
            sizeFactor: _heightFactor,
            axisAlignment: -1.0,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.cardDark.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: isEarnings
                    ? _EarningsDetails(event: e)
                    : _DividendDetails(event: e),
              ),
            ),
          ),
        ],
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
        color = AppTheme.accentBlue;
        icon = Icons.wb_sunny_rounded;
      case 'amc':
        label = 'AMC';
        color = AppTheme.shieldYellow;
        icon = Icons.nights_stay_rounded;
      case 'dmh':
        label = 'DMH';
        color = AppTheme.shieldGreen;
        icon = Icons.business_center_rounded;
      default:
        label = hour.toUpperCase();
        color = AppTheme.textDim;
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

/// Human-readable description of the hour code.
String _hourDescription(String? hour) {
  switch (hour) {
    case 'bmo':
      return 'Before Market Open';
    case 'amc':
      return 'After Market Close';
    case 'dmh':
      return 'During Market Hours';
    default:
      return '';
  }
}

// ---------------------------------------------------------------------------
// Earnings Details
// ---------------------------------------------------------------------------

class _EarningsDetails extends StatelessWidget {
  final CalendarEvent event;
  const _EarningsDetails({required this.event});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (event.hour != null) ...[
          _DetailRow(
            label: 'Time',
            value: _hourDescription(event.hour),
          ),
          const SizedBox(height: 8),
        ],
        _DetailRow(
          label: 'EPS Estimate',
          value: event.epsEstimate != null ? '\$${event.epsEstimate}' : 'N/A',
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Dividend Details
// ---------------------------------------------------------------------------

class _DividendDetails extends StatelessWidget {
  final CalendarEvent event;
  const _DividendDetails({required this.event});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _DetailRow(
          label: 'Amount',
          value: event.amount != null
              ? '\$${event.amount!.toStringAsFixed(4)}'
              : 'N/A',
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Detail Row
// ---------------------------------------------------------------------------

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textDim),
        ),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}
