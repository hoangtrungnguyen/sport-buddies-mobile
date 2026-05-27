import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class RecurringBookingScreen extends StatelessWidget {
  const RecurringBookingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Đặt sân định kỳ'),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: BackButton(onPressed: () => context.pop()),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 110),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  _CourtChip(),
                  _SectionLabel(n: '1', title: 'Khung giờ', sub: 'Áp dụng cho mỗi buổi chơi'),
                  _TimeSlotGrid(),
                  _SectionLabel(n: '2', title: 'Lặp lại'),
                  _RepeatChips(),
                  const SizedBox(height: 12),
                  _DowSelector(),
                  const SizedBox(height: 8),
                  const Text(
                    'Mỗi thứ ba và thứ năm hàng tuần',
                    style: TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
                  ),
                  _SectionLabel(n: '3', title: 'Bắt đầu từ'),
                  _StartDateRow(),
                  _SectionLabel(n: '4', title: 'Kết thúc'),
                  _EndChips(),
                  const SizedBox(height: 12),
                  _SessionCountRow(),
                  const SizedBox(height: 8),
                  Text.rich(
                    const TextSpan(
                      children: [
                        TextSpan(
                          text: '8 buổi · kết thúc ',
                          style: TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
                        ),
                        TextSpan(
                          text: 'thứ năm, 11/06/2026',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF111827),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  _SummaryPreviewCard(),
                ],
              ),
            ),
          ),
          _BottomCta(),
        ],
      ),
    );
  }
}

class _CourtChip extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF16A34A), Color(0xFF22C55E)],
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.sports_tennis,
                size: 20, color: Colors.white),
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pickle Hub Q1 · Sân B',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF111827),
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  '180.000 đ/giờ · Pickleball',
                  style: TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.n, required this.title, this.sub});

  final String n;
  final String title;
  final String? sub;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 22,
            height: 22,
            decoration: const BoxDecoration(
              color: Color(0xFF111827),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                n,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF111827),
                ),
              ),
              if (sub != null)
                Text(
                  sub!,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF6B7280),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TimeSlotGrid extends StatelessWidget {
  static const _timeSlots = [
    _TimeSlotItem(time: '06:00 – 07:30', price: '150k', selected: false),
    _TimeSlotItem(time: '07:30 – 09:00', price: '150k', selected: false),
    _TimeSlotItem(time: '19:00 – 20:30', price: '250k', selected: true),
    _TimeSlotItem(time: '20:30 – 22:00', price: '250k', selected: false),
  ];

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      childAspectRatio: 2.6,
      children: _timeSlots.map((s) => _TimeSlotTile(item: s)).toList(),
    );
  }
}

class _TimeSlotTile extends StatelessWidget {
  const _TimeSlotTile({required this.item});

  final _TimeSlotItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color:
            item.selected ? const Color(0xFFDCFCE7) : Colors.white,
        border: Border.all(
          color: item.selected
              ? const Color(0xFF16A34A)
              : const Color(0xFFE5E7EB),
          width: item.selected ? 2.0 : 1.0,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          if (item.selected)
            Container(
              width: 18,
              height: 18,
              margin: const EdgeInsets.only(right: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF16A34A),
                borderRadius: BorderRadius.circular(5),
              ),
              child: const Icon(Icons.check, size: 12, color: Colors.white),
            ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  item.time,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: item.selected
                        ? const Color(0xFF15803D)
                        : const Color(0xFF111827),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  item.price,
                  style: const TextStyle(
                    fontSize: 11,
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

class _RepeatChips extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [
        _Chip(label: 'Hằng ngày', active: false),
        SizedBox(width: 6),
        _Chip(label: 'Hằng tuần', active: false),
        SizedBox(width: 6),
        _Chip(label: 'Chọn thứ', active: true),
      ],
    );
  }
}

class _DowSelector extends StatelessWidget {
  static const _days = [
    _DayItem(label: 'T2', active: false),
    _DayItem(label: 'T3', active: true),
    _DayItem(label: 'T4', active: false),
    _DayItem(label: 'T5', active: true),
    _DayItem(label: 'T6', active: false),
    _DayItem(label: 'T7', active: false),
    _DayItem(label: 'CN', active: false),
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: _days.map((d) {
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: d.active ? const Color(0xFF16A34A) : Colors.white,
                border: Border.all(
                  color: d.active
                      ? const Color(0xFF16A34A)
                      : const Color(0xFFE5E7EB),
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  d.label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: d.active ? Colors.white : const Color(0xFF111827),
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _StartDateRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE5E7EB)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFDCFCE7),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.calendar_today_outlined,
                size: 20, color: Color(0xFF15803D)),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Thứ ba, 14/05/2026',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF111827),
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Buổi đầu tiên · còn 2 ngày',
                  style: TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: Color(0xFF6B7280)),
        ],
      ),
    );
  }
}

class _EndChips extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [
        _Chip(label: 'Sau N buổi', active: true),
        SizedBox(width: 6),
        _Chip(label: 'Đến ngày', active: false),
        SizedBox(width: 6),
        _Chip(label: 'Không kết thúc', active: false),
      ],
    );
  }
}

class _SessionCountRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE5E7EB)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          _CountBtn(
            label: '−',
            isPrimary: false,
          ),
          const Expanded(
            child: Center(
              child: Text(
                '8',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF111827),
                ),
              ),
            ),
          ),
          _CountBtn(
            label: '+',
            isPrimary: true,
          ),
        ],
      ),
    );
  }
}

class _CountBtn extends StatelessWidget {
  const _CountBtn({required this.label, required this.isPrimary});

  final String label;
  final bool isPrimary;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: isPrimary ? const Color(0xFF16A34A) : Colors.white,
        border: Border.all(
          color: isPrimary
              ? const Color(0xFF16A34A)
              : const Color(0xFFE5E7EB),
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Center(
        child: Text(
          label,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: isPrimary ? Colors.white : const Color(0xFF374151),
          ),
        ),
      ),
    );
  }
}

class _SummaryPreviewCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFDCFCE7),
        border: Border.all(color: const Color(0xFF16A34A)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'TÓM TẮT LỊCH',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Color(0xFF15803D),
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Mỗi T3, T5 · 19:00 – 20:30',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: const [
              _PreviewStat(n: '8', label: 'buổi'),
              SizedBox(width: 16),
              _PreviewStat(n: '12', label: 'giờ'),
              SizedBox(width: 16),
              _PreviewStat(n: '2.000.000 đ', label: ''),
            ],
          ),
        ],
      ),
    );
  }
}

class _PreviewStat extends StatelessWidget {
  const _PreviewStat({required this.n, required this.label});

  final String n;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: n,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              color: Color(0xFF374151),
              fontSize: 13,
            ),
          ),
          if (label.isNotEmpty)
            TextSpan(
              text: ' $label',
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF374151),
              ),
            ),
        ],
      ),
    );
  }
}

class _BottomCta extends StatelessWidget {
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
        ),
        child: FilledButton(
          onPressed: () {},
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFF16A34A),
            minimumSize: const Size(double.infinity, 52),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text(
            'Xem trước 8 buổi',
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

class _Chip extends StatelessWidget {
  const _Chip({required this.label, required this.active});

  final String label;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: active ? const Color(0xFF111827) : Colors.white,
        border: Border.all(
          color: active ? const Color(0xFF111827) : const Color(0xFFE5E7EB),
        ),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: active ? Colors.white : const Color(0xFF374151),
        ),
      ),
    );
  }
}

class _TimeSlotItem {
  const _TimeSlotItem({
    required this.time,
    required this.price,
    required this.selected,
  });

  final String time;
  final String price;
  final bool selected;
}

class _DayItem {
  const _DayItem({required this.label, required this.active});

  final String label;
  final bool active;
}
