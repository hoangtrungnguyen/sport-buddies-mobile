import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CourtDetailScreen extends StatelessWidget {
  const CourtDetailScreen({super.key, required this.courtId});

  final String courtId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _PhotoCarousel(),
                _CourtInfo(context: context, courtId: courtId),
              ],
            ),
          ),
          _BottomCta(courtId: courtId),
        ],
      ),
    );
  }
}

class _PhotoCarousel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: double.infinity,
          height: 280,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF16A34A), Color(0xFF0EA5E9)],
            ),
          ),
          child: CustomPaint(
            painter: _CourtLinesPainter(),
            child: const Center(
              child: Text(
                '[ photo carousel · 1/5 ]',
                style: TextStyle(
                  color: Color(0xB3FFFFFF),
                  fontFamily: 'monospace',
                  fontSize: 11,
                ),
              ),
            ),
          ),
        ),
        Positioned(
          top: 56,
          left: 16,
          right: 16,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _OverlayIconBtn(
                onPressed: () => context.pop(),
                icon: Icons.arrow_back_ios_new,
              ),
              Row(
                children: [
                  _OverlayIconBtn(
                    onPressed: () {},
                    icon: Icons.favorite_border,
                  ),
                  const SizedBox(width: 8),
                  _OverlayIconBtn(
                    onPressed: () {},
                    icon: Icons.share_outlined,
                  ),
                ],
              ),
            ],
          ),
        ),
        Positioned(
          bottom: 16,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (i) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: i == 0 ? 20 : 6,
                height: 6,
                decoration: BoxDecoration(
                  color: i == 0
                      ? Colors.white
                      : Colors.white.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(99),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}

class _OverlayIconBtn extends StatelessWidget {
  const _OverlayIconBtn({required this.onPressed, required this.icon});

  final VoidCallback onPressed;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.92),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, size: 20, color: const Color(0xFF111827)),
      ),
    );
  }
}

class _CourtInfo extends StatelessWidget {
  const _CourtInfo({required this.context, required this.courtId});

  final BuildContext context;
  final String courtId;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _SportBadge(
                label: 'Pickleball',
                bg: const Color(0xFFDCFCE7),
                textColor: const Color(0xFF15803D),
              ),
              const SizedBox(width: 6),
              _SportBadge(
                label: 'Tennis',
                bg: const Color(0xFFF3F4F6),
                textColor: const Color(0xFF374151),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Pickle Hub Q1',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.star, size: 16, color: Color(0xFFEAB308)),
              const SizedBox(width: 4),
              const Text(
                '4.8',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF111827),
                ),
              ),
              const SizedBox(width: 4),
              Text(
                '·',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade300,
                ),
              ),
              const SizedBox(width: 4),
              const Text(
                '126 đánh giá',
                style: TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
              ),
              const SizedBox(width: 4),
              Text(
                '·',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade300,
                ),
              ),
              const SizedBox(width: 4),
              const Text(
                '1.2 km',
                style: TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.location_on_outlined,
                  size: 16, color: Color(0xFF6B7280)),
              const SizedBox(width: 6),
              const Expanded(
                child: Text(
                  '123 Nguyễn Du, Phường Bến Nghé, Quận 1',
                  style: TextStyle(fontSize: 14, color: Color(0xFF374151)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _StatTile(
                  label: 'Giá / giờ',
                  value: '180.000',
                  valueSuffix: ' đ',
                  valueColor: const Color(0xFF111827),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _StatTile(
                  label: 'Slot trống hôm nay',
                  value: '4 slot',
                  valueColor: const Color(0xFF22C55E),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Text(
            'Tiện ích',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: const [
              _AmenityChip(emoji: '🏠', label: 'Có mái che'),
              _AmenityChip(emoji: '💡', label: 'Đèn đêm'),
              _AmenityChip(emoji: '🎾', label: 'Thuê vợt'),
              _AmenityChip(emoji: '📶', label: 'Wifi'),
              _AmenityChip(emoji: '🥤', label: 'Đồ uống'),
              _AmenityChip(emoji: '🅿️', label: 'Bãi giữ xe'),
            ],
          ),
          const SizedBox(height: 24),
          const Text(
            'Giới thiệu',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Sân pickleball trong nhà mới khai trương, sàn nhựa chuyên dụng, lưới đạt chuẩn. Có sẵn vợt cho thuê và nước uống miễn phí. Khu vực để xe rộng rãi, gần phố đi bộ Nguyễn Huệ.',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF374151),
              height: 1.6,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Thuộc cụm sân',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: const Color(0xFFE5E7EB)),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF16A34A), Color(0xFF0EA5E9)],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Pickle Hub Sài Gòn',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF111827),
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        '3 sân pickleball · xem lịch tổng hợp',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right,
                    color: Color(0xFF6B7280)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.label,
    required this.value,
    this.valueSuffix,
    required this.valueColor,
  });

  final String label;
  final String value;
  final String? valueSuffix;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
          ),
          const SizedBox(height: 2),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: value,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: valueColor,
                  ),
                ),
                if (valueSuffix != null)
                  TextSpan(
                    text: valueSuffix,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF111827),
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

class _SportBadge extends StatelessWidget {
  const _SportBadge({
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

class _AmenityChip extends StatelessWidget {
  const _AmenityChip({required this.emoji, required this.label});

  final String emoji;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 14)),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 13, color: Color(0xFF374151)),
          ),
        ],
      ),
    );
  }
}

class _BottomCta extends StatelessWidget {
  const _BottomCta({required this.courtId});

  final String courtId;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(color: const Color(0xFFE5E7EB)),
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0F000000),
              blurRadius: 12,
              offset: Offset(0, -4),
            ),
          ],
        ),
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: const [
                Text(
                  'Từ',
                  style: TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                ),
                SizedBox(height: 2),
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: '180k',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF111827),
                        ),
                      ),
                      TextSpan(
                        text: '/giờ',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton(
                onPressed: () => context.push('/court/$courtId/slots'),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF16A34A),
                  minimumSize: const Size(double.infinity, 52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Đặt sân ngay',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CourtLinesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.35)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final double left = size.width * 0.1;
    final double right = size.width * 0.9;
    final double top = size.height * 0.2;
    final double bottom = size.height * 0.8;
    final double midX = size.width / 2;
    final double midY = (top + bottom) / 2;

    canvas.drawRect(Rect.fromLTRB(left, top, right, bottom), paint);
    canvas.drawLine(Offset(midX, top), Offset(midX, bottom), paint);
    canvas.drawCircle(Offset(midX, midY), 34, paint);
    canvas.drawRect(Rect.fromLTRB(left, top + 30, left + 50, bottom - 30), paint);
    canvas.drawRect(
        Rect.fromLTRB(right - 50, top + 30, right, bottom - 30), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
