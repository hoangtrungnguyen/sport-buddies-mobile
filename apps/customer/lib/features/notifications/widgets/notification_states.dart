// Empty-state and error-state views for the notifications screen.
// Extracted from notifications_screen.dart.

import 'package:customer/features/notifications/notifications_style.dart';
import 'package:flutter/material.dart';

class EmptyState extends StatelessWidget {
  const EmptyState({super.key, required this.filter});

  final String filter;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.notifications_off_outlined,
            size: 56,
            color: mdOutlineVariant,
          ),
          const SizedBox(height: 12),
          const Text(
            'Không có thông báo',
            style: TextStyle(color: mdOnSurfaceVariant, fontSize: 15),
          ),
          if (filter != 'Tất cả') ...[
            const SizedBox(height: 4),
            Text(
              'trong mục $filter',
              style: const TextStyle(color: mdOutlineVariant, fontSize: 13),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Error state ───────────────────────────────────────────────────────────────

class ErrorState extends StatelessWidget {
  const ErrorState({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 56, color: mdError),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: mdOnSurfaceVariant, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
