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
      // Expanded — standard inline NavigationDrawer.
      shell = Scaffold(
        backgroundColor: scheme.surface,
        body: Row(
          children: [
            NavDrawer(
                selected: selected,
                management: managementNav,
                system: systemNav),
            Expanded(
              child: Column(
                children: [
                  if (!isSub) TopBar(location: location, onBellTap: _openNotif),
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
            NavRail(selected: selected, items: allNav),
            Expanded(
              child: Column(
                children: [
                  if (!isSub)
                    TopBar(
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
          child: NavDrawer(
              selected: selected,
              management: managementNav,
              system: systemNav,
              inDrawer: true),
        ),
        body: Column(
          children: [
            if (!isSub)
              TopBar(location: location, isMobile: true, onBellTap: _openNotif),
            Expanded(child: widget.child),
          ],
        ),
        bottomNavigationBar: BottomBar(location: location, items: bottomNav),
      );
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
}
