// Time & price card for the slot detail screen.
// Extracted from slot_detail_screen.dart.

import 'package:customer/features/slots/slots_style.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:spb_core/spb_core.dart';

class TimeCard extends StatelessWidget {
  const TimeCard({super.key, required this.slot});

  final Slot slot;

  @override
  Widget build(BuildContext context) {
    final timeFmt = DateFormat('HH:mm');
    final dateFmt = DateFormat('EEE, dd/MM', 'vi');
    final durationH = slot.endTime.difference(slot.startTime).inMinutes / 60;
    final durLabel = durationH == durationH.roundToDouble()
        ? '${durationH.toInt()} giờ'
        : '${durationH.toStringAsFixed(1)} giờ';

    return Material(
      color: const Color(0xFFFFFFFF),
      borderRadius: BorderRadius.circular(mdCornerMd),
      elevation: 1,
      shadowColor: const Color(0x1A000000),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'THỜI GIAN',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: mdOnSurfaceVariant,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${timeFmt.format(slot.startTime.toLocal())} – ${timeFmt.format(slot.endTime.toLocal())}',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: mdOnSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${dateFmt.format(slot.startTime.toLocal())} · $durLabel',
                    style: const TextStyle(
                      fontSize: 12,
                      color: mdOnSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
