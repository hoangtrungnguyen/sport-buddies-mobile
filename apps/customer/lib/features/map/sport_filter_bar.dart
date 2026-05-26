// SportFilterBar — grava-c9ca.3.1
//
// A horizontally scrollable row of FilterChip widgets displayed at the top of
// the map screen.  Exposes a stateless, value-driven API; the parent (e.g.
// BlocBuilder wrapping MapFilterCubit) owns the selected state.

import 'package:flutter/material.dart';

/// One entry in the sport filter list.
@immutable
class _SportEntry {
  const _SportEntry({required this.label, required this.slug});

  /// Human-readable label shown on the chip.
  final String label;

  /// Lower-case identifier used in [MapFilterState.selectedSports].
  /// Empty string means "All".
  final String slug;
}

/// All supported sports.  The empty-slug entry ("All") is first so it appears
/// at the leading edge of the scroll view.
const List<_SportEntry> _kSports = [
  _SportEntry(label: 'All', slug: ''),
  _SportEntry(label: 'Football', slug: 'football'),
  _SportEntry(label: 'Basketball', slug: 'basketball'),
  _SportEntry(label: 'Tennis', slug: 'tennis'),
  _SportEntry(label: 'Badminton', slug: 'badminton'),
  _SportEntry(label: 'Pickleball', slug: 'pickleball'),
];

/// Horizontal scrollable row of [FilterChip] widgets for sport-type filtering.
///
/// ### Usage
///
/// ```dart
/// BlocBuilder<MapFilterCubit, MapFilterState>(
///   builder: (context, state) => SportFilterBar(
///     selectedSports: state.selectedSports,
///     onSportsChanged: context.read<MapFilterCubit>().filterBySports,
///   ),
/// )
/// ```
///
/// - [selectedSports] — the set of currently selected sport slugs.  An empty
///   set means "All" is active.
/// - [onSportsChanged] — called with the new set of selected sport slugs after
///   the user taps a chip.  Pass an empty set to reset to "All".
class SportFilterBar extends StatelessWidget {
  const SportFilterBar({
    super.key,
    required this.selectedSports,
    required this.onSportsChanged,
  });

  final Set<String> selectedSports;
  final void Function(Set<String> sports) onSportsChanged;

  void _handleTap(_SportEntry entry) {
    if (entry.slug.isEmpty) {
      // "All" chip tapped — clear selection.
      onSportsChanged(const {});
      return;
    }

    final updated = Set<String>.from(selectedSports);
    if (updated.contains(entry.slug)) {
      updated.remove(entry.slug);
    } else {
      updated.add(entry.slug);
    }
    onSportsChanged(updated);
  }

  bool _isSelected(_SportEntry entry) {
    if (entry.slug.isEmpty) {
      // "All" is selected only when no sport-specific filter is active.
      return selectedSports.isEmpty;
    }
    return selectedSports.contains(entry.slug);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: _kSports.map((entry) {
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(entry.label),
              selected: _isSelected(entry),
              onSelected: (_) => _handleTap(entry),
            ),
          );
        }).toList(),
      ),
    );
  }
}
