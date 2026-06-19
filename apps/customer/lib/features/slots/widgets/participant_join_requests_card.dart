// Join-requests card (host approve/reject) for the participant management
// screen. Extracted from participant_management_screen.dart.

import 'package:customer/features/slots/cubit/participant_management_cubit.dart';
import 'package:customer/features/slots/cubit/participant_management_state.dart';
import 'package:customer/features/slots/slots_style.dart';
import 'package:customer/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class JoinRequestsCard extends StatelessWidget {
  const JoinRequestsCard({
    super.key,
    required this.pending,
    required this.confirmed,
    required this.maxPlayers,
  });

  final List<JoinRequest> pending;
  final List<SlotParticipant> confirmed;
  final int maxPlayers;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isFull = confirmed.length >= maxPlayers;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(mdCornerMd),
      elevation: 1,
      shadowColor: const Color(0x1A000000),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Text(
                  l10n.slotsJoinRequestsTitle,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: mdOnSurface,
                  ),
                ),
                if (pending.isNotEmpty) ...[
                  const SizedBox(width: 8),
                  Container(
                    height: 20,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      color: mdPrimary,
                      borderRadius: BorderRadius.circular(mdCornerFull),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '${pending.length}',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            // Full warning banner
            if (isFull && pending.isNotEmpty) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: mdWarningBg,
                  borderRadius: BorderRadius.circular(mdCornerSm),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.warning_amber_rounded,
                      size: 16,
                      color: mdWarningText,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        l10n.slotsSlotFullRemoveOne(maxPlayers),
                        style: const TextStyle(
                          fontSize: 12,
                          color: mdWarningText,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 12),
            // Empty state
            if (pending.isEmpty)
              Column(
                children: [
                  const CircleAvatar(
                    radius: 20,
                    backgroundColor: mdPrimaryContainer,
                    child: Icon(
                      Icons.check,
                      size: 20,
                      color: mdOnPrimaryContainer,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.slotsAllRequestsHandled,
                    style: const TextStyle(
                      fontSize: 13,
                      color: mdOnSurfaceVariant,
                    ),
                  ),
                ],
              )
            else
              ...pending.map(
                (req) => _JoinRequestRow(request: req, isFull: isFull),
              ),
          ],
        ),
      ),
    );
  }
}

class _JoinRequestRow extends StatelessWidget {
  const _JoinRequestRow({required this.request, required this.isFull});

  final JoinRequest request;
  final bool isFull;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ParticipantManagementCubit>();
    final l10n = AppLocalizations.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: request.avatarColor,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  request.initials,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      request.name,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: mdOnSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '⭐ ${request.rating} · '
                      '${l10n.slotsGamesPlayed(request.gamesPlayed)} · '
                      '${request.timeAgo}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: mdOnSurfaceVariant,
                      ),
                    ),
                    if (request.note != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        '"${request.note}"',
                        style: const TextStyle(
                          fontSize: 12,
                          color: mdOnSurfaceVariant,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Action buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => cubit.reject(request),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: mdOutlineVariant),
                    foregroundColor: mdOnSurfaceVariant,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(mdCornerSm),
                    ),
                  ),
                  child: Text(
                    l10n.slotsReject,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: FilledButton.icon(
                  onPressed: isFull ? null : () => cubit.approve(request),
                  style: FilledButton.styleFrom(
                    backgroundColor: mdPrimary,
                    disabledBackgroundColor: mdSurfaceContainerHighest,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(mdCornerSm),
                    ),
                  ),
                  icon: isFull
                      ? const Icon(Icons.lock_outline, size: 14)
                      : const SizedBox.shrink(),
                  label: Text(
                    l10n.slotsAccept,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
