import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/theme_v2.dart';
import '../../../core/theme/themed_button.dart';
import '../../../l10n/gen/app_localizations.dart';

// ---------------------------------------------------------------------------
// The four endings of a vacancy's own screen, in the order he described them
// (2026-10-10): save and cancel side by side, then delete and pause below.
//
// Save is asleep until something has actually changed -- a screen that was
// only looked at has nothing to save, and an enabled button there invites a
// pointless write.
//
// Its own file because the screen it serves is long enough already.
// ---------------------------------------------------------------------------

class VacancyActionButtons extends StatelessWidget {
  final AppPalette palette;
  final AppLocalizations l10n;
  final bool paused;
  final bool canSave;
  final bool busy;
  final VoidCallback onSave;
  final VoidCallback onCancel;
  final VoidCallback onDelete;
  final VoidCallback onTogglePause;

  const VacancyActionButtons({
    super.key,
    required this.palette,
    required this.l10n,
    required this.paused,
    required this.canSave,
    required this.busy,
    required this.onSave,
    required this.onCancel,
    required this.onDelete,
    required this.onTogglePause,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: brandCtaButton(
                palette: palette,
                label: l10n.etfVacancySaveButton,
                onTap: canSave ? onSave : null,
                busy: busy,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _outline(
                label: l10n.etfVacancyCancelButton,
                color: palette.textBody,
                onTap: busy ? null : onCancel,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _outline(
                label: l10n.etfVacancyDeleteButton,
                color: ThemeV2.loss,
                onTap: busy ? null : onDelete,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _outline(
                label: paused
                    ? l10n.etfVacancyResumeButton
                    : l10n.etfVacancyPauseButton,
                color: paused ? ThemeV2.success : palette.accentPrimary,
                onTap: busy ? null : onTogglePause,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// The app-wide OutlinedButton theme asks for an infinite width, which
  /// throws inside a Row -- see fomoshield_outlined_button_infinite_width.
  /// Every button here states its own size.
  Widget _outline({
    required String label,
    required Color color,
    required VoidCallback? onTap,
  }) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(0, 48),
        side: BorderSide(color: color.withValues(alpha: 0.6)),
        shape: RoundedRectangleBorder(borderRadius: ThemeV2.borderRadiusMedium),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}
