// Bookings feature — BookingTile widget.
//
// Displays a single booking entry in the upcoming bookings list.
//
// Shows:
//   - Court name
//   - Date (e.g. "Mon, 15 Jun 2026")
//   - Time range (e.g. "10:00 – 11:00")
//   - Status badge (colour-coded chip)

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'booking_model.dart';

class BookingTile extends StatelessWidget {
  const BookingTile({super.key, required this.booking});

  final Booking booking;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final slot = booking.slot;

    final dateStr = DateFormat('EEE, d MMM yyyy').format(slot.startTime);
    final startStr = DateFormat('HH:mm').format(slot.startTime);
    final endStr = DateFormat('HH:mm').format(slot.endTime);

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
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final String status;

  /// Returns the background colour for the given booking status.
  ///
  /// Mapping:
  ///   pending   → amber
  ///   confirmed → green
  ///   completed → grey
  ///   cancelled → red
  ///   (other)   → grey
  Color _badgeColor() {
    return switch (status) {
      'pending' => Colors.amber,
      'confirmed' => Colors.green,
      'completed' => Colors.grey,
      'cancelled' => Colors.red,
      _ => Colors.grey,
    };
  }

  /// Returns the localised Vietnamese label for the given booking status.
  String _badgeLabel() {
    return switch (status) {
      'pending' => 'Chờ xác nhận',
      'confirmed' => 'Đã xác nhận',
      'completed' => 'Hoàn thành',
      'cancelled' => 'Đã huỷ',
      _ => status,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(
        _badgeLabel(),
        style: const TextStyle(color: Colors.white, fontSize: 12),
      ),
      backgroundColor: _badgeColor(),
      padding: const EdgeInsets.symmetric(horizontal: 4),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
}
