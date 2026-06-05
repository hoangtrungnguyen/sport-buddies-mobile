// NotificationsCubit — loads the current user's notifications from Supabase.
//
// Reads the `notifications` table (id, type, title, body, read, created_at)
// for the authenticated user, newest first, and maps each row to an
// [AppNotification] the screen renders. Read-only: marking notifications read
// is left as a TODO (a DB write).

import 'package:customer/core/mixins/app_exception_mixin.dart';
import 'package:customer/features/notifications/notification_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'notifications_state.dart';

class NotificationsCubit extends Cubit<NotificationsState> {
  NotificationsCubit(this._client) : super(const NotificationsLoading());

  final SupabaseClient _client;

  /// Loads notifications for the current user, newest first.
  Future<void> load() async {
    emit(const NotificationsLoading());
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) {
        emit(const NotificationsLoaded([]));
        return;
      }

      final rows = await _client
          .from('notifications')
          .select('id, type, title, body, read, created_at')
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .limit(50) as List<dynamic>;

      final now = DateTime.now();
      final items = rows
          .cast<Map<String, dynamic>>()
          .map((r) => _mapRow(r, now))
          .toList();

      emit(NotificationsLoaded(items));
    } catch (e, st) {
      emit(NotificationsError(e.toString(), stackTrace: st));
    }
  }

  static AppNotification _mapRow(Map<String, dynamic> r, DateTime now) {
    final created =
        DateTime.parse(r['created_at'] as String).toLocal();
    return AppNotification(
      id: r['id'] as String,
      type: _mapType(r['type'] as String? ?? ''),
      title: (r['title'] as String?)?.trim().isNotEmpty == true
          ? r['title'] as String
          : 'Thông báo',
      body: r['body'] as String? ?? '',
      time: _relativeTime(created, now),
      day: _dayBucket(created, now),
      unread: r['read'] != true,
    );
  }

  /// Maps the DB `type` text to a [NotifType]. Unknown types fall back to
  /// [NotifType.reminder] so the row still renders.
  static NotifType _mapType(String t) => switch (t) {
        'booking_request' || 'join_request' => NotifType.joinRequest,
        'booking_confirmed' || 'booking_created' => NotifType.bookingConfirmed,
        'reminder' => NotifType.reminder,
        'player_joined' => NotifType.playerJoined,
        'join_approved' => NotifType.joinApproved,
        'join_rejected' => NotifType.joinRejected,
        'cancelled' || 'booking_cancelled' => NotifType.cancelled,
        'series' || 'series_reminder' => NotifType.series,
        _ => NotifType.reminder,
      };

  static NotifDay _dayBucket(DateTime created, DateTime now) {
    final d = DateTime(created.year, created.month, created.day);
    final today = DateTime(now.year, now.month, now.day);
    final diff = today.difference(d).inDays;
    if (diff <= 0) return NotifDay.today;
    if (diff == 1) return NotifDay.yesterday;
    return NotifDay.older;
  }

  static String _relativeTime(DateTime created, DateTime now) {
    final diff = now.difference(created);
    final hhmm =
        '${created.hour.toString().padLeft(2, '0')}:${created.minute.toString().padLeft(2, '0')}';
    if (diff.inMinutes < 1) return 'Vừa xong';
    if (diff.inMinutes < 60) return '${diff.inMinutes} phút trước';
    final bucket = _dayBucket(created, now);
    if (bucket == NotifDay.today) return '${diff.inHours} giờ trước';
    if (bucket == NotifDay.yesterday) return 'Hôm qua, $hhmm';
    return '${diff.inDays} ngày trước';
  }
}
