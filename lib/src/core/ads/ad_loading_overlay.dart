import 'package:flutter/material.dart';

/// Shows a small non-dismissible spinner while [future] is pending, then
/// pops it. AdMob's own rewarded/interstitial ad takes over the screen
/// once loaded — this only covers the brief network gap before that
/// happens, so the user isn't staring at an unresponsive tap.
Future<T> withAdLoadingOverlay<T>(BuildContext context, Future<T> future) async {
  showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (_) => const Center(child: CircularProgressIndicator()),
  );
  final result = await future;
  if (context.mounted) Navigator.of(context).pop();
  return result;
}
