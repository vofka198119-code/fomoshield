import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/fomo_shield_theme.dart';
import '../../../core/supabase/supabase_providers.dart' show myNicknameProvider;
import '../../../shared/widgets/card_frame.dart';
import '../../market_clock/market_clock_dial.dart' show darkCardDecoration;

// ---------------------------------------------------------------------------
// Name card — same visual pattern as Company Detail's own PriceHeader name
// card (price_header.dart): always-dark CardFrame, ring-bordered circular
// avatar on the left, big name text to the right. No real avatar upload
// yet (deferred 2026-09-10, moderation cost) — a plain person icon stands
// in. Shared by EmployeeProfileScreen and EmployeeHubScreen — factor any
// future change here once, not per call site.
// ---------------------------------------------------------------------------

class EmployeeIdentityCard extends ConsumerWidget {
  final AppPalette palette;

  const EmployeeIdentityCard({super.key, required this.palette});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: CardFrame(
        padding: const EdgeInsets.all(FomoShieldTheme.cardPadding),
        decoration: palette.windowGradient != null
            ? BoxDecoration(
                gradient: palette.windowGradient,
                borderRadius: FomoShieldTheme.cardRadius,
                boxShadow: FomoShieldTheme.shadowSoft,
              )
            : darkCardDecoration(),
        palette: palette,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: palette.accentPrimary, width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: palette.accentPrimary.withValues(alpha: 0.35),
                    blurRadius: 6,
                  ),
                ],
              ),
              child: CircleAvatar(
                radius: 30,
                backgroundColor: palette.accentPrimary.withValues(alpha: 0.15),
                child: Icon(
                  Icons.person_rounded,
                  color: palette.accentPrimary,
                  size: 32,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                ref.watch(myNicknameProvider).valueOrNull ?? '—',
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: palette.onWindow ?? Colors.white,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
