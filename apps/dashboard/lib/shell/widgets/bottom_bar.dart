import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../nav_model.dart';

class BottomBar extends StatelessWidget {
  const BottomBar({super.key, required this.location, required this.items});
  final String location;
  final List<NavItem> items;

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
