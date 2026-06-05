import 'package:customer/features/courts/cubit/court_detail_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
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
            CourtDetailLoaded(
                    court: final court,
                    openSlotCount: final openSlotCount,
                    groupSlots: final groupSlots) =>
              _Body(court: court, openSlotCount: openSlotCount, groupSlots: groupSlots),
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
  const _Body({required this.court, required this.openSlotCount, required this.groupSlots});

  final Court court;
  final int openSlotCount;
  final List<Slot> groupSlots;

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
    // Clear the sticky _BottomCta: its height is ~88 + safe-area inset when the
    // court is full (extra "Xem lịch trống" link row), so reserve enough scroll
    // padding that the last section ("Lịch tổng hợp") isn't hidden behind it.
    final bottomInset = MediaQuery.of(context).padding.bottom;
    return Stack(
      children: [
        SingleChildScrollView(
          padding: EdgeInsets.only(bottom: 120 + bottomInset),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _PhotoCarousel(
                photos: court.photos,
                controller: _pageController,
                currentPage: _currentPage,
                onPageChanged: (i) => setState(() => _currentPage = i),
              ),
              _CourtInfoSection(court: court, openSlotCount: widget.openSlotCount, groupSlots: widget.groupSlots),
            ],
          ),
        ),
        _BottomCta(
          courtId: court.id,
          pricePerHour: court.pricePerHour,
          openSlotCount: widget.openSlotCount,
          courtName: court.name,
          courtAddress: court.address,
        ),
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
                    loadingBuilder: (_, child, progress) =>
                        progress == null ? child : _PlaceholderHero(),
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
  const _CourtInfoSection({
    required this.court,
    required this.openSlotCount,
    required this.groupSlots,
  });

  final Court court;
  final int openSlotCount;
  final List<Slot> groupSlots;

  static const _sportColors = <String, Color>{
    'pickleball': Color(0xFF15803D),
    'tennis': Color(0xFFDC2626),
    'badminton': Color(0xFF0369A1),
    'cầu lông': Color(0xFF0369A1),
    'football': Color(0xFF374151),
    'bóng đá': Color(0xFF374151),
    'bóng đá 5v5': Color(0xFF374151),
    'basketball': Color(0xFF9A3412),
    'bóng rổ': Color(0xFF9A3412),
    'volleyball': Color(0xFF6D28D9),
  };

  static const _sportBg = <String, Color>{
    'pickleball': Color(0xFFDCFCE7),
    'tennis': Color(0xFFFEE2E2),
    'badminton': Color(0xFFE0F2FE),
    'cầu lông': Color(0xFFE0F2FE),
    'football': Color(0xFFF3F4F6),
    'bóng đá': Color(0xFFF3F4F6),
    'bóng đá 5v5': Color(0xFFF3F4F6),
    'basketball': Color(0xFFFEF3C7),
    'bóng rổ': Color(0xFFFEF3C7),
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
                final key = s.toLowerCase();
                final label = s.isNotEmpty ? s[0].toUpperCase() + s.substring(1) : s;
                return _SportBadge(
                  label: label,
                  bg: _sportBg[key] ?? const Color(0xFFF3F4F6),
                  textColor: _sportColors[key] ?? const Color(0xFF374151),
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
                  icon: Icons.attach_money,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _StatTile(
                  label: 'Slot trống hôm nay',
                  value: openSlotCount.toString(),
                  valueColor: openSlotCount > 0
                      ? const Color(0xFF22C55E)
                      : const Color(0xFFEF4444),
                  icon: Icons.schedule_outlined,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Divider(height: 1, thickness: 1, color: Color(0xFFF3F4F6)),
          // Amenities
          if (court.amenities.isNotEmpty) ...[
            const SizedBox(height: 20),
            const Text(
              'Tiện ích',
              style: TextStyle(
                fontSize: 16,
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
            const SizedBox(height: 20),
            const Divider(height: 1, thickness: 1, color: Color(0xFFF3F4F6)),
          ],
          // Description
          if (court.description != null && court.description!.isNotEmpty) ...[
            const SizedBox(height: 20),
            const Text(
              'Giới thiệu',
              style: TextStyle(
                fontSize: 16,
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
            const SizedBox(height: 20),
            const Divider(height: 1, thickness: 1, color: Color(0xFFF3F4F6)),
          ],
          // Lịch tổng hợp
          const SizedBox(height: 20),
          const Text(
            'Lịch tổng hợp',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () => context.push('/court/${court.id}/schedule'),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFDCFCE7),
                border: Border.all(color: const Color(0xFF16A34A)),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFF16A34A),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.calendar_month_outlined,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Xem lịch tất cả các sân',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF15803D),
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Chọn khung giờ & đặt sân',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF15803D),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: Color(0xFF15803D)),
                ],
              ),
            ),
          ),
          // Slot mở chơi ghép
          if (groupSlots.isNotEmpty) ...[
            const SizedBox(height: 20),
            const Divider(height: 1, thickness: 1, color: Color(0xFFF3F4F6)),
            const SizedBox(height: 20),
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Slot mở chơi ghép',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF111827),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDCFCE7),
                    borderRadius: BorderRadius.circular(99),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: Color(0xFF22C55E),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${groupSlots.length} slot',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF15803D),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            const Text(
              'Tham gia cùng người chơi khác tại sân này',
              style: TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
            ),
            const SizedBox(height: 12),
            ...groupSlots.map((s) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _GroupSlotCard(slot: s),
                )),
          ],
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
    this.icon,
  });

  final String label;
  final String value;
  final String? valueSuffix;
  final Color valueColor;
  final IconData? icon;

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
          Row(
            children: [
              if (icon != null) ...[
                Icon(icon, size: 12, color: const Color(0xFF9CA3AF)),
                const SizedBox(width: 4),
              ],
              Flexible(
                child: Text(label,
                    style: const TextStyle(
                        fontSize: 12, color: Color(0xFF6B7280))),
              ),
            ],
          ),
          const SizedBox(height: 4),
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
  const _BottomCta({
    required this.courtId,
    required this.openSlotCount,
    this.pricePerHour,
    this.courtName,
    this.courtAddress,
  });

  final String courtId;
  final double? pricePerHour;
  final int openSlotCount;
  final String? courtName;
  final String? courtAddress;

  @override
  Widget build(BuildContext context) {
    final safeBottom = MediaQuery.of(context).padding.bottom;
    final priceLabel = pricePerHour != null
        ? '${(pricePerHour! / 1000).toStringAsFixed(pricePerHour! % 1000 == 0 ? 0 : 1)}k'
        : '–';

    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Container(
        padding: EdgeInsets.fromLTRB(20, 10, 20, safeBottom + 4),
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Từ',
                        style: TextStyle(
                            fontSize: 12, color: Color(0xFF6B7280))),
                    const SizedBox(height: 2),
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: priceLabel,
                            style: const TextStyle(
                              fontSize: 18,
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
                    onPressed: openSlotCount > 0
                        ? () => context.push(
                              '/court/$courtId/slots',
                              extra: <String, String?>{
                                'name': courtName,
                                'address': courtAddress,
                              },
                            )
                        : null,
                    style: FilledButton.styleFrom(
                      backgroundColor: openSlotCount > 0
                          ? const Color(0xFF16A34A)
                          : const Color(0xFFD1D5DB),
                      disabledBackgroundColor: const Color(0xFFD1D5DB),
                      minimumSize: const Size(double.infinity, 48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      openSlotCount > 0 ? 'Đặt sân ngay' : 'Hết slot hôm nay',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: openSlotCount > 0
                            ? Colors.white
                            : const Color(0xFF9CA3AF),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            if (openSlotCount == 0) ...[
              const SizedBox(height: 6),
              GestureDetector(
                onTap: () => context.push('/court/$courtId/schedule'),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.calendar_month_outlined,
                        size: 16, color: Color(0xFF0EA5E9)),
                    SizedBox(width: 4),
                    Text(
                      'Xem lịch trống những ngày tới',
                      style: TextStyle(
                        fontSize: 15,
                        color: Color(0xFF0EA5E9),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(width: 2),
                    Icon(Icons.chevron_right,
                        size: 16, color: Color(0xFF0EA5E9)),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _GroupSlotCard extends StatelessWidget {
  const _GroupSlotCard({required this.slot});

  final Slot slot;

  static const _sportColors = <String, Color>{
    'pickleball': Color(0xFF0EA5E9),
    'badminton': Color(0xFF0369A1),
    'cầu lông': Color(0xFF0369A1),
    'tennis': Color(0xFFEF4444),
    'football': Color(0xFF374151),
    'bóng đá': Color(0xFF374151),
    'bóng đá 5v5': Color(0xFF374151),
    'basketball': Color(0xFF9A3412),
    'bóng rổ': Color(0xFF9A3412),
    'volleyball': Color(0xFF6D28D9),
  };

  static IconData _sportIcon(String sportType) => switch (sportType.toLowerCase()) {
    'badminton' || 'cầu lông' => Icons.sports_tennis,
    'tennis' => Icons.sports_tennis,
    'football' || 'bóng đá' || 'bóng đá 5v5' => Icons.sports_soccer,
    'basketball' || 'bóng rổ' => Icons.sports_basketball,
    'volleyball' => Icons.sports_volleyball,
    _ => Icons.sports,
  };

  @override
  Widget build(BuildContext context) {
    final key = slot.sportType.toLowerCase();
    final color = _sportColors[key] ?? const Color(0xFF374151);
    final icon = _sportIcon(slot.sportType);
    final left = slot.maxPlayers - slot.currentPlayers;
    final timeLabel = _buildTimeLabel(slot.startTime, slot.endTime);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE5E7EB)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  slot.courtName,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  timeLabel,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF6B7280),
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.group_outlined,
                        size: 14, color: Color(0xFF6B7280)),
                    const SizedBox(width: 4),
                    Text(
                      '${slot.currentPlayers}/${slot.maxPlayers} người',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF374151),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '· còn $left',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF22C55E),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          FilledButton(
            onPressed: () {},
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF16A34A),
              minimumSize: const Size(0, 36),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
              textStyle: const TextStyle(
                  fontSize: 12, fontWeight: FontWeight.w700),
            ),
            child: const Text('Tham gia'),
          ),
        ],
      ),
    );
  }

  static String _buildTimeLabel(DateTime start, DateTime end) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final slotDay = DateTime(start.year, start.month, start.day);
    final diff = slotDay.difference(today).inDays;
    final prefix = switch (diff) {
      0 => 'Hôm nay',
      1 => 'Mai',
      _ => DateFormat('EEE', 'vi').format(start),
    };
    final fmt = DateFormat('HH:mm');
    return '$prefix · ${fmt.format(start)} – ${fmt.format(end)}';
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
