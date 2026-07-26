// ---------------------------------------------------------------------------
// Set Goal Screen — full-screen total-balance-goal input for the TARGET widget
// ---------------------------------------------------------------------------
// Pushed as a real route (not a showDialog/showModalBottomSheet overlay) —
// see project memory on the invisible-dialog bug: overlays in this app
// render zero-size content with no error, root cause never found. Normal
// pushed screens render fine everywhere else in the app, so that's what
// this uses.
// ---------------------------------------------------------------------------

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/theme_v2.dart';
import '../portfolio_providers.dart';

// Fallback only — normally the min goal is the portfolio's own
// startingBalance ($15k for the first portfolio, $50k for the 2nd/3rd).
const double _fallbackMinGoal = 15000;

class SetGoalScreen extends ConsumerStatefulWidget {
  final String portfolioId;

  const SetGoalScreen({super.key, required this.portfolioId});

  @override
  ConsumerState<SetGoalScreen> createState() => _SetGoalScreenState();
}

class _SetGoalScreenState extends ConsumerState<SetGoalScreen> {
  late final TextEditingController _controller;
  late final bool _isEditing;

  @override
  void initState() {
    super.initState();
    final portfolios = ref.read(portfoliosProvider);
    final portfolio = portfolios.where((p) => p.id == widget.portfolioId);
    final currentGoal = portfolio.isEmpty ? null : portfolio.first.goalAmount;
    _isEditing = currentGoal != null;
    _controller = TextEditingController(
      text: currentGoal != null ? currentGoal.toStringAsFixed(0) : '',
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double get _minGoal {
    final portfolios = ref.read(portfoliosProvider);
    final portfolio = portfolios.where((p) => p.id == widget.portfolioId);
    return portfolio.isEmpty ? _fallbackMinGoal : portfolio.first.startingBalance;
  }

  void _save() {
    final amount = double.tryParse(_controller.text);
    final minGoal = _minGoal;
    if (amount == null || amount < minGoal) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Minimum target is \$${minGoal.toStringAsFixed(0)}',
          ),
        ),
      );
      return;
    }
    ref.read(portfoliosProvider.notifier).setGoal(widget.portfolioId, amount);
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final minGoal = _minGoal;
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(
          _isEditing ? 'CHANGE GOAL' : 'SET GOAL',
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: ThemeV2.primary,
            letterSpacing: 1.5,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: ThemeV2.textPrimary),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'What total portfolio value do you want to reach?',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: ThemeV2.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'This is your target total balance, not extra profit on top. '
                'Minimum \$${minGoal.toStringAsFixed(0)}.',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: ThemeV2.textSecondary,
                ),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _controller,
                autofocus: true,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                ],
                style: GoogleFonts.inter(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: ThemeV2.textPrimary,
                ),
                decoration: InputDecoration(
                  prefixText: '\$ ',
                  prefixStyle: GoogleFonts.inter(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: ThemeV2.textPrimary,
                  ),
                  hintText: minGoal.toStringAsFixed(0),
                  hintStyle: GoogleFonts.inter(color: ThemeV2.textSecondary),
                  filled: true,
                  fillColor: ThemeV2.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: ThemeV2.divider),
                  ),
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: ThemeV2.buttonHeight,
                child: ElevatedButton(
                  onPressed: _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ThemeV2.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(ThemeV2.buttonRadius),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Save Goal',
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
