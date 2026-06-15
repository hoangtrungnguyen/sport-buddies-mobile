import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../model/home_models.dart';

class GreetingHeader extends StatelessWidget {
  const GreetingHeader({super.key, required this.requests});
  final List<PendingRequest> requests;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final hour = DateTime.now().hour;
    final greeting = hour < 12
        ? 'Chào buổi sáng'
        : hour < 18
            ? 'Chào buổi chiều'
            : 'Chào buổi tối';

    return Wrap(
      spacing: 16,
      runSpacing: 12,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('$greeting, anh Minh',
                  style: theme.textTheme.headlineMedium),
              const SizedBox(height: 4),
              Row(
                children: [
                  Text(
                    'Thứ Sáu, 12/06/2026 · 5 cụm sân đang hoạt động · 12 sân con',
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
