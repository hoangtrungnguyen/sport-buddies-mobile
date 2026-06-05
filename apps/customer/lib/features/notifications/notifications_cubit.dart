// NotificationsCubit — loads the user's notifications.
//
// NOTE: there is no notifications backend yet (no Supabase `notifications`
// table, no FCM inbox). `load()` currently resolves to an empty list so the
// screen renders its empty state. Wire the real data source here once the
// backend exists — the screen already consumes [NotificationsLoaded.items].

import 'package:customer/core/mixins/app_exception_mixin.dart';
import 'package:customer/features/notifications/notification_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'notifications_state.dart';

class NotificationsCubit extends Cubit<NotificationsState> {
  NotificationsCubit() : super(const NotificationsLoading());

  /// Loads notifications for the current user.
  Future<void> load() async {
    emit(const NotificationsLoading());
    // TODO: fetch from backend (Supabase `notifications` table / FCM inbox).
    emit(const NotificationsLoaded([]));
  }
}
