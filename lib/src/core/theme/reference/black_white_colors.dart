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

/// Background gradient — light top. REVISED (2026-09-05): lightened one
/// 8%-lightness HSL stop from "Pearl White" (#F8F6F1) to fix a contrast
/// bug (near-black text on the gradient's dark end was unreadable) — the
/// step pushes this value to pure white regardless of stop size, since
/// Pearl White was already at 95.9% lightness.
const bwGradientLight = Color(0xFFFFFFFF);

/// Background gradient — dark corner (bottom-left). REVISED (2026-09-05):
/// lightened two 8%-lightness HSL stops from "Slate" (#2E343B) — same
/// contrast fix as [bwGradientLight]. Deliberately its own constant,
/// separate from [bwSlate] (border stroke) even though both read as
/// slate-toned — different UI role. (A same-day follow-up desaturated
/// this to a neutral #5D5D5D over an unrelated, unrequested complaint
/// about a blue tint — reverted, user never asked for that; don't repeat.)
const bwGradientDark = Color(0xFF525C69);

/// Widget card background — literal white, for every widget Standard
/// renders light/off-white (2026-09-02 request: this theme's normal cards
/// read as true white, not the dark [bwCharcoal] placeholder).
const bwCardWhite = Color(0xFFFFFFFF);

/// Border-gradient "steel" tone (2026-09-05) — the mid stop of
/// [BlackWhiteTheme.borderGradient], between the [bwSilver] glint and the
/// [bwCharcoal] bottom. A neutral gray at ~57% lightness: darker than
/// [bwSilver] on purpose, since the border needs to read as a distinct
/// ring against the near-white card/background it sits on — the first
/// attempt used [bwSilver] itself for this stop and it blended into the
/// backdrop (user: "сливается с фоном").
const bwSteel = Color(0xFF919191);

/// Card/window gradient bottom stop (2026-09-05) — [bwSilver] lightened
/// one 8%-lightness HSL stop (same step size as the earlier background
/// contrast fix), per user request to polish `BlackWhiteTheme.cardGradient`
/// one tone lighter at both ends. The top stop (`bwCardWhite`, pure white)
/// is already at maximum lightness and can't be lightened further, so
/// only this bottom stop actually moves.
const bwCardGradientBottom = Color(0xFFCDCDD0);
