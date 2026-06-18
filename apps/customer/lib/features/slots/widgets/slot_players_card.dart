// Players card for the slot detail screen: fullness badge, player rows and
// empty slot rows. Extracted from slot_detail_screen.dart.

import 'package:customer/features/slots/slot_detail_style.dart';
import 'package:flutter/material.dart';

class PlayersCard extends StatelessWidget {
  const PlayersCard({
    super.key,
    required this.joined,
    required this.max,
    required this.isFull,
    required this.empties,
  });

  final int joined;
  final int max;
  final bool isFull;
  final int empties;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFFFFFFF),
      borderRadius: BorderRadius.circular(mdCornerMd),
      elevation: 1,
      shadowColor: const Color(0x1A000000),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Người chơi',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: mdOnSurface,
                  ),
                ),
                _FullnessBadge(joined: joined, max: max, isFull: isFull),
              ],
            ),
            // Segmented fullness track
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Row(
                children: List.generate(
                  max,
                  (i) => Expanded(
                    child: Container(
                      height: 4,
                      margin: EdgeInsets.only(right: i < max - 1 ? 4 : 0),
                      decoration: BoxDecoration(
                        color: i < joined
                            ? mdPrimary
                            : mdSurfaceContainerHighest,
                        borderRadius: BorderRadius.circular(mdCornerFull),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isFull
                  ? 'Slot đã đầy. Hãy thử slot khác cùng giờ ở khu vực của bạn.'
                  : 'Còn $empties chỗ trống · Cấp độ trung bình',
              style: const TextStyle(fontSize: 13, color: mdOnSurfaceVariant),
            ),
            Divider(height: 28, color: mdOutlineVariant.withAlpha(128)),
            // Filled player rows
            ...List.generate(joined, (i) => _PlayerRow(index: i, filled: true)),
            // Empty slots
            if (!isFull)
              ...List.generate(empties, (_) => const _EmptySlotRow()),
          ],
        ),
      ),
    );
  }
}

class _FullnessBadge extends StatelessWidget {
  const _FullnessBadge({
    required this.joined,
    required this.max,
    required this.isFull,
  });

  final int joined;
  final int max;
  final bool isFull;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 24,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: isFull ? mdSurfaceContainerHighest : mdPrimaryContainer,
        borderRadius: BorderRadius.circular(mdCornerFull),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isFull ? const Color(0xFF72796C) : mdPrimary,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            isFull ? 'Đã đủ người' : '$joined/$max người',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: isFull ? mdOnSurfaceVariant : mdOnPrimaryContainer,
            ),
          ),
        ],
      ),
    );
  }
}

class _PlayerRow extends StatelessWidget {
  const _PlayerRow({required this.index, required this.filled});

  final int index;
  final bool filled;

  static const _colors = [
    Color(0xFF15803D),
    Color(0xFF0369A1),
    Color(0xFFEAB308),
    Color(0xFFEF4444),
  ];

  @override
  Widget build(BuildContext context) {
    final color = _colors[index % _colors.length];
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: color,
            child: Text(
              '${index + 1}',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Người chơi ${index + 1}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: mdOnSurface,
                      ),
                    ),
                    if (index == 0) ...[
                      const SizedBox(width: 8),
                      Container(
                        height: 20,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        decoration: BoxDecoration(
                          color: mdPrimaryContainer,
                          borderRadius: BorderRadius.circular(mdCornerFull),
                        ),
                        child: const Center(
                          child: Text(
                            'Chủ slot',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: mdOnPrimaryContainer,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const Text(
                  '⭐ 4.7 · đã tham gia',
                  style: TextStyle(fontSize: 12, color: mdOnSurfaceVariant),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptySlotRow extends StatelessWidget {
  const _EmptySlotRow();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: mdSurfaceContainer,
              shape: BoxShape.circle,
              border: Border.all(
                color: mdOutlineVariant,
                width: 1.5,
                style: BorderStyle.solid,
              ),
            ),
            child: const Center(
              child: Text(
                '+',
                style: TextStyle(fontSize: 20, color: mdOnSurfaceVariant),
              ),
            ),
          ),
          const SizedBox(width: 16),
          const Text(
            'Chỗ trống',
            style: TextStyle(fontSize: 14, color: mdOnSurfaceVariant),
          ),
        ],
      ),
    );
  }
}
