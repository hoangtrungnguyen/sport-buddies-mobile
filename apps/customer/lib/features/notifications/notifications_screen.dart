import 'package:customer/features/notifications/notification_model.dart';
import 'package:customer/features/notifications/notifications_cubit.dart';
import 'package:customer/features/notifications/notifications_style.dart';
import 'package:customer/features/notifications/widgets/notifications_top_bar.dart';
import 'package:customer/features/notifications/widgets/notification_filter_chips.dart';
import 'package:customer/features/notifications/widgets/notification_tile.dart';
import 'package:customer/features/notifications/widgets/notification_states.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// ── Screen ───────────────────────────────────────────────────────────────────

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  int _selectedFilter = 0;
  // Locally-dismissed ids (e.g. a rejected join request). Reset on reload.
  final Set<String> _dismissed = {};

  static const _filters = ['Tất cả', 'Đặt sân', 'Chơi ghép', 'Nhắc nhở'];

  List<AppNotification> _filtered(List<AppNotification> items) {
    final all = items.where((n) => !_dismissed.contains(n.id)).toList();
    switch (_selectedFilter) {
      case 1:
        return all
            .where(
              (n) =>
                  n.type == NotifType.bookingConfirmed ||
                  n.type == NotifType.cancelled ||
                  n.type == NotifType.reminder,
            )
            .toList();
      case 2:
        return all
            .where(
              (n) => [
                NotifType.joinRequest,
                NotifType.playerJoined,
                NotifType.joinApproved,
                NotifType.joinRejected,
              ].contains(n.type),
            )
            .toList();
      case 3:
        return all
            .where(
              (n) => n.type == NotifType.reminder || n.type == NotifType.series,
            )
            .toList();
      default:
        return all;
    }
  }

  int _unreadCount(List<AppNotification> items) =>
      items.where((n) => n.unread && !_dismissed.contains(n.id)).length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: mdBackground,
      body: BlocBuilder<NotificationsCubit, NotificationsState>(
        builder: (context, state) {
          final items = switch (state) {
            NotificationsLoaded(:final items) => items,
            _ => const <AppNotification>[],
          };
          final unread = _unreadCount(items);
          final notifs = _filtered(items);
          final today = notifs.where((n) => n.day == NotifDay.today).toList();
          final yesterday = notifs
              .where((n) => n.day == NotifDay.yesterday)
              .toList();
          final older = notifs.where((n) => n.day == NotifDay.older).toList();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TopBar(unreadCount: unread),
              FilterChips(
                filters: _filters,
                unreadCount: unread,
                selected: _selectedFilter,
                onSelected: (i) => setState(() => _selectedFilter = i),
              ),
              const Divider(height: 1, color: mdOutlineVariant),
              Expanded(
                child: switch (state) {
                  NotificationsLoading() => const Center(
                    child: CircularProgressIndicator(),
                  ),
                  NotificationsError(:final message) => ErrorState(
                    message: message,
                  ),
                  NotificationsLoaded() when notifs.isEmpty => RefreshIndicator(
                    color: mdPrimary,
                    onRefresh: () =>
                        context.read<NotificationsCubit>().refresh(),
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.6,
                          child: EmptyState(filter: _filters[_selectedFilter]),
                        ),
                      ],
                    ),
                  ),
                  NotificationsLoaded() => RefreshIndicator(
                    color: mdPrimary,
                    onRefresh: () =>
                        context.read<NotificationsCubit>().refresh(),
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.only(bottom: 32),
                      children: [
                        if (today.isNotEmpty) ...[
                          SectionHeader(
                            label: 'HÔM NAY',
                            count: today.where((n) => n.unread).length,
                          ),
                          ...today.map(
                            (n) => NotifTile(
                              notif: n,
                              onDismiss: () =>
                                  setState(() => _dismissed.add(n.id)),
                            ),
                          ),
                        ],
                        if (yesterday.isNotEmpty) ...[
                          const SectionHeader(label: 'HÔM QUA'),
                          ...yesterday.map((n) => NotifTile(notif: n)),
                        ],
                        if (older.isNotEmpty) ...[
                          const SectionHeader(label: 'TRƯỚC ĐÓ'),
                          ...older.map((n) => NotifTile(notif: n)),
                        ],
                      ],
                    ),
                  ),
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
