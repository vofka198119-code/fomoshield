import 'package:flutter/material.dart';

// ---------------------------------------------------------------------------
// App Overlay Host — a dedicated Overlay wrapped around the ENTIRE routed
// app (see main.dart's MaterialApp.router `builder`), so an entry inserted
// via `appOverlayKey` renders above every screen and every GoRoute/tab,
// not just whatever the nearest local Overlay.of(context) happens to be.
// This is what lets the notification popup (app_notification_popup.dart)
// "float above any window in the app" regardless of where it was triggered
// from — including plain Dart notifier code with no BuildContext at all.
// ---------------------------------------------------------------------------

final appOverlayKey = GlobalKey<OverlayState>();

class AppOverlayHost extends StatelessWidget {
  final Widget child;

  const AppOverlayHost({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Overlay(
      key: appOverlayKey,
      initialEntries: [OverlayEntry(builder: (_) => child)],
    );
  }
}
