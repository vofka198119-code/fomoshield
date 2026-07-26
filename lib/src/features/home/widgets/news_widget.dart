import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/theme_v2.dart';
import '../../../shared/widgets/widget_container.dart';

// ---------------------------------------------------------------------------
// News Widget — placeholder shell (no live news source wired up yet)
// ---------------------------------------------------------------------------

class NewsWidget extends StatelessWidget {
  const NewsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return WidgetContainer(
      title: 'NEWS',
      onTap: () => context.push('/market-clock'),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Center(
            child: Text(
              'Coming soon',
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: ThemeV2.textSecondary,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
