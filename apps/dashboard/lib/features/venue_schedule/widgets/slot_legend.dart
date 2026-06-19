import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:spb_core/core/theme/app_colors.dart';

import '../model/models.dart';
import '../style/slot_state_style.dart';
import 'slot_block.dart' show SlotDecorationPainter;

/// Legend bar shown under the Day & Week views (not Month) — `.sc-legend` in
/// the handoff: white card with a wrapping row of `swatch + label` pairs, one
/// per slot state.
///
/// Each swatch is a 13px rounded square painted with the state's exact look
/// (bg/stripes, 1.5px solid or dashed border, accent) via
/// [SlotDecorationPainter].
class SlotLegend extends StatelessWidget {
  const SlotLegend({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.neutral200),
        borderRadius: BorderRadius.circular(14),
      ),
      // gap: 8px 18px
      child: Wrap(
        spacing: 18,
        runSpacing: 8,
        children: [
          // Only states real data can produce; fixed/open/private stay gated
          // until matchmaking exists in the DB (TODO BCORE-321/326).
          for (final state in SlotState.values)
            if (kMatchmakingEnabled || !kMatchmakingOnlyStates.contains(state))
              _legendItem(state),
        ],
      ),
    );
  }

  Widget _legendItem(SlotState state) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 13,
          height: 13,
          child: CustomPaint(
            painter: SlotDecorationPainter.fromStyle(
              slotStateStyles[state]!,
              radius: 4,
            ),
          ),
        ),
        const SizedBox(width: 7),
        Text(
          slotStateLabels[state]!,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            color: AppColors.neutral600,
          ),
        ),
      ],
    );
  }
}
