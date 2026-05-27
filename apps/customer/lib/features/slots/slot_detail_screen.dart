import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SlotDetailScreen extends StatelessWidget {
  const SlotDetailScreen({super.key, required this.slotId, this.isFull = false});

  final String slotId;
  final bool isFull;

  static const _players = [
    _PlayerData(
      initials: 'TM',
      color: Color(0xFF16A34A),
      name: 'Trần Minh',
      sub: 'Chủ slot · ⭐ 4.8 · 12 trận',
      isHost: true,
    ),
    _PlayerData(
      initials: 'NH',
      color: Color(0xFF0EA5E9),
      name: 'Nguyễn Hoàng',
      sub: '⭐ 4.6 · 8 trận',
      isHost: false,
    ),
    _PlayerData(
      initials: 'PT',
      color: Color(0xFFEAB308),
      name: 'Phạm Thuỷ',
      sub: '⭐ 4.9 · 14 trận',
      isHost: false,
    ),
  ];

  static const int _joined = 3;
  static const int _max = 6;

  @override
  Widget build(BuildContext context) {
    final joined = isFull ? _max : _joined;
    final max = _max;
    final full = joined >= max;
    final empties = full ? 0 : max - joined;
    final displayPlayers = isFull ? _players : _players;

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
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _HeroSection(),
                const SizedBox(height: 8),
                _TimeCard(),
                const SizedBox(height: 12),
                _FullnessCard(
                  joined: joined,
                  max: max,
                  full: full,
                  empties: empties,
                  players: displayPlayers,
                ),
                const SizedBox(height: 12),
                _HostMessageCard(),
                const SizedBox(height: 12),
              ],
            ),
          ),
          _StickyCtaBar(isFull: full),
        ],
      ),
    );
  }
}

class _HeroSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFF0EA5E9).withOpacity(0.12),
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
            child: const Icon(
              Icons.sports_tennis,
              size: 28,
              color: Color(0xFF0EA5E9),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Pickle Hub Q1 · Sân B',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  '123 Nguyễn Du, Q.1 · 1.2 km',
                  style: TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _BadgePill(
                      label: '🌐 Mở chơi ghép',
                      bg: Colors.white,
                      textColor: const Color(0xFF374151),
                    ),
                    const SizedBox(width: 6),
                    _BadgePill(
                      label: 'Pickleball',
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
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'THỜI GIAN',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF6B7280),
                    letterSpacing: 0.5,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  '19:00 – 20:30',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF111827),
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Thứ tư, 14/05 · 1.5 giờ',
                  style: TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
                ),
              ],
            ),
            const Spacer(),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: const [
                Text(
                  'PHÍ / NGƯỜI',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF6B7280),
                    letterSpacing: 0.5,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  '50k',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF111827),
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Tổng sân 250k · chia đều',
                  style: TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
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
    required this.players,
  });

  final int joined;
  final int max;
  final bool full;
  final int empties;
  final List<_PlayerData> players;

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
            ...players.map((p) => _PlayerRow(player: p)),
            if (!full)
              ...List.generate(
                empties,
                (i) => const _EmptyPlayerRow(),
              ),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
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
              '"Mình tìm 3 bạn chơi đôi level trung bình. Mang vợt + giày sạch nhé. Cảm ơn 🏓"',
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
  const _StickyCtaBar({required this.isFull});

  final bool isFull;

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
                  'Đăng ký chơi cùng · 50k',
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

class _PlayerRow extends StatelessWidget {
  const _PlayerRow({required this.player});

  final _PlayerData player;

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
              color: player.color,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                player.initials,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
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
                      player.name,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF111827),
                      ),
                    ),
                    if (player.isHost) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFDCFCE7),
                          borderRadius: BorderRadius.circular(99),
                        ),
                        child: const Text(
                          'Chủ slot',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF15803D),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  player.sub,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyPlayerRow extends StatelessWidget {
  const _EmptyPlayerRow();

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
              color: const Color(0xFFF3F4F6),
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFFD1D5DB),
                width: 1.5,
                style: BorderStyle.solid,
              ),
            ),
            child: const Center(
              child: Text(
                '+',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF9CA3AF),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          const Text(
            'Chỗ trống',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Color(0xFF9CA3AF),
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

class _PlayerData {
  const _PlayerData({
    required this.initials,
    required this.color,
    required this.name,
    required this.sub,
    required this.isHost,
  });

  final String initials;
  final Color color;
  final String name;
  final String sub;
  final bool isHost;
}
