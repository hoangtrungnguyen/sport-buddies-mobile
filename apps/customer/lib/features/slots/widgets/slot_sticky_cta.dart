// Sticky bottom CTA bar for the slot detail screen: join/booked states and
// the pill button. Extracted from slot_detail_screen.dart.

import 'package:customer/features/slots/cubit/slot_detail_cubit.dart';
import 'package:customer/features/slots/slot_detail_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class StickyCtaBar extends StatelessWidget {
  const StickyCtaBar({
    super.key,
    required this.isFull,
    required this.slotId,
    required this.isOwner,
    required this.isOpen,
    required this.joinStatus,
    required this.joining,
  });

  final bool isFull;
  final String slotId;
  final bool isOwner;

  /// Slot is open for play-together (`access_policy == 'open'`).
  final bool isOpen;
  final SlotJoinStatus joinStatus;
  final bool joining;

  @override
  Widget build(BuildContext context) {
    // Players can only join open, non-owned slots. Owners get the manage
    // button; for a private slot a non-owner has no action, so hide the bar.
    if (!isOwner && !isOpen) return const SizedBox.shrink();

    final bottomPad = MediaQuery.of(context).padding.bottom;
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Container(
        decoration: BoxDecoration(
          color: mdSurface,
          border: Border(
            top: BorderSide(color: mdOutlineVariant.withAlpha(128)),
          ),
        ),
        padding: EdgeInsets.fromLTRB(16, 12, 16, 12 + bottomPad),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isOwner) ...[
              OutlinedButton(
                onPressed: () => context.push('/slot/$slotId/manage'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                  side: const BorderSide(color: mdPrimary),
                  foregroundColor: mdPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(mdCornerFull),
                  ),
                ),
                child: const Text(
                  'Quản lý người chơi',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
              ),
            ] else
              _JoinCta(
                isFull: isFull,
                joinStatus: joinStatus,
                joining: joining,
                onJoin: () =>
                    context.read<SlotDetailCubit>().requestToJoin(slotId),
              ),
          ],
        ),
      ),
    );
  }
}

/// Play-together join CTA — reflects the player's current request status.
class _JoinCta extends StatelessWidget {
  const _JoinCta({
    required this.isFull,
    required this.joinStatus,
    required this.joining,
    required this.onJoin,
  });

  final bool isFull;
  final SlotJoinStatus joinStatus;
  final bool joining;
  final VoidCallback onJoin;

  @override
  Widget build(BuildContext context) {
    // A request already sent / resolved takes priority over fullness.
    switch (joinStatus) {
      case SlotJoinStatus.pending:
        return const _CtaPill(
          label: 'Đã gửi yêu cầu · Chờ duyệt',
          bg: Color(0xFFFEF3C7),
          fg: Color(0xFF92670B),
        );
      case SlotJoinStatus.approved:
        return const _CtaPill(
          label: '✓ Đã tham gia',
          bg: mdPrimaryContainer,
          fg: mdOnPrimaryContainer,
        );
      case SlotJoinStatus.rejected:
        return const _CtaPill(
          label: 'Yêu cầu bị từ chối',
          bg: Color(0x1F181D17),
          fg: Color(0x61181D17),
        );
      case SlotJoinStatus.none:
        break;
    }

    if (isFull) {
      return const _CtaPill(
        label: 'Đã đủ người',
        bg: Color(0x1F181D17),
        fg: Color(0x61181D17),
      );
    }

    return FilledButton(
      onPressed: joining ? null : onJoin,
      style: FilledButton.styleFrom(
        backgroundColor: mdPrimary,
        disabledBackgroundColor: const Color(0x1F181D17),
        minimumSize: const Size(double.infinity, 56),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(mdCornerFull),
        ),
      ),
      child: joining
          ? const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: Colors.white,
              ),
            )
          : const Text(
              'Đăng ký chơi cùng',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
    );
  }
}

/// Non-interactive status pill shown in place of the join button.
class _CtaPill extends StatelessWidget {
  const _CtaPill({required this.label, required this.bg, required this.fg});

  final String label;
  final Color bg;
  final Color fg;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(mdCornerFull),
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: fg),
      ),
    );
  }
}
