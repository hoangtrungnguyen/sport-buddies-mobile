import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:spb_core/core/theme/app_colors.dart';

import '../model/models.dart';
import '../util/schedule_format.dart';
import 'side_sheet.dart';
import 'slot_detail_controls.dart';

/// Slot detail drawer — `DetailDrawer` in `schedule-page.jsx`.
///
/// Self-contained overlay: it already wraps the shared [ScheduleSideSheet]
/// chrome (scrim + 480px right panel), so the page drops it straight into its
/// `Stack` when `state.activeSheet == VenueScheduleSheet.detail`:
///
/// ```dart
/// if (state.activeSheet == VenueScheduleSheet.detail &&
///     state.detailSlot != null)
///   SlotDetailSheet(
///     slot: state.detailSlot!,
///     venueName: state.venues
///         .firstWhereOrNull((v) => v.id == state.detailSlot!.venueId)
///         ?.name,
///     onClose: () => bloc.add(const VenueScheduleEvent.sheetClosed()),
///     onApprove: () =>
///         bloc.add(VenueScheduleEvent.approveRequested(slot.id)),
///     ...
///   ),
/// ```
class SlotDetailSheet extends StatelessWidget {
  const SlotDetailSheet({
    super.key,
    required this.slot,
    this.venueName,
    required this.onClose,
    required this.onApprove,
    required this.onReject,
    required this.onCancel,
    required this.onOpenForMatchmaking,
    required this.onBookAtCounter,
    required this.onReschedule,
    required this.onCall,
  });

  final Slot slot;

  /// Resolved name of `slot.venueId` ("Sân 1") — header subtitle + "Sân" row.
  final String? venueName;

  /// Scrim tap / ✕ — dispatch `VenueScheduleEvent.sheetClosed()`.
  final VoidCallback onClose;

  /// "Duyệt" on a pending booking —
  /// dispatch `VenueScheduleEvent.approveRequested(slot.id)`.
  final VoidCallback onApprove;

  /// "Từ chối" on a pending booking —
  /// dispatch `VenueScheduleEvent.rejectRequested(slot.id)`.
  final VoidCallback onReject;

  /// "Huỷ" on a booking, and "Mở khoá giờ này" on a blocked hour —
  /// dispatch `VenueScheduleEvent.cancelRequested(slot.id)` (cancel doubles
  /// as unblock in the bloc).
  final VoidCallback onCancel;

  /// "Mở ghép" on an empty slot — not backed by a bloc event yet; the page
  /// may show a "Tính năng đang phát triển" toast.
  final VoidCallback onOpenForMatchmaking;

  /// "Đặt sân" (book at counter) on an empty slot — placeholder, see
  /// [onOpenForMatchmaking].
  final VoidCallback onBookAtCounter;

  /// "Dời lịch" — placeholder, see [onOpenForMatchmaking].
  final VoidCallback onReschedule;

  /// "Gọi" — placeholder, see [onOpenForMatchmaking].
  final VoidCallback onCall;

  @override
  Widget build(BuildContext context) {
    return ScheduleSideSheet(
      onDismiss: onClose,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHead(),
          Expanded(child: _buildBody()),
          _buildFoot(),
        ],
      ),
    );
  }

  // ---- drawer-head --------------------------------------------------------

  Widget _buildHead() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.neutral100)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  slot.label,
                  style: GoogleFonts.sora(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.neutral900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${venueName ?? ''} · ${hourLabel(slot.startHour)}–'
                  '${hourLabel(slot.endHour)}',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    color: AppColors.neutral500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          GhostCloseButton(onTap: onClose),
        ],
      ),
    );
  }

  // ---- drawer-body --------------------------------------------------------

  Widget _buildBody() {
    final rows = _detailRows();
    final contextCard = _contextCard();
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          StateBanner(state: slot.state),
          for (var i = 0; i < rows.length; i++)
            DetailRow(
              label: rows[i].label,
              value: rows[i].value,
              divider: i < rows.length - 1,
            ),
          if (contextCard != null) contextCard,
        ],
      ),
    );
  }

  /// Contextual info card under the detail rows — only open and empty slots
  /// get one (null for every other state).
  Widget? _contextCard() {
    switch (slot.state) {
      case SlotState.open:
        return InfoCard(
          strong: 'Slot ghép mở',
          text: ' — khách lẻ có thể tham gia tới khi đủ '
              '${slot.capacity ?? 0} người. Hiện đã có '
              '${slot.players ?? 0} người.',
        );
      case SlotState.empty:
        return InfoCard(
          strong: 'Slot trống',
          // No matchmaking mention while the feature is gated
          // (TODO BCORE-321/326).
          text: kMatchmakingEnabled
              ? ' — đang chờ khách đặt. Bạn có thể mở công khai để '
                  'ghép đội hoặc khoá giờ này.'
              : ' — đang chờ khách đặt. Bạn có thể khoá giờ này nếu '
                  'không nhận khách.',
        );
      default:
        return null;
    }
  }

  /// The label/value detail rows for the current slot — order matters, and
  /// each entry is included only when its field is present.
  List<({String label, Widget value})> _detailRows() {
    return <({String label, Widget value})>[
      if (slot.bookingCode != null)
        (
          label: 'Mã',
          value: Text(
            slot.bookingCode!,
            style: GoogleFonts.jetBrainsMono(
              fontSize: 13.5,
              fontWeight: FontWeight.w500,
              color: AppColors.neutral900,
            ),
          ),
        ),
      (label: 'Sân', value: Text(venueName ?? '—')),
      (
        label: 'Thời gian',
        value: Text(
          '${hourLabel(slot.startHour)} – ${hourLabel(slot.endHour)} · '
          '${_durationLabel(slot.durationHours)}',
        ),
      ),
      if (slot.subtitle != null)
        (label: 'Ghi chú', value: Text(slot.subtitle!)),
      if (slot.capacity != null)
        (
          label: 'Người chơi',
          // "tối đa N" when the joined count is unknown (no DB column) —
          // "0/N" would assert zero players joined, which the DB can't say.
          value: Text(slot.capacityLabel!),
        ),
      if (slot.price != null)
        (
          label: 'Giá',
          value: Text(
            vnd(slot.price!),
            style: GoogleFonts.sora(
              fontSize: 13.5,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryDark,
            ),
          ),
        ),
      if (slot.payment != null)
        (
          label: 'Thanh toán',
          value: Align(
            alignment: Alignment.centerLeft,
            child: PaymentBadge(payment: slot.payment!),
          ),
        ),
    ];
  }

  // ---- drawer-foot --------------------------------------------------------

  Widget _buildFoot() {
    final actions = _footActions();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
      decoration: const BoxDecoration(
        color: AppColors.neutral50,
        border: Border(top: BorderSide(color: AppColors.neutral100)),
      ),
      child: Row(
        children: [
          for (var i = 0; i < actions.length; i++) ...[
            if (i > 0) const SizedBox(width: 10),
            Expanded(child: actions[i]),
          ],
        ],
      ),
    );
  }

  /// The footer action buttons for the slot's current state (approve/reject,
  /// book, cancel/reschedule/call, or unblock).
  List<Widget> _footActions() {
    return switch (slot.state) {
      SlotState.pending => [
          SheetButton(
            label: 'Từ chối',
            variant: SheetButtonVariant.danger,
            onPressed: onReject,
          ),
          SheetButton(
            label: 'Duyệt',
            icon: Icons.check,
            variant: SheetButtonVariant.primary,
            onPressed: onApprove,
          ),
        ],
      SlotState.empty => [
          // TODO(BCORE-321/326): "Mở ghép" needs matchmaking slots in the DB.
          if (kMatchmakingEnabled)
            SheetButton(
              label: 'Mở ghép',
              icon: Icons.public,
              variant: SheetButtonVariant.secondary,
              onPressed: onOpenForMatchmaking,
            ),
          SheetButton(
            label: 'Đặt sân',
            icon: Icons.add,
            variant: SheetButtonVariant.primary,
            onPressed: onBookAtCounter,
          ),
        ],
      SlotState.confirmed ||
      SlotState.fixed ||
      SlotState.open ||
      SlotState.private =>
        [
          SheetButton(
            label: 'Huỷ',
            variant: SheetButtonVariant.danger,
            onPressed: onCancel,
          ),
          SheetButton(
            label: 'Dời lịch',
            icon: Icons.open_with,
            variant: SheetButtonVariant.secondary,
            onPressed: onReschedule,
          ),
          SheetButton(
            label: 'Gọi',
            icon: Icons.phone_outlined,
            variant: SheetButtonVariant.primary,
            onPressed: onCall,
          ),
        ],
      SlotState.locked || SlotState.maintenance || SlotState.owner => [
          SheetButton(
            label: 'Mở khoá giờ này',
            icon: Icons.check,
            variant: SheetButtonVariant.secondary,
            onPressed: onCancel,
          ),
        ],
    };
  }

  /// `1.5 → "1.5h"`, `1.0 → "1h"` — mirrors the prototype's `` `${dur}h` ``.
  static String _durationLabel(double duration) {
    final s = duration.toStringAsFixed(1);
    return s.endsWith('.0') ? '${duration.toInt()}h' : '${s}h';
  }
}
