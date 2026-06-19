// Hero section for the slot detail screen: cover, sport/court info and the
// assist chips. Extracted from slot_detail_screen.dart.

import 'package:customer/features/slots/slots_style.dart';
import 'package:flutter/material.dart';
import 'package:spb_core/spb_core.dart';

class HeroSection extends StatelessWidget {
  const HeroSection({super.key, required this.slot});

  final Slot slot;

  static IconData _sportIcon(String sport) => switch (sport) {
    'football' => Icons.sports_soccer,
    'badminton' => Icons.sports_tennis,
    'pickleball' => Icons.sports_tennis,
    'tennis' => Icons.sports_tennis,
    _ => Icons.sports,
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      color: mdSurfaceContainerLow,
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Primary-container sport icon
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: mdPrimaryContainer,
              borderRadius: BorderRadius.circular(mdCornerXl),
            ),
            child: Icon(
              _sportIcon(slot.sportType),
              size: 28,
              color: mdOnPrimaryContainer,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  slot.courtName,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: mdOnSurface,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Xem bản đồ',
                  style: TextStyle(fontSize: 13, color: mdOnSurfaceVariant),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    if (slot.accessPolicy == 'open')
                      const _AssistChip(label: '🌐 Mở chơi ghép'),
                    _AssistChip(label: slot.sportType),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AssistChip extends StatelessWidget {
  const _AssistChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 32,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: mdOutlineVariant),
        borderRadius: BorderRadius.circular(mdCornerSm),
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: mdOnSurfaceVariant,
        ),
      ),
    );
  }
}
