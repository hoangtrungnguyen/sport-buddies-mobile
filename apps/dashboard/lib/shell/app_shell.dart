import 'package:dashboard/features/notifications/view/notification_panel.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'nav_model.dart';
import 'widgets/app_fab.dart';
import 'widgets/bottom_bar.dart';
import 'widgets/nav_drawer.dart';
import 'widgets/nav_rail.dart';
import 'widgets/top_bar.dart';

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
    final managementNav = visibleNav(kManagementNav);
    final systemNav = visibleNav(kSystemNav);
    final allNav = [...managementNav, ...systemNav];
    final bottomNav = visibleNav(kBottomNav);
    final selected = indexForLocation(allNav, location);
    final width = MediaQuery.sizeOf(context).width;
    final showFab = location == '/' || location == '/requests';
    // Lift the FAB above the bottom navigation bar on the compact tier.
    final fabBottom = width < 600 ? 96.0 : 24.0;
    // Court detail/form screens carry their own app bar (back arrow); hide the
    // shell top bar on them so there is a single bar, not two.
    final isSub = isSubScreen(location);

    final Widget shell;
    if (width >= 1100) {
      shell = _expandedShell(scheme, location, selected, managementNav,
          systemNav, isSub: isSub);
    } else if (width >= 600) {
      shell =
          _mediumShell(scheme, location, selected, allNav, isSub: isSub);
    } else {
      shell = _compactShell(scheme, location, selected, managementNav,
          systemNav, bottomNav, isSub: isSub);
    }

    return Stack(
      children: [
        shell,
        if (_notifOpen)
          Positioned.fill(child: NotificationPanel(onClose: _closeNotif)),
        if (showFab)
          Positioned(right: 24, bottom: fabBottom, child: const AppFab()),
      ],
    );
  }

  /// Top bar (unless this is a sub-screen) above the routed child — the body
  /// content shared by the expanded and medium tiers.
  Widget _content(Widget? topBar) {
    return Column(
      children: [
        if (topBar != null) topBar,
        Expanded(child: widget.child),
      ],
    );
  }

  /// Expanded (≥1100) — standard inline NavigationDrawer.
  Widget _expandedShell(
    ColorScheme scheme,
    String location,
    int selected,
    List<NavItem> management,
    List<NavItem> system, {
    required bool isSub,
  }) {
    return Scaffold(
      backgroundColor: scheme.surface,
      body: Row(
        children: [
          NavDrawer(
              selected: selected, management: management, system: system),
          Expanded(
            child: _content(
              isSub ? null : TopBar(location: location, onBellTap: _openNotif),
            ),
          ),
        ],
      ),
    );
  }

  /// Medium (≥600) — icon-only NavigationRail.
  Widget _mediumShell(
    ColorScheme scheme,
    String location,
    int selected,
    List<NavItem> allNav, {
    required bool isSub,
  }) {
    return Scaffold(
      backgroundColor: scheme.surface,
      body: Row(
        children: [
          NavRail(selected: selected, items: allNav),
          Expanded(
            child: _content(
              isSub
                  ? null
                  : TopBar(
                      location: location,
                      onBellTap: _openNotif,
                      showSearch: false),
            ),
          ),
        ],
      ),
    );
  }

  /// Compact (<600) — bottom NavigationBar + modal drawer for the full list.
  Widget _compactShell(
    ColorScheme scheme,
    String location,
    int selected,
    List<NavItem> management,
    List<NavItem> system,
    List<NavItem> bottomNav, {
    required bool isSub,
  }) {
    return Scaffold(
      backgroundColor: scheme.surface,
      drawer: Drawer(
        backgroundColor: scheme.surfaceContainerLow,
        width: 280,
        shape: const RoundedRectangleBorder(),
        child: NavDrawer(
            selected: selected,
            management: management,
            system: system,
            inDrawer: true),
      ),
      body: _content(
        isSub
            ? null
            : TopBar(location: location, isMobile: true, onBellTap: _openNotif),
      ),
      bottomNavigationBar: BottomBar(location: location, items: bottomNav),
    );
  }
}
