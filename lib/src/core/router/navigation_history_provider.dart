import 'package:flutter_riverpod/flutter_riverpod.dart';

// ---------------------------------------------------------------------------
// Remembers which bottom-nav tab route was active right before switching to
// another one. The shell's tabs are wired with go() (not push), so there's
// no Navigator back-stack to pop when a tab's own AppBar wants a back
// arrow — this provider is what "back" actually undoes: exactly the switch
// that brought you here, not a hardcoded fixed destination.
// ---------------------------------------------------------------------------

final previousTabRouteProvider = StateProvider<String>((ref) => '/home');
