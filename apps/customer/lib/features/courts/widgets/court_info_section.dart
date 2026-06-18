// The scrollable court information section: title, stats, sport badges,
// amenities and the open group-slot cards. Extracted from
// court_detail_screen.dart.

import 'package:customer/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:spb_core/spb_core.dart';

class CourtInfoSection extends StatelessWidget {
  const CourtInfoSection({
    super.key,
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
    final l10n = AppLocalizations.of(context);
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
                final label = s.isNotEmpty
                    ? s[0].toUpperCase() + s.substring(1)
                    : s;
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
                const Icon(
                  Icons.location_on_outlined,
                  size: 16,
                  color: Color(0xFF6B7280),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    court.address!,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF374151),
                    ),
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
                  label: l10n.courtDetailPricePerHour,
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
                  label: l10n.courtDetailOpenToday,
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
            Text(
              l10n.courtDetailAmenities,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Color(0xFF111827),
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: court.amenities
                  .map((a) => _AmenityChip(label: a))
                  .toList(),
            ),
            const SizedBox(height: 20),
            const Divider(height: 1, thickness: 1, color: Color(0xFFF3F4F6)),
          ],
          // Description
          if (court.description != null && court.description!.isNotEmpty) ...[
            const SizedBox(height: 20),
            Text(
              l10n.courtDetailAbout,
              style: const TextStyle(
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
          Text(
            l10n.courtDetailScheduleTitle,
            style: const TextStyle(
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
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.courtDetailViewAllCourts,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF15803D),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          l10n.courtDetailScheduleSubtitle,
                          style: const TextStyle(
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
                Expanded(
                  child: Text(
                    l10n.courtsOpenMatchSlots,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF111827),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
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
                        l10n.courtDetailSlotCount(groupSlots.length),
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
            Text(
              l10n.courtDetailOpenSlotsHelper,
              style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
            ),
            const SizedBox(height: 12),
            ...groupSlots.map(
              (s) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _GroupSlotCard(slot: s),
              ),
            ),
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
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF6B7280),
                  ),
                ),
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
          Text(
            label,
            style: const TextStyle(fontSize: 13, color: Color(0xFF374151)),
          ),
        ],
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

  static IconData _sportIcon(String sportType) =>
      switch (sportType.toLowerCase()) {
        'badminton' || 'cầu lông' => Icons.sports_tennis,
        'tennis' => Icons.sports_tennis,
        'football' || 'bóng đá' || 'bóng đá 5v5' => Icons.sports_soccer,
        'basketball' || 'bóng rổ' => Icons.sports_basketball,
        'volleyball' => Icons.sports_volleyball,
        _ => Icons.sports,
      };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final key = slot.sportType.toLowerCase();
    final color = _sportColors[key] ?? const Color(0xFF374151);
    final icon = _sportIcon(slot.sportType);
    final left = slot.maxPlayers - slot.currentPlayers;
    final timeLabel = _buildTimeLabel(l10n, slot.startTime, slot.endTime);

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
                    const Icon(
                      Icons.group_outlined,
                      size: 14,
                      color: Color(0xFF6B7280),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      l10n.slotsJoinedCount(
                        slot.currentPlayers,
                        slot.maxPlayers,
                      ),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF374151),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      l10n.courtsSlotsLeft(left),
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
                borderRadius: BorderRadius.circular(8),
              ),
              textStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
            child: Text(l10n.courtsJoin),
          ),
        ],
      ),
    );
  }

  static String _buildTimeLabel(
    AppLocalizations l10n,
    DateTime start,
    DateTime end,
  ) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final slotDay = DateTime(start.year, start.month, start.day);
    final diff = slotDay.difference(today).inDays;
    final prefix = switch (diff) {
      0 => l10n.scheduleToday,
      1 => l10n.courtsTomorrow,
      _ => DateFormat('EEE', 'vi').format(start),
    };
    final fmt = DateFormat('HH:mm');
    return '$prefix · ${fmt.format(start)} – ${fmt.format(end)}';
  }
}
