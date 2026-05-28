import 'package:supabase_flutter/supabase_flutter.dart';

import '../model/app_notification.dart';

class NotificationRepository {
  const NotificationRepository(this._client);
  final SupabaseClient _client;

  String? get currentUserId => _client.auth.currentUser?.id;

  Future<List<AppNotification>> getNotifications({int limit = 50}) async {
    final uid = _client.auth.currentUser?.id;
    if (uid == null) return [];
    final rows = await _client
        .from('notifications')
        .select()
        .eq('owner_id', uid)
        .order('created_at', ascending: false)
        .limit(limit);
    return (rows as List)
        .map((r) => AppNotification.fromJson(r as Map<String, dynamic>))
        .toList();
  }

  Future<void> markAllRead() async {
    final uid = _client.auth.currentUser?.id;
    if (uid == null) return;
    await _client
        .from('notifications')
        .update({'is_read': true})
        .eq('owner_id', uid)
        .eq('is_read', false);
  }

  RealtimeChannel subscribeToNewNotifications(
    String ownerId,
    void Function() onNew,
  ) {
    return _client
        .channel('owner_notifs:$ownerId')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'notifications',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'owner_id',
            value: ownerId,
          ),
          callback: (_) => onNew(),
        )
        .subscribe();
  }
}
