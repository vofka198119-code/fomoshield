import 'package:flutter/material.dart';

// ---------------------------------------------------------------------------
// Black & White — reference color swatch. PLACEHOLDER, NOT LOCKED — first
// pass only, to be tuned against the Home screen the same way Luxury Gold
// was (background first, then border/text/card). Don't build the rest of
// the app against these values yet; they will move.
// ---------------------------------------------------------------------------

/// Primary background.
const bwBlack = Color(0xFF0C0C0D);

/// Cards and blocks.
const bwCharcoal = Color(0xFF18181A);

/// Borders and strokes.
const bwSlate = Color(0xFF2B2B2E);

/// Main accent / buttons / active icons — off-white, not pure white.
const bwWhite = Color(0xFFEDEDEF);

/// Secondary accent / gradients.
const bwSilver = Color(0xFFB8B8BC);

/// Headers and accent text.
const bwHeaderText = Color(0xFFF4F4F5);

/// Body text.
const bwBodyText = Color(0xFF9A9A9E);

/// Background gradient — light top. REVISED (2026-09-01): "Pearl White"
/// (was "Silver Grey") — same tone as Light Lime's [llGradientLight],
/// reused here as its own named constant.
const bwGradientLight = Color(0xFFF8F6F1);

/// Background gradient — dark corner (bottom-left). LOCKED IN (2026-09-01):
/// "Slate". Deliberately its own constant, separate from [bwSlate] (border
/// stroke) even though both read as slate-toned — different UI role.
const bwGradientDark = Color(0xFF2E343B);
