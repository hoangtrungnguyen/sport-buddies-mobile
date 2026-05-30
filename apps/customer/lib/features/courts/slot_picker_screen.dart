import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SlotPickerScreen extends StatefulWidget {
  const SlotPickerScreen({
    super.key,
    required this.courtId,
    this.courtName,
    this.courtAddress,
  });

  final String courtId;
  final String? courtName;
  final String? courtAddress;

  @override
  State<SlotPickerScreen> createState() => _SlotPickerScreenState();
}

class _SlotPickerScreenState extends State<SlotPickerScreen> {
  int? _selectedIndex = 7; // 18:00 pre-selected to match original mock
  // 0 = yesterday, 1 = today (default), …, 14 = today+13
  int _selectedDateIndex = 1;

  static List<_DateTab> _buildDates() {
    final today = DateTime.now();
    final yesterday = today.subtract(const Duration(days: 1));
    return List.generate(15, (i) {
      final date = yesterday.add(Duration(days: i));
      final isToday = date.day == today.day &&
          date.month == today.month &&
          date.year == today.year;
      return _DateTab(
        day: _weekdayLabel(date.weekday),
        num: date.day.toString(),
        label: isToday ? 'hôm nay' : null,
      );
    });
  }

  static String _weekdayLabel(int weekday) => switch (weekday) {
        1 => 'T2',
        2 => 'T3',
        3 => 'T4',
        4 => 'T5',
        5 => 'T6',
        6 => 'T7',
        _ => 'CN',
      };

  static const _slots = [
    _SlotData(time: '06:00', dur: '07:00', price: '300K', status: 'open'),
    _SlotData(time: '07:00', dur: '08:00', price: '300K', status: 'booked'),
    _SlotData(time: '08:00', dur: '09:00', price: '300K', status: 'open'),
    _SlotData(time: '09:00', dur: '10:00', price: '300K', status: 'blocked'),
    _SlotData(time: '10:00', dur: '11:00', price: '300K', status: 'open'),
    _SlotData(time: '16:00', dur: '17:00', price: '350K', status: 'open'),
    _SlotData(time: '17:00', dur: '18:00', price: '350K', status: 'booked'),
    _SlotData(time: '18:00', dur: '19:00', price: '450K', status: 'open'),
    _SlotData(time: '19:00', dur: '20:00', price: '450K', status: 'booked'),
    _SlotData(time: '20:00', dur: '21:00', price: '450K', status: 'open'),
    _SlotData(time: '21:00', dur: '22:00', price: '350K', status: 'open'),
    _SlotData(time: '22:00', dur: '23:00', price: '300K', status: 'open'),
  ];

  void _onSelect(int index) => setState(() => _selectedIndex = index);
  void _onDateSelect(int index) => setState(() => _selectedDateIndex = index);

  @override
  Widget build(BuildContext context) {
    const morningCount = 5;
    final morningSlots = _slots.sublist(0, morningCount);
    final eveningSlots = _slots.sublist(morningCount);
    final dates = _buildDates();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Chọn khung giờ'),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: BackButton(onPressed: () => context.pop()),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 96),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _CourtSummaryHeader(
                  courtName: widget.courtName,
                  courtAddress: widget.courtAddress,
                ),
                _DateTabRow(
                  dates: dates,
                  selectedIndex: _selectedDateIndex,
                  onTap: _onDateSelect,
                ),
                const _SectionDivider(label: 'SÁNG'),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: _SlotGrid(
                    slots: morningSlots,
                    indexOffset: 0,
                    selectedIndex: _selectedIndex,
                    onSelect: _onSelect,
                  ),
                ),
                const _SectionDivider(label: 'CHIỀU – TỐI'),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: _SlotGrid(
                    slots: eveningSlots,
                    indexOffset: morningCount,
                    selectedIndex: _selectedIndex,
                    onSelect: _onSelect,
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
          _BottomCta(courtId: widget.courtId),
        ],
      ),
    );
  }
}

// ── Header ────────────────────────────────────────────────────────────────────

class _CourtSummaryHeader extends StatelessWidget {
  const _CourtSummaryHeader({this.courtName, this.courtAddress});

  final String? courtName;
  final String? courtAddress;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFF0EA5E9).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.sports_soccer,
                size: 20, color: Color(0xFF0EA5E9)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  courtName ?? 'Sân thể thao',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF111827),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                if (courtAddress != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    courtAddress!,
                    style: const TextStyle(
                        fontSize: 12, color: Color(0xFF6B7280)),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Date tabs ─────────────────────────────────────────────────────────────────

class _DateTabRow extends StatelessWidget {
  const _DateTabRow({
    required this.dates,
    required this.selectedIndex,
    required this.onTap,
  });

  final List<_DateTab> dates;
  final int selectedIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 84,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        itemCount: dates.length,
        separatorBuilder: (_, __) => const SizedBox(width: 6),
        itemBuilder: (_, i) => _DateTabItem(
          tab: dates[i],
          isSelected: i == selectedIndex,
          onTap: () => onTap(i),
        ),
      ),
    );
  }
}

class _DateTabItem extends StatelessWidget {
  const _DateTabItem({
    required this.tab,
    required this.isSelected,
    required this.onTap,
  });

  final _DateTab tab;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 54,
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF111827) : Colors.white,
          border: Border.all(
            color: isSelected
                ? const Color(0xFF111827)
                : const Color(0xFFE5E7EB),
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              tab.day,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: isSelected
                    ? Colors.white.withValues(alpha: 0.7)
                    : const Color(0xFF374151),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              tab.num,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: isSelected ? Colors.white : const Color(0xFF111827),
              ),
            ),
            if (tab.label != null)
              Text(
                tab.label!,
                style: TextStyle(
                  fontSize: 9,
                  color: isSelected
                      ? Colors.white.withValues(alpha: 0.7)
                      : const Color(0xFF6B7280),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ── Section divider ───────────────────────────────────────────────────────────

class _SectionDivider extends StatelessWidget {
  const _SectionDivider({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: Color(0xFF6B7280),
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(width: 8),
          const Expanded(child: Divider(color: Color(0xFFE5E7EB), height: 1)),
        ],
      ),
    );
  }
}

// ── Slot grid + tile ──────────────────────────────────────────────────────────

class _SlotGrid extends StatelessWidget {
  const _SlotGrid({
    required this.slots,
    required this.indexOffset,
    required this.selectedIndex,
    required this.onSelect,
  });

  final List<_SlotData> slots;
  final int indexOffset;
  final int? selectedIndex;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      childAspectRatio: 2.0,
      children: [
        for (var i = 0; i < slots.length; i++)
          _SlotTile(
            slot: slots[i],
            isSelected: selectedIndex == indexOffset + i,
            onTap: () => onSelect(indexOffset + i),
          ),
      ],
    );
  }
}

class _SlotTile extends StatelessWidget {
  const _SlotTile({
    required this.slot,
    required this.isSelected,
    required this.onTap,
  });

  final _SlotData slot;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isBooked = slot.status == 'booked';
    final isBlocked = slot.status == 'blocked';
    final isDisabled = isBooked || isBlocked;

    final Color bgColor;
    final Color borderColor;
    if (isSelected) {
      bgColor = const Color(0xFFDCFCE7);
      borderColor = const Color(0xFF16A34A);
    } else if (isDisabled) {
      bgColor = const Color(0xFFF9FAFB);
      borderColor = const Color(0xFFE5E7EB);
    } else {
      bgColor = Colors.white;
      borderColor = const Color(0xFFE5E7EB);
    }

    return GestureDetector(
      onTap: isDisabled ? null : onTap,
      child: Opacity(
        opacity: isDisabled ? 0.6 : 1.0,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          decoration: BoxDecoration(
            color: bgColor,
            border: Border.all(
              color: borderColor,
              width: isSelected ? 2.0 : 1.0,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                children: [
                  if (isSelected)
                    Container(
                      width: 18,
                      height: 18,
                      margin: const EdgeInsets.only(right: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF16A34A),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Icon(Icons.check,
                          size: 12, color: Colors.white),
                    ),
                  Expanded(
                    child: Text(
                      '${slot.time} – ${slot.dur}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isSelected
                            ? const Color(0xFF15803D)
                            : const Color(0xFF111827),
                        decoration:
                            isBooked ? TextDecoration.lineThrough : null,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                isBlocked
                    ? 'Đã đóng'
                    : isBooked
                        ? 'Đã đặt'
                        : '${slot.price}đ',
                style: TextStyle(
                  fontSize: 11,
                  color: isSelected
                      ? const Color(0xFF15803D).withValues(alpha:0.7)
                      : const Color(0xFF6B7280),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Bottom CTA ────────────────────────────────────────────────────────────────

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
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '2 khung · 3 giờ',
                  style: TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                ),
                SizedBox(height: 2),
                Text(
                  '610.000 đ',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF111827),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton(
                onPressed: () => context.push(
                  '/booking',
                  extra: '0ec04944-a7d5-40f9-868c-43b703bd77c0',
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF16A34A),
                  minimumSize: const Size(double.infinity, 52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Tiếp tục',
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

// ── Data classes ──────────────────────────────────────────────────────────────

class _DateTab {
  const _DateTab({
    required this.day,
    required this.num,
    this.label,
  });

  final String day;
  final String num;
  final String? label;
}

class _SlotData {
  const _SlotData({
    required this.time,
    required this.dur,
    required this.price,
    required this.status,
  });

  final String time;
  final String dur;
  final String price;
  final String status;
}
