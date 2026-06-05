import 'package:flutter/material.dart';

// ── Design tokens (MD3 green theme) ─────────────────────────────────────────

const _mdPrimary = Color(0xFF15803D);
const _mdOnSurface = Color(0xFF1A1C19);
const _mdOnSurfaceVariant = Color(0xFF424940);
const _mdSurfaceVariant = Color(0xFFDDE5D9);
const _mdBackground = Color(0xFFF7FBF2);
const _mdError = Color(0xFFBA1A1A);
const _mdOutlineVariant = Color(0xFFBDC9B4);

// ── Mock data ────────────────────────────────────────────────────────────────

// TODO: replace with real notification data from Supabase
enum _NType {
  bookingConfirmed,
  joinRequest,
  reminder,
  playerJoined,
  joinApproved,
  joinRejected,
  cancelled,
  series,
}

/// Date bucket a notification falls into. Drives the section grouping so the
/// display never depends on parsing the human-readable [_Notif.time] string.
enum _Day { today, yesterday, older }

class _Notif {
  const _Notif({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.time,
    required this.day,
    this.unread = false,
  });

  final String id;
  final _NType type;
  final String title;
  final String body;
  final String time;
  final _Day day;
  final bool unread;
}

// ─── MOCK DATA — REMOVE BLOCK ───────────────────────────────────────────────
// TODO(mock): delete `_mockNotifs` entirely once notifications come from the
// backend (FCM + Supabase `notifications` table). Replace reads in
// `_filtered` and `_unreadCount` with a NotificationsCubit state.
final _mockNotifs = <_Notif>[
  // HÔM NAY
  const _Notif(
    id: 'n1',
    type: _NType.bookingConfirmed,
    title: 'Pickle Hub Q1 xác nhận đặt sân',
    body: '3 slots · 610.000đ · Chủ nhật 08:00 – 10:00',
    time: '2 phút trước',
    day: _Day.today,
    unread: true,
  ),
  const _Notif(
    id: 'n2',
    type: _NType.joinRequest,
    title: 'Phạm Thuỷ muốn tham gia slot',
    body: 'Pickleball · Pickle Hub Q3 · Hôm nay 19:00',
    time: '15 phút trước',
    day: _Day.today,
    unread: true,
  ),
  const _Notif(
    id: 'n3',
    type: _NType.reminder,
    title: 'Buổi chơi bắt đầu sau 1 giờ',
    body: 'Sân Tao Đàn · 20:00 – 21:30 · 120.000đ',
    time: '30 phút trước',
    day: _Day.today,
    unread: true,
  ),
  // HÔM QUA
  const _Notif(
    id: 'n4',
    type: _NType.playerJoined,
    title: 'Nguyễn Hoàng đã tham gia slot',
    body: 'Cầu lông · CLB Bình Thạnh · Hôm qua 18:00',
    time: 'Hôm qua, 18:45',
    day: _Day.yesterday,
    unread: false,
  ),
  const _Notif(
    id: 'n5',
    type: _NType.joinApproved,
    title: 'Minh Quân đã duyệt yêu cầu tham gia',
    body: 'Pickleball · Pickle Hub Q1 · Hôm qua 19:30',
    time: 'Hôm qua, 14:00',
    day: _Day.yesterday,
    unread: false,
  ),
  const _Notif(
    id: 'n6',
    type: _NType.series,
    title: 'Lịch định kỳ: Buổi 2/7 sắp tới',
    body: 'Tennis · Sân Phú Nhuận · Thứ Sáu 06:00',
    time: 'Hôm qua, 09:00',
    day: _Day.yesterday,
    unread: false,
  ),
  // TRƯỚC ĐÓ
  const _Notif(
    id: 'n7',
    type: _NType.cancelled,
    title: 'Chủ sân huỷ buổi định kỳ lần 3',
    body: 'Bóng đá · Sân Nguyễn Du · Thứ Tư 20:00',
    time: '2 ngày trước',
    day: _Day.older,
    unread: false,
  ),
  const _Notif(
    id: 'n8',
    type: _NType.joinRejected,
    title: 'Yêu cầu tham gia bị từ chối',
    body: 'Cầu lông · CLB Bình Thạnh · Thứ Ba 18:00',
    time: '3 ngày trước',
    day: _Day.older,
    unread: false,
  ),
];
// ─── END MOCK DATA ──────────────────────────────────────────────────────────

// ── Screen ───────────────────────────────────────────────────────────────────

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  int _selectedFilter = 0;
  // TODO: track dismissed join-requests from mock data; real state should come from cubit
  final Set<String> _dismissed = {};

  static const _filters = ['Tất cả', 'Đặt sân', 'Chơi ghép', 'Nhắc nhở'];

  List<_Notif> get _filtered {
    // TODO(mock): source from NotificationsCubit instead of `_mockNotifs`.
    final all = _mockNotifs.where((n) => !_dismissed.contains(n.id)).toList();
    switch (_selectedFilter) {
      case 1:
        return all.where((n) => n.type == _NType.bookingConfirmed || n.type == _NType.cancelled || n.type == _NType.reminder).toList();
      case 2:
        return all.where((n) => [_NType.joinRequest, _NType.playerJoined, _NType.joinApproved, _NType.joinRejected].contains(n.type)).toList();
      case 3:
        return all.where((n) => n.type == _NType.reminder || n.type == _NType.series).toList();
      default:
        return all;
    }
  }

  // TODO(mock): derive from NotificationsCubit state instead of `_mockNotifs`.
  int get _unreadCount =>
      _mockNotifs.where((n) => n.unread && !_dismissed.contains(n.id)).length;

  @override
  Widget build(BuildContext context) {
    final notifs = _filtered;

    final today = notifs.where((n) => n.day == _Day.today).toList();
    final yesterday = notifs.where((n) => n.day == _Day.yesterday).toList();
    final older = notifs.where((n) => n.day == _Day.older).toList();

    return Scaffold(
      backgroundColor: _mdBackground,
      appBar: AppBar(
        backgroundColor: _mdBackground,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: _mdOnSurface,
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: const Text(
          'Thông báo',
          style: TextStyle(
            color: _mdOnSurface,
            fontSize: 22,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          if (_unreadCount > 0)
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
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _FilterChips(
            filters: _filters,
            unreadCount: _unreadCount,
            selected: _selectedFilter,
            onSelected: (i) => setState(() => _selectedFilter = i),
          ),
          const Divider(height: 1, color: _mdOutlineVariant),
          Expanded(
            child: notifs.isEmpty
                ? _EmptyState(filter: _filters[_selectedFilter])
                : ListView(
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
        ],
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

  final _Notif notif;
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
                  if (notif.type == _NType.joinRequest)
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

  final _NType type;

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

  static (IconData, Color, Color) _resolve(_NType t) => switch (t) {
        _NType.bookingConfirmed => (Icons.check_circle_outline, const Color(0xFFDCFCE7), _mdPrimary),
        _NType.joinRequest => (Icons.person_add_alt_1_outlined, const Color(0xFFE0F2FE), const Color(0xFF0369A1)),
        _NType.reminder => (Icons.alarm_outlined, const Color(0xFFFFF7ED), const Color(0xFFC2410C)),
        _NType.playerJoined => (Icons.group_outlined, const Color(0xFFDCFCE7), _mdPrimary),
        _NType.joinApproved => (Icons.verified_outlined, const Color(0xFFDCFCE7), _mdPrimary),
        _NType.joinRejected => (Icons.cancel_outlined, const Color(0xFFFEE2E2), _mdError),
        _NType.cancelled => (Icons.event_busy_outlined, const Color(0xFFFEE2E2), _mdError),
        _NType.series => (Icons.repeat_outlined, const Color(0xFFF3E8FF), const Color(0xFF7C3AED)),
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
