import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/theme_v2.dart';
import '../../../core/theme/themed_divider.dart';
import '../../../core/theme/typography_helpers.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../../shared/utils/currency_format.dart';
import '../models/fund_bankruptcy_preview.dart';
import '../providers/fund_providers.dart';
import '../services/fund_api_service.dart' show FundApiException;

// ---------------------------------------------------------------------------
// Fund Bankruptcy Flow — replaces the old plain-delete AlertDialog stub
// (fomoshield_etf_bankruptcy_flow_spec memory) now that a real liquidation
// engine exists server-side. Two themed bottom sheets instead of
// AlertDialog (explicit ask, 2026-09-14: "красивые окна а не шаблонные
// фигни посреди экрана"), same drag-handle/rounded-top chrome as
// order_confirmation_sheet.dart. Step 2 fetches a live payout preview so
// the explanation screen shows real numbers, not just prose.
// ---------------------------------------------------------------------------

Future<void> showFundBankruptcyFlow(
  BuildContext context,
  WidgetRef ref,
  String fundId,
  AppPalette palette,
) async {
  final l10n = AppLocalizations.of(context)!;

  final step1 = await _showSimpleConfirmSheet(
    context: context,
    palette: palette,
    title: l10n.etfFundBankruptcyStep1Title,
    confirmLabel: l10n.etfFundBankruptcyStep1Confirm,
    cancelLabel: l10n.etfFundBankruptcyCancelButton,
  );
  if (step1 != true || !context.mounted) return;

  FundBankruptcyPreview preview;
  try {
    preview = await ref.read(fundApiServiceProvider).previewBankruptcy(fundId);
  } catch (_) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.etfFundBankruptcyPreviewErrorMessage),
        backgroundColor: ThemeV2.loss,
      ),
    );
    return;
  }
  if (!context.mounted) return;

  final step2 = await showModalBottomSheet<bool>(
    context: context,
    backgroundColor: palette.card,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) =>
        _BankruptcyExplanationSheet(preview: preview, palette: palette),
  );
  if (step2 != true || !context.mounted) return;

  try {
    await ref.read(fundApiServiceProvider).triggerBankruptcy(fundId);
    ref.invalidate(fundsListProvider);
    ref.invalidate(fundDetailProvider(fundId));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.etfFundBankruptcySuccessMessage)),
    );
    Navigator.of(context).pop();
  } on FundApiException catch (e) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(e.message), backgroundColor: ThemeV2.loss),
    );
  } catch (_) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.etfFundBankruptcyErrorMessage),
        backgroundColor: ThemeV2.loss,
      ),
    );
  }
}

Future<bool?> _showSimpleConfirmSheet({
  required BuildContext context,
  required AppPalette palette,
  required String title,
  required String confirmLabel,
  required String cancelLabel,
}) {
  return showModalBottomSheet<bool>(
    context: context,
    backgroundColor: palette.card,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) => SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: palette.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: palette.textHeader,
              ),
            ),
            const SizedBox(height: 22),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(ctx, false),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: Text(
                      cancelLabel,
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: palette.textBody,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SizedBox(
                    height: 50,
                    child: FilledButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      style: FilledButton.styleFrom(
                        backgroundColor: palette.accentPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        confirmLabel,
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

class _BankruptcyExplanationSheet extends StatelessWidget {
  final FundBankruptcyPreview preview;
  final AppPalette palette;

  const _BankruptcyExplanationSheet({
    required this.preview,
    required this.palette,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          20,
          20,
          20 + MediaQuery.of(context).viewInsets.bottom,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: palette.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                l10n.etfFundBankruptcyExplanationTitle,
                style: GoogleFonts.inter(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: palette.textHeader,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                l10n.etfFundBankruptcyExplanationBody,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  height: 1.45,
                  color: palette.textBody,
                ),
              ),
              const SizedBox(height: 18),
              themedDivider(palette, indent: 0, endIndent: 0, height: 1),
              const SizedBox(height: 14),
              _row(
                l10n.etfFundBankruptcyHoldingsLabel,
                formatUsd(preview.holdingsValue),
              ),
              _row(
                l10n.etfFundBankruptcyCommissionLabel,
                formatUsd(preview.brokerCommission),
              ),
              if (preview.employeeCount > 0)
                _row(
                  l10n.etfFundBankruptcyEmployeesLabel(preview.employeeCount),
                  formatUsd(preview.totalEmployeePayout),
                ),
              _row(
                l10n.etfFundBankruptcyInvestorsLabel,
                formatUsd(preview.totalInvestorPayout),
                note: preview.solvent
                    ? l10n.etfFundBankruptcySolventNote
                    : l10n.etfFundBankruptcyInsolventNote,
                noteColor: preview.solvent ? ThemeV2.success : ThemeV2.loss,
              ),
              const SizedBox(height: 4),
              themedDivider(palette, indent: 0, endIndent: 0, height: 1),
              const SizedBox(height: 10),
              _row(
                l10n.etfFundBankruptcyTotalLabel,
                formatUsd(preview.totalPayout),
                emphasize: true,
              ),
              const SizedBox(height: 22),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: Text(
                        l10n.etfFundBankruptcyCancelButton,
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: palette.textBody,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: SizedBox(
                      height: 50,
                      child: FilledButton(
                        onPressed: () => Navigator.pop(context, true),
                        style: FilledButton.styleFrom(
                          backgroundColor: ThemeV2.loss,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          l10n.etfFundBankruptcyConfirmButton,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _row(
    String label,
    String value, {
    bool emphasize = false,
    String? note,
    Color? noteColor,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: emphasize ? 14 : 13,
                  fontWeight: emphasize ? FontWeight.w700 : FontWeight.w400,
                  color: emphasize ? palette.textHeader : palette.textBody,
                ),
              ),
              Text(
                value,
                style: interNums(
                  fontSize: emphasize ? 16 : 14,
                  fontWeight: FontWeight.w700,
                  color: emphasize ? palette.accentPrimary : palette.textHeader,
                ),
              ),
            ],
          ),
          if (note != null)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                note,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: noteColor ?? palette.textBody,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
