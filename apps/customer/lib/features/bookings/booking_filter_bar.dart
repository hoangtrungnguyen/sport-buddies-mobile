// Bookings feature — BookingFilterBar widget.
//
// A stateless horizontal row of [FilterChip]s that lets the user narrow the
// bookings list by status.
//
// Chips: All | Pending | Confirmed | Completed | Cancelled
//
// Usage:
//   BookingFilterBar(
//     selectedStatus: state.selectedStatus,   // null == 'All'
//     onFilterChanged: (status) => context.read<BookingsCubit>().filterByStatus(status),
//   )

import 'package:flutter/material.dart';

/// Stateless widget that renders a scrollable row of status filter chips.
///
/// [selectedStatus] — the currently active filter value, or `null` for "All".
/// [onFilterChanged] — called with the new status string when a chip is tapped,
///   or `null` when the "All" chip is tapped.
class BookingFilterBar extends StatelessWidget {
  const BookingFilterBar({
    super.key,
    required this.selectedStatus,
    required this.onFilterChanged,
  });

  final String? selectedStatus;
  final void Function(String?) onFilterChanged;

  static const _chips = [
    (label: 'All', value: null),
    (label: 'Pending', value: 'pending'),
    (label: 'Confirmed', value: 'confirmed'),
    (label: 'Completed', value: 'completed'),
    (label: 'Cancelled', value: 'cancelled'),
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _chips.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final chip = _chips[index];
          final isSelected = chip.value == selectedStatus;
          return FilterChip(
            label: Text(chip.label),
            selected: isSelected,
            onSelected: (_) => onFilterChanged(chip.value),
          );
        },
      ),
    );
  }
}
