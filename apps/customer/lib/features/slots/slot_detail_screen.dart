// M3 Slot detail screen — SPB-035 / SPB-054.
// Design: EPIC-4 Slot Detail · Material 3 · slotDetailM3Base component.

import 'package:customer/features/slots/cubit/slot_detail_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:spb_core/spb_core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// ── MD3 tokens ────────────────────────────────────────────────────────────────
const _mdSurface               = Color(0xFFF7FBF2);
const _mdOnSurface             = Color(0xFF181D17);
const _mdOnSurfaceVariant      = Color(0xFF42493F);
const _mdSurfaceContainerLow   = Color(0xFFF1F6EC);
const _mdSurfaceContainer      = Color(0xFFEBF0E6);
const _mdSurfaceContainerHighest = Color(0xFFDFE4DA);
const _mdPrimary                 = Color(0xFF15803D);
const _mdPrimaryContainer        = Color(0xFFC9F2D2);
const _mdOnPrimaryContainer      = Color(0xFF00210B);
const _mdOutlineVariant          = Color(0xFFC2C8BB);
const _mdCornerSm              = 8.0;
const _mdCornerMd              = 12.0;
const _mdCornerXl              = 28.0;
const _mdCornerFull            = 9999.0;

class SlotDetailScreen extends StatefulWidget {
  const SlotDetailScreen({super.key, required this.slotId});

  final String slotId;

  @override
  State<SlotDetailScreen> createState() => _SlotDetailScreenState();
}

class _SlotDetailScreenState extends State<SlotDetailScreen> {
  @override
  void initState() {
    super.initState();
    context.read<SlotDetailCubit>().loadSlot(widget.slotId);
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SlotDetailCubit, SlotDetailState>(
      listenWhen: (prev, curr) =>
          curr is SlotDetailLoaded && curr.errorMessage != null,
      listener: (context, state) {
        final msg = (state as SlotDetailLoaded).errorMessage!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(msg), backgroundColor: Colors.red),
        );
      },
      builder: (context, state) => Scaffold(
        backgroundColor: _mdSurface,
        appBar: AppBar(
          backgroundColor: _mdSurface,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            color: _mdOnSurfaceVariant,
            onPressed: () => context.pop(),
          ),
          centerTitle: true,
          title: const Text(
            'Chi tiết slot',
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
        body: switch (state) {
          SlotDetailLoading() || SlotDetailInitial() => const Center(
              child: CircularProgressIndicator(),
            ),
          SlotDetailError(message: final msg) => Center(
              child: Text(
                msg,
                style: const TextStyle(color: _mdOnSurfaceVariant),
              ),
            ),
          SlotDetailLoaded(
            slot: final slot,
            joinStatus: final joinStatus,
            joining: final joining,
          ) =>
            _Body(slot: slot, joinStatus: joinStatus, joining: joining),
        },
      ),
    );
  }
}

// ── Body ──────────────────────────────────────────────────────────────────────

class _Body extends StatelessWidget {
  const _Body({
    required this.slot,
    required this.joinStatus,
    required this.joining,
  });

  final Slot slot;
  final SlotJoinStatus joinStatus;
  final bool joining;

  @override
  Widget build(BuildContext context) {
    final joined  = slot.currentPlayers;
    final max     = slot.maxPlayers;
    final isFull  = slot.isFull;
    final empties = isFull ? 0 : max - joined;
    final currentUserId =
        Supabase.instance.client.auth.currentSession?.user.id;
    final isOwner = slot.hostId != null && slot.hostId == currentUserId;

    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _HeroSection(slot: slot),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _TimeCard(slot: slot),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _PlayersCard(
                  joined: joined,
                  max: max,
                  isFull: isFull,
                  empties: empties,
                ),
              ),
              const SizedBox(height: 8),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: _HostMessageCard(),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
        _StickyCtaBar(
          isFull: isFull,
          slotId: slot.id,
          isOwner: isOwner,
          isOpen: slot.accessPolicy == 'open',
          joinStatus: joinStatus,
          joining: joining,
        ),
      ],
    );
  }
}

// ── Hero ──────────────────────────────────────────────────────────────────────

class _HeroSection extends StatelessWidget {
  const _HeroSection({required this.slot});

  final Slot slot;

  static IconData _sportIcon(String sport) => switch (sport) {
        'football'   => Icons.sports_soccer,
        'badminton'  => Icons.sports_tennis,
        'pickleball' => Icons.sports_tennis,
        'tennis'     => Icons.sports_tennis,
        _            => Icons.sports,
      };

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _mdSurfaceContainerLow,
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Primary-container sport icon
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: _mdPrimaryContainer,
              borderRadius: BorderRadius.circular(_mdCornerXl),
            ),
            child: Icon(
              _sportIcon(slot.sportType),
              size: 28,
              color: _mdOnPrimaryContainer,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  slot.courtName,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: _mdOnSurface,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Xem bản đồ',
                  style: TextStyle(fontSize: 13, color: _mdOnSurfaceVariant),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    if (slot.accessPolicy == 'open')
                      const _AssistChip(label: '🌐 Mở chơi ghép'),
                    _AssistChip(label: slot.sportType),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AssistChip extends StatelessWidget {
  const _AssistChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 32,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: _mdOutlineVariant),
        borderRadius: BorderRadius.circular(_mdCornerSm),
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: _mdOnSurfaceVariant,
        ),
      ),
    );
  }
}

// ── Time & price card ─────────────────────────────────────────────────────────

class _TimeCard extends StatelessWidget {
  const _TimeCard({required this.slot});

  final Slot slot;

  @override
  Widget build(BuildContext context) {
    final timeFmt    = DateFormat('HH:mm');
    final dateFmt    = DateFormat('EEE, dd/MM', 'vi');
    final durationH  = slot.endTime.difference(slot.startTime).inMinutes / 60;
    final durLabel   = durationH == durationH.roundToDouble()
        ? '${durationH.toInt()} giờ'
        : '${durationH.toStringAsFixed(1)} giờ';

    return Material(
      color: const Color(0xFFFFFFFF),
      borderRadius: BorderRadius.circular(_mdCornerMd),
      elevation: 1,
      shadowColor: const Color(0x1A000000),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'THỜI GIAN',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: _mdOnSurfaceVariant,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${timeFmt.format(slot.startTime.toLocal())} – ${timeFmt.format(slot.endTime.toLocal())}',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: _mdOnSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${dateFmt.format(slot.startTime.toLocal())} · $durLabel',
                    style: const TextStyle(
                      fontSize: 12,
                      color: _mdOnSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Players card ──────────────────────────────────────────────────────────────

class _PlayersCard extends StatelessWidget {
  const _PlayersCard({
    required this.joined,
    required this.max,
    required this.isFull,
    required this.empties,
  });

  final int joined;
  final int max;
  final bool isFull;
  final int empties;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFFFFFFF),
      borderRadius: BorderRadius.circular(_mdCornerMd),
      elevation: 1,
      shadowColor: const Color(0x1A000000),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Người chơi',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: _mdOnSurface,
                  ),
                ),
                _FullnessBadge(joined: joined, max: max, isFull: isFull),
              ],
            ),
            // Segmented fullness track
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Row(
                children: List.generate(max, (i) => Expanded(
                  child: Container(
                    height: 4,
                    margin: EdgeInsets.only(right: i < max - 1 ? 4 : 0),
                    decoration: BoxDecoration(
                      color: i < joined ? _mdPrimary : _mdSurfaceContainerHighest,
                      borderRadius: BorderRadius.circular(_mdCornerFull),
                    ),
                  ),
                )),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isFull
                  ? 'Slot đã đầy. Hãy thử slot khác cùng giờ ở khu vực của bạn.'
                  : 'Còn $empties chỗ trống · Cấp độ trung bình',
              style: const TextStyle(fontSize: 13, color: _mdOnSurfaceVariant),
            ),
            Divider(height: 28, color: _mdOutlineVariant.withAlpha(128)),
            // Filled player rows
            ...List.generate(
              joined,
              (i) => _PlayerRow(index: i, filled: true),
            ),
            // Empty slots
            if (!isFull)
              ...List.generate(
                empties,
                (_) => const _EmptySlotRow(),
              ),
          ],
        ),
      ),
    );
  }
}

class _FullnessBadge extends StatelessWidget {
  const _FullnessBadge({
    required this.joined,
    required this.max,
    required this.isFull,
  });

  final int joined;
  final int max;
  final bool isFull;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 24,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: isFull ? _mdSurfaceContainerHighest : _mdPrimaryContainer,
        borderRadius: BorderRadius.circular(_mdCornerFull),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isFull ? const Color(0xFF72796C) : _mdPrimary,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            isFull ? 'Đã đủ người' : '$joined/$max người',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: isFull ? _mdOnSurfaceVariant : _mdOnPrimaryContainer,
            ),
          ),
        ],
      ),
    );
  }
}

class _PlayerRow extends StatelessWidget {
  const _PlayerRow({required this.index, required this.filled});

  final int index;
  final bool filled;

  static const _colors = [
    Color(0xFF15803D),
    Color(0xFF0369A1),
    Color(0xFFEAB308),
    Color(0xFFEF4444),
  ];

  @override
  Widget build(BuildContext context) {
    final color = _colors[index % _colors.length];
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: color,
            child: Text(
              '${index + 1}',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Người chơi ${index + 1}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: _mdOnSurface,
                      ),
                    ),
                    if (index == 0) ...[
                      const SizedBox(width: 8),
                      Container(
                        height: 20,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        decoration: BoxDecoration(
                          color: _mdPrimaryContainer,
                          borderRadius: BorderRadius.circular(_mdCornerFull),
                        ),
                        child: const Center(
                          child: Text(
                            'Chủ slot',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: _mdOnPrimaryContainer,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const Text(
                  '⭐ 4.7 · đã tham gia',
                  style: TextStyle(fontSize: 12, color: _mdOnSurfaceVariant),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptySlotRow extends StatelessWidget {
  const _EmptySlotRow();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _mdSurfaceContainer,
              shape: BoxShape.circle,
              border: Border.all(
                color: _mdOutlineVariant,
                width: 1.5,
                style: BorderStyle.solid,
              ),
            ),
            child: const Center(
              child: Text(
                '+',
                style: TextStyle(
                  fontSize: 20,
                  color: _mdOnSurfaceVariant,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          const Text(
            'Chỗ trống',
            style: TextStyle(
              fontSize: 14,
              color: _mdOnSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Host message card ─────────────────────────────────────────────────────────

class _HostMessageCard extends StatelessWidget {
  const _HostMessageCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _mdSurfaceContainerLow,
        borderRadius: BorderRadius.circular(_mdCornerMd),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'LỜI NHẮN TỪ CHỦ SLOT',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: _mdOnSurfaceVariant,
              letterSpacing: 1,
            ),
          ),
          SizedBox(height: 10),
          Text(
            '"Mình tìm bạn chơi ghép. Mang vợt + giày sạch nhé. Cảm ơn 🏓"',
            style: TextStyle(
              fontSize: 14,
              color: _mdOnSurface,
              fontStyle: FontStyle.italic,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Sticky CTA ────────────────────────────────────────────────────────────────

class _StickyCtaBar extends StatelessWidget {
  const _StickyCtaBar({
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
          color: _mdSurface,
          border: Border(
            top: BorderSide(color: _mdOutlineVariant.withAlpha(128)),
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
                  side: const BorderSide(color: _mdPrimary),
                  foregroundColor: _mdPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(_mdCornerFull),
                  ),
                ),
                child: const Text(
                  'Quản lý người chơi',
                  style: TextStyle(
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
          bg: _mdPrimaryContainer,
          fg: _mdOnPrimaryContainer,
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
        backgroundColor: _mdPrimary,
        disabledBackgroundColor: const Color(0x1F181D17),
        minimumSize: const Size(double.infinity, 56),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_mdCornerFull),
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
        borderRadius: BorderRadius.circular(_mdCornerFull),
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: fg),
      ),
    );
  }
}
