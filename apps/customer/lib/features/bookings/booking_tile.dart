// Bookings feature — BookingTile widget.
//
// Displays a single booking entry in the upcoming bookings list.
//
// Shows:
//   - Court name
//   - Date (e.g. "Mon, 15 Jun 2026")
//   - Time range (e.g. "10:00 – 11:00")
//   - Status badge (colour-coded chip)
//   - Type badge (blue accent chip: 'Một lần' | 'Định kỳ')

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
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _StatusBadge(status: booking.status),
                const SizedBox(height: 6),
                _TypeBadge(bookingType: booking.bookingType),
              ],
            ),
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

class _TypeBadge extends StatelessWidget {
  const _TypeBadge({required this.bookingType});

  final String bookingType;

  String _label() {
    return switch (bookingType) {
      'recurring' => 'Định kỳ',
      _ => 'Một lần',
    };
  }

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(
        _label(),
        style: const TextStyle(color: Colors.white, fontSize: 12),
      ),
      backgroundColor: Colors.blueAccent,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
}
