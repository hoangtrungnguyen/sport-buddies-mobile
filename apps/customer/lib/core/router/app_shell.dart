// AppShell — host scaffold for the bottom-nav tabs.
//
// Uses a custom expanding-pill nav bar (Direction 2 design):
// inactive tabs collapse to icons; the active tab grows into a
// soft green pill with its label (300 ms ease-in-out).
//
// Built by go_router's StatefulShellRoute.indexedStack. The shell preserves
// per-tab Navigator state, so switching tabs does not rebuild the contents.

import 'package:customer/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:spb_core/spb_core.dart';

class AppShell extends StatelessWidget {
  const AppShell({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  void _goBranch(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: _ExpandingTabBar(
        currentIndex: navigationShell.currentIndex,
        onTap: _goBranch,
        items: [
          _NavItem(
            icon: Icons.map_outlined,
            activeIcon: Icons.map,
            label: l10n.navMap,
          ),
          _NavItem(
            icon: Icons.event_note_outlined,
            activeIcon: Icons.event_note,
            label: l10n.navBookings,
          ),
          _NavItem(
            icon: Icons.person_outline,
            activeIcon: Icons.person,
            label: l10n.navProfile,
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Data
// ---------------------------------------------------------------------------

class _NavItem {
  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
}

// ---------------------------------------------------------------------------
// Bar
// ---------------------------------------------------------------------------

class _ExpandingTabBar extends StatelessWidget {
  const _ExpandingTabBar({
    required this.currentIndex,
    required this.onTap,
    required this.items,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<_NavItem> items;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: AppColors.neutral200, width: 1),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 68,
          child: Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Row(
              children: [
                for (int i = 0; i < items.length; i++)
                  Expanded(
                    child: _ExpandingNavButton(
                      item: items[i],
                      active: i == currentIndex,
                      onTap: () => onTap(i),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Individual tab button
// ---------------------------------------------------------------------------

class _ExpandingNavButton extends StatelessWidget {
  const _ExpandingNavButton({
    required this.item,
    required this.active,
    required this.onTap,
  });

  final _NavItem item;
  final bool active;
  final VoidCallback onTap;

  static const _duration = Duration(milliseconds: 300);
  static const _curve = Curves.easeInOut;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Center(
        child: AnimatedContainer(
          duration: _duration,
          curve: _curve,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          decoration: BoxDecoration(
            color: active ? AppColors.primaryLight : Colors.transparent,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                active ? item.activeIcon : item.icon,
                size: 22,
                color: active ? AppColors.primaryDark : AppColors.neutral500,
              ),
              ClipRect(
                child: AnimatedAlign(
                  duration: _duration,
                  curve: _curve,
                  alignment: Alignment.centerLeft,
                  widthFactor: active ? 1.0 : 0.0,
                  child: AnimatedOpacity(
                    duration: _duration,
                    curve: _curve,
                    opacity: active ? 1.0 : 0.0,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 6),
                      child: Text(
                        item.label,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryDark,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
