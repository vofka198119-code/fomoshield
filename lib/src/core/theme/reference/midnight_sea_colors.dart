import 'package:flutter/material.dart';

// ---------------------------------------------------------------------------
// Midnight Sea — reference color swatch. PLACEHOLDER, NOT LOCKED — first
// pass only, to be tuned against the Home screen the same way Luxury Gold
// was (background first, then border/text/card). Don't build the rest of
// the app against these values yet; they will move.
// ---------------------------------------------------------------------------

/// Primary background — deep navy.
const msNavy = Color(0xFF060B14);

/// Cards and blocks.
const msDeepBlue = Color(0xFF0F1A2A);

/// Borders and strokes.
const msSlateBlue = Color(0xFF223349);

/// Main accent / buttons / active icons — teal.
const msTeal = Color(0xFF2FB6A3);

/// Secondary accent / gradients — brighter aqua.
const msAqua = Color(0xFF5FD6C6);

/// Headers and accent text.
const msHeaderText = Color(0xFFE8EEF5);

/// Body text.
const msBodyText = Color(0xFF8CA0B3);

/// Background gradient — light top. REVISED (2026-09-01): "Navy" (was
/// "Sapphire"). Deliberately its own constant, separate from [msNavy]
/// (the flat background fallback) — that tone reads almost as dark as
/// [msGradientDark] itself, too close in value to work as this gradient's
/// light end.
const msGradientLight = Color(0xFF17284A);

/// Background gradient — dark bottom. "Obsidian" — same tone as Luxury
/// Gold's `darkObsidian`, reused here as its own named constant.
const msGradientDark = Color(0xFF0B0C0E);
