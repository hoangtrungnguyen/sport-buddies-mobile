import 'package:flutter/material.dart';

const _labels = ['Xác nhận', 'Chơi ghép', 'Chờ duyệt', 'Hoàn tất'];

class BookingStepper extends StatelessWidget {
  const BookingStepper({super.key, required this.step});

  final int step;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(26, 14, 26, 28),
      color: Colors.white,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (int i = 0; i < 4; i++) ...[
            if (i > 0)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 13),
                  child: Container(
                    height: 2,
                    decoration: BoxDecoration(
                      color: i <= step
                          ? const Color(0xFF16A34A)
                          : const Color(0xFFE5E7EB),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ),
            _StepNode(index: i, currentStep: step),
          ],
        ],
      ),
    );
  }
}

class _StepNode extends StatelessWidget {
  const _StepNode({required this.index, required this.currentStep});

  final int index;
  final int currentStep;

  @override
  Widget build(BuildContext context) {
    final done = index < currentStep;
    final active = index == currentStep;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: (done || active) ? const Color(0xFF16A34A) : Colors.white,
            border: (done || active)
                ? null
                : Border.all(color: const Color(0xFFE5E7EB), width: 2),
            boxShadow: active
                ? const [
                    BoxShadow(
                      color: Color(0xFFDCFCE7),
                      spreadRadius: 4,
                      blurRadius: 0,
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: done
                ? const Icon(Icons.check, size: 14, color: Colors.white)
                : Text(
                    '${index + 1}',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: active ? Colors.white : const Color(0xFF9CA3AF),
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          _labels[index],
          style: TextStyle(
            fontSize: 11,
            fontWeight: active ? FontWeight.w700 : FontWeight.w600,
            color: active
                ? const Color(0xFF15803D)
                : done
                ? const Color(0xFF374151)
                : const Color(0xFF9CA3AF),
          ),
        ),
      ],
    );
  }
}
