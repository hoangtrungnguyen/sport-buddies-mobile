import 'package:customer/features/courts/cubit/court_detail_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:spb_core/spb_core.dart';

class CourtDetailScreen extends StatefulWidget {
  const CourtDetailScreen({super.key, required this.courtId});

  final String courtId;

  @override
  State<CourtDetailScreen> createState() => _CourtDetailScreenState();
}

class _CourtDetailScreenState extends State<CourtDetailScreen> {
  @override
  void initState() {
    super.initState();
    context.read<CourtDetailCubit>().loadCourt(widget.courtId);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CourtDetailCubit, CourtDetailState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Colors.white,
          body: switch (state) {
            CourtDetailLoading() || CourtDetailInitial() => const Center(
                child: CircularProgressIndicator(),
              ),
            CourtDetailError(message: final msg) => _ErrorBody(
                message: msg,
                courtId: widget.courtId,
              ),
            CourtDetailLoaded(court: final court) => _Body(court: court),
          },
        );
      },
    );
  }
}

class _ErrorBody extends StatelessWidget {
  const _ErrorBody({required this.message, required this.courtId});

  final String message;
  final String courtId;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(message,
              style: const TextStyle(color: Color(0xFF6B7280))),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: () =>
                context.read<CourtDetailCubit>().loadCourt(courtId),
            child: const Text('Thử lại'),
          ),
        ],
      ),
    );
  }
}

class _Body extends StatefulWidget {
  const _Body({required this.court});

  final Court court;

  @override
  State<_Body> createState() => _BodyState();
}

class _BodyState extends State<_Body> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final court = widget.court;
    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _PhotoCarousel(
                photos: court.photos,
                controller: _pageController,
                currentPage: _currentPage,
                onPageChanged: (i) => setState(() => _currentPage = i),
              ),
              _CourtInfoSection(court: court),
            ],
          ),
        ),
        _BottomCta(courtId: court.id, pricePerHour: court.pricePerHour),
      ],
    );
  }
}

class _PhotoCarousel extends StatelessWidget {
  const _PhotoCarousel({
    required this.photos,
    required this.controller,
    required this.currentPage,
    required this.onPageChanged,
  });

  final List<String> photos;
  final PageController controller;
  final int currentPage;
  final ValueChanged<int> onPageChanged;

  @override
  Widget build(BuildContext context) {
    final count = photos.isEmpty ? 1 : photos.length;
    return Stack(
      children: [
        SizedBox(
          width: double.infinity,
          height: 280,
          child: photos.isEmpty
              ? _PlaceholderHero()
              : PageView.builder(
                  controller: controller,
                  onPageChanged: onPageChanged,
                  itemCount: photos.length,
                  itemBuilder: (_, i) => Image.network(
                    photos[i],
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _PlaceholderHero(),
                  ),
                ),
        ),
        // Back + action buttons
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
                  _OverlayIconBtn(onPressed: () {}, icon: Icons.favorite_border),
                  const SizedBox(width: 8),
                  _OverlayIconBtn(onPressed: () {}, icon: Icons.share_outlined),
                ],
              ),
            ],
          ),
        ),
        // Page indicator dots
        Positioned(
          bottom: 16,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(count, (i) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: i == currentPage ? 20 : 6,
                height: 6,
                decoration: BoxDecoration(
                  color: i == currentPage
                      ? Colors.white
                      : Colors.white.withValues(alpha: 0.6),
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

class _PlaceholderHero extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF16A34A), Color(0xFF0EA5E9)],
        ),
      ),
      child: CustomPaint(
        painter: _CourtLinesPainter(),
      ),
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
          color: Colors.white.withValues(alpha: 0.92),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, size: 20, color: const Color(0xFF111827)),
      ),
    );
  }
}

class _CourtInfoSection extends StatelessWidget {
  const _CourtInfoSection({required this.court});

  final Court court;

  static const _sportColors = <String, Color>{
    'pickleball': Color(0xFF15803D),
    'tennis': Color(0xFF374151),
    'badminton': Color(0xFF0369A1),
    'football': Color(0xFF374151),
    'basketball': Color(0xFF9A3412),
    'volleyball': Color(0xFF6D28D9),
  };

  static const _sportBg = <String, Color>{
    'pickleball': Color(0xFFDCFCE7),
    'tennis': Color(0xFFF3F4F6),
    'badminton': Color(0xFFE0F2FE),
    'football': Color(0xFFF3F4F6),
    'basketball': Color(0xFFFEF3C7),
    'volleyball': Color(0xFFEDE9FE),
  };

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Sport type badges
          if (court.sportTypes.isNotEmpty)
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: court.sportTypes.map((s) {
                final label = s[0].toUpperCase() + s.substring(1);
                return _SportBadge(
                  label: label,
                  bg: _sportBg[s] ?? const Color(0xFFF3F4F6),
                  textColor: _sportColors[s] ?? const Color(0xFF374151),
                );
              }).toList(),
            ),
          const SizedBox(height: 8),
          // Court name
          Text(
            court.name,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Color(0xFF111827),
            ),
          ),
          // Address
          if (court.address != null) ...[
            const SizedBox(height: 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.location_on_outlined,
                    size: 16, color: Color(0xFF6B7280)),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    court.address!,
                    style: const TextStyle(
                        fontSize: 14, color: Color(0xFF374151)),
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 16),
          // Price + slot count tiles
          Row(
            children: [
              Expanded(
                child: _StatTile(
                  label: 'Giá / giờ',
                  value: court.pricePerHour != null
                      ? _formatPrice(court.pricePerHour!)
                      : '–',
                  valueSuffix: court.pricePerHour != null ? ' đ' : null,
                  valueColor: const Color(0xFF111827),
                ),
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: _StatTile(
                  label: 'Slot trống hôm nay',
                  value: '–',
                  valueColor: Color(0xFF22C55E),
                ),
              ),
            ],
          ),
          // Amenities
          if (court.amenities.isNotEmpty) ...[
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
              children:
                  court.amenities.map((a) => _AmenityChip(label: a)).toList(),
            ),
          ],
          // Description
          if (court.description != null && court.description!.isNotEmpty) ...[
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
            Text(
              court.description!,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF374151),
                height: 1.6,
              ),
            ),
          ],
          // Schedule overview link
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
          GestureDetector(
            onTap: () => context.push('/court/${court.id}/schedule'),
            child: Container(
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
                          'Xem lịch tổng hợp',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF111827),
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'So sánh khung giờ trống toàn bộ sân',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: Color(0xFF6B7280)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  static String _formatPrice(double price) {
    if (price >= 1000) {
      return '${(price / 1000).toStringAsFixed(price % 1000 == 0 ? 0 : 1)}k';
    }
    return price.toStringAsFixed(0);
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
          Text(label,
              style:
                  const TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
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
  const _AmenityChip({required this.label});

  final String label;

  static const _emojiMap = <String, String>{
    'Có mái che': '🏠',
    'Đèn đêm': '💡',
    'Thuê vợt': '🎾',
    'Wifi': '📶',
    'Đồ uống': '🥤',
    'Bãi giữ xe': '🅿️',
    'Phòng thay đồ': '🚿',
    'Máy lạnh': '❄️',
  };

  @override
  Widget build(BuildContext context) {
    final emoji = _emojiMap[label];
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
          if (emoji != null) ...[
            Text(emoji, style: const TextStyle(fontSize: 14)),
            const SizedBox(width: 4),
          ],
          Text(label,
              style: const TextStyle(
                  fontSize: 13, color: Color(0xFF374151))),
        ],
      ),
    );
  }
}

class _BottomCta extends StatelessWidget {
  const _BottomCta({required this.courtId, this.pricePerHour});

  final String courtId;
  final double? pricePerHour;

  @override
  Widget build(BuildContext context) {
    final priceLabel = pricePerHour != null
        ? '${(pricePerHour! / 1000).toStringAsFixed(pricePerHour! % 1000 == 0 ? 0 : 1)}k'
        : '–';

    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Color(0xFFE5E7EB))),
          boxShadow: [
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
              children: [
                const Text('Từ',
                    style:
                        TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
                const SizedBox(height: 2),
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: priceLabel,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF111827),
                        ),
                      ),
                      if (pricePerHour != null)
                        const TextSpan(
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
      ..color = Colors.white.withValues(alpha: 0.35)
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
    canvas.drawRect(
        Rect.fromLTRB(left, top + 30, left + 50, bottom - 30), paint);
    canvas.drawRect(
        Rect.fromLTRB(right - 50, top + 30, right, bottom - 30), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
