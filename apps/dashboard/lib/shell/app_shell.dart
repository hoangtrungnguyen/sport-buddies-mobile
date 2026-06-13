import 'package:dashboard/config/feature_flags/feature_flag_service.dart';
import 'package:dashboard/core/di/injection.dart';
import 'package:dashboard/core/theme/app_theme.dart';
import 'package:dashboard/features/notifications/bloc/notification_bloc.dart';
import 'package:dashboard/features/notifications/bloc/notification_state.dart';
import 'package:dashboard/features/notifications/view/notification_panel.dart';
import 'package:dashboard/features/requests/bloc/requests_bloc.dart';
import 'package:dashboard/features/requests/model/booking_request.dart';
import 'package:dashboard/features/setup/bloc/court_bloc.dart';
import 'package:dashboard/features/setup/bloc/court_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// ---------------------------------------------------------------------------
// Nav model — single source of truth (Navigation M3 guide §2)
// ---------------------------------------------------------------------------

class _NavItem {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.route,
    this.warn = false,
  });
  final IconData icon;
  final String label;
  final String route;

  /// Tints the live badge as a warning (pending requests / unread alerts).
  final bool warn;
}

/// Filters [items] down to the routes the feature flags allow. The nav→flag
/// mapping lives in the YAML (`route:` on a flag); a route no flag governs
/// stays visible. See [FeatureFlagService.isRouteEnabled].
List<_NavItem> _visibleNav(List<_NavItem> items) => [
      for (final it in items)
        if (sl<FeatureFlagService>().isRouteEnabled(it.route)) it,
    ];

/// QUẢN LÝ (Management)
const _managementNav = <_NavItem>[
  _NavItem(icon: Symbols.home, label: 'Trang chủ', route: '/'),
  _NavItem(
      icon: Symbols.inbox, label: 'Yêu cầu', route: '/requests', warn: true),
  _NavItem(
      icon: Symbols.calendar_month, label: 'Lịch sân', route: '/schedule'),
  _NavItem(icon: Symbols.autorenew, label: 'Lịch cố định', route: '/fixed'),
  _NavItem(icon: Symbols.monitoring, label: 'Thống kê', route: '/analytics'),
  _NavItem(icon: Symbols.stadium, label: 'Sân của tôi', route: '/courts'),
  _NavItem(icon: Symbols.group, label: 'Khách hàng', route: '/players'),
];

/// HỆ THỐNG (System)
const _systemNav = <_NavItem>[
  _NavItem(
      icon: Symbols.notifications,
      label: 'Thông báo',
      route: '/notifications',
      warn: true),
  _NavItem(icon: Symbols.settings, label: 'Cài đặt sân', route: '/settings'),
  _NavItem(icon: Symbols.help, label: 'Hỗ trợ', route: '/support'),
];

/// Compact bottom-bar primaries (guide §6).
const _bottomNav = <_NavItem>[
  _NavItem(icon: Symbols.home, label: 'Trang chủ', route: '/'),
  _NavItem(icon: Symbols.inbox, label: 'Yêu cầu', route: '/requests'),
  _NavItem(icon: Symbols.calendar_month, label: 'Lịch sân', route: '/schedule'),
  _NavItem(icon: Symbols.stadium, label: 'Sân của tôi', route: '/courts'),
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

/// Index of the destination owning [loc] — selection follows the route, not the
/// tap (guide §8). Sub-routes light their parent via longest-prefix match, so
/// `/courts/new` keeps "Sân của tôi" selected. Returns -1 when nothing matches.
int _indexForLocation(List<_NavItem> nav, String loc) {
  var best = -1;
  var bestLen = -1;
  for (var i = 0; i < nav.length; i++) {
    final r = nav[i].route;
    final match = r == '/' ? loc == '/' : loc == r || loc.startsWith('$r/');
    if (match && r.length > bestLen) {
      best = i;
      bestLen = r.length;
    }
  }
  return best;
}

/// True when [location] is a court sub-screen. These render their own app bar
/// (with a back arrow), so the shell hides its top bar to avoid a double bar.
bool _isSubScreen(String location) =>
    location.startsWith('/courts/') && location != '/courts';

// ---------------------------------------------------------------------------
// Shell — adaptive: drawer ≥1100 · rail 600–1100 · bottom bar <600 (guide §10)
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
    final location = GoRouterState.of(context).matchedLocation;
    // Feature-flag-gated nav. Filtered once here so selection indices, the
    // drawer/rail/bottom renderers, and the index lookup all agree.
    final managementNav = _visibleNav(_managementNav);
    final systemNav = _visibleNav(_systemNav);
    final allNav = [...managementNav, ...systemNav];
    final bottomNav = _visibleNav(_bottomNav);
    final selected = _indexForLocation(allNav, location);
    final width = MediaQuery.sizeOf(context).width;
    final showFab = location == '/' || location == '/requests';
    // Lift the FAB above the bottom navigation bar on the compact tier.
    final fabBottom = width < 600 ? 96.0 : 24.0;
    // Court detail/form screens carry their own app bar (back arrow); hide the
    // shell top bar on them so there is a single bar, not two.
    final isSub = _isSubScreen(location);

    final Widget shell;
    if (width >= 1100) {
      // Expanded — standard inline NavigationDrawer.
      shell = Scaffold(
        backgroundColor: scheme.surface,
        body: Row(
          children: [
            _NavDrawer(
                selected: selected,
                management: managementNav,
                system: systemNav),
            Expanded(
              child: Column(
                children: [
                  if (!isSub) _TopBar(location: location, onBellTap: _openNotif),
                  Expanded(child: widget.child),
                ],
              ),
            ),
          ],
        ),
      );
    } else if (width >= 600) {
      // Medium — icon-only NavigationRail.
      shell = Scaffold(
        backgroundColor: scheme.surface,
        body: Row(
          children: [
            _NavRail(selected: selected, items: allNav),
            Expanded(
              child: Column(
                children: [
                  if (!isSub)
                    _TopBar(
                        location: location,
                        onBellTap: _openNotif,
                        showSearch: false),
                  Expanded(child: widget.child),
                ],
              ),
            ),
          ],
        ),
      );
    } else {
      // Compact — bottom NavigationBar + modal drawer for the full list.
      shell = Scaffold(
        backgroundColor: scheme.surface,
        drawer: Drawer(
          backgroundColor: scheme.surfaceContainerLow,
          width: 280,
          shape: const RoundedRectangleBorder(),
          child: _NavDrawer(
              selected: selected,
              management: managementNav,
              system: systemNav,
              inDrawer: true),
        ),
        body: Column(
          children: [
            if (!isSub)
              _TopBar(location: location, isMobile: true, onBellTap: _openNotif),
            Expanded(child: widget.child),
          ],
        ),
        bottomNavigationBar: _BottomBar(location: location, items: bottomNav),
      );
    }

    return Stack(
      children: [
        shell,
        if (_notifOpen)
          Positioned.fill(child: NotificationPanel(onClose: _closeNotif)),
        if (showFab)
          Positioned(right: 24, bottom: fabBottom, child: const _Fab()),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// FAB — M3 extended FAB (primary = action role)
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
// Top app bar (small, 64px — guide §7)
// ---------------------------------------------------------------------------

class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.location,
    required this.onBellTap,
    this.isMobile = false,
    this.showSearch = true,
  });
  final String location;
  final VoidCallback onBellTap;
  final bool isMobile;
  final bool showSearch;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final title = _routeTitle[location] ?? 'Trang chủ';

    return Container(
      height: 64,
      decoration: BoxDecoration(
        color: scheme.surface,
        border: Border(bottom: BorderSide(color: scheme.outlineVariant)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          if (isMobile) ...[
            Builder(
              builder: (ctx) => IconButton(
                icon: const Icon(Symbols.menu),
                onPressed: () => Scaffold.of(ctx).openDrawer(),
              ),
            ),
            const SizedBox(width: 4),
          ],

          // Breadcrumb + venue context chip (title-only on compact to fit)
          if (isMobile)
            Flexible(
              child: Text(
                title,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
            )
          else
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

          if (showSearch && !isMobile) ...[
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
    showDialog<void>(context: context, builder: (_) => const _SearchDialog());
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
                    decoration: const InputDecoration(
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
              decoration:
                  BoxDecoration(shape: BoxShape.circle, color: scheme.error),
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

class _NavDrawer extends StatelessWidget {
  const _NavDrawer({
    required this.selected,
    required this.management,
    required this.system,
    this.inDrawer = false,
  });
  final int selected;
  final List<_NavItem> management;
  final List<_NavItem> system;
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
          _BrandTile(),
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

class _BrandTile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Container(
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
  final _NavItem item;
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

// ---------------------------------------------------------------------------
// Rail (600–1100px, icon-only — guide §5)
// ---------------------------------------------------------------------------

class _NavRail extends StatelessWidget {
  const _NavRail({required this.selected, required this.items});
  final int selected;
  final List<_NavItem> items;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    // All destinations stay reachable as icons; the footer (owner/trial) is
    // dropped per the guide. Owner actions live in the top bar.
    return SingleChildScrollView(
      child: ConstrainedBox(
        constraints:
            BoxConstraints(minHeight: MediaQuery.sizeOf(context).height),
        child: IntrinsicHeight(
          child: NavigationRail(
            backgroundColor: scheme.surfaceContainerLow,
            selectedIndex: selected < 0 ? null : selected,
            labelType: NavigationRailLabelType.none,
            minWidth: 84,
            leading: const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: _BrandTileWrap(),
            ),
            destinations: [
              for (final item in items)
                NavigationRailDestination(
                  icon: Tooltip(message: item.label, child: Icon(item.icon)),
                  selectedIcon: Tooltip(
                    message: item.label,
                    child: Icon(item.icon, fill: 1),
                  ),
                  label: Text(item.label),
                ),
            ],
            onDestinationSelected: (i) => context.go(items[i].route),
          ),
        ),
      ),
    );
  }
}

class _BrandTileWrap extends StatelessWidget {
  const _BrandTileWrap();
  @override
  Widget build(BuildContext context) => _BrandTile();
}

// ---------------------------------------------------------------------------
// Bottom bar (<600px — guide §6)
// ---------------------------------------------------------------------------

class _BottomBar extends StatelessWidget {
  const _BottomBar({required this.location, required this.items});
  final String location;
  final List<_NavItem> items;

  @override
  Widget build(BuildContext context) {
    var idx = items.indexWhere((it) =>
        it.route == '/' ? location == '/' : location.startsWith(it.route));
    if (idx < 0) idx = 0;

    return NavigationBar(
      selectedIndex: idx,
      destinations: [
        for (final item in items)
          NavigationDestination(
            icon: Icon(item.icon),
            selectedIcon: Icon(item.icon, fill: 1),
            label: item.label,
          ),
      ],
      onDestinationSelected: (i) => context.go(items[i].route),
    );
  }
}

// ---------------------------------------------------------------------------
// Drawer footer — owner row + trial card (guide §4)
// ---------------------------------------------------------------------------

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
