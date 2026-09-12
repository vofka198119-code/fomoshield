import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/fomo_shield_theme.dart';
import '../../../core/theme/theme_v2.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/theme_variant_provider.dart';
import '../../../core/theme/themed_header.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../../shared/widgets/card_frame.dart';
import '../models/employee.dart';
import '../providers/employee_providers.dart';

// ---------------------------------------------------------------------------
// Employment Detail — one fund stint: period worked, how it ended
// (resigned/terminated), and — only while still active — a self-service
// "leave this fund" action (the only voluntary-departure path; a head can
// only fire, via the 5-day-notice flow on FundManagementScreen).
// ---------------------------------------------------------------------------

class EmploymentDetailScreen extends ConsumerStatefulWidget {
  final EmploymentRecord record;

  const EmploymentDetailScreen({super.key, required this.record});

  @override
  ConsumerState<EmploymentDetailScreen> createState() =>
      _EmploymentDetailScreenState();
}

class _EmploymentDetailScreenState
    extends ConsumerState<EmploymentDetailScreen> {
  bool _leaving = false;

  String _roleLabel(AppLocalizations l10n, String role) {
    switch (role) {
      case 'co_manager':
        return l10n.etfRoleCoManager;
      case 'trader':
        return l10n.etfRoleTrader;
      case 'risk_manager':
        return l10n.etfRoleRiskManager;
      default:
        return l10n.etfRoleAnalyst;
    }
  }

  String _statusLabel(AppLocalizations l10n) {
    if (widget.record.isActive) return l10n.etfEmploymentDetailStatusActive;
    return widget.record.leaveType == 'resigned'
        ? l10n.etfEmploymentDetailStatusResigned
        : l10n.etfEmploymentDetailStatusTerminated;
  }

  Color _statusColor() {
    if (widget.record.isActive) return ThemeV2.success;
    return widget.record.leaveType == 'resigned'
        ? ThemeV2.warning
        : ThemeV2.loss;
  }

  Future<void> _confirmLeave(AppPalette palette, AppLocalizations l10n) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.etfEmploymentDetailLeaveConfirmTitle),
        content: Text(l10n.etfEmploymentDetailLeaveConfirmBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(
              MaterialLocalizations.of(dialogContext).cancelButtonLabel,
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(
              l10n.etfEmploymentDetailLeaveButton,
              style: const TextStyle(color: ThemeV2.loss),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _leaving = true);
    try {
      await ref
          .read(employeeApiServiceProvider)
          .leaveFund(widget.record.fundId);
      ref.invalidate(myEmploymentHistoryProvider);
      if (!mounted) return;
      Navigator.of(context).pop();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.etfEmploymentDetailLeaveError),
          backgroundColor: ThemeV2.loss,
        ),
      );
    } finally {
      if (mounted) setState(() => _leaving = false);
    }
  }

  Widget _row(AppPalette palette, String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(fontSize: 13, color: palette.textBody),
        ),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: palette.textHeader,
          ),
        ),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final palette = resolveAppPalette(ref.watch(themeVariantProvider));
    final locale = Localizations.localeOf(context).languageCode;
    final dateFormat = DateFormat.yMMMd(locale);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        centerTitle: true,
        leading: themedBackButton(context, palette, size: 22),
        title: themedHeaderText(
          l10n.etfEmploymentDetailTitle,
          palette,
          GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            letterSpacing: 1,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CardFrame(
                decoration: FomoShieldTheme.cardDecoration,
                palette: palette,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: palette.accentPrimary.withValues(
                                alpha: 0.3,
                              ),
                              width: 1.5,
                            ),
                          ),
                          padding: const EdgeInsets.all(2),
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: palette.windowGradient,
                              color: palette.windowGradient == null
                                  ? palette.accentPrimary.withValues(
                                      alpha: 0.15,
                                    )
                                  : null,
                            ),
                            child: Icon(
                              Icons.account_balance_rounded,
                              color: palette.accentPrimary,
                              size: 20,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.record.fundName ??
                                    widget.record.fundTicker ??
                                    '—',
                                style: GoogleFonts.inter(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: palette.textHeader,
                                ),
                              ),
                              Text(
                                widget.record.fundTicker ?? '',
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  color: palette.textBody,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: _statusColor().withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            _statusLabel(l10n),
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: _statusColor(),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _row(
                      palette,
                      l10n.etfEmployeeProfileDesiredRoleLabel,
                      _roleLabel(l10n, widget.record.role),
                    ),
                    _row(
                      palette,
                      l10n.etfEmploymentDetailJoinedLabel,
                      dateFormat.format(widget.record.joinedAt.toLocal()),
                    ),
                    if (widget.record.leftAt != null)
                      _row(
                        palette,
                        l10n.etfEmploymentDetailLeftLabel,
                        dateFormat.format(widget.record.leftAt!.toLocal()),
                      ),
                  ],
                ),
              ),
              if (widget.record.isActive) ...[
                const SizedBox(height: 20),
                SizedBox(
                  height: ThemeV2.buttonHeight,
                  child: OutlinedButton(
                    onPressed: _leaving ? null : () => _confirmLeave(palette, l10n),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: ThemeV2.loss),
                    ),
                    child: _leaving
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: ThemeV2.loss,
                            ),
                          )
                        : Text(
                            l10n.etfEmploymentDetailLeaveButton,
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.w600,
                              color: ThemeV2.loss,
                            ),
                          ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
