import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../model/home_models.dart';
import '../../util/home_format.dart';

class GreetingHeader extends StatelessWidget {
  const GreetingHeader({super.key, required this.summary});
  final HomeSummary summary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final now = DateTime.now();
    final hour = now.hour;
    final greeting = hour < 12
        ? 'Chào buổi sáng'
        : hour < 18
            ? 'Chào buổi chiều'
            : 'Chào buổi tối';
    final name = summary.ownerName;
    final dateLine =
        '${weekdayFull(now)}, ${dmy(now)} · ${summary.activeCourts} cụm sân đang hoạt động · ${summary.totalVenues} sân con';

    return Wrap(
      spacing: 16,
      runSpacing: 12,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name == null ? greeting : '$greeting, $name',
                  style: theme.textTheme.headlineMedium),
              const SizedBox(height: 4),
              Row(
                children: [
                  Text(
                    dateLine,
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(color: scheme.onSurfaceVariant),
                  ),
                ],
              ),
            ],
          ),
        ),
        FilledButton.icon(
          icon: const Icon(Symbols.person_add, size: 18),
          label: const Text('Khách vãng lai'),
          onPressed: () {},
        ),
        FilledButton.icon(
          icon: const Icon(Symbols.add, size: 18),
          label: const Text('Tạo đặt sân'),
          onPressed: () {},
        ),
      ],
    );
  }
}
