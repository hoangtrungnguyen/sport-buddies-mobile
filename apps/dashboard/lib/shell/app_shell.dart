import 'package:dashboard/features/notifications/bloc/notification_bloc.dart';
import 'package:dashboard/features/notifications/bloc/notification_state.dart';
import 'package:dashboard/features/notifications/view/notification_panel.dart';
import 'package:dashboard/features/requests/bloc/requests_bloc.dart';
import 'package:dashboard/features/requests/model/booking_request.dart';
import 'package:dashboard/core/theme/app_theme.dart';
import 'package:dashboard/features/setup/bloc/court_bloc.dart';
import 'package:dashboard/features/setup/bloc/court_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// ---------------------------------------------------------------------------
// Nav model
// ---------------------------------------------------------------------------

class _NavEntry {
  const _NavEntry({
    required this.icon,
    required this.label,
    required this.route,
    this.badge,
    this.warn = false,
  });
  final IconData icon;
  final String label;
  final String route;
  final int? badge;
  final bool warn;
}

const _mainNav = <_NavEntry>[
  _NavEntry(
    icon: Symbols.home,
    label: 'Trang chủ',
    route: '/',
    badge: 3,
  ),
  _NavEntry(
    icon: Symbols.inbox,
    label: 'Yêu cầu',
    route: '/requests',
    warn: true,
  ),
  _NavEntry(
    icon: Symbols.calendar_today,
    label: 'Lịch sân',
    route: '/schedule',
  ),
  _NavEntry(
    icon: Symbols.event_repeat,
    label: 'Lịch cố định',
    route: '/fixed',
    badge: 6,
  ),
  _NavEntry(
    icon: Symbols.bar_chart,
    label: 'Thống kê',
    route: '/analytics',
  ),
  _NavEntry(
    icon: Symbols.stadium,
    label: 'Sân của tôi',
    route: '/courts',
  ),
  _NavEntry(
    icon: Symbols.group,
    label: 'Khách hàng',
    route: '/players',
  ),
];

const _systemNav = <_NavEntry>[
  _NavEntry(
    icon: Symbols.notifications,
    label: 'Thông báo',
    route: '/notifications',
    badge: 4,
    warn: true,
  ),
  _NavEntry(
    icon: Symbols.settings,
    label: 'Cài đặt sân',
    route: '/settings',
  ),
  _NavEntry(
    icon: Symbols.help,
    label: 'Hỗ trợ',
    route: '/support',
  ),
];

const _routeTitle = <String, String>{
  '/': 'Trang chủ',
  '/requests': 'Yêu cầu đặt sân',
  '/schedule': 'Lịch sân',
  '/fixed': 'Lịch cố định',
  '/analytics': 'Thống kê',
  '/courts': 'Sân của tôi',
  '/courts/new': 'Thêm sân mới',
  '/players': 'Khách hàng',
  '/notifications': 'Thông báo',
  '/settings': 'Cài đặt sân',
  '/support': 'Hỗ trợ',
};

/// True when [location] is a court sub-screen (form / detail) that should show
/// a back arrow instead of being a top-level nav destination.
bool _isSubScreen(String location) =>
    location.startsWith('/courts/');

// ---------------------------------------------------------------------------
// Shell
// ---------------------------------------------------------------------------

class AppShell extends StatefulWidget {
  const AppShell({super.key, required this.child});
  final Widget child;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  bool _notifOpen = false;

  void _openNotif() => setState(() => _notifOpen = true);
  void _closeNotif() => setState(() => _notifOpen = false);

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final state = GoRouterState.of(context);
    final location = state.matchedLocation;
    final isWide = MediaQuery.sizeOf(context).width >= 1024;
    final showFab = location == '/' || location == '/requests';

    Widget shell;
    if (isWide) {
      shell = Scaffold(
        backgroundColor: scheme.surface,
        body: Row(
          children: [
            _NavDrawer(location: location),
            Expanded(
              child: Column(
                children: [
                  _TopBar(location: location, onBellTap: _openNotif),
                  Expanded(child: widget.child),
                ],
              ),
            ),
          ],
        ),
      );
    } else {
      shell = Scaffold(
        backgroundColor: scheme.surface,
        drawer: Drawer(
          backgroundColor: scheme.surfaceContainerLow,
          width: 280,
          shape: const RoundedRectangleBorder(),
          child: _NavDrawer(location: location, inDrawer: true),
        ),
        body: Column(
          children: [
            _TopBar(location: location, isMobile: true, onBellTap: _openNotif),
            Expanded(child: widget.child),
          ],
        ),
      );
    }

    return Stack(
      children: [
        shell,
        if (_notifOpen)
          Positioned.fill(child: NotificationPanel(onClose: _closeNotif)),
        if (showFab)
          const Positioned(right: 24, bottom: 24, child: _Fab()),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// FAB — M3 extended FAB (primary container per design's action role)
// ---------------------------------------------------------------------------

class _Fab extends StatelessWidget {
  const _Fab();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return FloatingActionButton.extended(
      backgroundColor: scheme.primary,
      foregroundColor: scheme.onPrimary,
      elevation: 2,
      icon: const Icon(Symbols.add, size: 20),
      label: const Text('Đặt sân tại quầy'),
      onPressed: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Form đặt sân tại quầy sẽ có trong Epic Đặt Slot.'),
          ),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Top app bar (small, 64px)
// ---------------------------------------------------------------------------

class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.location,
    required this.onBellTap,
    this.isMobile = false,
  });
  final String location;
  final VoidCallback onBellTap;
  final bool isMobile;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final title = _routeTitle[location] ?? 'Trang chủ';
    final isSub = _isSubScreen(location) && location != '/courts';

    return Container(
      height: 64,
      decoration: BoxDecoration(
        color: scheme.surface,
        border: Border(bottom: BorderSide(color: scheme.outlineVariant)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          if (isSub)
            IconButton(
              icon: const Icon(Symbols.arrow_back),
              onPressed: () =>
                  context.canPop() ? context.pop() : context.go('/courts'),
            )
          else if (isMobile)
            Builder(
              builder: (ctx) => IconButton(
                icon: const Icon(Symbols.menu),
                onPressed: () => Scaffold.of(ctx).openDrawer(),
              ),
            ),
          if (isSub || isMobile) const SizedBox(width: 4),

          // Breadcrumb + venue context chip
          Flexible(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Chủ sân',
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(color: scheme.onSurfaceVariant),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: Text('/',
                      style: theme.textTheme.bodyMedium
                          ?.copyWith(color: scheme.outline)),
                ),
                Flexible(
                  child: Text(
                    title,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(width: 10),
                const _VenueChip(),
              ],
            ),
          ),

          const Spacer(),

          if (!isMobile) ...[
            const _SearchBar(),
            const SizedBox(width: 8),
          ],
          IconButton(
            icon: const Icon(Symbols.mail),
            color: scheme.onSurfaceVariant,
            onPressed: () {},
          ),
          _BellButton(onTap: onBellTap),
          Container(
            width: 1,
            height: 28,
            margin: const EdgeInsets.symmetric(horizontal: 12),
            color: scheme.outlineVariant,
          ),
          const _ProfileAvatar(initials: 'MN'),
        ],
      ),
    );
  }
}

class _VenueChip extends StatelessWidget {
  const _VenueChip();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: scheme.primaryContainer,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration:
                BoxDecoration(shape: BoxShape.circle, color: scheme.primary),
          ),
          const SizedBox(width: 6),
          Text(
            'SnB Đại Lộc · Q7',
            style: theme.textTheme.labelMedium?.copyWith(
              color: scheme.onPrimaryContainer,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar({required this.initials});
  final String initials;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return CircleAvatar(
      radius: 17,
      backgroundColor: scheme.primary,
      child: Text(
        initials,
        style: theme.textTheme.labelMedium?.copyWith(
          color: scheme.onPrimary,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: () => _openSearch(context),
      child: Container(
        width: 300,
        height: 40,
        decoration: BoxDecoration(
          color: scheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: scheme.outlineVariant),
        ),
        child: Row(
          children: [
            const SizedBox(width: 12),
            Icon(Symbols.search, size: 18, color: scheme.onSurfaceVariant),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Tìm booking, khách hàng, mã đơn...',
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium
                    ?.copyWith(color: scheme.onSurfaceVariant),
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: scheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                '⌘K',
                style: theme.textTheme.labelSmall
                    ?.copyWith(color: scheme.onSurfaceVariant),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openSearch(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (_) => const _SearchDialog(),
    );
  }
}

class _SearchDialog extends StatefulWidget {
  const _SearchDialog();

  @override
  State<_SearchDialog> createState() => _SearchDialogState();
}

class _SearchDialogState extends State<_SearchDialog> {
  final _ctrl = TextEditingController();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Dialog(
      alignment: Alignment.topCenter,
      insetPadding: const EdgeInsets.only(top: 80, left: 200, right: 200),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
            child: Row(
              children: [
                Icon(Symbols.search, size: 20, color: scheme.onSurfaceVariant),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _ctrl,
                    autofocus: true,
                    style: theme.textTheme.bodyLarge,
                    decoration: InputDecoration(
                      hintText: 'Tìm booking, khách hàng, mã đơn...',
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Đóng'),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Container(
            height: 200,
            alignment: Alignment.center,
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Symbols.search, size: 32, color: scheme.outline),
                const SizedBox(height: 10),
                Text(
                  _ctrl.text.isEmpty
                      ? 'Nhập để tìm booking, khách hàng hoặc mã đơn'
                      : 'Chức năng tìm kiếm sẽ có sau khi tích hợp booking',
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(color: scheme.onSurfaceVariant),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BellButton extends StatelessWidget {
  const _BellButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final unread = context.select<NotificationBloc, int>(
      (bloc) => bloc.state is NotificationLoaded
          ? (bloc.state as NotificationLoaded).unreadCount
          : 0,
    );

    return Stack(
      clipBehavior: Clip.none,
      children: [
        IconButton(
          icon: const Icon(Symbols.notifications),
          color: scheme.onSurfaceVariant,
          onPressed: onTap,
        ),
        if (unread > 0)
          Positioned(
            right: 6,
            top: 6,
            child: Container(
              padding: const EdgeInsets.all(4),
              constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: scheme.error,
              ),
              alignment: Alignment.center,
              child: Text(
                unread > 9 ? '9+' : unread.toString(),
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  color: scheme.onError,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Navigation drawer (standard, always visible — 280px, surfaceContainerLow)
// ---------------------------------------------------------------------------

class _NavDrawer extends StatelessWidget {
  const _NavDrawer({required this.location, this.inDrawer = false});
  final String location;
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
                  ..._mainNav.map((e) {
                    if (e.route == '/requests') {
                      final pendingCount =
                          context.select<RequestsBloc, int>((bloc) {
                        final s = bloc.state;
                        return s is RequestsLoaded
                            ? s.requests
                                .where((r) => r.status == BookingStatus.pending)
                                .length
                            : 0;
                      });
                      return _NavItem(
                        entry: e,
                        location: location,
                        liveBadge: pendingCount > 0 ? pendingCount : null,
                      );
                    }
                    return _NavItem(entry: e, location: location);
                  }),
                  const SizedBox(height: 8),
                  const _SectionLabel('Hệ thống'),
                  ..._systemNav
                      .map((e) => _NavItem(entry: e, location: location)),
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
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: scheme.primary,
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: Text(
              'S',
              style: theme.textTheme.titleLarge?.copyWith(
                color: scheme.onPrimary,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
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

/// M3 navigation destination — 56px full-pill row, active = secondaryContainer
/// indicator + filled icon, trailing badge count.
class _NavItem extends StatelessWidget {
  const _NavItem({required this.entry, required this.location, this.liveBadge});
  final _NavEntry entry;
  final String location;
  final int? liveBadge;

  bool get _active => location == entry.route;

  String get _semanticsLabel =>
      'nav-${entry.route == '/' ? 'home' : entry.route.replaceAll('/', '')}';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final badge = liveBadge ?? entry.badge;
    final fg = _active ? scheme.onSecondaryContainer : scheme.onSurfaceVariant;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: Semantics(
        label: _semanticsLabel,
        button: true,
        selected: _active,
        child: Material(
          color: _active ? scheme.secondaryContainer : Colors.transparent,
          borderRadius: BorderRadius.circular(28),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () {
              final scaffold = Scaffold.maybeOf(context);
              if (scaffold?.hasDrawer ?? false) Navigator.of(context).pop();
              context.go(entry.route);
            },
            child: SizedBox(
              height: 56,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Icon(
                      entry.icon,
                      size: 24,
                      color: fg,
                      fill: _active ? 1 : 0,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        entry.label,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: fg,
                          fontWeight:
                              _active ? FontWeight.w600 : FontWeight.w500,
                        ),
                      ),
                    ),
                    if (badge != null)
                      _NavBadge(count: badge, warn: entry.warn, active: _active),
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
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
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
