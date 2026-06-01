import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:spb_core/core/theme/app_colors.dart';

import '../../setup/model/owner_court.dart';
import '../../slot_detail/view/slot_players_dialog.dart';
import '../bloc/schedule_bloc.dart';
import '../model/owner_slot.dart';

/// Opens the slot-action sheet for a tapped calendar slot (OWNER-25).
///
/// What it offers depends on [slot.status]:
/// - **open** → "Khoá giờ" with an optional reason → [ScheduleEvent.slotBlocked]
/// - **blocked** → shows the reason + "Bỏ khoá" → [ScheduleEvent.slotUnblocked]
/// - **booked** → block is disabled with an explanatory error (AC: cannot block
///   a booked slot), plus a "Xem danh sách người chơi" action (OWNER-33)
/// - anything else (owner/pending/maintenance) → an info note; only open slots
///   are blockable.
Future<void> showSlotActionsDialog(
  BuildContext context, {
  required ScheduleBloc bloc,
  required OwnerSlot slot,
  required OwnerCourt court,
}) {
  return showDialog<void>(
    context: context,
    builder: (_) => _SlotActionsDialog(bloc: bloc, slot: slot, court: court),
  );
}

class _SlotActionsDialog extends StatefulWidget {
  const _SlotActionsDialog({
    required this.bloc,
    required this.slot,
    required this.court,
  });
  final ScheduleBloc bloc;
  final OwnerSlot slot;
  final OwnerCourt court;

  @override
  State<_SlotActionsDialog> createState() => _SlotActionsDialogState();
}

class _SlotActionsDialogState extends State<_SlotActionsDialog> {
  final _reasonCtrl = TextEditingController();

  @override
  void dispose() {
    _reasonCtrl.dispose();
    super.dispose();
  }

  OwnerSlot get _slot => widget.slot;

  String get _timeLabel {
    final s = _slot.startAt.toLocal();
    final e = _slot.endAt.toLocal();
    final f = DateFormat('HH:mm');
    return '${f.format(s)} – ${f.format(e)} · ${DateFormat('dd/MM').format(s)}';
  }

  void _block() {
    widget.bloc
        .add(ScheduleEvent.slotBlocked(_slot.id, reason: _reasonCtrl.text));
    Navigator.of(context).pop();
  }

  void _unblock() {
    widget.bloc.add(ScheduleEvent.slotUnblocked(_slot.id));
    Navigator.of(context).pop();
  }

  /// OWNER-33: open the slot's player roster (stacked over this sheet).
  void _viewPlayers() {
    showSlotPlayersDialog(
      context,
      slotId: _slot.id,
      courtName: widget.court.name,
      // Per-slot cap drives the "X/Y" denominator; fall back to court capacity.
      capacity: _slot.maxPlayers,
      sportType: null,
      // slot_participants has no notes column; blockedReason is the closest note.
      notes: _slot.blockedReason,
      startLocal: _slot.startAt.toLocal(),
      endLocal: _slot.endAt.toLocal(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Semantics(
          label: 'slot-actions-dialog',
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: _body(),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _body() => switch (_slot.status) {
        SlotStatus.open => _blockBody(),
        SlotStatus.blocked => _unblockBody(),
        SlotStatus.booked => _bookedBody(),
        _ => _cannotBody(
            'Không thể khoá',
            'Chỉ có thể khoá khung giờ còn trống.',
          ),
      };

  // --- open → block ---------------------------------------------------------
  List<Widget> _blockBody() => [
        _Header(
          icon: Icons.lock_outline_rounded,
          iconBg: AppColors.neutral100,
          iconColor: AppColors.neutral700,
          title: 'Khoá khung giờ',
          subtitle: _timeLabel,
          onClose: () => Navigator.of(context).pop(),
        ),
        const SizedBox(height: 18),
        Text(
          'Lý do (không bắt buộc)',
          style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.neutral700),
        ),
        const SizedBox(height: 6),
        Semantics(
          label: 'slot-block-reason-field',
          textField: true,
          child: TextField(
            controller: _reasonCtrl,
            maxLines: 2,
            style: GoogleFonts.plusJakartaSans(fontSize: 13.5),
            decoration: const InputDecoration(
              hintText: 'VD: Bảo trì sân, sự kiện riêng…',
            ),
          ),
        ),
        const SizedBox(height: 12),
        _InfoNote(
          'Khung giờ bị khoá sẽ không hiển thị cho khách đặt sân.',
        ),
        const SizedBox(height: 22),
        Row(
          children: [
            Expanded(child: _CancelButton(onTap: () => Navigator.of(context).pop())),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: Semantics(
                label: 'slot-block-btn',
                button: true,
                child: FilledButton.icon(
                  icon: const Icon(Icons.lock_rounded, size: 16),
                  label: const Text('Khoá giờ'),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.neutral800,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    textStyle: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                  onPressed: _block,
                ),
              ),
            ),
          ],
        ),
      ];

  // --- blocked → unblock ----------------------------------------------------
  List<Widget> _unblockBody() {
    final reason = _slot.blockedReason?.trim();
    return [
      _Header(
        icon: Icons.lock_rounded,
        iconBg: AppColors.neutral100,
        iconColor: AppColors.neutral600,
        title: 'Khung giờ đang khoá',
        subtitle: _timeLabel,
        onClose: () => Navigator.of(context).pop(),
      ),
      if (reason != null && reason.isNotEmpty) ...[
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.neutral50,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.neutral200),
          ),
          child: Semantics(
            label: 'slot-block-reason-text',
            child: Text(
              'Lý do: $reason',
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 13, color: AppColors.neutral700),
            ),
          ),
        ),
      ],
      const SizedBox(height: 22),
      Row(
        children: [
          Expanded(child: _CancelButton(onTap: () => Navigator.of(context).pop())),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: Semantics(
              label: 'slot-unblock-btn',
              button: true,
              child: FilledButton.icon(
                icon: const Icon(Icons.lock_open_rounded, size: 16),
                label: const Text('Bỏ khoá'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  textStyle: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w600, fontSize: 14),
                ),
                onPressed: _unblock,
              ),
            ),
          ),
        ],
      ),
    ];
  }

  // --- booked / other → cannot block ---------------------------------------
  List<Widget> _cannotBody(String title, String message) => [
        _Header(
          icon: Icons.event_busy_rounded,
          iconBg: AppColors.dangerBg,
          iconColor: AppColors.danger,
          title: title,
          subtitle: _timeLabel,
          onClose: () => Navigator.of(context).pop(),
        ),
        const SizedBox(height: 16),
        Semantics(
          label: 'slot-block-error',
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.dangerBg,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.danger.withValues(alpha: 0.3)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.error_outline_rounded,
                    size: 16, color: AppColors.danger),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    message,
                    style: GoogleFonts.plusJakartaSans(
                        fontSize: 13, color: AppColors.dangerDark),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            // Block is disabled for a booked slot (AC #4).
            Expanded(
              child: Semantics(
                label: 'slot-block-btn',
                button: true,
                enabled: false,
                child: FilledButton.icon(
                  icon: const Icon(Icons.lock_rounded, size: 16),
                  label: const Text('Khoá giờ'),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.neutral800,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: AppColors.neutral200,
                    disabledForegroundColor: AppColors.neutral400,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: null, // disabled
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(child: _CancelButton(onTap: () => Navigator.of(context).pop(), label: 'Đóng')),
          ],
        ),
      ];

  // --- booked → cannot block, but can view the player list (OWNER-33) -------
  List<Widget> _bookedBody() => [
        _Header(
          icon: Icons.event_busy_rounded,
          iconBg: AppColors.dangerBg,
          iconColor: AppColors.danger,
          title: 'Khung giờ đã được đặt',
          subtitle: _timeLabel,
          onClose: () => Navigator.of(context).pop(),
        ),
        const SizedBox(height: 16),
        Semantics(
          label: 'slot-block-error',
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.dangerBg,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.danger.withValues(alpha: 0.3)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.error_outline_rounded,
                    size: 16, color: AppColors.danger),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Không thể khoá khung giờ đã có khách đặt.',
                    style: GoogleFonts.plusJakartaSans(
                        fontSize: 13, color: AppColors.dangerDark),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: Semantics(
            label: 'slot-view-players-btn',
            button: true,
            child: FilledButton.icon(
              icon: const Icon(Icons.groups_rounded, size: 18),
              label: const Text('Xem danh sách người chơi'),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(vertical: 14),
                textStyle: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w600, fontSize: 14),
              ),
              onPressed: _viewPlayers,
            ),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            // Block stays disabled for a booked slot (OWNER-25 AC #4).
            Expanded(
              child: Semantics(
                label: 'slot-block-btn',
                button: true,
                enabled: false,
                child: FilledButton.icon(
                  icon: const Icon(Icons.lock_rounded, size: 16),
                  label: const Text('Khoá giờ'),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.neutral800,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: AppColors.neutral200,
                    disabledForegroundColor: AppColors.neutral400,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: null, // disabled
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
                child: _CancelButton(
                    onTap: () => Navigator.of(context).pop(), label: 'Đóng')),
          ],
        ),
      ];
}

// ---------------------------------------------------------------------------

class _Header extends StatelessWidget {
  const _Header({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onClose,
  });
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration:
              BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, size: 20, color: iconColor),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.sora(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: AppColors.neutral900),
              ),
              Text(
                subtitle,
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 13, color: AppColors.neutral500),
              ),
            ],
          ),
        ),
        IconButton(
          icon: const Icon(Icons.close_rounded, size: 20),
          color: AppColors.neutral500,
          onPressed: onClose,
        ),
      ],
    );
  }
}

class _CancelButton extends StatelessWidget {
  const _CancelButton({required this.onTap, this.label = 'Huỷ'});
  final VoidCallback onTap;
  final String label;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.neutral700,
        side: const BorderSide(color: AppColors.neutral200),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        padding: const EdgeInsets.symmetric(vertical: 14),
      ),
      child: Text(label),
    );
  }
}

class _InfoNote extends StatelessWidget {
  const _InfoNote(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.neutral50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.neutral200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline_rounded,
              size: 16, color: AppColors.neutral500),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 12.5, height: 1.4, color: AppColors.neutral600),
            ),
          ),
        ],
      ),
    );
  }
}
