import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_palette.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../models/employee.dart';
import 'fund_form_fields.dart';
import 'team_member_permissions_sheet.dart' show roleLabelFor;

// ---------------------------------------------------------------------------
// Role picker — one field with a chevron that drops the four roles under it,
// most senior first (employeeRoles). His ask, 2026-10-10: "выбор должности в
// виде разворачивающегося окна справа с шевроном вниз... выбрал нужное и оно
// в окне" -- and the same control in both places it is needed, the invite
// sheet and the employee's own CV, which until now had a row of chips in one
// and a field in the other.
//
// Shared rather than copied: the two were already drifting, and a picker is
// exactly the kind of thing that ends up with two different behaviours.
// ---------------------------------------------------------------------------

class RolePickerField extends StatelessWidget {
  final AppPalette palette;
  final String? value;
  final ValueChanged<String> onChanged;

  /// Shown when nothing is picked yet. A CV may legitimately have no wish;
  /// an invite always carries a role, so its caller passes a value.
  final String? hint;

  const RolePickerField({
    super.key,
    required this.palette,
    required this.value,
    required this.onChanged,
    this.hint,
  });

  Future<void> _open(BuildContext fieldContext, AppLocalizations l10n) async {
    final box = fieldContext.findRenderObject() as RenderBox?;
    final overlay =
        Overlay.of(fieldContext).context.findRenderObject() as RenderBox?;
    if (box == null || overlay == null) return;
    // Anchored under the field itself, so the list opens where the eye
    // already is rather than in the middle of the screen.
    final position = RelativeRect.fromRect(
      Rect.fromPoints(
        box.localToGlobal(Offset(0, box.size.height), ancestor: overlay),
        box.localToGlobal(box.size.bottomRight(Offset.zero), ancestor: overlay),
      ),
      Offset.zero & overlay.size,
    );
    final selected = await showMenu<String>(
      context: fieldContext,
      position: position,
      color: palette.card,
      items: [
        for (final role in employeeRoles)
          PopupMenuItem<String>(
            value: role,
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    roleLabelFor(l10n, role),
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: role == value
                          ? FontWeight.w700
                          : FontWeight.w500,
                      color: role == value
                          ? palette.accentPrimary
                          : palette.textHeader,
                    ),
                  ),
                ),
                if (role == value)
                  Icon(
                    Icons.check_rounded,
                    size: 18,
                    color: palette.accentPrimary,
                  ),
              ],
            ),
          ),
      ],
    );
    if (selected != null) onChanged(selected);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final picked = value;
    return fundFieldWrapper(
      palette,
      Builder(
        builder: (fieldContext) => InkWell(
          onTap: () => _open(fieldContext, l10n),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    picked != null ? roleLabelFor(l10n, picked) : (hint ?? ''),
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: picked != null
                          ? palette.textHeader
                          : palette.textHeader.withValues(alpha: 0.5),
                    ),
                  ),
                ),
                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: palette.textBody,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
