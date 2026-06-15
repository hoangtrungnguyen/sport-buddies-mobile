// AppShell — host scaffold for the bottom-nav tabs.
//
// Uses Flutter's MD3 NavigationBar widget:
//   • Pill indicator sits behind the active icon only (spec-compliant).
//   • Labels are always visible for all destinations.
//   • 80dp bar height + safe-area padding (NavigationBar default).
//   • Icon/label colours themed to the app's green palette.
//
// Tab switch animation:
//   Tapping a different tab triggers a 120 ms fade-out of the current content,
//   switches the IndexedStack, then fades back in over 180 ms. Re-tapping the
//   active tab pops to the branch root (no fade needed).

import 'package:customer/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppShell extends StatefulWidget {
  const AppShell({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell>
    with SingleTickerProviderStateMixin {
  late final AnimationController _fadeCtrl;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
      value: 1.0,
    );
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    super.dispose();
  }

  Future<void> _goBranch(int index) async {
    // Re-tap active tab → pop to root of that branch, no fade.
    if (index == widget.navigationShell.currentIndex) {
      widget.navigationShell.goBranch(index, initialLocation: true);
      return;
    }
    // Fade out current content.
    _fadeCtrl.stop();
    await _fadeCtrl.animateTo(
      0.0,
      duration: const Duration(milliseconds: 120),
      curve: Curves.easeOut,
    );
    if (!mounted) return;
    // Switch tab (IndexedStack update).
    widget.navigationShell.goBranch(index, initialLocation: false);
    // Fade in new content.
    _fadeCtrl.animateTo(
      1.0,
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeIn,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      body: FadeTransition(
        opacity: _fadeCtrl,
        child: widget.navigationShell,
      ),
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
                color:
                    active ? const Color(0xFF166534) : const Color(0xFF6B7280),
              );
            }),
            labelTextStyle: WidgetStateProperty.resolveWith((states) {
              final active = states.contains(WidgetState.selected);
              return TextStyle(
                fontSize: 12,
                fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                color:
                    active ? const Color(0xFF166534) : const Color(0xFF6B7280),
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
            selectedIndex: widget.navigationShell.currentIndex,
            onDestinationSelected: _goBranch,
            destinations: [
              NavigationDestination(
                icon: const Icon(Icons.explore_outlined),
                selectedIcon: const Icon(Icons.explore),
                label: l10n.navMap,
              ),
              NavigationDestination(
                icon: const Icon(Icons.event_note_outlined),
                selectedIcon: const Icon(Icons.event_note),
                label: l10n.navBookings,
              ),
              NavigationDestination(
                icon: const Icon(Icons.group_outlined),
                selectedIcon: const Icon(Icons.group),
                label: l10n.navSlots,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
