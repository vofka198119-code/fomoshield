import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/app_palette.dart';

// ---------------------------------------------------------------------------
// App sheet — the one shape every panel that slides up from the bottom wears.
//
// There were five of them in the funds module and five slightly different
// recipes: two painted the card themselves and three let the modal do it, the
// paddings differed, one forgot the keyboard entirely, and NOT ONE of them
// accounted for the system navigation bar -- so a button could sit on top of
// the phone's own buttons. That last one was found on a device (2026-10-10),
// fixed in the invite sheet, and would have stayed broken in the other four.
//
// So the reference lives here rather than in whichever sheet was polished
// most recently. A caller supplies content; the shell supplies the card, the
// corners, the insets and the room to breathe.
//
// The navigation bar's height is padding INSIDE the card, never a gap under
// it: lifting the whole sheet clears the buttons but leaves the scrim showing
// through beneath as a black strip.
// ---------------------------------------------------------------------------

Future<T?> showAppSheet<T>({
  required BuildContext context,
  required AppPalette palette,
  required Widget Function(BuildContext context) builder,

  /// For a sheet whose content can outgrow the screen -- a form that raises
  /// the keyboard, or a list. Off by default: a short panel scrolls nowhere
  /// and a scroll view would only swallow its intrinsic height.
  bool scrollable = false,

  /// False for a sheet that already lays out its own insides -- it still
  /// gets the card, the corners and the keyboard, and takes responsibility
  /// for the navigation bar itself (its own SafeArea, usually). Converting
  /// such a sheet's innards as well is a separate job; this lets it join the
  /// shell today without being rebuilt.
  bool padded = true,
}) {
  return showModalBottomSheet<T>(
    context: context,
    // The card is drawn below, not by the modal: the two ways of doing it
    // disagree about where padding goes once an inset is involved.
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (sheetContext) {
      final media = MediaQuery.of(sheetContext);
      final Widget content = padded
          ? Padding(
              padding: EdgeInsets.fromLTRB(
                20,
                20,
                20,
                24 + media.padding.bottom,
              ),
              child: builder(sheetContext),
            )
          : builder(sheetContext);
      return Padding(
        padding: EdgeInsets.only(bottom: media.viewInsets.bottom),
        child: Container(
          decoration: BoxDecoration(
            color: palette.card,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: scrollable ? SingleChildScrollView(child: content) : content,
        ),
      );
    },
  );
}

/// The centred heading a sheet opens with. Centred because a panel is not a
/// screen: there is no back arrow on its left for the title to balance.
Widget appSheetTitle(String text, AppPalette palette) {
  return Center(
    child: Text(
      text,
      textAlign: TextAlign.center,
      style: GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: palette.textHeader,
      ),
    ),
  );
}
