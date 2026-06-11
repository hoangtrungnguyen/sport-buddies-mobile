import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../theme/browse_pick_theme.dart';

// EPIC-5 SlotPickerPage — stub; built out in its dedicated task.
class SlotPickerPage extends StatelessWidget {
  const SlotPickerPage({super.key, required this.courtId});

  final String courtId;

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
          title: const Text('SlotPickerPage'),
        ),
        body: Center(child: Text('courtId = $courtId')),
      ),
    );
  }
}
