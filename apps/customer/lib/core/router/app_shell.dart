// AppShell — host scaffold for the bottom-nav tabs.
//
// Uses Flutter's MD3 NavigationBar widget:
//   • Pill indicator sits behind the active icon only (spec-compliant).
//   • Labels are always visible for all destinations.
//   • 80dp bar height + safe-area padding (NavigationBar default).
//   • Icon/label colours themed to the app's green palette.

import 'package:customer/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          navigationBarTheme: NavigationBarThemeData(
            backgroundColor: Colors.white,
            indicatorColor: const Color(0xFFDCFCE7),
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            height: 80,
            labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
            iconTheme: WidgetStateProperty.resolveWith((states) {
              final active = states.contains(WidgetState.selected);
              return IconThemeData(
                size: 24,
                color: active
                    ? const Color(0xFF166534)
                    : const Color(0xFF6B7280),
              );
            }),
            labelTextStyle: WidgetStateProperty.resolveWith((states) {
              final active = states.contains(WidgetState.selected);
              return TextStyle(
                fontSize: 12,
                fontWeight:
                    active ? FontWeight.w600 : FontWeight.w400,
                color: active
                    ? const Color(0xFF166534)
                    : const Color(0xFF6B7280),
              );
            }),
          ),
        ),
        child: DecoratedBox(
          decoration: const BoxDecoration(
            border: Border(
              top: BorderSide(color: Color(0xFFE5E7EB), width: 1),
            ),
          ),
          child: NavigationBar(
            selectedIndex: navigationShell.currentIndex,
            onDestinationSelected: _goBranch,
            destinations: [
              NavigationDestination(
                icon: const Icon(Icons.map_outlined),
                selectedIcon: const Icon(Icons.map),
                label: l10n.navMap,
              ),
              NavigationDestination(
                icon: const Icon(Icons.event_note_outlined),
                selectedIcon: const Icon(Icons.event_note),
                label: l10n.navBookings,
              ),
              NavigationDestination(
                icon: const Icon(Icons.person_outline),
                selectedIcon: const Icon(Icons.person),
                label: l10n.navProfile,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
