import 'package:flutter/material.dart';

// ---------------------------------------------------------------------------
// Luxury Gold — reference color swatch (canonical, "Dark Gold & Luxury
// Tech" spec, 2026-08-23). This file is the single source of truth for the
// raw hex values only — it has no opinion on which UI role uses which
// color. That mapping (background/card/border/accent/text) lives in
// ../luxury_gold_theme.dart, which imports these constants instead of
// re-deriving hex values. Don't reference these constants directly from
// widgets — go through AppPalette (../app_palette.dart) so a widget never
// has to know which theme is active.
//
// 60/30/10 usage rule from the spec: obsidian+graphite ~60% of the screen,
// silver/champagne text ~30%, gold accents ~10% (CTAs/active icons/key
// stats only).
// ---------------------------------------------------------------------------

/// Основной фон / Primary background.
const darkObsidian = Color(0xFF0B0C0E);

/// Карточки и блоки / Cards and blocks.
const darkGraphite = Color(0xFF141619);

/// Границы и обводки / Borders and strokes.
const bronzeStroke = Color(0xFF2E2A20);

/// Главный акцент / Кнопки / Main accent, buttons.
const metallicGold = Color(0xFFD4A343);

/// Вторичный акцент / Градиенты / Secondary accent, gradients.
const brightGold = Color(0xFFF3C663);

/// Заголовки и акцентный текст / Headers and accent text.
const warmChampagne = Color(0xFFE6D5B8);

/// Основной текст (Body) / Body text.
const mutedSilver = Color(0xFFA0A5AD);

/// Bottom stop of the button gradient (`brightGold` → this, 135°).
const buttonGradientEnd = Color(0xFFC28E2E);
