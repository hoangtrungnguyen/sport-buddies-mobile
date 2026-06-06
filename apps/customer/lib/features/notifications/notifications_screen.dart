import 'package:customer/features/notifications/notification_model.dart';
import 'package:customer/features/notifications/notifications_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// ── Design tokens (MD3 green theme) ─────────────────────────────────────────

const _mdPrimary = Color(0xFF15803D);
const _mdOnSurface = Color(0xFF1A1C19);
const _mdOnSurfaceVariant = Color(0xFF424940);
const _mdSurfaceVariant = Color(0xFFDDE5D9);
const _mdBackground = Color(0xFFF7FBF2);
const _mdError = Color(0xFFBA1A1A);
const _mdOutlineVariant = Color(0xFFBDC9B4);

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
        return all.where((n) => n.type == NotifType.bookingConfirmed || n.type == NotifType.cancelled || n.type == NotifType.reminder).toList();
      case 2:
        return all.where((n) => [NotifType.joinRequest, NotifType.playerJoined, NotifType.joinApproved, NotifType.joinRejected].contains(n.type)).toList();
      case 3:
        return all.where((n) => n.type == NotifType.reminder || n.type == NotifType.series).toList();
      default:
        return all;
    }
  }

  int _unreadCount(List<AppNotification> items) =>
      items.where((n) => n.unread && !_dismissed.contains(n.id)).length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _mdBackground,
      body: BlocBuilder<NotificationsCubit, NotificationsState>(
        builder: (context, state) {
          final items = switch (state) {
            NotificationsLoaded(:final items) => items,
            _ => const <AppNotification>[],
          };
          final unread = _unreadCount(items);
          final notifs = _filtered(items);
          final today = notifs.where((n) => n.day == NotifDay.today).toList();
          final yesterday = notifs.where((n) => n.day == NotifDay.yesterday).toList();
          final older = notifs.where((n) => n.day == NotifDay.older).toList();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _TopBar(unreadCount: unread),
              _FilterChips(
                filters: _filters,
                unreadCount: unread,
                selected: _selectedFilter,
                onSelected: (i) => setState(() => _selectedFilter = i),
              ),
              const Divider(height: 1, color: _mdOutlineVariant),
              Expanded(
                child: switch (state) {
                  NotificationsLoading() =>
                    const Center(child: CircularProgressIndicator()),
                  NotificationsError(:final message) =>
                    _ErrorState(message: message),
                  NotificationsLoaded() when notifs.isEmpty => RefreshIndicator(
                      color: _mdPrimary,
                      onRefresh: () =>
                          context.read<NotificationsCubit>().refresh(),
                      child: ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: [
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.6,
                            child: _EmptyState(
                                filter: _filters[_selectedFilter]),
                          ),
                        ],
                      ),
                    ),
                  NotificationsLoaded() => RefreshIndicator(
                      color: _mdPrimary,
                      onRefresh: () =>
                          context.read<NotificationsCubit>().refresh(),
                      child: ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.only(bottom: 32),
                        children: [
                          if (today.isNotEmpty) ...[
                            _SectionHeader(label: 'HÔM NAY', count: today.where((n) => n.unread).length),
                            ...today.map((n) => _NotifTile(
                                  notif: n,
                                  onDismiss: () => setState(() => _dismissed.add(n.id)),
                                )),
                          ],
                          if (yesterday.isNotEmpty) ...[
                            const _SectionHeader(label: 'HÔM QUA'),
                            ...yesterday.map((n) => _NotifTile(notif: n)),
                          ],
                          if (older.isNotEmpty) ...[
                            const _SectionHeader(label: 'TRƯỚC ĐÓ'),
                            ...older.map((n) => _NotifTile(notif: n)),
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

// ── Top bar ────────────────────────────────────────────────────────────────

class _TopBar extends StatelessWidget {
  const _TopBar({required this.unreadCount});

  final int unreadCount;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(4, 4, 8, 0),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back),
              color: _mdOnSurface,
              onPressed: () => Navigator.of(context).maybePop(),
            ),
            const Expanded(
              child: Text(
                'Thông báo',
                style: TextStyle(
                  color: _mdOnSurface,
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (unreadCount > 0)
              TextButton(
                onPressed: () {
                  // TODO: mark all read via cubit
                },
                child: const Text(
                  'Đọc tất cả',
                  style: TextStyle(color: _mdPrimary, fontSize: 14),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ── Filter chips ─────────────────────────────────────────────────────────────

class _FilterChips extends StatelessWidget {
  const _FilterChips({
    required this.filters,
    required this.unreadCount,
    required this.selected,
    required this.onSelected,
  });

  final List<String> filters;
  final int unreadCount;
  final int selected;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        itemCount: filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final isSelected = i == selected;
          final label = i == 0 && unreadCount > 0
              ? '${filters[i]} $unreadCount'
              : filters[i];
          return GestureDetector(
            onTap: () => onSelected(i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: isSelected ? _mdPrimary : _mdSurfaceVariant,
                borderRadius: BorderRadius.circular(20),
              ),
              alignment: Alignment.center,
              child: Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : _mdOnSurfaceVariant,
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ── Section header ────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.label, this.count});

  final String label;
  final int? count;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 6),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(
              color: _mdOnSurfaceVariant,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.8,
            ),
          ),
          if (count != null && count! > 0) ...[
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
              decoration: BoxDecoration(
                color: _mdPrimary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$count',
                style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Notification tile ─────────────────────────────────────────────────────────

class _NotifTile extends StatelessWidget {
  const _NotifTile({required this.notif, this.onDismiss});

  final AppNotification notif;
  final VoidCallback? onDismiss;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: notif.unread ? _mdPrimary.withValues(alpha: 0.05) : Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _NotifIcon(type: notif.type),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          notif.title,
                          style: TextStyle(
                            color: _mdOnSurface,
                            fontSize: 14,
                            fontWeight: notif.unread ? FontWeight.w600 : FontWeight.w400,
                          ),
                        ),
                      ),
                      if (notif.unread)
                        Container(
                          width: 8,
                          height: 8,
                          margin: const EdgeInsets.only(left: 8, top: 4),
                          decoration: const BoxDecoration(
                            color: _mdPrimary,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    notif.body,
                    style: const TextStyle(
                      color: _mdOnSurfaceVariant,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notif.time,
                    style: const TextStyle(
                      color: _mdOnSurfaceVariant,
                      fontSize: 11,
                    ),
                  ),
                  if (notif.type == NotifType.joinRequest)
                    _JoinRequestActions(onDismiss: onDismiss),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Notification icon ─────────────────────────────────────────────────────────

class _NotifIcon extends StatelessWidget {
  const _NotifIcon({required this.type});

  final NotifType type;

  @override
  Widget build(BuildContext context) {
    final (icon, bg, fg) = _resolve(type);
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
      child: Icon(icon, color: fg, size: 22),
    );
  }

  static (IconData, Color, Color) _resolve(NotifType t) => switch (t) {
        NotifType.bookingConfirmed => (Icons.check_circle_outline, const Color(0xFFDCFCE7), _mdPrimary),
        NotifType.joinRequest => (Icons.person_add_alt_1_outlined, const Color(0xFFE0F2FE), const Color(0xFF0369A1)),
        NotifType.reminder => (Icons.alarm_outlined, const Color(0xFFFFF7ED), const Color(0xFFC2410C)),
        NotifType.playerJoined => (Icons.group_outlined, const Color(0xFFDCFCE7), _mdPrimary),
        NotifType.joinApproved => (Icons.verified_outlined, const Color(0xFFDCFCE7), _mdPrimary),
        NotifType.joinRejected => (Icons.cancel_outlined, const Color(0xFFFEE2E2), _mdError),
        NotifType.cancelled => (Icons.event_busy_outlined, const Color(0xFFFEE2E2), _mdError),
        NotifType.series => (Icons.repeat_outlined, const Color(0xFFF3E8FF), const Color(0xFF7C3AED)),
      };
}

// ── Join-request inline actions ───────────────────────────────────────────────

class _JoinRequestActions extends StatefulWidget {
  const _JoinRequestActions({this.onDismiss});

  final VoidCallback? onDismiss;

  @override
  State<_JoinRequestActions> createState() => _JoinRequestActionsState();
}

class _JoinRequestActionsState extends State<_JoinRequestActions> {
  _Action? _chosen;

  @override
  Widget build(BuildContext context) {
    if (_chosen != null) {
      final label = _chosen == _Action.approve ? 'Đã duyệt' : 'Đã từ chối';
      final color = _chosen == _Action.approve ? _mdPrimary : _mdOnSurfaceVariant;
      return Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Text(label, style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.w500)),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Row(
        children: [
          _ActionBtn(
            label: 'Từ chối',
            filled: false,
            onTap: () {
              setState(() => _chosen = _Action.reject);
              widget.onDismiss?.call();
            },
          ),
          const SizedBox(width: 8),
          _ActionBtn(
            label: 'Duyệt',
            filled: true,
            onTap: () => setState(() => _chosen = _Action.approve),
          ),
        ],
      ),
    );
  }
}

enum _Action { approve, reject }

class _ActionBtn extends StatelessWidget {
  const _ActionBtn({required this.label, required this.filled, required this.onTap});

  final String label;
  final bool filled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
        decoration: BoxDecoration(
          color: filled ? _mdPrimary : Colors.transparent,
          border: Border.all(color: filled ? _mdPrimary : _mdOutlineVariant),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: filled ? Colors.white : _mdOnSurfaceVariant,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

// ── Empty state ───────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.filter});

  final String filter;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.notifications_off_outlined, size: 56, color: _mdOutlineVariant),
          const SizedBox(height: 12),
          const Text(
            'Không có thông báo',
            style: TextStyle(color: _mdOnSurfaceVariant, fontSize: 15),
          ),
          if (filter != 'Tất cả') ...[
            const SizedBox(height: 4),
            Text(
              'trong mục $filter',
              style: const TextStyle(color: _mdOutlineVariant, fontSize: 13),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Error state ───────────────────────────────────────────────────────────────

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 56, color: _mdError),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: _mdOnSurfaceVariant, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
