// Schedule controls for the recurring-booking screen: repeat/end chips,
// day-of-week selector, start-date row and session count stepper. Extracted
// from recurring_booking_screen.dart.

import 'package:customer/features/recurring/widgets/recurring_common.dart';
import 'package:flutter/material.dart';

class RepeatChips extends StatelessWidget {
  const RepeatChips({super.key});

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        RecurringChip(label: 'Hằng ngày', active: false),
        SizedBox(width: 6),
        RecurringChip(label: 'Hằng tuần', active: false),
        SizedBox(width: 6),
        RecurringChip(label: 'Chọn thứ', active: true),
      ],
    );
  }
}

class DowSelector extends StatelessWidget {
  const DowSelector({super.key});

  static const _days = [
    DayItem(label: 'T2', active: false),
    DayItem(label: 'T3', active: true),
    DayItem(label: 'T4', active: false),
    DayItem(label: 'T5', active: true),
    DayItem(label: 'T6', active: false),
    DayItem(label: 'T7', active: false),
    DayItem(label: 'CN', active: false),
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: _days.map((d) {
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: d.active ? const Color(0xFF16A34A) : Colors.white,
                border: Border.all(
                  color: d.active
                      ? const Color(0xFF16A34A)
                      : const Color(0xFFE5E7EB),
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  d.label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: d.active ? Colors.white : const Color(0xFF111827),
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class StartDateRow extends StatelessWidget {
  const StartDateRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE5E7EB)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFDCFCE7),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.calendar_today_outlined,
              size: 20,
              color: Color(0xFF15803D),
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Thứ ba, 14/05/2026',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF111827),
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Buổi đầu tiên · còn 2 ngày',
                  style: TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: Color(0xFF6B7280)),
        ],
      ),
    );
  }
}

class EndChips extends StatelessWidget {
  const EndChips({super.key});

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        RecurringChip(label: 'Sau N buổi', active: true),
        SizedBox(width: 6),
        RecurringChip(label: 'Đến ngày', active: false),
        SizedBox(width: 6),
        RecurringChip(label: 'Không kết thúc', active: false),
      ],
    );
  }
}

class SessionCountRow extends StatelessWidget {
  const SessionCountRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE5E7EB)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Row(
        children: [
          _CountBtn(label: '−', isPrimary: false),
          Expanded(
            child: Center(
              child: Text(
                '8',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF111827),
                ),
              ),
            ),
          ),
          _CountBtn(label: '+', isPrimary: true),
        ],
      ),
    );
  }
}

class _CountBtn extends StatelessWidget {
  const _CountBtn({required this.label, required this.isPrimary});

  final String label;
  final bool isPrimary;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: isPrimary ? const Color(0xFF16A34A) : Colors.white,
        border: Border.all(
          color: isPrimary ? const Color(0xFF16A34A) : const Color(0xFFE5E7EB),
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Center(
        child: Text(
          label,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: isPrimary ? Colors.white : const Color(0xFF374151),
          ),
        ),
      ),
    );
  }
}
