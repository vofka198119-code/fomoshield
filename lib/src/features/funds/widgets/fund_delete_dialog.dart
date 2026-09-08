import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/theme_v2.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../providers/fund_providers.dart';

// ---------------------------------------------------------------------------
// Two-step delete confirmation for a fund's own head. Simple delete for now
// (no investor payout — Phase 1 has nowhere to credit proceeds to, see
// fundService.deleteFund's own comment); the full bankruptcy flow is
// Phase 8, see fomoshield_etf_bankruptcy_flow_spec memory.
// ---------------------------------------------------------------------------

Future<void> showFundDeleteFlow(
  BuildContext context,
  WidgetRef ref,
  String fundId,
  AppPalette palette,
) async {
  final l10n = AppLocalizations.of(context)!;
  final step1 = await _confirm(
    context,
    palette,
    title: l10n.etfFundDeleteConfirmTitle,
    body: l10n.etfFundDeleteConfirmBody,
    confirmLabel: l10n.etfFundDeleteConfirmYes,
    l10n: l10n,
  );
  if (step1 != true || !context.mounted) return;

  final step2 = await _confirm(
    context,
    palette,
    title: l10n.etfFundDeleteFinalTitle,
    body: l10n.etfFundDeleteFinalBody,
    confirmLabel: l10n.etfFundDeleteFinalConfirm,
    destructive: true,
    l10n: l10n,
  );
  if (step2 != true || !context.mounted) return;

  try {
    await ref.read(fundApiServiceProvider).deleteFund(fundId);
    ref.invalidate(fundsListProvider);
    if (!context.mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l10n.etfFundDeleteSuccess)));
    Navigator.of(context).pop();
  } catch (_) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.etfCreateFundErrorGeneric),
        backgroundColor: ThemeV2.loss,
      ),
    );
  }
}

Future<bool?> _confirm(
  BuildContext context,
  AppPalette palette, {
  required String title,
  required String body,
  required String confirmLabel,
  required AppLocalizations l10n,
  bool destructive = false,
}) {
  return showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: palette.card,
      title: Text(
        title,
        style: GoogleFonts.inter(
          fontWeight: FontWeight.w700,
          color: palette.textHeader,
        ),
      ),
      content: Text(
        body,
        style: GoogleFonts.inter(fontSize: 13, color: palette.textBody),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: Text(
            l10n.profileCancel,
            style: GoogleFonts.inter(color: palette.textBody),
          ),
        ),
        TextButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: Text(
            confirmLabel,
            style: GoogleFonts.inter(
              color: destructive ? ThemeV2.loss : palette.accentPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    ),
  );
}
