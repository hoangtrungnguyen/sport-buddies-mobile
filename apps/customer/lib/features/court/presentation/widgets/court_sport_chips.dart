// Sport chip row for the court detail screen.
// Extracted from court_detail_page.dart.

import 'package:flutter/material.dart';

import '../../domain/court.dart';
import '../../theme/app_tokens.dart';
import 'sport_style.dart';

class SportChips extends StatelessWidget {
  const SportChips({super.key, required this.sports});

  final List<Sport> sports;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (var i = 0; i < sports.length; i++)
          _Chip(
            selected: i == 0,
            icon: SportStyle.icon(sports[i]),
            label: SportStyle.label(sports[i]),
            scheme: scheme,
            text: text,
          ),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.selected,
    required this.icon,
    required this.label,
    required this.scheme,
    required this.text,
  });

  final bool selected;
  final IconData icon;
  final String label;
  final ColorScheme scheme;
  final TextTheme text;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: AppTokens.chipHeight,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: selected ? scheme.primaryContainer : scheme.surface,
        borderRadius: AppTokens.radiusSm,
        border: selected ? null : Border.all(color: scheme.outlineVariant),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: selected
                ? scheme.onPrimaryContainer
                : scheme.onSurfaceVariant,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: text.labelLarge?.copyWith(
              color: selected
                  ? scheme.onPrimaryContainer
                  : scheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
