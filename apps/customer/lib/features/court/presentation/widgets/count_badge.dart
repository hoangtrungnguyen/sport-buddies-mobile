import 'package:flutter/material.dart';

import '../../theme/app_tokens.dart';

/// Tonal pill + leading dot (doc 01 §5 / doc 02 §8): "3 slot".
class CountBadge extends StatelessWidget {
  const CountBadge({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      height: AppTokens.badgeHeight,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: scheme.primaryContainer,
        borderRadius: AppTokens.radiusFull,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: scheme.primary, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: scheme.onPrimaryContainer,
              fontFeatures: AppTokens.tnum,
            ),
          ),
        ],
      ),
    );
  }
}
