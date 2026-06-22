// Bottom selection cart for the venue schedule: grouped chosen slots, totals
// and the continue CTA. Extracted from court_schedule_overview_screen.dart.

import 'package:customer/features/courts/schedule/court_schedule_style.dart';
import 'package:customer/features/courts/schedule/cubit/court_schedule_overview_state.dart';
import 'package:customer/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SelectionCart extends StatelessWidget {
  const SelectionCart({
    super.key,
    required this.groups,
    required this.count,
    required this.total,
    required this.submitting,
    required this.onClearAll,
    required this.onContinue,
  });

  final List<CartGroup> groups;
  final int count;
  final int total;
  final bool submitting;
  final VoidCallback onClearAll;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final fmt = NumberFormat.decimalPattern('vi_VN');
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      decoration: BoxDecoration(
        color: const Color(0xFFDCFCE7),
        border: Border.all(color: const Color(0xFF16A34A)),
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 12,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.scheduleSelectedCount(count),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF166534),
                  ),
                ),
              ),
              GestureDetector(
                onTap: onClearAll,
                child: Text(
                  l10n.scheduleClearAll,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF166534),
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          for (var g = 0; g < groups.length; g++) ...[
            if (g > 0) const SizedBox(height: 8),
            _CartGroupSection(group: groups[g]),
          ],
          const SizedBox(height: 8),
          const SizedBox(height: 1, child: _DottedDivider()),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.wizardLabelTotal,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF166534),
                  ),
                ),
              ),
              Text(
                '${fmt.format(total)} đ',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF166534),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: submitting ? null : onContinue,
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF16A34A),
              disabledBackgroundColor: const Color(0xFF86EFAC),
              minimumSize: const Size(double.infinity, 48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: submitting
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Colors.white,
                    ),
                  )
                : Text(
                    l10n.scheduleContinue,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _CartGroupSection extends StatelessWidget {
  const _CartGroupSection({required this.group});

  final CartGroup group;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Text(
            _groupHeader(l10n, group.date),
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Color(0xFF15803D),
              letterSpacing: 0.3,
            ),
          ),
        ),
        for (final item in group.items)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 3),
            child: Row(
              children: [
                const Icon(Icons.check_box, size: 16, color: Color(0xFF16A34A)),
                const SizedBox(width: 6),
                Expanded(
                  flex: 5,
                  child: Text(
                    '${item.courtName} · ${item.sport}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF111827),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Expanded(
                  flex: 4,
                  child: Text(
                    item.timeLabel,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF111827),
                    ),
                  ),
                ),
                Text(
                  '${(item.price / 1000).round()}k',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF111827),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  static String _groupHeader(AppLocalizations l10n, DateTime d) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final diff = DateTime(d.year, d.month, d.day).difference(today).inDays;
    final dd = d.day.toString().padLeft(2, '0');
    final mm = d.month.toString().padLeft(2, '0');
    final label = switch (diff) {
      0 => l10n.bookingsToday,
      1 => l10n.courtsTomorrow.toUpperCase(),
      _ => fullWeekday(l10n, d.weekday).toUpperCase(),
    };
    return '$label · $dd/$mm';
  }
}

class _DottedDivider extends StatelessWidget {
  const _DottedDivider();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DottedPainter(),
      child: const SizedBox.expand(),
    );
  }
}

class _DottedPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF86EFAC)
      ..strokeWidth = 1;
    const dashW = 3.0;
    const gapW = 3.0;
    double x = 0;
    while (x < size.width) {
      canvas.drawLine(Offset(x, 0), Offset(x + dashW, 0), paint);
      x += dashW + gapW;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
