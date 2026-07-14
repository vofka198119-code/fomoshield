// ---------------------------------------------------------------------------
// Typography Helpers — Design Bible Part 3
// ---------------------------------------------------------------------------
// Все числовые значения используют interNums() вместо GoogleFonts.inter(),
// чтобы включить tabular-figures (одинаковая ширина цифр для быстрого
// сканирования взглядом).
//
// Правила Part 3:
// - Числа: tabular-nums, tnum
// - Инвестор не читает, а сканирует взглядом — экран считывается за 3-4 сек
// - Сумма портфеля — основным цветом текста, изменение (+/-) — зелёным/красным
// - Не красить всё в зелёный/красный
// ---------------------------------------------------------------------------

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// GoogleFonts.inter с FontFeature.tabularFigures() для числовых значений.
///
/// Все денежные суммы, проценты, scores и цифровые метки используют этот
/// хелпер вместо прямого GoogleFonts.inter().
TextStyle interNums({
  double? fontSize,
  FontWeight? fontWeight,
  Color? color,
  double? letterSpacing,
  double? height,
  TextDecoration? decoration,
  FontStyle? fontStyle,
}) {
  return GoogleFonts.inter(
    fontSize: fontSize,
    fontWeight: fontWeight,
    color: color,
    letterSpacing: letterSpacing,
    height: height,
    decoration: decoration,
    fontStyle: fontStyle,
    fontFeatures: const [FontFeature.tabularFigures()],
  );
}

/// GoogleFonts.inter без tabular-figures (для обычного текста).
TextStyle interRegular({
  double? fontSize,
  FontWeight? fontWeight,
  Color? color,
  double? letterSpacing,
  double? height,
  TextDecoration? decoration,
  FontStyle? fontStyle,
}) {
  return GoogleFonts.inter(
    fontSize: fontSize,
    fontWeight: fontWeight,
    color: color,
    letterSpacing: letterSpacing,
    height: height,
    decoration: decoration,
    fontStyle: fontStyle,
  );
}
