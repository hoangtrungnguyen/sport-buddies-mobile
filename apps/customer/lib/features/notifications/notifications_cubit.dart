// NotificationsCubit — loads the current user's notifications from Supabase.
//
// Reads the `notifications` table (id, type, title, body, read, created_at)
// for the authenticated user, newest first, and maps each row to an
// [AppNotification] the screen renders. Read-only: marking notifications read
// is left as a TODO (a DB write).

import 'package:customer/core/mixins/app_exception_mixin.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spb_core/spb_core.dart' show AppNotification;
import 'package:supabase_flutter/supabase_flutter.dart';

part 'notifications_state.dart';

class NotificationsCubit extends Cubit<NotificationsState> {
  NotificationsCubit(this._client) : super(const NotificationsLoading());

  final SupabaseClient _client;
  RealtimeChannel? _channel;

  /// Initial load: shows a spinner, fetches, then subscribes to live updates.
  Future<void> load() async {
    emit(const NotificationsLoading());
    await _fetch();
    _subscribeRealtime();
  }

  /// Re-fetches without a loading flash — for pull-to-refresh and realtime.
  Future<void> refresh() => _fetch();

  /// Marks every unread notification for the current user as read.
  Future<void> markAllRead() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return;
    _applyRead((_) => true); // optimistic: clear all unread immediately
    try {
      await _client
          .from('notifications')
          .update({'read': true})
          .eq('user_id', userId)
          .eq('read', false);
    } catch (_) {
      await _fetch(); // revert to server truth on failure
    }
  }

  /// Marks a single notification read.
  Future<void> markRead(String id) async {
    _applyRead((n) => n.id == id); // optimistic
    try {
      await _client.from('notifications').update({'read': true}).eq('id', id);
    } catch (_) {
      await _fetch();
    }
  }

  /// Optimistically flips `unread` to false for notifications matching [match].
  void _applyRead(bool Function(AppNotification) match) {
    final s = state;
    if (s is! NotificationsLoaded) return;
    final updated = [
      for (final n in s.items)
        n.isUnread && match(n) ? n.copyWith(isRead: true) : n,
    ];
    emit(NotificationsLoaded(updated));
  }

  Future<void> _fetch() async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) {
        emit(const NotificationsLoaded([]));
        return;
      }

      final rows =
          await _client
                  .from('notifications')
                  .select('id, type, title, body, read, created_at')
                  .eq('user_id', userId)
                  .order('created_at', ascending: false)
                  .limit(50)
              as List<dynamic>;

      final items = rows
          .cast<Map<String, dynamic>>()
          .map(_mapRow)
          .toList();

      emit(NotificationsLoaded(items));
    } catch (e, st) {
      emit(NotificationsError(e.toString(), stackTrace: st));
    }
  }

  /// Subscribes to changes on the user's notifications and re-fetches on any
  /// insert/update/delete so the inbox stays live. No-op if not signed in.
  void _subscribeRealtime() {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return;
    _channel?.unsubscribe();
    _channel = _client
        .channel('notifications_$userId')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'notifications',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'user_id',
            value: userId,
          ),
          callback: (_) => _fetch(),
        )
        .subscribe();
  }

  @override
  Future<void> close() {
    _channel?.unsubscribe();
    return super.close();
  }

  /// Maps a `notifications` row to the shared [AppNotification]. The raw `type`
  /// string is kept verbatim — the view layer derives its [NotifType] icon and
  /// [NotifDay] bucket from it ([NotificationView]).
  static AppNotification _mapRow(Map<String, dynamic> r) {
    final created = DateTime.parse(r['created_at'] as String).toLocal();
    return AppNotification(
      id: r['id'] as String,
      type: (r['type'] as String?)?.trim() ?? '',
      text: (r['title'] as String?)?.trim() ?? '',
      meta: r['body'] as String? ?? '',
      createdAt: created,
      isRead: r['read'] == true,
    );
  }
}
