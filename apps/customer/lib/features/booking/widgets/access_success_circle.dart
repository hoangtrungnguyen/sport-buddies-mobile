// Animated success circle for the access-control confirmation state.
// Extracted from access_control_screen.dart.

import 'package:flutter/material.dart';

class SuccessCircle extends StatelessWidget {
  const SuccessCircle({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      decoration: const BoxDecoration(
        color: Color(0xFF16A34A),
        shape: BoxShape.circle,
      ),
      child: const Icon(Icons.check_rounded, size: 18, color: Colors.white),
    );
  }
}
