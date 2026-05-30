import 'package:customer/features/slots/cubit/slot_detail_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:spb_core/spb_core.dart';

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
    return BlocBuilder<SlotDetailCubit, SlotDetailState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: const Color(0xFFF9FAFB),
          appBar: AppBar(
            title: const Text('Chi tiết slot'),
            backgroundColor: const Color(0xFFF9FAFB),
            elevation: 0,
            leading: BackButton(onPressed: () => context.pop()),
            actions: [
              IconButton(
                icon: const Icon(Icons.share_outlined),
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
                  style: const TextStyle(color: Color(0xFF6B7280)),
                ),
              ),
            SlotDetailLoaded(slot: final slot) => _Body(slot: slot),
          },
        );
      },
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.slot});

  final Slot slot;

  @override
  Widget build(BuildContext context) {
    final joined = slot.currentPlayers;
    final max = slot.maxPlayers;
    final full = slot.isFull;
    final empties = full ? 0 : max - joined;

    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _HeroSection(slot: slot),
              const SizedBox(height: 8),
              _TimeCard(slot: slot),
              const SizedBox(height: 12),
              _FullnessCard(
                joined: joined,
                max: max,
                full: full,
                empties: empties,
              ),
              const SizedBox(height: 12),
              _HostMessageCard(),
              const SizedBox(height: 12),
            ],
          ),
        ),
        _StickyCtaBar(isFull: full, slot: slot),
      ],
    );
  }
}

class _HeroSection extends StatelessWidget {
  const _HeroSection({required this.slot});

  final Slot slot;

  static const _sportIcons = <String, IconData>{
    'pickleball': Icons.sports_tennis,
    'badminton': Icons.sports_tennis,
    'tennis': Icons.sports_tennis,
    'football': Icons.sports_soccer,
    'basketball': Icons.sports_basketball,
    'volleyball': Icons.sports_volleyball,
  };

  @override
  Widget build(BuildContext context) {
    final icon = _sportIcons[slot.sportType] ?? Icons.sports;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF0EA5E9).withValues(alpha: 0.12),
            const Color(0xFFF9FAFB),
          ],
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x1A000000),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Icon(icon, size: 28, color: const Color(0xFF0EA5E9)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  slot.courtName,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    if (slot.accessPolicy == 'open') ...[
                      const _BadgePill(
                        label: '🌐 Mở chơi ghép',
                        bg: Colors.white,
                        textColor: Color(0xFF374151),
                      ),
                      const SizedBox(width: 6),
                    ],
                    _BadgePill(
                      label: slot.sportType,
                      bg: Colors.white,
                      textColor: const Color(0xFF374151),
                    ),
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

class _TimeCard extends StatelessWidget {
  const _TimeCard({required this.slot});

  final Slot slot;

  @override
  Widget build(BuildContext context) {
    final timeFmt = DateFormat('HH:mm');
    final dateFmt = DateFormat('EEE, dd/MM', 'vi');
    final durationH = slot.endTime.difference(slot.startTime).inMinutes / 60;
    final durationLabel = durationH == durationH.roundToDouble()
        ? '${durationH.toInt()} giờ'
        : '${durationH.toStringAsFixed(1)} giờ';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0D000000),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'THỜI GIAN',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF6B7280),
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${timeFmt.format(slot.startTime)} – ${timeFmt.format(slot.endTime)}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${dateFmt.format(slot.startTime)} · $durationLabel',
                  style: const TextStyle(
                      fontSize: 13, color: Color(0xFF6B7280)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _FullnessCard extends StatelessWidget {
  const _FullnessCard({
    required this.joined,
    required this.max,
    required this.full,
    required this.empties,
  });

  final int joined;
  final int max;
  final bool full;
  final int empties;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0D000000),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Người chơi',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF111827),
                  ),
                ),
                _FullnessPill(joined: joined, max: max, full: full),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: List.generate(max, (i) {
                return Expanded(
                  child: Container(
                    height: 6,
                    margin: EdgeInsets.only(right: i < max - 1 ? 4 : 0),
                    decoration: BoxDecoration(
                      color: i < joined
                          ? const Color(0xFF16A34A)
                          : const Color(0xFFE5E7EB),
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 8),
            Text(
              full
                  ? 'Slot đã đầy. Hãy thử slot khác cùng giờ ở khu vực của bạn.'
                  : 'Còn $empties chỗ trống · Cấp độ trung bình',
              style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
            ),
            const Divider(height: 28, color: Color(0xFFE5E7EB)),
            ...List.generate(joined, (_) => const _EmptyPlayerRow(filled: true)),
            if (!full)
              ...List.generate(empties, (_) => const _EmptyPlayerRow(filled: false)),
          ],
        ),
      ),
    );
  }
}

class _HostMessageCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0D000000),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'LỜI NHẮN TỪ CHỦ SLOT',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Color(0xFF6B7280),
                letterSpacing: 0.5,
              ),
            ),
            SizedBox(height: 6),
            Text(
              '"Mình tìm bạn chơi ghép. Mang vợt + giày sạch nhé. Cảm ơn 🏓"',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF374151),
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StickyCtaBar extends StatelessWidget {
  const _StickyCtaBar({required this.isFull, required this.slot});

  final bool isFull;
  final Slot slot;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Color(0xFFE5E7EB))),
        ),
        child: isFull
            ? SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE5E7EB),
                    disabledBackgroundColor: const Color(0xFFE5E7EB),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Đã đủ người',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF9CA3AF),
                    ),
                  ),
                ),
              )
            : FilledButton(
                onPressed: () {},
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF16A34A),
                  minimumSize: const Size(double.infinity, 52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Đăng ký chơi cùng',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
      ),
    );
  }
}

class _FullnessPill extends StatelessWidget {
  const _FullnessPill({
    required this.joined,
    required this.max,
    required this.full,
  });

  final int joined;
  final int max;
  final bool full;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: full ? const Color(0xFFF3F4F6) : const Color(0xFFDCFCE7),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: full ? const Color(0xFF6B7280) : const Color(0xFF22C55E),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            full ? 'Đã đủ người' : '$joined/$max người',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: full
                  ? const Color(0xFF6B7280)
                  : const Color(0xFF15803D),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyPlayerRow extends StatelessWidget {
  const _EmptyPlayerRow({required this.filled});

  final bool filled;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: filled ? const Color(0xFFDCFCE7) : const Color(0xFFF3F4F6),
              shape: BoxShape.circle,
              border: Border.all(
                color: filled
                    ? const Color(0xFF86EFAC)
                    : const Color(0xFFD1D5DB),
                width: 1.5,
              ),
            ),
            child: Center(
              child: Text(
                filled ? '✓' : '+',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: filled
                      ? const Color(0xFF16A34A)
                      : const Color(0xFF9CA3AF),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            filled ? 'Đã có người' : 'Chỗ trống',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: filled
                  ? const Color(0xFF374151)
                  : const Color(0xFF9CA3AF),
            ),
          ),
        ],
      ),
    );
  }
}

class _BadgePill extends StatelessWidget {
  const _BadgePill({
    required this.label,
    required this.bg,
    required this.textColor,
  });

  final String label;
  final Color bg;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        border: Border.all(color: const Color(0xFFE5E7EB)),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }
}
