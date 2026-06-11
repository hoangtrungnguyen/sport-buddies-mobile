import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../theme/browse_pick_theme.dart';

// EPIC-5 SchedulePage — stub; built out in its dedicated task.
class SchedulePage extends StatelessWidget {
  const SchedulePage({super.key, required this.centerId});

  final String centerId;

  @override
  Widget build(BuildContext context) {
    return BrowsePickTheme(
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            tooltip: 'Quay lại',
            onPressed: () => context.pop(),
          ),
          title: const Text('SchedulePage'),
        ),
        body: Center(child: Text('centerId = $centerId')),
      ),
    );
  }
}
