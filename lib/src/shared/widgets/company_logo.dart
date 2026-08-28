import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/cache/logo_providers.dart';
import '../../core/theme/theme_v2.dart';

// ---------------------------------------------------------------------------
// CompanyLogo — Cached logo with CircleAvatar letter fallback
// ---------------------------------------------------------------------------
// Использует logoUrl из LogoCache (если есть) для отображения логотипа.
// Если logoUrl отсутствует — показывает первую букву названия в круге.
//
// Приоритет:
//   1. logoUrl, если явно передан вызывающей стороной (обычно из
//      LogoDao/cachedLogoEntryProvider/quickLogoProvider — тикер уже
//      реально резолвился раньше).
//   2. Если resolveIfMissing (default true) — cachedLogoProvider(ticker).
//      Это НЕ прямой вызов Finnhub/Clearbit/FMP с клиента (раньше был
//      именно им) — это единственный сервер-бэкенд эндпоинт
//      /api/v1/icons/:symbol, который сам никогда синхронно не бьёт по
//      Finnhub (см. cachedLogoProvider's own doc comment и
//      scanco-backend's routes/icons.js). Ленты, список секторов,
//      карточки сделок и т.д. идут этим путём.
//   3. Ничего не резолвилось (или resolveIfMissing: false) — первая
//      буква ticker в CircleAvatar.
//
// resolveIfMissing: false — Watchlist/Portfolio Holdings передают его
// явно. Это per-user списки: если каждый ряд сам достукивается до
// нашего бэкенда за иконкой, стоимость масштабируется с числом
// пользователей, а не с каталогом (см. feedback_finnhub_cost_at_scale
// memory) — тот же принцип, что уже применён к их провайдерам
// (cachedLogoEntryProvider/quickLogoProvider остаются cache-only). Раньше
// это не имело значения, т.к. CompanyLogo сам строил FMP-URL бесплатно;
// теперь, когда фоллбэк ушёл на бэкенд, эти экраны должны явно
// отказаться от него.
// ---------------------------------------------------------------------------

class CompanyLogo extends ConsumerWidget {
  final String ticker;
  final String? logoUrl;
  final double radius;
  final bool resolveIfMissing;

  const CompanyLogo({
    super.key,
    required this.ticker,
    this.logoUrl,
    this.radius = 16,
    this.resolveIfMissing = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final initial = ticker.isNotEmpty ? ticker[0].toUpperCase() : '?';
    final url = logoUrl ??
        (resolveIfMissing
            ? ref.watch(cachedLogoProvider(ticker)).valueOrNull
            : null);

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


