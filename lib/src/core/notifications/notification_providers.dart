import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/app_notification.dart';
import '../supabase/supabase_providers.dart';

// ---------------------------------------------------------------------------
// Notifications — app-wide bell-icon history. Local-only (SharedPreferences),
// not synced to Supabase — same tier as e.g. LogoDao/SectorDao, not the
// heavier per-session Supabase-synced state the trade/verdict data gets.
// FIFO-capped so the local store can't grow unbounded over a long-lived
// install.
// ---------------------------------------------------------------------------

const int _maxNotifications = 200;

String _notificationsKey(String? uid) =>
    uid != null ? 'app_notifications_$uid' : 'app_notifications';

class NotificationsNotifier extends StateNotifier<List<AppNotification>> {
  final String? _userId;

  NotificationsNotifier([this._userId]) : super([]) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_notificationsKey(_userId));
    if (raw == null) return;
    final list = jsonDecode(raw) as List;
    state = list
        .map((e) => AppNotification.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _notificationsKey(_userId),
      jsonEncode(state.map((n) => n.toJson()).toList()),
    );
  }

  /// Records a new notification (most-recent first), trimming to
  /// [_maxNotifications]. Does NOT show the popup — see
  /// `pushAppNotification` in app_notification_popup.dart for the combined
  /// "record + pop up" entry point every trigger site should call.
  void add(AppNotification notification) {
    final updated = [notification, ...state];
    state = updated.length > _maxNotifications
        ? updated.sublist(0, _maxNotifications)
        : updated;
    _save();
  }

  void markRead(String id) {
    final index = state.indexWhere((n) => n.id == id);
    if (index < 0 || state[index].read) return;
    state = [
      for (int i = 0; i < state.length; i++)
        if (i == index) state[i].copyWith(read: true) else state[i],
    ];
    _save();
  }

  void markAllRead() {
    if (state.every((n) => n.read)) return;
    state = [for (final n in state) n.copyWith(read: true)];
    _save();
  }
}

final notificationsProvider =
    StateNotifierProvider<NotificationsNotifier, List<AppNotification>>((
      ref,
    ) {
      final user = ref.watch(currentUserProvider);
      return NotificationsNotifier(user?.id);
    });

final unreadNotificationCountProvider = Provider<int>((ref) {
  return ref.watch(notificationsProvider).where((n) => !n.read).length;
});
