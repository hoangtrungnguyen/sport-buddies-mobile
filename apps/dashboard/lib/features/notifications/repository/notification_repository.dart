import 'package:dashboard/core/debug/app_logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:spb_core/spb_core.dart';

class NotificationRepository {
  const NotificationRepository(this._client);
  final SupabaseClient _client;

  String? get currentUserId => _client.auth.currentUser?.id;

  Future<List<AppNotification>> getNotifications({int limit = 50}) async {
    try {
      final uid = _client.auth.currentUser?.id;
      if (uid == null) return [];
      final rows = await _client
          .from('notifications')
          .select()
          .eq('user_id', uid)
          .order('created_at', ascending: false)
          .limit(limit);
      return (rows as List)
          .map((r) => AppNotification.fromJson(r as Map<String, dynamic>))
          .toList();
    } catch (e, st) {
      appLogger.e('NotificationRepository.getNotifications',
          error: e, stackTrace: st);
      rethrow;
    }
  }

  Future<void> markAllRead() async {
    try {
      final uid = _client.auth.currentUser?.id;
      if (uid == null) return;
      await _client
          .from('notifications')
          .update({'is_read': true})
          .eq('user_id', uid)
          .eq('is_read', false);
    } catch (e, st) {
      appLogger.e('NotificationRepository.markAllRead',
          error: e, stackTrace: st);
      rethrow;
    }
  }

  RealtimeChannel subscribeToNewNotifications(
    String userId,
    void Function() onNew,
  ) {
    return _client
        .channel('user_notifs:$userId')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'notifications',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'user_id',
            value: userId,
          ),
          callback: (_) => onNew(),
        )
        .subscribe();
  }
}
