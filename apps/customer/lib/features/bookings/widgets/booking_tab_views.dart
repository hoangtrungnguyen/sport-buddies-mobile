// The three My Bookings tab bodies (Upcoming / Pending / History) plus the
// error view, role legend, filter chips and date section header they share.
// Each view is fed data via its constructor — no cubit access here.

import 'package:customer/features/bookings/booking_view.dart';
import 'package:customer/features/bookings/bookings_style.dart';
import 'package:customer/features/bookings/widgets/booking_card.dart';
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
              _RoleFilterChip(
                label: '${l10n.bookingsFilterAll} · ${allBookings.length}',
                value: null,
                isActive: activeFilter == null,
                onTap: () => onFilterChanged(null),
              ),
              const SizedBox(width: 8),
              _RoleFilterChip(
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
              _RoleFilterChip(
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
              _RoleFilterChip(
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
        const _RoleLegend(),
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
            _SectionHeader(label: group.key),
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
        _SectionHeader(label: l10n.bookingsPendingHeader),
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
              _RoleFilterChip(
                label: l10n.bookingsFilterAll,
                value: null,
                isActive: activeFilter == null,
                onTap: () => onFilterChanged(null),
              ),
              const SizedBox(width: 8),
              _RoleFilterChip(
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
              _RoleFilterChip(
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
              _RoleFilterChip(
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

// ─── Role legend ──────────────────────────────────────────────────────────────

class _RoleLegend extends StatelessWidget {
  const _RoleLegend();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: mdSurfaceContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _LegendItem(
            color: mdPrimary,
            label: AppLocalizations.of(context).bookingsLegendHost,
          ),
          const SizedBox(width: 16),
          _LegendItem(
            color: mdSecondary,
            label: AppLocalizations.of(context).bookingsLegendJoin,
          ),
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 4,
          height: 18,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 7),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: mdOnSurfaceVariant),
        ),
      ],
    );
  }
}

// ─── Filter chips ─────────────────────────────────────────────────────────────

class _RoleFilterChip extends StatelessWidget {
  const _RoleFilterChip({
    required this.label,
    required this.value,
    required this.isActive,
    required this.onTap,
    this.leading,
  });

  final String label;
  final String? value;
  final bool isActive;
  final VoidCallback onTap;
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 36,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: isActive ? mdPrimary : mdSurfaceContainerLowest,
          borderRadius: BorderRadius.circular(99),
          border: Border.all(color: isActive ? mdPrimary : mdOutlineVariant),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (leading != null) ...[leading!, const SizedBox(width: 6)],
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isActive ? Colors.white : mdOnSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Section header ───────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        fontFamily: 'Plus Jakarta Sans',
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: mdOnSurfaceVariant,
        letterSpacing: 0.5,
      ),
    );
  }
}
