import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/theme_v2.dart';
import '../../../core/theme/typography_helpers.dart';
import '../../portfolio/portfolio_providers.dart';

// ---------------------------------------------------------------------------
// Portfolio Goal Gauge — set a target value, ring fills + recolors as the
// portfolio approaches it.
// ---------------------------------------------------------------------------

class PortfolioGoalGauge extends ConsumerWidget {
  final String portfolioId;
  final double currentValue;

  const PortfolioGoalGauge({
    super.key,
    required this.portfolioId,
    required this.currentValue,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final portfolios = ref.watch(portfoliosProvider);
    final portfolio = portfolios.where((p) => p.id == portfolioId).firstOrNull;
    final goal = portfolio?.goalAmount;

    return GestureDetector(
      onTap: () => _showGoalSheet(context, ref, goal),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: ThemeV2.divider),
        ),
        child: goal == null || goal <= 0
            ? _emptyState()
            : _ringState(goal),
      ),
    );
  }

  Widget _emptyState() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.add_circle_outline_rounded,
          size: 26,
          color: ThemeV2.primary.withValues(alpha: 0.6),
        ),
        const SizedBox(height: 6),
        Text(
          'SET GOAL',
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.6,
            color: ThemeV2.primary,
          ),
        ),
      ],
    );
  }

  Widget _ringState(double goal) {
    final progress = (currentValue / goal).clamp(0.0, 1.0);
    final color = _progressColor(progress);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final size = math.min(
                constraints.maxWidth,
                constraints.maxHeight,
              );
              return Center(
                child: SizedBox(
                  width: size,
                  height: size,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CustomPaint(
                        size: Size(size, size),
                        painter: _GoalRingPainter(progress: progress),
                      ),
                      Text(
                        '${(progress * 100).round()}%',
                        style: interNums(
                          fontSize: size * 0.22,
                          fontWeight: FontWeight.w800,
                          color: color,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'GOAL',
          style: GoogleFonts.inter(
            fontSize: 9,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.6,
            color: ThemeV2.primary,
          ),
        ),
      ],
    );
  }

  static Color _progressColor(double progress) {
    if (progress < 0.5) {
      return Color.lerp(ThemeV2.loss, ThemeV2.warning, progress / 0.5)!;
    }
    return Color.lerp(ThemeV2.warning, ThemeV2.success, (progress - 0.5) / 0.5)!;
  }

  void _showGoalSheet(BuildContext context, WidgetRef ref, double? goal) {
    showModalBottomSheet(
      context: context,
      backgroundColor: ThemeV2.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => _GoalSheet(
        portfolioId: portfolioId,
        currentValue: currentValue,
        initialGoal: goal,
      ),
    );
  }
}

/// Full-circle progress ring: grey track + colored fill sweep from the top.
class _GoalRingPainter extends CustomPainter {
  final double progress; // 0..1

  _GoalRingPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 5;
    const strokeWidth = 6.0;

    final trackPaint = Paint()
      ..color = ThemeV2.divider
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, trackPaint);

    final sweepAngle = progress * 2 * math.pi;
    if (sweepAngle > 0) {
      final fillPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round
        ..color = PortfolioGoalGauge._progressColor(progress);
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2,
        sweepAngle,
        false,
        fillPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _GoalRingPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

// ---------------------------------------------------------------------------
// Goal-setting bottom sheet — slider + free-text ("17k") entry
// ---------------------------------------------------------------------------

class _GoalSheet extends ConsumerStatefulWidget {
  final String portfolioId;
  final double currentValue;
  final double? initialGoal;

  const _GoalSheet({
    required this.portfolioId,
    required this.currentValue,
    required this.initialGoal,
  });

  @override
  ConsumerState<_GoalSheet> createState() => _GoalSheetState();
}

class _GoalSheetState extends ConsumerState<_GoalSheet> {
  late double _sliderMax;
  late double _value;
  late TextEditingController _textController;

  @override
  void initState() {
    super.initState();
    final base = widget.initialGoal ?? (widget.currentValue * 2);
    _sliderMax = math.max(10000, (base * 2).ceilToDouble());
    _value = (widget.initialGoal ?? base).clamp(0, _sliderMax);
    _textController = TextEditingController(text: _formatAmount(_value));
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  String _formatAmount(double v) {
    if (v >= 1000) {
      final k = v / 1000;
      return k == k.roundToDouble()
          ? '${k.round()}k'
          : '${k.toStringAsFixed(1)}k';
    }
    return v.round().toString();
  }

  /// Parses free-text amounts like "17000", "17k", "17.5k", "$17,000".
  double? _parseAmount(String raw) {
    var text = raw.trim().toLowerCase().replaceAll(RegExp(r'[\$,\s]'), '');
    if (text.isEmpty) return null;
    double multiplier = 1;
    if (text.endsWith('k')) {
      multiplier = 1000;
      text = text.substring(0, text.length - 1);
    } else if (text.endsWith('m')) {
      multiplier = 1000000;
      text = text.substring(0, text.length - 1);
    }
    final parsed = double.tryParse(text);
    if (parsed == null) return null;
    return parsed * multiplier;
  }

  void _onSliderChanged(double v) {
    setState(() {
      _value = v;
      _textController.text = _formatAmount(v);
    });
  }

  void _onTextChanged(String raw) {
    final parsed = _parseAmount(raw);
    if (parsed == null || parsed <= 0) return;
    setState(() {
      _value = parsed.clamp(0, math.max(_sliderMax, parsed));
      if (_value > _sliderMax) _sliderMax = _value;
    });
  }

  void _save() {
    final parsed = _parseAmount(_textController.text) ?? _value;
    if (parsed <= 0) return;
    ref.read(portfoliosProvider.notifier).setGoal(widget.portfolioId, parsed);
    Navigator.pop(context);
  }

  void _removeGoal() {
    ref.read(portfoliosProvider.notifier).setGoal(widget.portfolioId, null);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              alignment: Alignment.center,
              margin: const EdgeInsets.only(bottom: 16),
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.black26,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Text(
              'Set a Goal',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: ThemeV2.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'What portfolio value are you aiming for?',
              style: GoogleFonts.inter(
                fontSize: 13,
                color: ThemeV2.textSecondary,
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _textController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9.kmKM]')),
              ],
              onChanged: _onTextChanged,
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: ThemeV2.textPrimary,
              ),
              decoration: InputDecoration(
                prefixText: '\$ ',
                prefixStyle: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: ThemeV2.textSecondary,
                ),
                hintText: 'e.g. 17k',
                filled: true,
                fillColor: ThemeV2.surfaceDark,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Slider(
              value: _value.clamp(0, _sliderMax),
              min: 0,
              max: _sliderMax,
              activeColor: ThemeV2.primary,
              onChanged: _onSliderChanged,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                if (widget.initialGoal != null)
                  TextButton(
                    onPressed: _removeGoal,
                    child: Text(
                      'Remove goal',
                      style: GoogleFonts.inter(
                        color: ThemeV2.loss,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                const Spacer(),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Cancel',
                    style: GoogleFonts.inter(color: ThemeV2.textSecondary),
                  ),
                ),
                const SizedBox(width: 4),
                ElevatedButton(
                  onPressed: _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ThemeV2.primary,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Save'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
