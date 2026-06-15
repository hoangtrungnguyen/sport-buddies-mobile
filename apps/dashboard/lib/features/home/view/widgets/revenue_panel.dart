import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../model/home_models.dart';

class RevenuePanel extends StatelessWidget {
  const RevenuePanel({super.key, required this.data});
  final List<RevenueDay> data;

  int get _total => data.fold(0, (sum, d) => sum + d.value);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final avg = _total ~/ data.length;
    final formatted = (_total / 1000000).toStringAsFixed(2);

    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 12, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Symbols.bar_chart, size: 20, color: scheme.onSurfaceVariant),
                const SizedBox(width: 12),
                Expanded(
                  child: Text('Doanh thu 7 ngày',
                      style: theme.textTheme.titleMedium),
                ),
                TextButton(
                  onPressed: () => context.go('/analytics'),
                  child: const Text('Thống kê'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              '${formatted}tr',
              style:
                  const TextStyle(fontSize: 26, fontWeight: FontWeight.w500),
            ),
            Text(
              'tổng tuần · TB ${_formatVnd(avg)}/ngày',
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: scheme.onSurfaceVariant),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 104,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  for (final day in data)
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Expanded(
                              child: Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: day.today
                                      ? scheme.primary
                                      : scheme.secondaryContainer,
                                  borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(4)),
                                ),
                                child: Tooltip(
                                  message: _formatVnd(day.value),
                                  child: const SizedBox(),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              day.day,
                              style: TextStyle(
                                fontSize: 12,
                                color: scheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
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

  String _formatVnd(int value) {
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}tr';
    } else if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(0)}k';
    }
    return '$value';
  }
}
