import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/fomo_shield_theme.dart';
import '../../../core/supabase/supabase_providers.dart'
    show myNicknameProvider, isAdminProvider, currentUserProvider;
import '../../../l10n/gen/app_localizations.dart';
import '../../../shared/widgets/admin_badge.dart';
import '../../../shared/widgets/dark_card_chip.dart';
import '../../../shared/widgets/card_frame.dart';
import '../../market_clock/market_clock_dial.dart'
    show darkCardDecoration, dialBrassLight;
import '../providers/fund_providers.dart';

// ---------------------------------------------------------------------------
// Name card — same visual pattern as Company Detail's own PriceHeader name
// card (price_header.dart): always-dark CardFrame, ring-bordered circular
// avatar on the left, name text to the right, a role chip below it (styled
// like PriceHeader's sector chip) with an ADMIN badge next to that chip for
// the hardcoded admin account. No real avatar upload yet (deferred
// 2026-09-10, moderation cost) — a plain person icon stands in. Shared by
// EmployeeProfileScreen and EmployeeHubScreen — factor any future change
// here once, not per call site.
//
// Purely visual — the admin-only rename-nickname/create-fund tools this
// card used to host inline moved to EmployeeHubScreen's own AppBar ⋮ menu
// (2026-09-11, matches Portfolio's header-actions-sheet convention rather
// than crowding icons into this card's name row).
// ---------------------------------------------------------------------------

class EmployeeIdentityCard extends ConsumerWidget {
  final AppPalette palette;

  const EmployeeIdentityCard({super.key, required this.palette});

  /// PriceHeader's own ring expression: the theme's market-clock accent,
  /// brass when it has none.
  Color get _ringColour => palette.marketClockAccent ?? dialBrassLight;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final isAdmin = ref.watch(isAdminProvider);
    final userId = ref.watch(currentUserProvider)?.id;
    final headsAFund =
        ref
            .watch(fundsListProvider)
            .valueOrNull
            ?.any((f) => f.headUserId == userId) ??
        false;
    final positionLabel = headsAFund
        ? l10n.etfPositionFundManager
        : l10n.etfPositionEmployee;

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
                // Brass, like PriceHeader's logo ring and the fund card's —
                // an accent-green ring on this dark green card is a green
                // line on green (2026-10-09).
                border: Border.all(color: _ringColour, width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: _ringColour.withValues(alpha: 0.35),
                    blurRadius: 6,
                  ),
                ],
              ),
              // windowGradient fill (same recipe as CircleShortcutRow's
              // own inner circle) when the theme defines one, instead of
              // a flat accentPrimary@15% tint — that flat tint is the
              // actual "dirty gray" culprit under Black & White (a
              // near-black accentPrimary blended at 15% into a white
              // card reads as a muddy flat gray, not a clean fill). The
              // ring's own glow above was already fine and untouched.
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: palette.windowGradient,
                  color: palette.windowGradient == null
                      ? palette.accentPrimary.withValues(alpha: 0.15)
                      : null,
                ),
                child: Icon(
                  Icons.person_rounded,
                  // Same brass as the ring around it.
                  color: _ringColour,
                  size: 32,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ref.watch(myNicknameProvider).valueOrNull ?? '—',
                    // Exactly PriceHeader's own companyName style
                    // (price_header.dart) — this card claims to mirror it
                    // (see file doc comment) but had drifted to 17/w700;
                    // matching it precisely, same as FundManagementScreen's
                    // name card below, fixes a same-day inconsistency
                    // between the two nearly-identical cards.
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: palette.onWindow ?? Colors.white,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      DarkCardChip(label: positionLabel, palette: palette),
                      if (isAdmin) ...[
                        const SizedBox(width: 6),
                        const AdminBadge(),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
