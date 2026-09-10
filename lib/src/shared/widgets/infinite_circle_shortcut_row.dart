import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_palette.dart';

// ---------------------------------------------------------------------------
// Infinite horizontal circle-shortcut row — icon-in-a-ring + caption below,
// scrollable both directions with no start/end (wraps via index % length
// over a large virtual item count — Flutter has no circular ListView
// primitive, this is the standard trick for one). Takes a plain list of
// items rather than being hardcoded to any one screen's shortcuts, so any
// screen can reuse it — first user: EmployeeHubScreen (2026-09-10), per
// the author's own reference screenshot (a package-tracking app's
// Price/Point/Activity/Support row).
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

class InfiniteCircleShortcutRow extends StatefulWidget {
  final List<CircleShortcut> items;
  final AppPalette palette;

  const InfiniteCircleShortcutRow({
    super.key,
    required this.items,
    required this.palette,
  });

  @override
  State<InfiniteCircleShortcutRow> createState() =>
      _InfiniteCircleShortcutRowState();
}

class _InfiniteCircleShortcutRowState
    extends State<InfiniteCircleShortcutRow> {
  static const _virtualCount = 100000;
  static const _itemExtent = 108.0;
  late final ScrollController _controller;

  @override
  void initState() {
    super.initState();
    // Starts deep in the virtual range so the user can scroll either
    // direction for a very long time before ever hitting a real edge.
    final middleIndex =
        (_virtualCount ~/ 2) - ((_virtualCount ~/ 2) % widget.items.length);
    _controller = ScrollController(
      initialScrollOffset: middleIndex * _itemExtent,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty) return const SizedBox.shrink();
    final palette = widget.palette;
    return SizedBox(
      height: 124,
      child: ListView.builder(
        controller: _controller,
        scrollDirection: Axis.horizontal,
        itemExtent: _itemExtent,
        itemCount: _virtualCount,
        itemBuilder: (context, index) {
          final item = widget.items[index % widget.items.length];
          return InkWell(
            onTap: item.onTap,
            borderRadius: BorderRadius.circular(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: palette.accentPrimary.withValues(alpha: 0.15),
                  ),
                  child: Icon(
                    item.icon,
                    color: palette.accentPrimary,
                    size: 36,
                  ),
                ),
                const SizedBox(height: 8),
                _label(item.label, palette),
              ],
            ),
          );
        },
      ),
    );
  }

  // Exactly two words (e.g. "Мои приглашения") get one word per line,
  // centered, instead of leaving the wrap point to whatever fits — a
  // longer single label (a "(3)" count suffix, say) or a one-word label
  // falls back to normal wrapping/ellipsis.
  Widget _label(String label, AppPalette palette) {
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
