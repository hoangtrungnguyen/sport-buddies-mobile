import 'package:flutter/material.dart';

import '../model/models.dart';
import '../style/slot_state_style.dart';
import 'create_slot_controls.dart';

/// One radio card of the type picker (`createKinds` / `blockKinds` in the
/// prototype's `CreateDrawer`).
class KindOption {
  const KindOption(this.state, this.title, this.description);

  final SlotState state;
  final String title;
  final String description;
}

/// `seg-pick` — equal-width radio cards (one per [KindOption]), stretched to
/// the tallest. The slot/block type picker for [CreateSlotSheet]; [active] is
/// the selected kind and [onSelect] fires with the tapped card's state.
class KindPicker extends StatelessWidget {
  const KindPicker({
    super.key,
    required this.options,
    required this.active,
    required this.onSelect,
  });

  final List<KindOption> options;
  final SlotState active;
  final ValueChanged<SlotState> onSelect;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < options.length; i++) ...[
            if (i > 0) const SizedBox(width: 8),
            Expanded(
              child: KindCard(
                active: active == options[i].state,
                icon: slotStateIcons[options[i].state]!,
                title: options[i].title,
                description: options[i].description,
                onTap: () => onSelect(options[i].state),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
