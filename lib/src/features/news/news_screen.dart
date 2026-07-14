import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';

class NewsScreen extends ConsumerWidget {
  const NewsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: Text('News', style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w800, color: AppTheme.accentBlue, letterSpacing: 1.5))),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.newspaper_rounded, color: AppTheme.textDim, size: 64),
              const SizedBox(height: 16),
              Text(
                'No news yet',
                style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
              ),
              const SizedBox(height: 8),
              Text(
                'Add companies to your watchlist to see\nrelevant news',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(fontSize: 14, color: AppTheme.textDim, height: 1.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
