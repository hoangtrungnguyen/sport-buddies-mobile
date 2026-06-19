// Animated status toast for the participant management screen.
// Extracted from participant_management_screen.dart.

import 'package:customer/features/slots/slots_style.dart';
import 'package:flutter/material.dart';

class ToastWidget extends StatelessWidget {
  const ToastWidget({super.key, required this.message, required this.isDanger});

  final String message;
  final bool isDanger;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF111827),
        borderRadius: BorderRadius.circular(mdCornerMd),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: isDanger
                  ? const Color(0xFFEF4444)
                  : const Color(0xFF22C55E),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Icon(
              isDanger ? Icons.close : Icons.check,
              size: 14,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
