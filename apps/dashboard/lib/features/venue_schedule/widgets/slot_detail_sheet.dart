import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:spb_core/core/theme/app_colors.dart';

import '../model/models.dart';
import '../style/slot_state_style.dart';
import '../util/schedule_format.dart';
import 'side_sheet.dart';

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
          _GhostCloseButton(onTap: onClose),
        ],
      ),
    );
  }

  // ---- drawer-body --------------------------------------------------------

  Widget _buildBody() {
    final rows = <({String label, Widget value})>[
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
            child: _PaymentBadge(payment: slot.payment!),
          ),
        ),
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _StateBanner(state: slot.state),
          for (var i = 0; i < rows.length; i++)
            _DetailRow(
              label: rows[i].label,
              value: rows[i].value,
              divider: i < rows.length - 1,
            ),
          // Contextual info card for open / empty slots.
          if (slot.state == SlotState.open)
            _InfoCard(
              strong: 'Slot ghép mở',
              text: ' — khách lẻ có thể tham gia tới khi đủ '
                  '${slot.capacity ?? 0} người. Hiện đã có '
                  '${slot.players ?? 0} người.',
            ),
          if (slot.state == SlotState.empty)
            _InfoCard(
              strong: 'Slot trống',
              // No matchmaking mention while the feature is gated
              // (TODO BCORE-321/326).
              text: kMatchmakingEnabled
                  ? ' — đang chờ khách đặt. Bạn có thể mở công khai để '
                      'ghép đội hoặc khoá giờ này.'
                  : ' — đang chờ khách đặt. Bạn có thể khoá giờ này nếu '
                      'không nhận khách.',
            ),
        ],
      ),
    );
  }

  // ---- drawer-foot --------------------------------------------------------

  Widget _buildFoot() {
    final actions = switch (slot.state) {
      SlotState.pending => [
          _SheetButton(
            label: 'Từ chối',
            variant: _SheetButtonVariant.danger,
            onPressed: onReject,
          ),
          _SheetButton(
            label: 'Duyệt',
            icon: Icons.check,
            variant: _SheetButtonVariant.primary,
            onPressed: onApprove,
          ),
        ],
      SlotState.empty => [
          // TODO(BCORE-321/326): "Mở ghép" needs matchmaking slots in the DB.
          if (kMatchmakingEnabled)
            _SheetButton(
              label: 'Mở ghép',
              icon: Icons.public,
              variant: _SheetButtonVariant.secondary,
              onPressed: onOpenForMatchmaking,
            ),
          _SheetButton(
            label: 'Đặt sân',
            icon: Icons.add,
            variant: _SheetButtonVariant.primary,
            onPressed: onBookAtCounter,
          ),
        ],
      SlotState.confirmed ||
      SlotState.fixed ||
      SlotState.open ||
      SlotState.private =>
        [
          _SheetButton(
            label: 'Huỷ',
            variant: _SheetButtonVariant.danger,
            onPressed: onCancel,
          ),
          _SheetButton(
            label: 'Dời lịch',
            icon: Icons.open_with,
            variant: _SheetButtonVariant.secondary,
            onPressed: onReschedule,
          ),
          _SheetButton(
            label: 'Gọi',
            icon: Icons.phone_outlined,
            variant: _SheetButtonVariant.primary,
            onPressed: onCall,
          ),
        ],
      SlotState.locked || SlotState.maintenance || SlotState.owner => [
          _SheetButton(
            label: 'Mở khoá giờ này',
            icon: Icons.check,
            variant: _SheetButtonVariant.secondary,
            onPressed: onCancel,
          ),
        ],
    };

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

  /// `1.5 → "1.5h"`, `1.0 → "1h"` — mirrors the prototype's `` `${dur}h` ``.
  static String _durationLabel(double duration) {
    final s = duration.toStringAsFixed(1);
    return s.endsWith('.0') ? '${duration.toInt()}h' : '${s}h';
  }
}

/// `.drawer-state-banner` — full-width state-tinted pill with icon + label.
class _StateBanner extends StatelessWidget {
  const _StateBanner({required this.state});

  final SlotState state;

  @override
  Widget build(BuildContext context) {
    final fg = slotStateBannerFg[state]!;
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: slotStateBannerBg[state],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(slotStateIcons[state], size: 16, color: fg),
          const SizedBox(width: 10),
          Text(
            slotStateLabels[state]!,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: fg,
            ),
          ),
        ],
      ),
    );
  }
}

/// `.detail-row` — `[110px label] [value]` grid with a bottom hairline.
class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.label,
    required this.value,
    this.divider = true,
  });

  final String label;
  final Widget value;
  final bool divider;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: divider
          ? const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.neutral100)),
            )
          : null,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12.5,
                color: AppColors.neutral500,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: DefaultTextStyle.merge(
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13.5,
                fontWeight: FontWeight.w500,
                color: AppColors.neutral900,
              ),
              child: value,
            ),
          ),
        ],
      ),
    );
  }
}

/// Payment badge (`.badge.pay.*` in the handoff CSS) — paid / partial /
/// unpaid pill on the "Thanh toán" row.
class _PaymentBadge extends StatelessWidget {
  const _PaymentBadge({required this.payment});

  final PaymentStatus payment;

  static const _labels = {
    PaymentStatus.paid: 'Đã thanh toán',
    PaymentStatus.partial: 'Đặt cọc',
    PaymentStatus.unpaid: 'Chưa TT',
  };
  static const _bg = {
    PaymentStatus.paid: AppColors.successBg, // .pay.paid
    PaymentStatus.partial: Color(0xFFFFEDD5), // .pay.partial
    PaymentStatus.unpaid: AppColors.warningBg, // .pay.unpaid
  };
  static const _fg = {
    PaymentStatus.paid: Color(0xFF15803D),
    PaymentStatus.partial: Color(0xFFC2410C),
    PaymentStatus.unpaid: Color(0xFF854D0E),
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 2),
      decoration: BoxDecoration(
        color: _bg[payment],
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        _labels[payment]!,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 11.5,
          fontWeight: FontWeight.w700,
          color: _fg[payment],
        ),
      ),
    );
  }
}

/// `.batch-preview` — green-tinted contextual info card (open / empty slots).
class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.strong, required this.text});

  final String strong;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.primary50,
        border: Border.all(color: AppColors.primaryLight),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: strong,
              style: GoogleFonts.sora(fontWeight: FontWeight.w700),
            ),
            TextSpan(text: text),
          ],
        ),
        style: GoogleFonts.plusJakartaSans(
          fontSize: 12.5,
          color: AppColors.primaryDark,
          height: 1.5,
        ),
      ),
    );
  }
}

/// `.btn.btn-ghost.btn-sm.btn-icon-only` — the header's ✕ close button.
class _GhostCloseButton extends StatefulWidget {
  const _GhostCloseButton({required this.onTap});

  final VoidCallback onTap;

  @override
  State<_GhostCloseButton> createState() => _GhostCloseButtonState();
}

class _GhostCloseButtonState extends State<_GhostCloseButton> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 80),
          width: 38,
          height: 32,
          decoration: BoxDecoration(
            color: _hover ? AppColors.neutral100 : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.close, size: 16, color: AppColors.neutral700),
        ),
      ),
    );
  }
}

enum _SheetButtonVariant { primary, secondary, danger }

/// `.btn` in the handoff CSS — 38px tall, radius 10, 13.5/600, 80ms hover.
///
/// `primary` = filled `--primary` (hover `--primary-dark`); `secondary` =
/// white + `--n-200` border (hover `--n-50` / `--n-300`); `danger` = white +
/// `--danger` text (hover `--danger-bg` fill + `--danger` border).
class _SheetButton extends StatefulWidget {
  const _SheetButton({
    required this.label,
    this.icon,
    required this.variant,
    required this.onPressed,
  });

  final String label;
  final IconData? icon;
  final _SheetButtonVariant variant;
  final VoidCallback onPressed;

  @override
  State<_SheetButton> createState() => _SheetButtonState();
}

class _SheetButtonState extends State<_SheetButton> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final (Color bg, Color fg, Color border, List<BoxShadow> shadow) =
        switch (widget.variant) {
      _SheetButtonVariant.primary => (
          _hover ? AppColors.primaryDark : AppColors.primary,
          Colors.white,
          Colors.transparent,
          // 0 1px 2px rgba(22,163,74,.24)
          const [
            BoxShadow(
              color: Color(0x3D16A34A),
              offset: Offset(0, 1),
              blurRadius: 2,
            ),
          ],
        ),
      _SheetButtonVariant.secondary => (
          _hover ? AppColors.neutral50 : Colors.white,
          AppColors.neutral800,
          _hover ? AppColors.neutral300 : AppColors.neutral200,
          const <BoxShadow>[],
        ),
      _SheetButtonVariant.danger => (
          _hover ? AppColors.dangerBg : Colors.white,
          _hover ? AppColors.dangerDark : AppColors.danger,
          _hover ? AppColors.danger : AppColors.neutral200,
          const <BoxShadow>[],
        ),
    };

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 80),
          height: 38,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: bg,
            border: Border.all(color: border),
            borderRadius: BorderRadius.circular(10),
            boxShadow: shadow,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.icon != null) ...[
                Icon(widget.icon, size: 15, color: fg),
                const SizedBox(width: 8),
              ],
              Flexible(
                child: Text(
                  widget.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    color: fg,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
