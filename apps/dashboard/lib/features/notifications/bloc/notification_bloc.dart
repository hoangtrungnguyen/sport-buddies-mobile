import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../repository/notification_repository.dart';
import 'notification_event.dart';
import 'notification_state.dart';

class NotificationBloc
    extends Bloc<NotificationEvent, NotificationState> {
  NotificationBloc(this._repo) : super(const NotificationState.initial()) {
    on<NotificationLoadRequested>(_onLoad);
    on<NotificationMarkAllReadRequested>(_onMarkAllRead);
    on<NotificationRealtimeReceived>(_onRealtime);
  }

  final NotificationRepository _repo;
  RealtimeChannel? _channel;

  Future<void> _onLoad(
    NotificationLoadRequested _,
    Emitter<NotificationState> emit,
  ) async {
    emit(const NotificationState.loading());
    try {
      final notifications = await _repo.getNotifications();
      final unread = notifications.where((n) => !n.isRead).length;
      emit(NotificationState.loaded(notifications, unreadCount: unread));

      final uid = _repo.currentUserId;
      if (uid != null && _channel == null) {
        _channel = _repo.subscribeToNewNotifications(uid, () {
          add(const NotificationEvent.realtimeReceived());
        });
      }
    } catch (_) {
      // Notifications table may not exist yet — show empty list silently.
      emit(const NotificationState.loaded([], unreadCount: 0));
    }
  }

  Future<void> _onMarkAllRead(
    NotificationMarkAllReadRequested _,
    Emitter<NotificationState> emit,
  ) async {
    final current = state;
    if (current is! NotificationLoaded) return;
    try {
      await _repo.markAllRead();
      final updated =
          current.notifications.map((n) => n.copyWith(isRead: true)).toList();
      emit(NotificationState.loaded(updated, unreadCount: 0));
    } catch (_) {
      // Silent failure — local state already reflects intent.
    }
  }

  Future<void> _onRealtime(
    NotificationRealtimeReceived _,
    Emitter<NotificationState> emit,
  ) async {
    // Re-fetch to pick up the new notification.
    try {
      final notifications = await _repo.getNotifications();
      final unread = notifications.where((n) => !n.isRead).length;
      emit(NotificationState.loaded(notifications, unreadCount: unread));
    } catch (_) {}
  }

  @override
  Future<void> close() async {
    await _channel?.unsubscribe();
    _channel = null;
    return super.close();
  }
}
