import 'package:flutter/material.dart';
import '../../core/theme/app_palette.dart';
import '../../core/theme/theme_v2.dart';

/// The single place that decides what colour fine-print/disclaimer text gets.
/// All three disclaimer widgets go through here so the treatment can't drift
/// apart between them again.
///
/// A theme that sets [AppPalette.disclaimerColor] wins outright. Everything
/// else — Standard, Luxury Gold and Midnight Sea, all of which put this text
/// on a near-black backdrop — gets [ThemeV2.textSecondary] at full opacity.
///
/// This used to be that same grey at 50% alpha, which composited to roughly
/// #4B4C4C on those backdrops: a contrast ratio around **2.3:1** at 9-10px,
/// far under the 4.5:1 floor for small text and genuinely hard to read
/// (measured 2026-09-26). Dropping the alpha keeps the intended muted-grey
/// look and lifts it to about **5.7:1**. Fine print is meant to be
/// understated, not unreadable — so don't push it to full white either.
Color resolveDisclaimerColor(AppPalette? palette) =>
    palette?.disclaimerColor ?? ThemeV2.textSecondary;
