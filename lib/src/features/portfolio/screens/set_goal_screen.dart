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
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/models/app_notification.dart';
import '../../../core/overlay/app_notification_popup.dart';
import '../../../core/theme/theme_v2.dart';
import '../../../core/theme/typography_helpers.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../../shared/utils/currency_format.dart';
import '../../../shared/widgets/numeric_keypad.dart';
import '../../../core/supabase/supabase_providers.dart';
import '../portfolio_limits_provider.dart';
import '../portfolio_providers.dart';

class SetGoalScreen extends ConsumerStatefulWidget {
  final String portfolioId;

  const SetGoalScreen({super.key, required this.portfolioId});

  @override
  ConsumerState<SetGoalScreen> createState() => _SetGoalScreenState();
}

class _SetGoalScreenState extends ConsumerState<SetGoalScreen> {
  late final TextEditingController _controller;
  late bool _isEditing;
  double? _previousGoal;
  bool _keypadOpen = false;

  @override
  void initState() {
    super.initState();
    final portfolios = ref.read(portfoliosProvider);
    final portfolio = portfolios.where((p) => p.id == widget.portfolioId);
    final currentGoal = portfolio.isEmpty ? null : portfolio.first.goalAmount;
    _isEditing = currentGoal != null;
    _previousGoal = currentGoal;
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
    if (portfolio.isNotEmpty) return portfolio.first.startingBalance;
    // Fallback only — portfolio not found is an edge case that shouldn't
    // happen in practice; falls back to this tier's own starting capital.
    return startingCapitalForTier(ref.read(subscriptionTierProvider));
  }

  void _save() {
    final l10n = AppLocalizations.of(context)!;
    final amount = double.tryParse(_controller.text);
    final minGoal = _minGoal;
    if (amount == null || amount < minGoal) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            l10n.setGoalScreenMinimumTargetError(formatUsd(minGoal)),
          ),
        ),
      );
      return;
    }
    ref.read(portfoliosProvider.notifier).setGoal(widget.portfolioId, amount);

    final previous = _previousGoal;
    showTransientAppNotificationPopup(
      AppNotification(
        id: 'notif_${DateTime.now().microsecondsSinceEpoch}',
        type: AppNotificationType.goalUpdated,
        portfolioKind: NotificationPortfolioKind.real,
        portfolioId: widget.portfolioId,
        title: previous == null
            ? l10n.setGoalScreenNotifTitleSet
            : l10n.setGoalScreenNotifTitleUpdated,
        detail: previous == null
            ? l10n.setGoalScreenNotifDetailSet(formatUsd(amount))
            : l10n.setGoalScreenNotifDetailUpdated(
                formatUsd(amount),
                formatUsdSigned(amount - previous),
              ),
        createdAt: DateTime.now(),
      ),
    );

    setState(() {
      _previousGoal = amount;
      _isEditing = true;
      _keypadOpen = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final minGoal = _minGoal;
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(
          _isEditing
              ? l10n.setGoalScreenTitleChange
              : l10n.setGoalScreenTitleSet,
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: ThemeV2.primary,
            letterSpacing: 1.5,
          ),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: ThemeV2.textPrimary,
          ),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.setGoalScreenPrompt,
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: ThemeV2.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      l10n.setGoalScreenSubtitle(formatUsd(minGoal)),
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: ThemeV2.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 24),
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => setState(() => _keypadOpen = true),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          color: ThemeV2.surface,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: ThemeV2.divider),
                        ),
                        child: Text(
                          _controller.text.isEmpty
                              ? '\$ ${minGoal.toStringAsFixed(0)}'
                              : '\$ ${_controller.text}',
                          style: interNums(
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                            color: _controller.text.isEmpty
                                ? ThemeV2.textSecondary
                                : ThemeV2.textPrimary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (_keypadOpen)
              NumericKeypad(
                controller: _controller,
                onChanged: () => setState(() {}),
                onDone: () => setState(() => _keypadOpen = false),
                header: _saveButton(height: 44),
              )
            else
              Padding(
                padding: const EdgeInsets.all(22),
                child: _saveButton(height: ThemeV2.buttonHeight),
              ),
          ],
        ),
      ),
    );
  }

  Widget _saveButton({required double height}) {
    return SizedBox(
      width: double.infinity,
      height: height,
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
          AppLocalizations.of(context)!.setGoalScreenSaveButton,
          style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}
