// Horizontal venue photo strip for the slot picker.
// Extracted from slot_picker_page.dart.

import 'package:flutter/material.dart';

import '../../theme/app_tokens.dart';

class PhotoStrip extends StatelessWidget {
  const PhotoStrip({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 118,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.zero,
        itemCount: 5,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) => ClipRRect(
          borderRadius: AppTokens.radiusLg,
          child: SizedBox(
            width: i == 0 ? 200 : 150,
            child: const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF16A34A), Color(0xFF0EA5E9)],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
