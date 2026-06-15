import 'package:dashboard/core/theme/app_theme.dart';
import 'package:dashboard/features/notifications/bloc/notification_bloc.dart';
import 'package:dashboard/features/notifications/bloc/notification_state.dart';
import 'package:dashboard/features/requests/bloc/requests_bloc.dart';
import 'package:dashboard/features/requests/model/booking_request.dart';
import 'package:dashboard/features/setup/bloc/court_bloc.dart';
import 'package:dashboard/features/setup/bloc/court_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../nav_model.dart';
import 'brand_tile.dart';

/// Live pending-requests badge override for the `/requests` destination.
int? _liveRequestsBadge(BuildContext context) {
  final pending = context.select<RequestsBloc, int>((bloc) {
    final s = bloc.state;
    return s is RequestsLoaded
        ? s.requests.where((r) => r.status == BookingStatus.pending).length
        : 0;
  });
  return pending > 0 ? pending : null;
}

/// Live unread-notifications badge for the `/notifications` destination.
int? _liveNotificationsBadge(BuildContext context) {
  final unread = context.select<NotificationBloc, int>((bloc) {
    final s = bloc.state;
    return s is NotificationLoaded ? s.unreadCount : 0;
  });
  return unread > 0 ? unread : null;
}

// ---------------------------------------------------------------------------
// Expanded navigation drawer (≥1100px / modal on compact — guide §4)
// ---------------------------------------------------------------------------

class NavDrawer extends StatelessWidget {
  const NavDrawer({
    super.key,
    required this.selected,
    required this.management,
    required this.system,
    this.inDrawer = false,
  });
  final int selected;
  final List<NavItem> management;
  final List<NavItem> system;
  final bool inDrawer;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: 280,
      color: scheme.surfaceContainerLow,
      child: SafeArea(
        child: Column(
          children: [
            const _BrandRow(),
            const SizedBox(height: 8),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.only(bottom: 8),
                children: [
                  const _SectionLabel('Quản lý'),
                  for (var i = 0; i < management.length; i++)
                    _NavRow(
                      item: management[i],
                      active: selected == i,
                      liveBadge: management[i].route == '/requests'
                          ? _liveRequestsBadge(context)
                          : null,
                    ),
                  const SizedBox(height: 8),
                  const _SectionLabel('Hệ thống'),
                  for (var i = 0; i < system.length; i++)
                    _NavRow(
                      item: system[i],
                      active: selected == management.length + i,
                      liveBadge: system[i].route == '/notifications'
                          ? _liveNotificationsBadge(context)
                          : null,
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: Column(
                children: const [
                  _UserCard(),
                  SizedBox(height: 10),
                  _TrialCard(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BrandRow extends StatelessWidget {
  const _BrandRow();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: [
          BrandTile(),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'SportBuddies',
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
                Text(
                  'Chủ sân · Quận 7',
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: scheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.label);
  final String label;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 12, 28, 6),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.8,
          color: scheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

/// 56px full-pill destination row: secondaryContainer indicator + filled icon
/// when active, trailing numeral badge (guide §4).
class _NavRow extends StatelessWidget {
  const _NavRow({required this.item, required this.active, this.liveBadge});
  final NavItem item;
  final bool active;
  final int? liveBadge;

  String get _semanticsLabel =>
      'nav-${item.route == '/' ? 'home' : item.route.replaceAll('/', '')}';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final badge = liveBadge;
    final fg = active ? scheme.onSecondaryContainer : scheme.onSurfaceVariant;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: Semantics(
        label: _semanticsLabel,
        button: true,
        selected: active,
        child: Material(
          color: active ? scheme.secondaryContainer : Colors.transparent,
          borderRadius: BorderRadius.circular(28),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () {
              if (Scaffold.maybeOf(context)?.hasDrawer ?? false) {
                if (Scaffold.of(context).isDrawerOpen) {
                  Navigator.of(context).pop();
                }
              }
              context.go(item.route);
            },
            child: SizedBox(
              height: 56,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Icon(item.icon, size: 24, color: fg, fill: active ? 1 : 0),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        item.label,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: fg,
                          fontWeight:
                              active ? FontWeight.w600 : FontWeight.w500,
                        ),
                      ),
                    ),
                    if (badge != null)
                      _NavBadge(count: badge, warn: item.warn, active: active),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavBadge extends StatelessWidget {
  const _NavBadge({
    required this.count,
    required this.warn,
    required this.active,
  });
  final int count;
  final bool warn;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final snb = theme.extension<SnbColors>();

    Color bg;
    Color fg;
    if (warn) {
      bg = snb?.warnContainer ?? const Color(0xFFFEF3C0);
      fg = snb?.onWarnContainer ?? const Color(0xFF574500);
    } else if (active) {
      bg = scheme.surfaceContainerLowest;
      fg = scheme.onSecondaryContainer;
    } else {
      bg = scheme.surfaceContainerHighest;
      fg = scheme.onSurfaceVariant;
    }

    return Container(
      constraints: const BoxConstraints(minWidth: 22),
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration:
          BoxDecoration(color: bg, borderRadius: BorderRadius.circular(999)),
      alignment: Alignment.center,
      child: Text(
        count.toString(),
        style: theme.textTheme.labelMedium
            ?.copyWith(color: fg, fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _UserCard extends StatelessWidget {
  const _UserCard();

  /// Display name for the signed-in owner, sourced from Supabase auth.
  /// Supabase exposes no profile table for owners, so we prefer a name in
  /// `user_metadata` (if the backend ever sets one) and otherwise fall back
  /// to the email's local part. Never the old hardcoded placeholder.
  static String _displayName(User? user) {
    final meta = user?.userMetadata;
    final metaName =
        (meta?['full_name'] ?? meta?['name'] ?? meta?['display_name'])
            as String?;
    if (metaName != null && metaName.trim().isNotEmpty) return metaName.trim();
    final email = user?.email ?? '';
    if (email.contains('@')) return email.split('@').first;
    return email.isNotEmpty ? email : 'Chủ sân';
  }

  /// 1–2 letter avatar initials derived from [name].
  static String _initials(String name) {
    final parts =
        name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) {
      final p = parts.first;
      return (p.length >= 2 ? p.substring(0, 2) : p).toUpperCase();
    }
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final user = Supabase.instance.client.auth.currentUser;
    final name = _displayName(user);
    final initials = _initials(name);

    final courtCount = context.select<CourtBloc, int>((bloc) {
      final s = bloc.state;
      return s is CourtLoaded ? s.courts.length : 0;
    });
    final subtitle = courtCount > 0 ? 'Chủ sân · $courtCount sân' : 'Chủ sân';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: scheme.tertiaryContainer,
            child: Text(
              initials,
              style: theme.textTheme.labelLarge?.copyWith(
                color: scheme.onTertiaryContainer,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleSmall,
                ),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: scheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Symbols.logout, size: 20),
            color: scheme.onSurfaceVariant,
            tooltip: 'Đăng xuất',
            onPressed: () async {
              try {
                await Supabase.instance.client.auth.signOut();
              } catch (_) {}
              if (context.mounted) context.go('/login');
            },
          ),
        ],
      ),
    );
  }
}

class _TrialCard extends StatelessWidget {
  const _TrialCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: scheme.primaryContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Gói miễn phí 3 tháng',
            style: theme.textTheme.labelLarge?.copyWith(
              color: scheme.onPrimaryContainer,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Hết hạn 04/08/2026',
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: scheme.onPrimaryContainer),
                ),
              ),
              InkWell(
                onTap: () {},
                child: Text(
                  'Nâng cấp',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: scheme.onPrimaryContainer,
                    fontWeight: FontWeight.w700,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
