import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_palette.dart';

// ---------------------------------------------------------------------------
// Horizontal circle-shortcut row — icon-in-a-ring + caption below. Was
// InfiniteCircleShortcutRow (a virtual-item-count looping ListView) until
// 2026-09-11: the looping behavior was scrapped ("я погорячился", author's
// own words) in favor of a normal bounded scroll that stops at the real
// first/last item. Takes a plain list of items rather than being hardcoded
// to any one screen's shortcuts, so any screen can reuse it — first user:
// EmployeeHubScreen (2026-09-10).
// ---------------------------------------------------------------------------

class CircleShortcut {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const CircleShortcut({
    required this.icon,
    required this.label,
    required this.onTap,
  });
}

class CircleShortcutRow extends StatelessWidget {
  final List<CircleShortcut> items;
  final AppPalette palette;

  const CircleShortcutRow({
    super.key,
    required this.items,
    required this.palette,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();
    return SizedBox(
      height: 124,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemExtent: 108.0,
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return InkWell(
            onTap: item.onTap,
            borderRadius: BorderRadius.circular(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _ring(item.icon),
                const SizedBox(height: 8),
                _label(item.label),
              ],
            ),
          );
        },
      ),
    );
  }

  // Same gradient-border-ring + gradient-window-fill treatment as
  // CardFrame/themedBorder, adapted to a circle: an outer circle painted
  // with borderGradient (falls back to a plain 1px palette.border ring
  // when the theme has none) inset by 0.5, an inner circle filled with
  // windowGradient (or palette.card when the theme has no gradient).
  Widget _ring(IconData icon) {
    final borderGradient = palette.borderGradient;
    final inner = Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: palette.windowGradient,
        color: palette.windowGradient == null ? palette.card : null,
        border: borderGradient == null
            ? Border.all(color: palette.border, width: 1)
            : null,
      ),
      child: Icon(icon, color: palette.accentPrimary, size: 36),
    );
    if (borderGradient == null) return inner;
    return Container(
      padding: const EdgeInsets.all(1.5),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: borderGradient,
        boxShadow: [if (palette.cardGlow != null) palette.cardGlow!],
      ),
      child: inner,
    );
  }

  // Exactly two words (e.g. "Мои приглашения") get one word per line,
  // centered, instead of leaving the wrap point to whatever fits — a
  // longer single label (a "(3)" count suffix, say) or a one-word label
  // falls back to normal wrapping/ellipsis.
  Widget _label(String label) {
    final style = GoogleFonts.inter(
      fontSize: 12,
      fontWeight: FontWeight.w600,
      color: palette.textBody,
      height: 1.2,
    );
    final words = label.split(' ');
    if (words.length == 2) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(words[0], textAlign: TextAlign.center, style: style),
          Text(words[1], textAlign: TextAlign.center, style: style),
        ],
      );
    }
    return Text(
      label,
      textAlign: TextAlign.center,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: style,
    );
  }
}
