// Time-slot grid and tile for the recurring-booking screen.
// Extracted from recurring_booking_screen.dart.

import 'package:customer/features/recurring/widgets/recurring_common.dart';
import 'package:flutter/material.dart';

class TimeSlotGrid extends StatelessWidget {
  const TimeSlotGrid({super.key});

  static const _timeSlots = [
    TimeSlotItem(time: '06:00 – 07:30', price: '150k', selected: false),
    TimeSlotItem(time: '07:30 – 09:00', price: '150k', selected: false),
    TimeSlotItem(time: '19:00 – 20:30', price: '250k', selected: true),
    TimeSlotItem(time: '20:30 – 22:00', price: '250k', selected: false),
  ];

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      childAspectRatio: 2.6,
      children: _timeSlots.map((s) => _TimeSlotTile(item: s)).toList(),
    );
  }
}

class _TimeSlotTile extends StatelessWidget {
  const _TimeSlotTile({required this.item});

  final TimeSlotItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: item.selected ? const Color(0xFFDCFCE7) : Colors.white,
        border: Border.all(
          color: item.selected
              ? const Color(0xFF16A34A)
              : const Color(0xFFE5E7EB),
          width: item.selected ? 2.0 : 1.0,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          if (item.selected)
            Container(
              width: 18,
              height: 18,
              margin: const EdgeInsets.only(right: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF16A34A),
                borderRadius: BorderRadius.circular(5),
              ),
              child: const Icon(Icons.check, size: 12, color: Colors.white),
            ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  item.time,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: item.selected
                        ? const Color(0xFF15803D)
                        : const Color(0xFF111827),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  item.price,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
