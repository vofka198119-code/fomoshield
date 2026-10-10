import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/theme_v2.dart';
import 'slide_down_card.dart';

// ---------------------------------------------------------------------------
// App banner — the one-line confirmation that used to be a SnackBar.
//
// It wears the notification card (slide_down_card.dart), so "анкета
// сохранена" and "AAPL куплена" arrive the same way, from the same edge of
// the screen, instead of the trade looking like an event and everything else
// looking like a browser alert at the bottom. Nothing here reaches the bell's
// history: these are moments, not records, and the history is for things
// worth coming back to.
//
// Free-form text on purpose. The bell's own popup derives its words from an
// AppNotification's type, which is right for a trade and useless for the
// forty-odd confirmations and complaints the app needs to make -- giving
// those a type each would fill the history model with types that never reach
// the history.
// ---------------------------------------------------------------------------

enum AppBannerTone {
  /// It worked. Green, like a buy in the bell.
  success,

  /// It did not. Red, same as the SnackBars that used to carry a loss colour.
  failure,

  /// Neither — "order placed", "waiting for the market". Plain dark text.
  info,
}

Color _toneColor(AppBannerTone tone) {
  switch (tone) {
    case AppBannerTone.success:
      return ThemeV2.success;
    case AppBannerTone.failure:
      return ThemeV2.loss;
    case AppBannerTone.info:
      // The navy the notification popup has always used for its badge, and
      // near-black for the words, which is what makes an ordinary message
      // read as ordinary.
      return const Color(0xFF1B365D);
  }
}

IconData _toneIcon(AppBannerTone tone) {
  switch (tone) {
    case AppBannerTone.success:
      return Icons.check_circle_rounded;
    case AppBannerTone.failure:
      return Icons.error_rounded;
    case AppBannerTone.info:
      return Icons.info_rounded;
  }
}

/// Drops a confirmation in from the top of the app and takes it away again.
///
/// [message] is shown as written — no title is invented for it, so no new
/// string has to be translated to move a message off a SnackBar. [icon]
/// overrides the one the tone would pick.
///
/// Needs no BuildContext and so works from a notifier, a callback after an
/// await, or a screen that has already been popped. Returns false if the
/// app's overlay is not up yet (only before the first frame).
bool showAppBanner(
  String message, {
  AppBannerTone tone = AppBannerTone.info,
  IconData? icon,
}) {
  final trimmed = message.trim();
  if (trimmed.isEmpty) return false;
  final color = _toneColor(tone);
  return showSlideDownCard(
    builder: (context, dismiss) => slideDownCardShell(
      onTap: dismiss,
      child: Row(
        children: [
          slideDownCardBadge(icon: icon ?? _toneIcon(tone), color: color),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              trimmed,
              // Three lines is enough for the longest message the app sends
              // and short enough that the card never becomes a wall.
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                height: 1.3,
                color: tone == AppBannerTone.info
                    ? Colors.black87
                    : _toneColor(tone),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
