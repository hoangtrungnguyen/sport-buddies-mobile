import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:spb_core/core/theme/app_colors.dart';

import '../bloc/notification_bloc.dart';
import '../bloc/notification_event.dart';
import '../bloc/notification_state.dart';
import '../model/app_notification.dart';

class NotificationPanel extends StatelessWidget {
  const NotificationPanel({super.key, required this.onClose});
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Backdrop
        GestureDetector(
          onTap: onClose,
          child: Container(color: Colors.black.withValues(alpha: 0.3)),
        ),
        // Panel
        Positioned(
          right: 0,
          top: 0,
          bottom: 0,
          width: 380,
          child: Material(
            elevation: 16,
            color: AppColors.surface,
            child: BlocBuilder<NotificationBloc, NotificationState>(
              builder: (context, state) {
                final notifs = state is NotificationLoaded
                    ? state.notifications
                    : <AppNotification>[];
                final unread = state is NotificationLoaded
                    ? state.unreadCount
                    : 0;

                return Column(
                  children: [
                    // Header
                    Container(
                      height: 60,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: const BoxDecoration(
                        border: Border(
                            bottom: BorderSide(color: AppColors.neutral200)),
                      ),
                      child: Row(
                        children: [
                          Text(
                            'Thông báo',
                            style: GoogleFonts.sora(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: AppColors.neutral900,
                            ),
                          ),
                          const SizedBox(width: 8),
                          if (unread > 0)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 7, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.danger,
                                borderRadius: BorderRadius.circular(99),
                              ),
                              child: Text(
                                '$unread mới',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          const Spacer(),
                          if (unread > 0)
                            TextButton(
                              onPressed: () => context
                                  .read<NotificationBloc>()
                                  .add(const NotificationEvent
                                      .markAllReadRequested()),
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 6),
                                foregroundColor: AppColors.neutral600,
                                textStyle: GoogleFonts.plusJakartaSans(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w500),
                              ),
                              child: const Text('Đánh dấu đã đọc'),
                            ),
                          const SizedBox(width: 4),
                          InkWell(
                            borderRadius: BorderRadius.circular(6),
                            onTap: onClose,
                            child: const Padding(
                              padding: EdgeInsets.all(6),
                              child: Icon(Icons.close_rounded,
                                  size: 18, color: AppColors.neutral500),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Body
                    Expanded(
                      child: switch (state) {
                        NotificationInitial() || NotificationLoading() =>
                          const Center(
                              child: CircularProgressIndicator(
                                  color: AppColors.primary)),
                        NotificationLoaded() when notifs.isEmpty =>
                          _EmptyState(),
                        NotificationLoaded() => ListView.builder(
                            itemCount: notifs.length,
                            itemBuilder: (_, i) =>
                                _NotifItem(notif: notifs[i]),
                          ),
                        NotificationFailure(:final message) => Center(
                            child: Text(message,
                                style: GoogleFonts.plusJakartaSans(
                                    color: AppColors.neutral500,
                                    fontSize: 13)),
                          ),
                      },
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------

class _NotifItem extends StatelessWidget {
  const _NotifItem({required this.notif});
  final AppNotification notif;

  @override
  Widget build(BuildContext context) {
    final (iconData, iconColor, iconBg) = switch (notif.type) {
      'new_booking' => (
          Icons.add_circle_outline_rounded,
          AppColors.primary,
          AppColors.primaryLight,
        ),
      'cancellation' => (
          Icons.cancel_outlined,
          AppColors.danger,
          AppColors.dangerBg,
        ),
      'info' => (
          Icons.info_outline_rounded,
          AppColors.secondary,
          AppColors.secondaryLight,
        ),
      _ => (
          Icons.settings_outlined,
          AppColors.neutral500,
          AppColors.neutral100,
        ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: notif.isRead ? AppColors.surface : const Color(0xFFF0FDF4),
        border: const Border(
            bottom: BorderSide(color: AppColors.neutral100)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(iconData, size: 16, color: iconColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _RichText(notif.text),
                const SizedBox(height: 3),
                Text(
                  '${notif.meta} · ${_timeAgo(notif.createdAt)}',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11.5,
                    color: AppColors.neutral400,
                  ),
                ),
              ],
            ),
          ),
          if (!notif.isRead)
            Container(
              margin: const EdgeInsets.only(top: 2, left: 8),
              width: 7,
              height: 7,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary,
              ),
            ),
        ],
      ),
    );
  }
}

/// Renders **bold** markdown-style text.
class _RichText extends StatelessWidget {
  const _RichText(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    final spans = <TextSpan>[];
    final regex = RegExp(r'\*\*(.+?)\*\*');
    int last = 0;
    for (final m in regex.allMatches(text)) {
      if (m.start > last) {
        spans.add(TextSpan(text: text.substring(last, m.start)));
      }
      spans.add(TextSpan(
        text: m.group(1),
        style: const TextStyle(fontWeight: FontWeight.w700),
      ));
      last = m.end;
    }
    if (last < text.length) spans.add(TextSpan(text: text.substring(last)));

    return RichText(
      text: TextSpan(
        style: GoogleFonts.plusJakartaSans(
          fontSize: 13,
          color: AppColors.neutral800,
          height: 1.4,
        ),
        children: spans,
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.notifications_none_rounded,
              size: 40, color: AppColors.neutral300),
          const SizedBox(height: 12),
          Text(
            'Chưa có thông báo nào',
            style: GoogleFonts.sora(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.neutral600),
          ),
          const SizedBox(height: 4),
          Text(
            'Thông báo đặt sân mới sẽ xuất hiện ở đây.',
            style: GoogleFonts.plusJakartaSans(
                fontSize: 13, color: AppColors.neutral400),
          ),
        ],
      ),
    );
  }
}

String _timeAgo(DateTime dt) {
  final diff = DateTime.now().difference(dt);
  if (diff.inMinutes < 1) return 'Vừa xong';
  if (diff.inMinutes < 60) return '${diff.inMinutes} phút trước';
  if (diff.inHours < 24) return '${diff.inHours} giờ trước';
  if (diff.inDays < 7) return '${diff.inDays} ngày trước';
  return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}';
}
