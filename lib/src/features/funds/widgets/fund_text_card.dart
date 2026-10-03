import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_palette.dart';
import '../../../shared/widgets/card_frame.dart';

class FundTextCard extends StatelessWidget {
  final String title;
  final String body;
  final AppPalette palette;

  const FundTextCard({
    super.key,
    required this.title,
    required this.body,
    required this.palette,
  });

  @override
  Widget build(BuildContext context) {
    return CardFrame(
      palette: palette,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: palette.textBody,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            body,
            style: GoogleFonts.inter(
              fontSize: 13,
              height: 1.5,
              color: palette.textHeader,
            ),
          ),
        ],
      ),
    );
  }
}
