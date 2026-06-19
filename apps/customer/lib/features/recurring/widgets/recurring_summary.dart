// Summary preview card and bottom CTA for the recurring-booking screen.
// Extracted from recurring_booking_screen.dart.

import 'package:flutter/material.dart';

class SummaryPreviewCard extends StatelessWidget {
  const SummaryPreviewCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFDCFCE7),
        border: Border.all(color: const Color(0xFF16A34A)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'TÓM TẮT LỊCH',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Color(0xFF15803D),
              letterSpacing: 0.5,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Mỗi T3, T5 · 19:00 – 20:30',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: Color(0xFF111827),
            ),
          ),
          SizedBox(height: 8),
          Row(
            children: [
              _PreviewStat(n: '8', label: 'buổi'),
              SizedBox(width: 16),
              _PreviewStat(n: '12', label: 'giờ'),
              SizedBox(width: 16),
              _PreviewStat(n: '2.000.000 đ', label: ''),
            ],
          ),
        ],
      ),
    );
  }
}

class _PreviewStat extends StatelessWidget {
  const _PreviewStat({required this.n, required this.label});

  final String n;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: n,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              color: Color(0xFF374151),
              fontSize: 13,
            ),
          ),
          if (label.isNotEmpty)
            TextSpan(
              text: ' $label',
              style: const TextStyle(fontSize: 13, color: Color(0xFF374151)),
            ),
        ],
      ),
    );
  }
}

class BottomCta extends StatelessWidget {
  const BottomCta({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Color(0xFFE5E7EB))),
        ),
        child: FilledButton(
          onPressed: () {},
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFF16A34A),
            minimumSize: const Size(double.infinity, 52),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text(
            'Xem trước 8 buổi',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
