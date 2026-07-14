import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/theme/theme_v2.dart';

// ---------------------------------------------------------------------------
// CompanyLogo — Cached logo with CircleAvatar letter fallback
// ---------------------------------------------------------------------------
// Использует logoUrl из LogoCache (если есть) для отображения логотипа.
// Если logoUrl отсутствует — показывает первую букву названия в круге.
//
// Приоритет:
//   1. logoUrl (из LogoCache) → CachedNetworkImage
//   2. domain → Clearbit (logo.clearbit.com/$domain)
//   3. Ничего → первая буква ticker в CircleAvatar
// ---------------------------------------------------------------------------

class CompanyLogo extends StatelessWidget {
  final String ticker;
  final String? logoUrl;
  final String? domain;
  final double radius;

  const CompanyLogo({
    super.key,
    required this.ticker,
    this.logoUrl,
    this.domain,
    this.radius = 16,
  });

  /// Extracts the host domain from a company URL.
  /// e.g. "https://www.apple.com" → "apple.com"
  static String? extractDomain(String? weburl) {
    if (weburl == null || weburl.isEmpty) return null;
    try {
      final uri = Uri.parse(weburl);
      final host = uri.host;
      // Remove leading "www." if present
      if (host.startsWith('www.')) return host.substring(4);
      return host;
    } catch (_) {
      return null;
    }
  }

  /// Builds the Clearbit logo URL from a domain or ticker.
  static String? logoUrlFromDomain(String? domain, String ticker) {
    final effectiveDomain = domain ?? '${ticker.toLowerCase()}.com';
    if (effectiveDomain.isEmpty) return null;
    return 'https://logo.clearbit.com/$effectiveDomain';
  }

  @override
  Widget build(BuildContext context) {
    final initial = ticker.isNotEmpty ? ticker[0].toUpperCase() : '?';

    // Приоритет: явный logoUrl > Clearbit по domain
    final url = logoUrl ?? (domain != null ? 'https://logo.clearbit.com/$domain' : null);

    if (url != null) {
      return CachedNetworkImage(
        imageUrl: url,
        imageBuilder: (context, imageProvider) => CircleAvatar(
          radius: radius,
          backgroundColor: ThemeV2.surfaceDark,
          backgroundImage: imageProvider,
        ),
        placeholder: (context, url) => _buildPlaceholder(initial),
        errorWidget: (context, url, error) => _buildPlaceholder(initial),
        maxWidthDiskCache: (radius * 4).toInt(),
        maxHeightDiskCache: (radius * 4).toInt(),
      );
    }

    return _buildPlaceholder(initial);
  }

  Widget _buildPlaceholder(String initial) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: ThemeV2.surfaceDark,
      child: Text(
        initial,
        style: GoogleFonts.inter(
          color: ThemeV2.primary,
          fontWeight: FontWeight.w700,
          fontSize: radius > 16 ? 14 : 12,
        ),
      ),
    );
  }
}


