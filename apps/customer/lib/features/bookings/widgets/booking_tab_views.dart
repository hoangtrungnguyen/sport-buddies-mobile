// The three My Bookings tab bodies (Upcoming / Pending / History) plus the
// error view. The shared role legend, filter chips and date section header
// live in sibling files. Each view is fed data via its constructor — no cubit
// access here.

import 'package:customer/features/bookings/booking_view.dart';
import 'package:customer/features/bookings/bookings_style.dart';
import 'package:customer/features/bookings/widgets/booking_card.dart';
import 'package:customer/features/bookings/widgets/booking_role_filter_chip.dart';
import 'package:customer/features/bookings/widgets/booking_role_legend.dart';
import 'package:customer/features/bookings/widgets/booking_section_header.dart';
import 'package:customer/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

// ─── Upcoming tab ─────────────────────────────────────────────────────────────

class UpcomingTabView extends StatelessWidget {
  const UpcomingTabView({
    super.key,
    required this.bookings,
    required this.allBookings,
    required this.activeFilter,
    required this.onFilterChanged,
  });

  final List<BookingView> bookings;
  final List<BookingView> allBookings;
  final String? activeFilter;
  final ValueChanged<String?> onFilterChanged;

  List<MapEntry<String, List<BookingView>>> _groupByDate(
    AppLocalizations l10n,
  ) {
    final grouped = <String, List<BookingView>>{};
    for (final b in bookings) {
      final key = dateSectionLabel(l10n, b.date);
      grouped.putIfAbsent(key, () => []).add(b);
    }
    return grouped.entries.toList();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final groups = _groupByDate(l10n);
    final hostCount = allBookings
        .where((b) => b.role == BookingRole.host)
        .length;
    final joinCount = allBookings
        .where((b) => b.role == BookingRole.join)
        .length;
    final recurringCount = allBookings
        .where((b) => b.type == BookingType.recurring)
        .length;

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
      children: [
        SizedBox(
          height: 36,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              RoleFilterChip(
                label: '${l10n.bookingsFilterAll} · ${allBookings.length}',
                value: null,
                isActive: activeFilter == null,
                onTap: () => onFilterChanged(null),
              ),
              const SizedBox(width: 8),
              RoleFilterChip(
                label: '${l10n.bookingsFilterHost} · $hostCount',
                value: 'host',
                isActive: activeFilter == 'host',
                leading: HostCrown(
                  color: activeFilter == 'host'
                      ? mdOnPrimaryContainer
                      : mdPrimary,
                  size: 12,
                ),
                onTap: () =>
                    onFilterChanged(activeFilter == 'host' ? null : 'host'),
              ),
              const SizedBox(width: 8),
              RoleFilterChip(
                label: '${l10n.bookingsFilterJoin} · $joinCount',
                value: 'join',
                isActive: activeFilter == 'join',
                leading: Container(
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(
                    color: activeFilter == 'join'
                        ? mdOnSecondaryContainer
                        : mdSecondary,
                    shape: BoxShape.circle,
                  ),
                ),
                onTap: () =>
                    onFilterChanged(activeFilter == 'join' ? null : 'join'),
              ),
              const SizedBox(width: 8),
              RoleFilterChip(
                label: '${l10n.bookingsFilterRecurring} · $recurringCount',
                value: 'recurring',
                isActive: activeFilter == 'recurring',
                onTap: () => onFilterChanged(
                  activeFilter == 'recurring' ? null : 'recurring',
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        const RoleLegend(),
        const SizedBox(height: 8),
        if (groups.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 40),
            child: Center(
              child: Text(
                l10n.bookingsEmptyUpcoming,
                style: const TextStyle(color: mdOnSurfaceVariant),
              ),
            ),
          )
        else
          for (final group in groups) ...[
            const SizedBox(height: 6),
            BookingSectionHeader(label: group.key),
            const SizedBox(height: 8),
            for (final booking in group.value) ...[
              BookingCard(booking: booking),
              const SizedBox(height: 10),
            ],
          ],
      ],
    );
  }
}

// ─── Pending tab ──────────────────────────────────────────────────────────────

class PendingTabView extends StatelessWidget {
  const PendingTabView({super.key, required this.pending});

  final List<BookingView> pending;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (pending.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 80),
            child: Center(
              child: Text(
                l10n.bookingsEmptyPending,
                style: const TextStyle(color: mdOnSurfaceVariant),
              ),
            ),
          ),
        ],
      );
    }

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
      children: [
        BookingSectionHeader(label: l10n.bookingsPendingHeader),
        const SizedBox(height: 8),
        for (final b in pending) ...[
          BookingCard(booking: b),
          const SizedBox(height: 10),
        ],
      ],
    );
  }
}

// ─── History tab ──────────────────────────────────────────────────────────────

class HistoryTabView extends StatelessWidget {
  const HistoryTabView({
    super.key,
    required this.bookings,
    required this.activeFilter,
    required this.onFilterChanged,
  });

  final List<BookingView> bookings;
  final String? activeFilter;
  final ValueChanged<String?> onFilterChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
      children: [
        SizedBox(
          height: 36,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              RoleFilterChip(
                label: l10n.bookingsFilterAll,
                value: null,
                isActive: activeFilter == null,
                onTap: () => onFilterChanged(null),
              ),
              const SizedBox(width: 8),
              RoleFilterChip(
                label: l10n.bookingsFilterHost,
                value: 'host',
                isActive: activeFilter == 'host',
                leading: HostCrown(
                  color: activeFilter == 'host'
                      ? mdOnPrimaryContainer
                      : mdPrimary,
                  size: 12,
                ),
                onTap: () =>
                    onFilterChanged(activeFilter == 'host' ? null : 'host'),
              ),
              const SizedBox(width: 8),
              RoleFilterChip(
                label: l10n.bookingsFilterJoin,
                value: 'join',
                isActive: activeFilter == 'join',
                leading: Container(
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(
                    color: activeFilter == 'join'
                        ? mdOnSecondaryContainer
                        : mdSecondary,
                    shape: BoxShape.circle,
                  ),
                ),
                onTap: () =>
                    onFilterChanged(activeFilter == 'join' ? null : 'join'),
              ),
              const SizedBox(width: 8),
              RoleFilterChip(
                label: l10n.bookingsFilterCompleted,
                value: 'completed',
                isActive: activeFilter == 'completed',
                onTap: () => onFilterChanged(
                  activeFilter == 'completed' ? null : 'completed',
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        if (bookings.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 40),
            child: Center(
              child: Text(
                l10n.bookingsEmptyHistory,
                style: const TextStyle(color: mdOnSurfaceVariant),
              ),
            ),
          )
        else
          for (final booking in bookings) ...[
            BookingCard(booking: booking),
            const SizedBox(height: 10),
          ],
      ],
    );
  }
}

// ─── Error view ───────────────────────────────────────────────────────────────

class ErrorView extends StatelessWidget {
  const ErrorView({super.key, required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: mdOnSurfaceVariant),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onRetry,
              child: Text(AppLocalizations.of(context).commonRetry),
            ),
          ],
        ),
      ),
    );
  }
}
