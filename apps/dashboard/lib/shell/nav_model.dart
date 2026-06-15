import 'package:dashboard/config/feature_flags/feature_flag_service.dart';
import 'package:dashboard/core/di/injection.dart';
import 'package:flutter/widgets.dart';
import 'package:material_symbols_icons/symbols.dart';

class NavItem {
  const NavItem({
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
List<NavItem> visibleNav(List<NavItem> items) => [
      for (final it in items)
        if (sl<FeatureFlagService>().isRouteEnabled(it.route)) it,
    ];

/// QUẢN LÝ (Management)
const kManagementNav = <NavItem>[
  NavItem(icon: Symbols.home, label: 'Trang chủ', route: '/'),
  NavItem(
      icon: Symbols.inbox, label: 'Yêu cầu', route: '/requests', warn: true),
  NavItem(
      icon: Symbols.calendar_month, label: 'Lịch sân', route: '/schedule'),
  NavItem(icon: Symbols.autorenew, label: 'Lịch cố định', route: '/fixed'),
  NavItem(icon: Symbols.monitoring, label: 'Thống kê', route: '/analytics'),
  NavItem(icon: Symbols.stadium, label: 'Sân của tôi', route: '/courts'),
  NavItem(icon: Symbols.group, label: 'Khách hàng', route: '/players'),
];

/// HỆ THỐNG (System)
const kSystemNav = <NavItem>[
  NavItem(
      icon: Symbols.notifications,
      label: 'Thông báo',
      route: '/notifications',
      warn: true),
  NavItem(icon: Symbols.settings, label: 'Cài đặt sân', route: '/settings'),
  NavItem(icon: Symbols.help, label: 'Hỗ trợ', route: '/support'),
];

/// Compact bottom-bar primaries (guide §6).
const kBottomNav = <NavItem>[
  NavItem(icon: Symbols.home, label: 'Trang chủ', route: '/'),
  NavItem(icon: Symbols.inbox, label: 'Yêu cầu', route: '/requests'),
  NavItem(icon: Symbols.calendar_month, label: 'Lịch sân', route: '/schedule'),
  NavItem(icon: Symbols.stadium, label: 'Sân của tôi', route: '/courts'),
];

const kRouteTitle = <String, String>{
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
int indexForLocation(List<NavItem> nav, String loc) {
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
bool isSubScreen(String location) =>
    location.startsWith('/courts/') && location != '/courts';
