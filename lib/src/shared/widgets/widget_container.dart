import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/theme_v2.dart';
import 'card_frame.dart';

// ---------------------------------------------------------------------------
// Widget Container — Card wrapper in Revolut style
// ---------------------------------------------------------------------------
// Renders a titled card with a chevron header, compact item list,
// thin dividers between items, and a "More" footer button.
// ---------------------------------------------------------------------------

class WidgetContainer extends StatelessWidget {
  final String title;
  final VoidCallback onTap;
  final List<Widget> children;
  final String footerText;
  final bool showFooter;
  final String? emptyText;

  const WidgetContainer({
    super.key,
    required this.title,
    required this.onTap,
    this.children = const [],
    this.footerText = 'More',
    this.showFooter = true,
    this.emptyText,
  });

  @override
  Widget build(BuildContext context) {
    return CardFrame(
      showTopBar: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- Header ---
          InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(22),
              child: Row(
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    color: ThemeV2.primary,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: ThemeV2.textSecondary,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),

          // --- Items with thin dividers (indented) ---
          if (children.isNotEmpty)
            ...List.generate(children.length * 2 - 1, (i) {
              if (i.isOdd) {
                return Divider(
                  height: 1,
                  indent: 16,
                  endIndent: 16,
                  color: Colors.black.withValues(alpha: 0.06),
                );
              }
              return children[i ~/ 2];
            }),

          // --- Footer "More" button ---
          if (children.isNotEmpty && showFooter)
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: Colors.black.withValues(alpha: 0.06),
                  ),
                ),
              ),
              child: InkWell(
                onTap: onTap,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Center(
                    child: Text(
                      footerText,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: ThemeV2.primary,
                      ),
                    ),
                  ),
                ),
              ),
            ),

          // --- Empty state fallback ---
          if (children.isEmpty && emptyText != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
              child: Center(
                child: Text(
                  emptyText!,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: ThemeV2.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

