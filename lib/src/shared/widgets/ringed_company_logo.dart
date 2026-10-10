import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/cache/logo_providers.dart';
import '../../core/theme/app_palette.dart';
import 'company_logo.dart';

// ---------------------------------------------------------------------------
// A company's logo inside the accent ring — the way every list of companies
// in this app draws one (the proposal cards' own recipe).
//
// Shared because it was already being hand-copied: the proposal card, the
// proposal list tile and then the rebalance list each wrote out the same
// Container-border-ClipOval-CompanyLogo stack, and the rebalance one shipped
// without the ring at all because it was written from memory rather than from
// the original (2026-10-10).
//
// Cache-only by default: these appear in lists of forty, and every company in
// them is already on the fund's own screens, so there is nothing here worth
// forty fresh network lookups.
// ---------------------------------------------------------------------------

class RingedCompanyLogo extends ConsumerWidget {
  final String symbol;
  final AppPalette palette;

  /// Diameter of the logo itself; the ring adds 2px of padding around it.
  final double size;

  /// The ring's colour. Defaults to the theme accent, which is right on a
  /// light card. On a dark card pass the brass the fund and employee cards
  /// use, or the accent disappears into the background.
  final Color? ringColour;

  const RingedCompanyLogo({
    super.key,
    required this.symbol,
    required this.palette,
    this.size = 32,
    this.ringColour,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logoUrl = ref.watch(cachedLogoProvider(symbol)).valueOrNull;
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: ringColour ?? palette.accentPrimary,
          width: 1.5,
        ),
      ),
      child: ClipOval(
        child: SizedBox(
          width: size,
          height: size,
          child: CompanyLogo(
            ticker: symbol,
            logoUrl: logoUrl,
            radius: size / 2,
            resolveIfMissing: false,
          ),
        ),
      ),
    );
  }
}
