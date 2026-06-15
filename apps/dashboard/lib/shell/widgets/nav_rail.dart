import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../nav_model.dart';
import 'brand_tile.dart';

class NavRail extends StatelessWidget {
  const NavRail({super.key, required this.selected, required this.items});
  final int selected;
  final List<NavItem> items;

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
              child: BrandTile(),
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
