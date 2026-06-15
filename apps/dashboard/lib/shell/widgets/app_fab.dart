import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

class AppFab extends StatelessWidget {
  const AppFab({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return FloatingActionButton.extended(
      backgroundColor: scheme.primary,
      foregroundColor: scheme.onPrimary,
      elevation: 2,
      icon: const Icon(Symbols.add, size: 20),
      label: const Text('Đặt sân tại quầy'),
      onPressed: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Form đặt sân tại quầy sẽ có trong Epic Đặt Slot.'),
          ),
        );
      },
    );
  }
}
