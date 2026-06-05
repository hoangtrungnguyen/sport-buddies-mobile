// Participant management screen — host-only view for an open group slot.
// Covers: OwnerManage (pre-game) — slot summary, confirmed roster,
// join-request approve/reject, and an animated toast.

import 'package:customer/features/slots/cubit/participant_management_cubit.dart';
import 'package:customer/features/slots/cubit/participant_management_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

// ── MD3 tokens ────────────────────────────────────────────────────────────────
const _mdSurface = Color(0xFFF7FBF2);
const _mdOnSurface = Color(0xFF181D17);
const _mdOnSurfaceVariant = Color(0xFF42493F);
const _mdSurfaceContainer = Color(0xFFEBF0E6);
const _mdSurfaceContainerHighest = Color(0xFFDFE4DA);
const _mdPrimary = Color(0xFF15803D);
const _mdPrimaryContainer = Color(0xFFC9F2D2);
const _mdOnPrimaryContainer = Color(0xFF00210B);
const _mdOutlineVariant = Color(0xFFC2C8BB);
const _mdCornerSm = 8.0;
const _mdCornerMd = 12.0;
const _mdCornerFull = 9999.0;
const _mdWarningBg = Color(0xFFFFFBEB);
const _mdWarningText = Color(0xFF92670B);

// ── Screen ────────────────────────────────────────────────────────────────────

class ParticipantManagementScreen extends StatelessWidget {
  const ParticipantManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _mdSurface,
      appBar: AppBar(
        backgroundColor: _mdSurface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: _mdOnSurfaceVariant,
          onPressed: () => Navigator.of(context).pop(),
        ),
        centerTitle: true,
        title: const Text(
          'Quản lý người chơi',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: _mdOnSurface,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            color: _mdOnSurfaceVariant,
            onPressed: () {},
          ),
        ],
      ),
      body: BlocConsumer<ParticipantManagementCubit, ParticipantManagementState>(
        listener: (context, state) {
          if (state is ParticipantManagementLoaded &&
              state.toastMessage != null) {
            Future.delayed(const Duration(milliseconds: 2600), () {
              if (context.mounted) {
                context.read<ParticipantManagementCubit>().clearToast();
              }
            });
          }
        },
        builder: (context, state) {
          return switch (state) {
            ParticipantManagementLoading() => const Center(
                child: CircularProgressIndicator(),
              ),
            ParticipantManagementLoaded() => _LoadedBody(state: state),
          };
        },
      ),
    );
  }
}

// ── Loaded body ───────────────────────────────────────────────────────────────

class _LoadedBody extends StatelessWidget {
  const _LoadedBody({required this.state});

  final ParticipantManagementLoaded state;

  @override
  Widget build(BuildContext context) {
    final isShowingToast = state.toastMessage != null;

    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SlotSummaryCard(slot: state.slot),
              const SizedBox(height: 12),
              _ConfirmedPlayersCard(
                confirmed: state.confirmed,
                maxPlayers: state.maxPlayers,
              ),
              const SizedBox(height: 12),
              _JoinRequestsCard(
                pending: state.pending,
                confirmed: state.confirmed,
                maxPlayers: state.maxPlayers,
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
        // Animated toast
        AnimatedPositioned(
          duration: const Duration(milliseconds: 320),
          curve: Curves.easeOutBack,
          bottom: isShowingToast ? 20 : -80,
          left: 16,
          right: 16,
          child: _ToastWidget(
            message: state.toastMessage ?? '',
            isDanger: state.toastDanger,
          ),
        ),
      ],
    );
  }
}

// ── Card 1 — Slot summary ─────────────────────────────────────────────────────

class _SlotSummaryCard extends StatelessWidget {
  const _SlotSummaryCard({required this.slot});

  final SlotSummary slot;

  @override
  Widget build(BuildContext context) {
    final timeFmt = DateFormat('HH:mm');
    final dateFmt = DateFormat('EEE, dd/MM', 'vi');

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(_mdCornerMd),
      elevation: 1,
      shadowColor: const Color(0x1A000000),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top row: badge + slot ID
            Row(
              children: [
                Container(
                  height: 24,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: _mdPrimaryContainer,
                    borderRadius: BorderRadius.circular(_mdCornerFull),
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    '🌐 Mở chơi ghép',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: _mdOnPrimaryContainer,
                    ),
                  ),
                ),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: _mdSurfaceContainer,
                    borderRadius: BorderRadius.circular(_mdCornerSm),
                  ),
                  child: const Text(
                    'slot_open_001',
                    style: TextStyle(
                      fontSize: 11,
                      fontFamily: 'monospace',
                      color: _mdOnSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              slot.courtName,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: _mdOnSurface,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${dateFmt.format(slot.startTime)} · '
              '${timeFmt.format(slot.startTime)}–${timeFmt.format(slot.endTime)} · '
              '${slot.sportType}',
              style: const TextStyle(
                fontSize: 13,
                color: _mdOnSurfaceVariant,
              ),
            ),
            Divider(
              height: 20,
              color: _mdOutlineVariant.withAlpha(128),
            ),
            // Fullness row — rendered by parent since we need maxPlayers from
            // the loaded state. We pass slot only here, so the fullness meter
            // is shown in the players card instead.
            const Row(
              children: [
                Icon(Icons.group_outlined,
                    size: 16, color: _mdOnSurfaceVariant),
                SizedBox(width: 6),
                Text(
                  'Xem danh sách bên dưới',
                  style: TextStyle(fontSize: 12, color: _mdOnSurfaceVariant),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Card 2 — Confirmed players ────────────────────────────────────────────────

class _ConfirmedPlayersCard extends StatelessWidget {
  const _ConfirmedPlayersCard({
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
      borderRadius: BorderRadius.circular(_mdCornerMd),
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
                      color: _mdOnSurface,
                    ),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: _mdSurfaceContainer,
                    borderRadius: BorderRadius.circular(_mdCornerSm),
                  ),
                  child: const Text(
                    'slot_participants',
                    style: TextStyle(
                      fontSize: 10,
                      fontFamily: 'monospace',
                      color: _mdOnSurfaceVariant,
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
                      color: i < filled
                          ? _mdPrimary
                          : _mdSurfaceContainerHighest,
                      borderRadius: BorderRadius.circular(_mdCornerFull),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '$filled/$maxPlayers người',
              style: const TextStyle(
                fontSize: 11,
                color: _mdOnSurfaceVariant,
              ),
            ),
            Divider(height: 20, color: _mdOutlineVariant.withAlpha(128)),
            // Player rows
            ...confirmed.map(
              (p) => _ParticipantRow(
                participant: p,
                onRemove: p.isHost
                    ? null
                    : () => context
                        .read<ParticipantManagementCubit>()
                        .remove(p.id),
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
                        color: _mdOnSurface,
                      ),
                    ),
                    if (participant.isHost) ...[
                      const SizedBox(width: 6),
                      Container(
                        height: 18,
                        padding: const EdgeInsets.symmetric(horizontal: 7),
                        decoration: BoxDecoration(
                          color: _mdPrimaryContainer,
                          borderRadius: BorderRadius.circular(_mdCornerFull),
                        ),
                        alignment: Alignment.center,
                        child: const Text(
                          'Chủ slot',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: _mdOnPrimaryContainer,
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
                      color: _mdOnSurfaceVariant,
                    ),
                  ),
              ],
            ),
          ),
          if (onRemove != null)
            IconButton(
              icon: const Icon(Icons.close, size: 18),
              color: _mdOnSurfaceVariant,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              onPressed: onRemove,
            ),
        ],
      ),
    );
  }
}

// ── Card 3 — Join requests ────────────────────────────────────────────────────

class _JoinRequestsCard extends StatelessWidget {
  const _JoinRequestsCard({
    required this.pending,
    required this.confirmed,
    required this.maxPlayers,
  });

  final List<JoinRequest> pending;
  final List<SlotParticipant> confirmed;
  final int maxPlayers;

  @override
  Widget build(BuildContext context) {
    final isFull = confirmed.length >= maxPlayers;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(_mdCornerMd),
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
                const Text(
                  'Yêu cầu tham gia',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: _mdOnSurface,
                  ),
                ),
                if (pending.isNotEmpty) ...[
                  const SizedBox(width: 8),
                  Container(
                    height: 20,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      color: _mdPrimary,
                      borderRadius: BorderRadius.circular(_mdCornerFull),
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
                  color: _mdWarningBg,
                  borderRadius: BorderRadius.circular(_mdCornerSm),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning_amber_rounded,
                        size: 16, color: _mdWarningText),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Slot đã đủ $maxPlayers người. Gỡ một người để chấp nhận thêm.',
                        style: const TextStyle(
                          fontSize: 12,
                          color: _mdWarningText,
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
              const Column(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: _mdPrimaryContainer,
                    child: Icon(Icons.check,
                        size: 20, color: _mdOnPrimaryContainer),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Đã xử lý hết yêu cầu',
                    style: TextStyle(fontSize: 13, color: _mdOnSurfaceVariant),
                  ),
                ],
              )
            else
              ...pending.map(
                (req) => _JoinRequestRow(
                  request: req,
                  isFull: isFull,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _JoinRequestRow extends StatelessWidget {
  const _JoinRequestRow({
    required this.request,
    required this.isFull,
  });

  final JoinRequest request;
  final bool isFull;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ParticipantManagementCubit>();

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
                        color: _mdOnSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '⭐ ${request.rating} · ${request.gamesPlayed} trận · ${request.timeAgo}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: _mdOnSurfaceVariant,
                      ),
                    ),
                    if (request.note != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        '"${request.note}"',
                        style: const TextStyle(
                          fontSize: 12,
                          color: _mdOnSurfaceVariant,
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
                    side: const BorderSide(color: _mdOutlineVariant),
                    foregroundColor: _mdOnSurfaceVariant,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(_mdCornerSm),
                    ),
                  ),
                  child: const Text(
                    'Từ chối',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: FilledButton.icon(
                  onPressed: isFull ? null : () => cubit.approve(request),
                  style: FilledButton.styleFrom(
                    backgroundColor: _mdPrimary,
                    disabledBackgroundColor:
                        _mdSurfaceContainerHighest,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(_mdCornerSm),
                    ),
                  ),
                  icon: isFull
                      ? const Icon(Icons.lock_outline, size: 14)
                      : const SizedBox.shrink(),
                  label: const Text(
                    'Chấp nhận',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
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

// ── Toast ─────────────────────────────────────────────────────────────────────

class _ToastWidget extends StatelessWidget {
  const _ToastWidget({required this.message, required this.isDanger});

  final String message;
  final bool isDanger;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF111827),
        borderRadius: BorderRadius.circular(_mdCornerMd),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: isDanger
                  ? const Color(0xFFEF4444)
                  : const Color(0xFF22C55E),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Icon(
              isDanger ? Icons.close : Icons.check,
              size: 14,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
