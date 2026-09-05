import 'package:flutter/material.dart';

// ---------------------------------------------------------------------------
// Graphite — reference color swatch. Replaces the earlier "Light Lime"
// placeholder (2026-09-06, full redesign per explicit user spec — off-white/
// lime abandoned entirely, not tuned). Full first pass, not yet device-
// confirmed — same "molecule by molecule" caveat every other theme's swatch
// carried before its own on-device polish pass.
// ---------------------------------------------------------------------------

/// Screen backdrop / darkest reference tone — "black as tar", matte (no
/// bright highlight layered on it, unlike the border gradient below).
const grTarBlack = Color(0xFF0A0A0B);

/// Screen backdrop gradient's lighter top stop — a little lighter than
/// [grTarBlack], same "light top, dark bottom" convention every other admin
/// theme's backdrop already uses.
const grBackgroundLight = Color(0xFF141416);

/// Card/widget gradient's darker (bottom) stop — a couple tones lighter than
/// [grTarBlack], per spec ("низ на пару тонов светлее от фона").
const grGraphiteBottom = Color(0xFF1C1C1F);

/// Card/widget gradient's lighter (top) stop — a bit lighter still than
/// [grGraphiteBottom], per spec ("сверху чуть светлее").
const grGraphiteTop = Color(0xFF26262A);

/// Pure white — body/header text, dial numerals, one end of every
/// white-steel gradient.
const grWhite = Colors.white;

/// Light steel gray — the other end of every white-steel gradient (borders,
/// title/icon sheen, Market Clock ring + hands).
const grSteel = Color(0xFFAEB4BD);

/// Deeper steel gray — border gradient's base (bottom) stop, so the
/// white→steel glint at the top doesn't wash out over the whole border.
const grSteelDark = Color(0xFF6B7078);
