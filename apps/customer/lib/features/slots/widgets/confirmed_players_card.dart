// Confirmed-roster card (with per-player actions) for the participant
// management screen. Extracted from participant_management_screen.dart.

import 'package:customer/features/slots/cubit/participant_management_cubit.dart';
import 'package:customer/features/slots/cubit/participant_management_state.dart';
import 'package:customer/features/slots/slots_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ConfirmedPlayersCard extends StatelessWidget {
  const ConfirmedPlayersCard({
    super.key,
    required this.confirmed,
    required this.maxPlayers,
  });

  final List<SlotParticipant> confirmed;
  final int maxPlayers;

  @override
  Widget build(BuildContext context) {
    final filled = confirmed.length;

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
                Expanded(
                  child: Text(
                    'Người chơi · $filled/$maxPlayers',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: mdOnSurface,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: mdSurfaceContainer,
                    borderRadius: BorderRadius.circular(mdCornerSm),
                  ),
                  child: const Text(
                    'slot_participants',
                    style: TextStyle(
                      fontSize: 10,
                      fontFamily: 'monospace',
                      color: mdOnSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            // Fullness meter
            Row(
              children: List.generate(
                maxPlayers,
                (i) => Expanded(
                  child: Container(
                    height: 4,
                    margin: EdgeInsets.only(right: i < maxPlayers - 1 ? 4 : 0),
                    decoration: BoxDecoration(
                      color: i < filled ? mdPrimary : mdSurfaceContainerHighest,
                      borderRadius: BorderRadius.circular(mdCornerFull),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '$filled/$maxPlayers người',
              style: const TextStyle(fontSize: 11, color: mdOnSurfaceVariant),
            ),
            Divider(height: 20, color: mdOutlineVariant.withAlpha(128)),
            // Player rows
            ...confirmed.map(
              (p) => _ParticipantRow(
                participant: p,
                onRemove: p.isHost
                    ? null
                    : () => context.read<ParticipantManagementCubit>().remove(
                        p.id,
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ParticipantRow extends StatelessWidget {
  const _ParticipantRow({required this.participant, this.onRemove});

  final SlotParticipant participant;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: participant.avatarColor,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              participant.initials,
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
                Row(
                  children: [
                    Text(
                      participant.name,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: mdOnSurface,
                      ),
                    ),
                    if (participant.isHost) ...[
                      const SizedBox(width: 6),
                      Container(
                        height: 18,
                        padding: const EdgeInsets.symmetric(horizontal: 7),
                        decoration: BoxDecoration(
                          color: mdPrimaryContainer,
                          borderRadius: BorderRadius.circular(mdCornerFull),
                        ),
                        alignment: Alignment.center,
                        child: const Text(
                          'Chủ slot',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: mdOnPrimaryContainer,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                if (participant.subtitle != null)
                  Text(
                    participant.subtitle!,
                    style: const TextStyle(
                      fontSize: 12,
                      color: mdOnSurfaceVariant,
                    ),
                  ),
              ],
            ),
          ),
          if (onRemove != null)
            IconButton(
              icon: const Icon(Icons.close, size: 18),
              color: mdOnSurfaceVariant,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              onPressed: onRemove,
            ),
        ],
      ),
    );
  }
}
