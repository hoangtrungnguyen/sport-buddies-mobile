// Selection summary card for the venue schedule: chosen cells, total and the
// continue CTA into the booking wizard. Extracted from schedule_page.dart.

import 'package:customer/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

import '../../domain/court.dart';
import '../../domain/schedule.dart';
import '../../theme/app_tokens.dart';
import '../../theme/browse_pick_theme.dart';
import '../schedule_grid_ref.dart';

class SummaryCard extends StatelessWidget {
  const SummaryCard({
    super.key,
    required this.center,
    required this.day,
    required this.selection,
    required this.cellPriceVnd,
    required this.onClear,
    required this.onContinue,
  });

  final SportsCenter center;
  final ScheduleDay? day;
  final Set<GridRef> selection;
  final int cellPriceVnd;
  final VoidCallback onClear;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context);
    final onCt = scheme.onPrimaryContainer;
    final rows = selection.toList();
    final total = rows.length * cellPriceVnd;

    Court courtOf(String id) => center.courts.firstWhere(
      (c) => c.id == id,
      orElse: () => center.courts.first,
    );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.primaryContainer,
        borderRadius: AppTokens.radiusLg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                l10n.scheduleSelectedCount(rows.length),
                style: text.labelLarge?.copyWith(color: onCt),
              ),
              const Spacer(),
              InkWell(
                onTap: onClear,
                child: Text(
                  l10n.scheduleClearAll,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: onCt,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          for (final ref in rows)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                children: [
                  Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: scheme.primary,
                      borderRadius: const BorderRadius.all(
                        Radius.circular(AppTokens.cornerXs),
                      ),
                    ),
                    child: Icon(Icons.check, size: 12, color: scheme.onPrimary),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    courtOf(ref.courtId).name,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: onCt,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _timeLabel(ref.hour),
                    style: TextStyle(
                      fontSize: 12,
                      color: onCt.withValues(alpha: 0.75),
                      fontFeatures: AppTokens.tnum,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    _thousandsK(cellPriceVnd),
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: onCt,
                      fontFeatures: AppTokens.tnum,
                    ),
                  ),
                ],
              ),
            ),
          Divider(color: onCt.withValues(alpha: 0.18), height: 16),
          Row(
            children: [
              Text(
                l10n.wizardLabelTotal,
                style: text.labelLarge?.copyWith(color: onCt),
              ),
              const Spacer(),
              Text(
                '${_thousands(total)} đ',
                style: text.priceMedium(scheme).copyWith(color: onCt),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: onContinue,
              style: FilledButton.styleFrom(
                minimumSize: const Size(0, AppTokens.buttonSummaryHeight),
              ),
              child: Text(l10n.scheduleContinue),
            ),
          ),
        ],
      ),
    );
  }

  String _timeLabel(int hour) {
    final labels = day?.hourLabels ?? const [];
    if (hour >= labels.length) return '';
    final start = labels[hour].substring(0, 5);
    final h = int.tryParse(start.substring(0, 2)) ?? 0;
    final end = '${(h + 2).toString().padLeft(2, '0')}:00';
    return '$start – $end';
  }
}

String _thousands(int v) {
  final s = v.toString();
  final buf = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
    buf.write(s[i]);
  }
  return buf.toString();
}

String _thousandsK(int v) => '${(v / 1000).round()}k';
