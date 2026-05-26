// Bookings feature — BookingTile widget.
//
// Displays a single booking entry in the upcoming bookings list.
//
// Shows:
//   - Court name
//   - Date (e.g. "Mon, 15 Jun 2026")
//   - Time range (e.g. "10:00 – 11:00")
//   - Status badge (colour-coded chip)
//   - Cancel button — only rendered when booking.status == 'pending'
//     AND an [onCancel] callback is provided (grava-654b.3.3).

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'booking_model.dart';

class BookingTile extends StatelessWidget {
  const BookingTile({
    super.key,
    required this.booking,
    this.onCancel,
  });

  final Booking booking;

  /// Called when the user taps the cancel button.
  ///
  /// If null, the cancel button is not shown regardless of booking status.
  final VoidCallback? onCancel;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final slot = booking.slot;

    final dateStr = DateFormat('EEE, d MMM yyyy').format(slot.startTime);
    final startStr = DateFormat('HH:mm').format(slot.startTime);
    final endStr = DateFormat('HH:mm').format(slot.endTime);

    final showCancelButton =
        booking.status == 'pending' && onCancel != null;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    slot.court.name,
                    style: textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(dateStr, style: textTheme.bodyMedium),
                  const SizedBox(height: 2),
                  Text(
                    '$startStr – $endStr',
                    style: textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            _StatusBadge(status: booking.status),
            if (showCancelButton) ...[
              const SizedBox(width: 4),
              IconButton(
                key: const Key('cancel_booking_button'),
                icon: const Icon(Icons.cancel_outlined),
                tooltip: 'Cancel booking',
                onPressed: onCancel,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final String status;

  Color _badgeColor() {
    return switch (status) {
      'confirmed' => Colors.green,
      'pending' => Colors.orange,
      'cancelled' => Colors.red,
      _ => Colors.grey,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(
        status,
        style: const TextStyle(color: Colors.white, fontSize: 12),
      ),
      backgroundColor: _badgeColor(),
      padding: const EdgeInsets.symmetric(horizontal: 4),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
}
