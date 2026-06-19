// Header + sport filter chips for the open-slot list screen.
// Extracted from open_slot_list_screen.dart.

import 'package:customer/l10n/app_localizations.dart';
import 'package:customer/features/slots/slots_style.dart';
import 'package:flutter/material.dart';

/// Quick-filter labels, ordered: all · football · pickleball · badminton · tennis.
List<String> _filterLabels(AppLocalizations l10n) => [
  l10n.sportAll,
  l10n.sportFootball,
  l10n.sportPickleball,
  l10n.sportBadminton,
  l10n.sportTennis,
];

class Header extends StatelessWidget {
  const Header({
    super.key,
    required this.selectedFilter,
    required this.onFilterSelected,
  });

  final int selectedFilter;
  final ValueChanged<int> onFilterSelected;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final filterLabels = _filterLabels(l10n);
    return Container(
      color: mdSurfaceContainerLow,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: MediaQuery.of(context).padding.top + 8),
          // Title row
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.slotsTitle,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: mdOnSurface,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        l10n.slotsSubtitle,
                        style: const TextStyle(
                          fontSize: 12,
                          color: mdOnSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Filter chips
          SizedBox(
            height: 52,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              itemCount: filterLabels.length + 1,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) {
                if (i < filterLabels.length) {
                  return _FilterChip(
                    label: filterLabels[i],
                    selected: selectedFilter == i,
                    onTap: () => onFilterSelected(i),
                  );
                }
                // Distance chip (non-interactive for now)
                return _FilterChip(
                  label: l10n.distanceWithin5,
                  selected: false,
                  onTap: () {},
                );
              },
            ),
          ),
          Divider(height: 1, color: mdOutlineVariant.withAlpha(128)),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: selected ? mdPrimaryContainer : Colors.transparent,
          borderRadius: BorderRadius.circular(mdCornerSm),
          border: Border.all(
            color: selected ? mdPrimary : mdOutlineVariant,
            width: selected ? 0 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (selected) ...[
              const Icon(Icons.check, size: 14, color: mdOnPrimaryContainer),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: selected ? mdOnPrimaryContainer : mdOnSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
