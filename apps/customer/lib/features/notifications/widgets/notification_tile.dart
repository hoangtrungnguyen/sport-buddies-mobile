// Notification tile, section header, type icon and inline join-request
// actions for the notifications screen. Extracted from notifications_screen.dart.

import 'package:customer/features/notifications/notifications_cubit.dart';
import 'package:customer/features/notifications/notification_model.dart';
import 'package:customer/features/notifications/notifications_style.dart';
import 'package:customer/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Localized relative time ("Just now", "5 min ago", "Yesterday, 14:30", …).
String relativeNotifTime(AppLocalizations l10n, DateTime created) {
  final now = DateTime.now();
  final diff = now.difference(created);
  if (diff.inMinutes < 1) return l10n.notifTimeJustNow;
  if (diff.inMinutes < 60) return l10n.notifTimeMinutesAgo(diff.inMinutes);
  final d = DateTime(created.year, created.month, created.day);
  final today = DateTime(now.year, now.month, now.day);
  final dayDiff = today.difference(d).inDays;
  if (dayDiff <= 0) return l10n.notifTimeHoursAgo(diff.inHours);
  if (dayDiff == 1) {
    final hhmm =
        '${created.hour.toString().padLeft(2, '0')}:'
        '${created.minute.toString().padLeft(2, '0')}';
    return l10n.notifTimeYesterdayAt(hhmm);
  }
  return l10n.notifTimeDaysAgo(diff.inDays);
}

class SectionHeader extends StatelessWidget {
  const SectionHeader({super.key, required this.label, this.count});

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
              color: mdOnSurfaceVariant,
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
                color: mdPrimary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$count',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class NotifTile extends StatelessWidget {
  const NotifTile({super.key, required this.notif, this.onDismiss});

  final AppNotification notif;
  final VoidCallback? onDismiss;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: notif.isUnread
          ? mdPrimary.withValues(alpha: 0.05)
          : Colors.transparent,
      child: InkWell(
        // Tapping an unread notification marks it read.
        onTap: notif.isUnread
            ? () => context.read<NotificationsCubit>().markRead(notif.id)
            : null,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _NotifIcon(type: notif.notifType),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notif.text.isEmpty
                                ? AppLocalizations.of(context).notifTitle
                                : notif.text,
                            style: TextStyle(
                              color: mdOnSurface,
                              fontSize: 14,
                              fontWeight: notif.isUnread
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                            ),
                          ),
                        ),
                        if (notif.isUnread)
                          Container(
                            width: 8,
                            height: 8,
                            margin: const EdgeInsets.only(left: 8, top: 4),
                            decoration: const BoxDecoration(
                              color: mdPrimary,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      notif.meta,
                      style: const TextStyle(
                        color: mdOnSurfaceVariant,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      relativeNotifTime(
                        AppLocalizations.of(context),
                        notif.createdAt,
                      ),
                      style: const TextStyle(
                        color: mdOnSurfaceVariant,
                        fontSize: 11,
                      ),
                    ),
                    if (notif.notifType == NotifType.joinRequest)
                      _JoinRequestActions(onDismiss: onDismiss),
                  ],
                ),
              ),
            ],
          ),
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
    NotifType.bookingConfirmed => (
      Icons.check_circle_outline,
      const Color(0xFFDCFCE7),
      mdPrimary,
    ),
    NotifType.joinRequest => (
      Icons.person_add_alt_1_outlined,
      const Color(0xFFE0F2FE),
      const Color(0xFF0369A1),
    ),
    NotifType.reminder => (
      Icons.alarm_outlined,
      const Color(0xFFFFF7ED),
      const Color(0xFFC2410C),
    ),
    NotifType.playerJoined => (
      Icons.group_outlined,
      const Color(0xFFDCFCE7),
      mdPrimary,
    ),
    NotifType.joinApproved => (
      Icons.verified_outlined,
      const Color(0xFFDCFCE7),
      mdPrimary,
    ),
    NotifType.joinRejected => (
      Icons.cancel_outlined,
      const Color(0xFFFEE2E2),
      mdError,
    ),
    NotifType.cancelled => (
      Icons.event_busy_outlined,
      const Color(0xFFFEE2E2),
      mdError,
    ),
    NotifType.series => (
      Icons.repeat_outlined,
      const Color(0xFFF3E8FF),
      const Color(0xFF7C3AED),
    ),
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
    final l10n = AppLocalizations.of(context);
    if (_chosen != null) {
      final label = _chosen == _Action.approve
          ? l10n.notifJoinApproved
          : l10n.notifJoinRejected;
      final color = _chosen == _Action.approve ? mdPrimary : mdOnSurfaceVariant;
      return Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Row(
        children: [
          _ActionBtn(
            label: l10n.notifActionReject,
            filled: false,
            onTap: () {
              setState(() => _chosen = _Action.reject);
              widget.onDismiss?.call();
            },
          ),
          const SizedBox(width: 8),
          _ActionBtn(
            label: l10n.notifActionApprove,
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
  const _ActionBtn({
    required this.label,
    required this.filled,
    required this.onTap,
  });

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
          color: filled ? mdPrimary : Colors.transparent,
          border: Border.all(color: filled ? mdPrimary : mdOutlineVariant),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: filled ? Colors.white : mdOnSurfaceVariant,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
