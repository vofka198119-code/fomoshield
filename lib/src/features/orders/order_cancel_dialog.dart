import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/theme_v2.dart';
import '../../l10n/gen/app_localizations.dart';

// ---------------------------------------------------------------------------
// Order Cancel Confirmation — plain AlertDialog (proven safe in this app,
// unlike custom Dialog content — see project_fomo_shield_target_dialog_
// invisible_bug memory). Shared by every place an active order can be
// cancelled. Yes/No rendered as two equal small buttons inside `content`
// rather than the default `actions` bar, which right-hugged them and left
// a large empty gap on the left.
// ---------------------------------------------------------------------------

Future<bool> confirmCancelOrder(BuildContext context) async {
  final l10n = AppLocalizations.of(context)!;
  final result = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: ThemeV2.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            l10n.orderCancelDialogTitle,
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: ThemeV2.textPrimary,
            ),
          ),
          GestureDetector(
            onTap: () => Navigator.pop(ctx, false),
            child: Icon(
              Icons.close_rounded,
              size: 20,
              color: ThemeV2.textSecondary,
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            l10n.orderCancelDialogBody,
            style: GoogleFonts.inter(
              fontSize: 13,
              color: ThemeV2.textSecondary,
            ),
          ),
          const SizedBox(height: 22),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: ThemeV2.textSecondary,
                    side: BorderSide(
                      color: ThemeV2.textSecondary.withValues(alpha: 0.35),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    l10n.orderCancelDialogNo,
                    style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ThemeV2.loss,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    l10n.orderCancelDialogYes,
                    style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
  return result ?? false;
}
