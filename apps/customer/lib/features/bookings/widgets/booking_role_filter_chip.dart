// Pill-shaped filter chip used in the Upcoming/History booking tab filter rows.
// Extracted from booking_tab_views.dart.

import 'package:customer/features/bookings/bookings_style.dart';
import 'package:flutter/material.dart';

class RoleFilterChip extends StatelessWidget {
  const RoleFilterChip({
    super.key,
    required this.label,
    required this.value,
    required this.isActive,
    required this.onTap,
    this.leading,
  });

  final String label;
  final String? value;
  final bool isActive;
  final VoidCallback onTap;
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 36,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: isActive ? mdPrimary : mdSurfaceContainerLowest,
          borderRadius: BorderRadius.circular(99),
          border: Border.all(color: isActive ? mdPrimary : mdOutlineVariant),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (leading != null) ...[leading!, const SizedBox(width: 6)],
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isActive ? Colors.white : mdOnSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
