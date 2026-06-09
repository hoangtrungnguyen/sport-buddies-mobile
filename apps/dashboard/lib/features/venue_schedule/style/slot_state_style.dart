import 'package:flutter/material.dart';
import 'package:spb_core/core/theme/app_colors.dart';

import '../model/models.dart';

/// Visual tokens for the "Lịch sân" slot blocks, legend swatches, detail-sheet
/// banner and Month-view heatmap — exact values from the design handoff
/// ("Slot-state styling (EXACT)" table + `schedule-styles.css`).

/// Diagonal-stripe fill variant for a slot block background.
///
/// Carries the exact stripe geometry from `schedule-styles.css` so the slot
/// painter can reproduce `repeating-linear-gradient` faithfully:
/// `colorA 0..bandWidth, colorB bandWidth..2*bandWidth` repeated at [angleDeg].
enum SlotStripe {
  /// Solid background — no stripes.
  none(null, null, 0, 0),

  /// `empty`: 135° stripes `#FFF`/`--n-50`, 7px/14px period.
  light135(Colors.white, AppColors.neutral50, 7, 135),

  /// `locked`: 45° stripes `--n-100`/`--n-200`, 6px/12px period.
  gray45(AppColors.neutral100, AppColors.neutral200, 6, 45);

  const SlotStripe(this.colorA, this.colorB, this.bandWidth, this.angleDeg);

  final Color? colorA;
  final Color? colorB;

  /// Width of one stripe band in logical px (period = 2 × bandWidth).
  final double bandWidth;
  final double angleDeg;
}

/// Per-state look of a slot block: 1.5px border (solid or dashed), tinted
/// background (solid or striped), text colour, optional 3px left accent bar.
@immutable
class SlotStateStyle {
  const SlotStateStyle({
    required this.bg,
    required this.border,
    required this.text,
    this.dashed = false,
    this.striped = SlotStripe.none,
    this.accentLeft,
  });

  /// Fill colour. For striped states this is the base coat under the stripes.
  final Color bg;

  /// 1.5px border colour.
  final Color border;

  /// Label / time / subtitle colour.
  final Color text;

  /// Dashed border (`pending`, `private`, `empty`).
  final bool dashed;

  /// Diagonal-stripe fill (`empty`, `locked`).
  final SlotStripe striped;

  /// 3px solid accent bar on the left edge (`fixed`).
  final Color? accentLeft;
}

/// Slot-state palette — EXACT per the handoff table.
const Map<SlotState, SlotStateStyle> slotStateStyles = {
  SlotState.confirmed: SlotStateStyle(
    bg: Color(0xFFDCFCE7),
    border: Color(0xFF22C55E),
    text: Color(0xFF14532D),
  ),
  SlotState.pending: SlotStateStyle(
    bg: Color(0xFFFEF9C3),
    border: Color(0xFFEAB308),
    text: Color(0xFF713F12),
    dashed: true,
  ),
  SlotState.fixed: SlotStateStyle(
    bg: Color(0xFFEDE9FE),
    border: Color(0xFFA855F7),
    text: Color(0xFF5B21B6),
    accentLeft: Color(0xFFA855F7),
  ),
  SlotState.open: SlotStateStyle(
    bg: Color(0xFFCCFBF1),
    border: Color(0xFF14B8A6),
    text: Color(0xFF115E59),
  ),
  SlotState.private: SlotStateStyle(
    bg: Color(0xFFE0E7FF),
    border: Color(0xFF6366F1),
    text: Color(0xFF3730A3),
    dashed: true,
  ),
  SlotState.empty: SlotStateStyle(
    bg: Colors.white,
    border: AppColors.neutral300,
    text: AppColors.neutral500,
    dashed: true,
    striped: SlotStripe.light135,
  ),
  SlotState.owner: SlotStateStyle(
    bg: Color(0xFFDBEAFE),
    border: Color(0xFF3B82F6),
    text: Color(0xFF1E3A8A),
  ),
  SlotState.maintenance: SlotStateStyle(
    bg: Color(0xFFFEF3C7),
    border: Color(0xFFFBBF24),
    text: Color(0xFF92400E),
  ),
  SlotState.locked: SlotStateStyle(
    bg: AppColors.neutral100,
    border: AppColors.neutral300,
    text: AppColors.neutral600,
    striped: SlotStripe.gray45,
  ),
};

/// Hover look of an `empty` slot block (`st-empty:hover` in the CSS):
/// `--primary` border + `--primary-50` bg + `--primary-dark` text.
const SlotStateStyle emptySlotHoverStyle = SlotStateStyle(
  bg: AppColors.primary50,
  border: AppColors.primary,
  text: AppColors.primaryDark,
  dashed: true,
);

/// Full Vietnamese label per state (`SC_STATES[*].label` — legend, banner).
const Map<SlotState, String> slotStateLabels = {
  SlotState.confirmed: 'Đã đặt',
  SlotState.pending: 'Chờ duyệt',
  SlotState.fixed: 'Lịch cố định',
  SlotState.open: 'Slot mở (ghép)',
  SlotState.private: 'Slot riêng tư',
  SlotState.empty: 'Slot trống',
  SlotState.owner: 'Sân chủ / cá nhân',
  SlotState.maintenance: 'Bảo trì',
  SlotState.locked: 'Khoá / đóng cửa',
};

/// Short Vietnamese label per state (`SC_STATES[*].short` — filter chips).
const Map<SlotState, String> slotStateShortLabels = {
  SlotState.confirmed: 'Đã đặt',
  SlotState.pending: 'Chờ duyệt',
  SlotState.fixed: 'Cố định',
  SlotState.open: 'Mở ghép',
  SlotState.private: 'Riêng',
  SlotState.empty: 'Trống',
  SlotState.owner: 'Sân chủ',
  SlotState.maintenance: 'Bảo trì',
  SlotState.locked: 'Khoá',
};

/// State icon (`stateIcon` in `schedule-views.jsx`) — Material approximations
/// of the prototype's check/clock/repeat/globe/eye-off/plus/user/wrench/lock.
const Map<SlotState, IconData> slotStateIcons = {
  SlotState.confirmed: Icons.check,
  SlotState.pending: Icons.schedule,
  SlotState.fixed: Icons.repeat,
  SlotState.open: Icons.public,
  SlotState.private: Icons.visibility_off_outlined,
  SlotState.empty: Icons.add,
  SlotState.owner: Icons.person_outline,
  SlotState.maintenance: Icons.build_outlined,
  SlotState.locked: Icons.lock_outline,
};

/// Month-view heatmap colour scale (`occColor` in `schedule-views.jsx`):
/// `< .35 → #BBF7D0`, `< .55 → #4ADE80`, `< .70 → #FCD34D`,
/// `< .85 → #FB923C`, else `#EF4444`.
Color occupancyColor(double occupancy) {
  if (occupancy < 0.35) return const Color(0xFFBBF7D0);
  if (occupancy < 0.55) return const Color(0xFF4ADE80);
  if (occupancy < 0.70) return const Color(0xFFFCD34D);
  if (occupancy < 0.85) return const Color(0xFFFB923C);
  return AppColors.danger; // #EF4444
}

/// Detail-sheet state-banner background per state (`bannerBg` in
/// `schedule-page.jsx`).
const Map<SlotState, Color> slotStateBannerBg = {
  SlotState.confirmed: Color(0xFFDCFCE7),
  SlotState.pending: Color(0xFFFEF9C3),
  SlotState.fixed: Color(0xFFEDE9FE),
  SlotState.open: Color(0xFFCCFBF1),
  SlotState.private: Color(0xFFE0E7FF),
  SlotState.empty: AppColors.neutral100,
  SlotState.owner: Color(0xFFDBEAFE),
  SlotState.maintenance: Color(0xFFFEF3C7),
  SlotState.locked: AppColors.neutral100,
};

/// Detail-sheet state-banner foreground per state (`bannerFg` in
/// `schedule-page.jsx`).
const Map<SlotState, Color> slotStateBannerFg = {
  SlotState.confirmed: Color(0xFF15803D),
  SlotState.pending: Color(0xFF854D0E),
  SlotState.fixed: Color(0xFF6D28D9),
  SlotState.open: Color(0xFF0F766E),
  SlotState.private: Color(0xFF4338CA),
  SlotState.empty: AppColors.neutral600,
  SlotState.owner: Color(0xFF1E40AF),
  SlotState.maintenance: Color(0xFF92400E),
  SlotState.locked: AppColors.neutral600,
};
