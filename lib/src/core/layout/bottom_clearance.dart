import 'package:flutter/material.dart';

// ---------------------------------------------------------------------------
// Bottom clearance for scrollable content sitting under the app's own
// translucent bottom navigation bar (_AppShell in app_router.dart).
// ---------------------------------------------------------------------------
// _AppShell uses `extendBody: true` so its blurred bar reads as see-through
// while scrolling — but that means Scaffold does NOT auto-inset body content
// for the bar's height, unlike a normal opaque bottom bar. Each of the 4
// shell tabs (Home/Portfolio/Profile/Stress Test Hub) must reserve this much
// bottom space itself, or content ends up rendered behind the bar.
//
// The bar's on-screen height is _AppShell's `SizedBox(height: 4)` top
// padding + BottomNavigationBar's own height, plus the device's system
// nav-bar/gesture-bar inset (SafeArea(top: false) inside the bar pushes its
// content up by that inset, but the bar's rendered background still spans
// it) — a fixed guess (previously 100/40/32, inconsistent across the 4
// tabs) doesn't scale with that inset across devices.
// ---------------------------------------------------------------------------

const double _kAppShellBarTopPadding = 4;

/// Bottom padding a shell-tab screen's scroll view needs so its last
/// row/button clears the translucent bottom nav bar on every device.
double shellBottomClearance(BuildContext context) =>
    kBottomNavigationBarHeight +
    _kAppShellBarTopPadding +
    MediaQuery.of(context).padding.bottom;
