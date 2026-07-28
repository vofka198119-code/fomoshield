import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/theme_v2.dart';
import '../../core/theme/fomo_shield_theme.dart';
import 'market_clock_dial.dart';
import 'market_clock_engine.dart';
import 'market_clock_widget_order_provider.dart';

class MarketClockScreen extends ConsumerStatefulWidget {
  const MarketClockScreen({super.key});

  @override
  ConsumerState<MarketClockScreen> createState() => _MarketClockScreenState();
}

class _MarketClockScreenState extends ConsumerState<MarketClockScreen> {
  late Timer _timer;
  late MarketClockState _state;

  @override
  void initState() {
    super.initState();
    _state = resolveMarketClockState(nowInNewYork());
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => _state = resolveMarketClockState(nowInNewYork()));
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _showWidgetsBottomSheet() {
    final notifier = ref.read(marketClockWidgetsProvider.notifier);
    final currentConfigs = ref.read(marketClockWidgetsProvider);

    showModalBottomSheet(
      context: context,
      backgroundColor: ThemeV2.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (sheetContext) {
        return _MarketClockWidgetsSettingsSheet(
          initialConfigs: currentConfigs,
          notifier: notifier,
        );
      },
    );
  }

  Widget _buildWidget(String id) {
    switch (id) {
      case 'ny_time':
        return _NewYorkTimeWidget(state: _state);
      case 'market_phase':
        return _MarketPhaseWidget(
          window: _state.window,
          isEarlyClose: _state.isEarlyCloseDay,
        );
      default:
        return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    final widgetConfigs = ref.watch(marketClockWidgetsProvider);
    final visibleWidgets = widgetConfigs.where((w) => w.visible).toList();

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        centerTitle: true,
        title: Text(
          'MARKET CLOCK',
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: ThemeV2.primary,
            letterSpacing: 1.5,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          children: [
            for (int i = 0; i < visibleWidgets.length; i++) ...[
              if (i > 0) const SizedBox(height: 24),
              KeyedSubtree(
                key: ValueKey(visibleWidgets[i].id),
                child: _buildWidget(visibleWidgets[i].id),
              ),
            ],
            const SizedBox(height: 24),
            // Add widgets button
            Center(
              child: TextButton.icon(
                onPressed: _showWidgetsBottomSheet,
                icon: const Icon(
                  Icons.add_rounded,
                  color: ThemeV2.primary,
                  size: 20,
                ),
                label: Text(
                  'Add widgets',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: ThemeV2.primary,
                  ),
                ),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                    side: const BorderSide(
                      color: ThemeV2.primary,
                      width: 0.5,
                    ),
                  ),
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
// New York Time widget (id: 'ny_time') — the instrument-panel dial + 4
// corner phase panels, unchanged instrument-panel look (dark card, own
// title bar) — this one is NOT restyled to the plain Home-card look, that
// dark dial aesthetic is deliberate (see Market Clock v1 memory).
// ---------------------------------------------------------------------------

class _NewYorkTimeWidget extends StatelessWidget {
  final MarketClockState state;
  const _NewYorkTimeWidget({required this.state});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: marketClockCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 14, 22, 14),
            child: Text(
              'NEW YORK TIME',
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: 1.2,
              ),
            ),
          ),
          Divider(
            height: 1,
            indent: 16,
            endIndent: 16,
            color: Colors.white.withValues(alpha: 0.1),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: LayoutBuilder(
              builder: (context, constraints) {
                return _MarketClockInstrumentPanel(
                    state: state, area: constraints.maxWidth);
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Instrument panel: central dial + 4 corner phase panels. Each panel's inner
// edge is clipped to a concave arc that hugs the dial's ring, so it nests
// into its corner instead of floating next to the circle as a plain
// rectangle — the empty corner space around the dial was otherwise unused.
// ---------------------------------------------------------------------------

enum _Corner { topLeft, topRight, bottomLeft, bottomRight }

class _MacroPhase {
  final MarketPhase phase;
  final IconData icon;
  final String label;
  final int start;
  final int end;
  const _MacroPhase({
    required this.phase,
    required this.icon,
    required this.label,
    required this.start,
    required this.end,
  });
}

/// Boundaries in ET minutes-of-day. `closed` deliberately wraps past
/// midnight (1200 → 240) — handled generically by the mod-1440 countdown
/// math below, same trick already used for the `closed` MarketWindow.
/// Note: unlike `resolveMarketClockState`, this ignores weekends/holidays —
/// on a non-trading day these countdowns still tick against the ordinary
/// daily cycle rather than the next actual trading day. Acceptable v1
/// simplification; revisit if it reads as wrong on a real weekend.
const _macroPhases = [
  _MacroPhase(
    phase: MarketPhase.preMarket,
    icon: Icons.wb_twilight,
    label: 'PRE-MARKET',
    start: 240,
    end: 570,
  ),
  _MacroPhase(
    phase: MarketPhase.marketOpen,
    icon: Icons.wb_sunny_rounded,
    label: 'MARKET OPEN',
    start: 570,
    end: 960,
  ),
  _MacroPhase(
    phase: MarketPhase.afterHours,
    icon: Icons.nightlight_round,
    label: 'AFTER HOURS',
    start: 960,
    end: 1200,
  ),
  _MacroPhase(
    phase: MarketPhase.closed,
    icon: Icons.bedtime_rounded,
    label: 'MARKET CLOSED',
    start: 1200,
    end: 240,
  ),
];

Color _macroPhaseColor(MarketPhase phase) {
  switch (phase) {
    case MarketPhase.preMarket:
      return dialBrassLight;
    case MarketPhase.marketOpen:
      return ThemeV2.success;
    case MarketPhase.afterHours:
      return const Color(0xFF5DA9E0);
    case MarketPhase.closed:
      return Colors.white;
  }
}

String _formatHm(int minutes) {
  final h = minutes ~/ 60;
  final m = minutes % 60;
  if (h == 0) return '${m}m';
  return '${h}h ${m.toString().padLeft(2, '0')}m';
}

class _MarketClockInstrumentPanel extends StatelessWidget {
  final MarketClockState state;
  final double area;
  const _MarketClockInstrumentPanel({required this.state, required this.area});

  @override
  Widget build(BuildContext context) {
    final panelSize = area / 2;
    final dialSize = area * 0.62;
    // True circle, radius matched tightly to the dial's own outer edge (incl.
    // ring stroke + glow) — every panel clips against this exact same circle,
    // so all 4 arcs are quarters of ONE circle and meet perfectly where they
    // border each other. (An earlier attempt stretched this into an ellipse
    // to create panel-to-panel gaps and it broke that: adjacent panels' arcs
    // no longer matched, meeting in a lens/"eye" shape instead of a smooth
    // curve — see conversation 2026-07-27.)
    final notchRadius = dialSize / 2 * 1.08;
    // Panel-to-panel gaps are a separate mechanism: shrink each panel's own
    // rectangular bounds away from the two centerlines.
    // hGap = gap between the LEFT-column and RIGHT-column panels (PRE-MARKET
    // vs MARKET OPEN at top, MARKET CLOSED vs AFTER HOURS at bottom) —
    // confirmed good as-is, don't touch.
    // vGap = gap between the TOP-row and BOTTOM-row panels on the same side
    // (PRE-MARKET vs MARKET CLOSED near 9 o'clock, MARKET OPEN vs AFTER
    // HOURS near 3 o'clock) — this one needed to grow.
    final hGap = panelSize * 0.14;
    final vGap = panelSize * 0.14;
    final panelW = panelSize - hGap;
    final panelH = panelSize - vGap;
    final nowMinute = state.nowEt.hour * 60 + state.nowEt.minute;

    Widget corner(_Corner c, _MacroPhase macro) {
      final duration = (macro.end - macro.start + 1440) % 1440;
      final elapsed = (nowMinute - macro.start + 1440) % 1440;
      final active = elapsed < duration;
      final remaining = active ? duration - elapsed : (macro.start - nowMinute + 1440) % 1440;
      return Positioned(
        top: (c == _Corner.topLeft || c == _Corner.topRight) ? 0 : null,
        bottom: (c == _Corner.bottomLeft || c == _Corner.bottomRight) ? 0 : null,
        left: (c == _Corner.topLeft || c == _Corner.bottomLeft) ? 0 : null,
        right: (c == _Corner.topRight || c == _Corner.bottomRight) ? 0 : null,
        width: panelW,
        height: panelH,
        child: _CornerPanel(
          corner: c,
          panelSize: panelSize,
          panelW: panelW,
          panelH: panelH,
          notchRadius: notchRadius,
          macro: macro,
          active: active,
          remainingMinutes: remaining,
        ),
      );
    }

    return SizedBox(
      width: area,
      height: area,
      child: Stack(
        children: [
          Center(child: MarketClockDial(state: state, size: dialSize, showDigitalReadout: true)),
          corner(_Corner.topLeft, _macroPhases[0]),
          corner(_Corner.topRight, _macroPhases[1]),
          corner(_Corner.bottomRight, _macroPhases[2]),
          corner(_Corner.bottomLeft, _macroPhases[3]),
        ],
      ),
    );
  }
}

class _CornerPanel extends StatelessWidget {
  final _Corner corner;
  final double panelSize;
  final double panelW;
  final double panelH;
  final double notchRadius;
  final _MacroPhase macro;
  final bool active;
  final int remainingMinutes;

  const _CornerPanel({
    required this.corner,
    required this.panelSize,
    required this.panelW,
    required this.panelH,
    required this.notchRadius,
    required this.macro,
    required this.active,
    required this.remainingMinutes,
  });

  // The notch circle sits at the true center of the whole instrument-panel
  // square (which is always (panelSize, panelSize) measured from this
  // panel's own outer-corner anchor, regardless of how much panelW/panelH
  // have been shrunk for the gap) — so shrinking the panel just moves its
  // own far edge away from that fixed point, without moving the circle.
  Offset get _notchCenter => switch (corner) {
        _Corner.topLeft => Offset(panelSize, panelSize),
        _Corner.topRight => Offset(panelW - panelSize, panelSize),
        _Corner.bottomLeft => Offset(panelSize, panelH - panelSize),
        _Corner.bottomRight => Offset(panelW - panelSize, panelH - panelSize),
      };

  Alignment get _contentAlignment => switch (corner) {
        _Corner.topLeft => Alignment.topLeft,
        _Corner.topRight => Alignment.topRight,
        _Corner.bottomLeft => Alignment.bottomLeft,
        _Corner.bottomRight => Alignment.bottomRight,
      };

  bool get _mirrored => corner == _Corner.bottomLeft || corner == _Corner.bottomRight;

  bool get _rightSide => corner == _Corner.topRight || corner == _Corner.bottomRight;

  @override
  Widget build(BuildContext context) {
    final accent = active ? _macroPhaseColor(macro.phase) : Colors.white.withValues(alpha: 0.4);

    final labelStyle = GoogleFonts.inter(
      fontSize: panelSize * 0.072,
      fontWeight: FontWeight.w700,
      color: accent,
      letterSpacing: 0.2,
    );
    final timerStyle = GoogleFonts.inter(
      fontSize: panelSize * 0.078,
      fontWeight: FontWeight.w700,
      color: dialIvory,
    );
    final timerString = active ? 'Ends ${_formatHm(remainingMinutes)}' : 'Starts ${_formatHm(remainingMinutes)}';

    // The notch only bites into the corner nearest the dial, so a thin band
    // along the panel's OUTER edge (top edge for top panels, bottom edge
    // for bottom panels) is clear almost all the way across — safe to use
    // most of panelSize as width, as long as the whole block stays short
    // (label line + timer line, each capped to 1 line so neither can ever
    // grow past the box and spill outside the panel).
    final labelRow = Text(macro.label, maxLines: 1, overflow: TextOverflow.ellipsis, style: labelStyle);
    final timerText = Text(timerString, maxLines: 1, overflow: TextOverflow.ellipsis, style: timerStyle);

    final spacer = SizedBox(height: panelSize * 0.03);

    // Calibrated on-device against a 24-point numbered grid (see
    // debugMarkers below) — user picked the midpoint between grid points 13
    // and 14, i.e. x≈17.5%, y≈65% of the panel, measured from its own
    // outer corner (mirrored for right-side / bottom panels).
    const xFraction = 0.175;
    const yFraction = 0.65;
    final iconAlignX = _rightSide ? -(2 * xFraction - 1) : (2 * xFraction - 1);
    final iconAlignY = _mirrored ? -(2 * yFraction - 1) : (2 * yFraction - 1);

    return SizedBox(
      width: panelW,
      height: panelH,
      child: Stack(
        children: [
          CustomPaint(
            size: Size(panelW, panelH),
            painter: _NotchedPanelPainter(
              corner: corner,
              notchCenter: _notchCenter,
              notchRadius: notchRadius,
              cornerRadius: panelSize * 0.16,
              borderColor: active
                  ? _macroPhaseColor(macro.phase).withValues(alpha: 0.7)
                  : dialBrassLight.withValues(alpha: 0.3),
              fillColor: active ? _macroPhaseColor(macro.phase).withValues(alpha: 0.1) : dialDark.withValues(alpha: 0.25),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(panelSize * 0.08),
            child: Align(
              alignment: _contentAlignment,
              child: SizedBox(
                width: panelW * 0.82,
                child: Column(
                  crossAxisAlignment: _rightSide ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: _mirrored
                      ? [timerText, spacer, labelRow]
                      : [labelRow, spacer, timerText],
                ),
              ),
            ),
          ),
          // Phase icon, detached from the header — calibrated position
          // (see comment above), mirrored per corner.
          Align(
            alignment: Alignment(iconAlignX, iconAlignY),
            child: Icon(macro.icon, size: panelSize * 0.15, color: accent),
          ),
        ],
      ),
    );
  }
}

/// Fills+strokes a rounded rect with a circular notch cut from the corner
/// nearest the dial, so the border traces the arc too (a plain
/// ClipPath+Container border would clip the straight edges but leave the
/// arc itself unbordered). Every panel clips against the exact same circle
/// (same absolute center + radius as the dial's own outer edge) so all 4
/// arcs are quarters of one circle and meet seamlessly — panel-to-panel
/// gaps come from shrinking the panel rectangle itself (see call site), not
/// from distorting this circle into an ellipse (that produced a mismatched
/// "eye" shape where adjacent panels met — see conversation 2026-07-27).
class _NotchedPanelPainter extends CustomPainter {
  final _Corner corner;
  final Offset notchCenter;
  final double notchRadius;
  final double cornerRadius;
  final Color borderColor;
  final Color fillColor;

  _NotchedPanelPainter({
    required this.corner,
    required this.notchCenter,
    required this.notchRadius,
    required this.cornerRadius,
    required this.borderColor,
    required this.fillColor,
  });

  Path _buildPath(Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final rrect = RRect.fromRectAndCorners(
      rect,
      topLeft: corner == _Corner.topLeft ? Radius.circular(cornerRadius) : Radius.zero,
      topRight: corner == _Corner.topRight ? Radius.circular(cornerRadius) : Radius.zero,
      bottomLeft: corner == _Corner.bottomLeft ? Radius.circular(cornerRadius) : Radius.zero,
      bottomRight: corner == _Corner.bottomRight ? Radius.circular(cornerRadius) : Radius.zero,
    );
    final rectPath = Path()..addRRect(rrect);
    final notchPath = Path()..addOval(Rect.fromCircle(center: notchCenter, radius: notchRadius));
    return Path.combine(PathOperation.difference, rectPath, notchPath);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final path = _buildPath(size);
    canvas.drawPath(path, Paint()..color = fillColor..style = PaintingStyle.fill);
    canvas.drawPath(
      path,
      Paint()
        ..color = borderColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4,
    );
  }

  @override
  bool shouldRepaint(covariant _NotchedPanelPainter oldDelegate) =>
      oldDelegate.borderColor != borderColor || oldDelegate.fillColor != fillColor;
}

// ---------------------------------------------------------------------------
// Market Phase widget (id: 'market_phase') — same Home-card look as every
// other widget on Home (title bar + divider via FomoShieldTheme), instead of
// the old plain surface box.
// ---------------------------------------------------------------------------

class _MarketPhaseWidget extends StatelessWidget {
  final MarketWindow window;
  final bool isEarlyClose;
  const _MarketPhaseWidget({required this.window, required this.isEarlyClose});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: FomoShieldTheme.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () => context.push('/market-clock/phases'),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(22, 14, 22, 14),
              child: Row(
                children: [
                  Text('MARKET PHASE', style: FomoShieldTheme.cardTitle()),
                  const Spacer(),
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: ThemeV2.textSecondary,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
          Divider(
            height: 1,
            indent: 16,
            endIndent: 16,
            color: Colors.black.withValues(alpha: 0.06),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(window.emoji, style: const TextStyle(fontSize: 18)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              window.shortHeadline,
                              style: GoogleFonts.inter(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: ThemeV2.textPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        window.shortDetail,
                        style: GoogleFonts.inter(fontSize: 13, color: ThemeV2.textSecondary),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        window.timeRangeLabel,
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: ThemeV2.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => context.push('/market-clock/period/${window.id}'),
                  icon: const Icon(Icons.help_outline_rounded, color: ThemeV2.primary),
                  tooltip: 'Details',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Widgets Settings BottomSheet — mirrors home_screen.dart's
// _WidgetsSettingsSheet (same reorder + visibility-toggle UI), scoped to
// this screen's own provider. No premium-lock concept yet since none of
// this screen's widgets are premium-gated.
// ---------------------------------------------------------------------------

class _MarketClockWidgetsSettingsSheet extends StatefulWidget {
  final List<MarketClockWidgetConfig> initialConfigs;
  final MarketClockWidgetsNotifier notifier;

  const _MarketClockWidgetsSettingsSheet({
    required this.initialConfigs,
    required this.notifier,
  });

  @override
  State<_MarketClockWidgetsSettingsSheet> createState() =>
      _MarketClockWidgetsSettingsSheetState();
}

class _MarketClockWidgetsSettingsSheetState
    extends State<_MarketClockWidgetsSettingsSheet> {
  late List<MarketClockWidgetConfig> _configs;

  @override
  void initState() {
    super.initState();
    _configs = List.from(widget.initialConfigs);
  }

  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      final item = _configs.removeAt(oldIndex);
      _configs.insert(newIndex, item);
    });
    widget.notifier.reorder(_configs[newIndex].id, newIndex);
  }

  void _toggleVisibility(String id) {
    setState(() {
      final index = _configs.indexWhere((c) => c.id == id);
      if (index >= 0) {
        final current = _configs[index];
        _configs[index] = MarketClockWidgetConfig(
          id: current.id,
          visible: !current.visible,
        );
      }
    });
    widget.notifier.toggleVisibility(id);
  }

  IconData _widgetIcon(String id) {
    switch (id) {
      case 'ny_time':
        return Icons.access_time_filled_rounded;
      case 'market_phase':
        return Icons.schedule_rounded;
      default:
        return Icons.widgets_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.black26,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              children: [
                Text(
                  'Widget Settings',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: ThemeV2.textPrimary,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    widget.notifier.resetToDefaults();
                    setState(() {
                      _configs = marketClockDefaultOrder
                          .map((id) =>
                              MarketClockWidgetConfig(id: id, visible: true))
                          .toList();
                    });
                  },
                  child: Text(
                    'Reset',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: ThemeV2.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          // Reorderable list
          Flexible(
            child: ReorderableListView.builder(
              shrinkWrap: true,
              itemCount: _configs.length,
              onReorderItem: _onReorder,
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              buildDefaultDragHandles: false,
              proxyDecorator: (child, index, animation) {
                return AnimatedBuilder(
                  animation: animation,
                  builder: (context, child) {
                    return Material(
                      color: Colors.transparent,
                      elevation: 4,
                      shadowColor: Colors.black45,
                      child: child!,
                    );
                  },
                  child: child,
                );
              },
              itemBuilder: (context, index) {
                final config = _configs[index];
                return Container(
                  key: ValueKey(config.id),
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: config.visible
                        ? ThemeV2.surfaceDark
                        : ThemeV2.surfaceDark.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: config.visible
                          ? Colors.black12
                          : Colors.black.withValues(alpha: 0.03),
                    ),
                  ),
                  child: ListTile(
                    key: ValueKey('${config.id}_tile'),
                    leading: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ReorderableDragStartListener(
                          index: index,
                          child: const Icon(
                            Icons.drag_handle_rounded,
                            color: ThemeV2.textSecondary,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          _widgetIcon(config.id),
                          color: config.visible
                              ? ThemeV2.primary
                              : ThemeV2.textSecondary,
                          size: 22,
                        ),
                      ],
                    ),
                    title: Text(
                      config.displayName,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: config.visible
                            ? ThemeV2.textPrimary
                            : ThemeV2.textSecondary,
                      ),
                    ),
                    trailing: Switch(
                      value: config.visible,
                      activeThumbColor: ThemeV2.primary,
                      onChanged: (_) => _toggleVisibility(config.id),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
