// Sticky bottom CTA bar for the slot detail screen: join/booked states and
// the pill button. Extracted from slot_detail_screen.dart.

import 'package:customer/features/slots/cubit/slot_detail_cubit.dart';
import 'package:customer/features/slots/slots_style.dart';
import 'package:customer/l10n/app_localizations.dart';
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
                child: Text(
                  AppLocalizations.of(context).slotsManageTitle,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
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
    final l10n = AppLocalizations.of(context);
    // A request already sent / resolved takes priority over fullness.
    switch (joinStatus) {
      case SlotJoinStatus.pending:
        return _CtaPill(
          label: l10n.slotsRequestSentPending,
          bg: const Color(0xFFFEF3C7),
          fg: const Color(0xFF92670B),
        );
      case SlotJoinStatus.approved:
        return _CtaPill(
          label: '✓ ${l10n.slotsJoined}',
          bg: mdPrimaryContainer,
          fg: mdOnPrimaryContainer,
        );
      case SlotJoinStatus.rejected:
        return _CtaPill(
          label: l10n.slotsRequestRejected,
          bg: const Color(0x1F181D17),
          fg: const Color(0x61181D17),
        );
      case SlotJoinStatus.none:
        break;
    }

    if (isFull) {
      return _CtaPill(
        label: l10n.slotsFull,
        bg: const Color(0x1F181D17),
        fg: const Color(0x61181D17),
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
          : Text(
              l10n.slotsRegisterToJoin,
              style: const TextStyle(
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
