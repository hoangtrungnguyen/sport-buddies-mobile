import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SlotPickerScreen extends StatelessWidget {
  const SlotPickerScreen({super.key, required this.courtId});

  final String courtId;

  static const _dates = [
    _DateTab(day: 'T2', num: '5', isActive: true),
    _DateTab(day: 'T3', num: '6', label: 'hôm nay'),
    _DateTab(day: 'T4', num: '7'),
    _DateTab(day: 'T5', num: '8'),
    _DateTab(day: 'T6', num: '9'),
    _DateTab(day: 'T7', num: '10'),
    _DateTab(day: 'CN', num: '11'),
  ];

  static const _slots = [
    _SlotData(time: '06:00', dur: '07:00', price: '300K', status: 'open'),
    _SlotData(time: '07:00', dur: '08:00', price: '300K', status: 'booked'),
    _SlotData(time: '08:00', dur: '09:00', price: '300K', status: 'open'),
    _SlotData(time: '09:00', dur: '10:00', price: '300K', status: 'blocked'),
    _SlotData(time: '10:00', dur: '11:00', price: '300K', status: 'open'),
    _SlotData(time: '16:00', dur: '17:00', price: '350K', status: 'open'),
    _SlotData(time: '17:00', dur: '18:00', price: '350K', status: 'booked'),
    _SlotData(
        time: '18:00',
        dur: '19:00',
        price: '450K',
        status: 'open',
        selected: true),
    _SlotData(time: '19:00', dur: '20:00', price: '450K', status: 'booked'),
    _SlotData(time: '20:00', dur: '21:00', price: '450K', status: 'open'),
    _SlotData(time: '21:00', dur: '22:00', price: '350K', status: 'open'),
    _SlotData(time: '22:00', dur: '23:00', price: '300K', status: 'open'),
  ];

  @override
  Widget build(BuildContext context) {
    final morningSlots = _slots.sublist(0, 5);
    final eveningSlots = _slots.sublist(5);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Chọn khung giờ'),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: BackButton(
          onPressed: () => context.pop(),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 96),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _CourtSummaryHeader(),
                _DateTabRow(dates: _dates),
                const _SectionDivider(label: 'SÁNG'),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: _SlotGrid(slots: morningSlots),
                ),
                const _SectionDivider(label: 'CHIỀU – TỐI'),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: _SlotGrid(slots: eveningSlots),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
          _BottomCta(courtId: courtId),
        ],
      ),
    );
  }
}

class _CourtSummaryHeader extends StatelessWidget {
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
              color: const Color(0xFF0EA5E9).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.sports_tennis,
                size: 20, color: Color(0xFF0EA5E9)),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'Sân Bóng Tao Đàn',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF111827),
                ),
              ),
              SizedBox(height: 2),
              Text(
                '55 Trương Định · 0.8 km',
                style: TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DateTabRow extends StatelessWidget {
  const _DateTabRow({required this.dates});

  final List<_DateTab> dates;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 72,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        itemCount: dates.length,
        separatorBuilder: (_, __) => const SizedBox(width: 6),
        itemBuilder: (_, i) {
          final d = dates[i];
          return _DateTabItem(tab: d);
        },
      ),
    );
  }
}

class _DateTabItem extends StatelessWidget {
  const _DateTabItem({required this.tab});

  final _DateTab tab;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 54,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
      decoration: BoxDecoration(
        color: tab.isActive ? const Color(0xFF111827) : Colors.white,
        border: Border.all(
          color: tab.isActive
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
              color: tab.isActive
                  ? Colors.white.withOpacity(0.7)
                  : const Color(0xFF374151),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            tab.num,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: tab.isActive ? Colors.white : const Color(0xFF111827),
            ),
          ),
          if (tab.label != null)
            Text(
              tab.label!,
              style: TextStyle(
                fontSize: 9,
                color: tab.isActive
                    ? Colors.white.withOpacity(0.7)
                    : const Color(0xFF6B7280),
              ),
            ),
        ],
      ),
    );
  }
}

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
          const Expanded(
            child: Divider(color: Color(0xFFE5E7EB), height: 1),
          ),
        ],
      ),
    );
  }
}

class _SlotGrid extends StatelessWidget {
  const _SlotGrid({required this.slots});

  final List<_SlotData> slots;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      childAspectRatio: 2.0,
      children: slots.map((s) => _SlotTile(slot: s)).toList(),
    );
  }
}

class _SlotTile extends StatelessWidget {
  const _SlotTile({required this.slot});

  final _SlotData slot;

  @override
  Widget build(BuildContext context) {
    final isBooked = slot.status == 'booked';
    final isBlocked = slot.status == 'blocked';
    final isDisabled = isBooked || isBlocked;
    final isSelected = slot.selected;

    Color bgColor;
    Color borderColor;
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

    return Opacity(
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
                    ? const Color(0xFF15803D).withOpacity(0.7)
                    : const Color(0xFF6B7280),
              ),
            ),
          ],
        ),
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
              children: const [
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

class _DateTab {
  const _DateTab({required this.day, required this.num, this.label, this.isActive = false});

  final String day;
  final String num;
  final String? label;
  final bool isActive;
}

class _SlotData {
  const _SlotData({
    required this.time,
    required this.dur,
    required this.price,
    required this.status,
    this.selected = false,
  });

  final String time;
  final String dur;
  final String price;
  final String status;
  final bool selected;
}
