// Host message card for the slot detail screen.
// Extracted from slot_detail_screen.dart.

import 'package:customer/features/slots/slots_style.dart';
import 'package:flutter/material.dart';

class HostMessageCard extends StatelessWidget {
  const HostMessageCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: mdSurfaceContainerLow,
        borderRadius: BorderRadius.circular(mdCornerMd),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'LỜI NHẮN TỪ CHỦ SLOT',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: mdOnSurfaceVariant,
              letterSpacing: 1,
            ),
          ),
          SizedBox(height: 10),
          Text(
            '"Mình tìm bạn chơi ghép. Mang vợt + giày sạch nhé. Cảm ơn 🏓"',
            style: TextStyle(
              fontSize: 14,
              color: mdOnSurface,
              fontStyle: FontStyle.italic,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
