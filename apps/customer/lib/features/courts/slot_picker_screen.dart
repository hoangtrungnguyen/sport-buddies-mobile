import 'package:customer/features/courts/cubit/slot_picker_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:spb_core/spb_core.dart';

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
  int _selectedDateIndex = 0;

  /// Selected slot ID (single selection for booking).
  String? _selectedSlotId;

  @override
  void initState() {
    super.initState();
    context.read<SlotPickerCubit>().load(widget.courtId);
  }

  void _onDateSelect(int i) => setState(() {
        _selectedDateIndex = i;
        _selectedSlotId = null;
      });

  void _toggle(String slotId) => setState(() {
        _selectedSlotId = _selectedSlotId == slotId ? null : slotId;
      });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: const Text(
          'Chọn giờ',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF111827),
        elevation: 0,
        leading: BackButton(onPressed: () => context.pop()),
      ),
      body: BlocBuilder<SlotPickerCubit, SlotPickerState>(
        builder: (context, state) => switch (state) {
          SlotPickerLoading() => const Center(child: CircularProgressIndicator()),
          SlotPickerError(:final message) => _ErrorView(
              message: message,
              onRetry: () => context.read<SlotPickerCubit>().load(widget.courtId),
            ),
          SlotPickerLoaded(:final slots, :final pricePerHour) =>
            _LoadedBody(
              courtId: widget.courtId,
              courtName: widget.courtName,
              courtAddress: widget.courtAddress,
              slots: slots,
              pricePerHour: pricePerHour,
              selectedDateIndex: _selectedDateIndex,
              selectedSlotId: _selectedSlotId,
              onDateSelect: _onDateSelect,
              onToggle: _toggle,
            ),
        },
      ),
    );
  }
}

// ── Loaded body ───────────────────────────────────────────────────────────────

class _LoadedBody extends StatelessWidget {
  const _LoadedBody({
    required this.courtId,
    required this.courtName,
    required this.courtAddress,
    required this.slots,
    required this.pricePerHour,
    required this.selectedDateIndex,
    required this.selectedSlotId,
    required this.onDateSelect,
    required this.onToggle,
  });

  final String courtId;
  final String? courtName;
  final String? courtAddress;
  final List<Slot> slots;
  final double? pricePerHour;
  final int selectedDateIndex;
  final String? selectedSlotId;
  final ValueChanged<int> onDateSelect;
  final ValueChanged<String> onToggle;

  List<DateTime> _buildDates() {
    final today = DateTime.now();
    return List.generate(
      7,
      (i) => DateTime(today.year, today.month, today.day + i),
    );
  }

  List<Slot> _slotsForDate(DateTime date) {
    return slots.where((s) {
      final local = s.startTime.toLocal();
      return local.year == date.year &&
          local.month == date.month &&
          local.day == date.day;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final dates = _buildDates();
    final selectedDate = dates[selectedDateIndex];
    final daySlots = _slotsForDate(selectedDate);
    final selected =
        selectedSlotId != null ? slots.where((s) => s.id == selectedSlotId).firstOrNull : null;

    final durationMinutes = selected != null
        ? selected.endTime.difference(selected.startTime).inMinutes
        : 0;
    final totalPrice = selected != null && pricePerHour != null
        ? pricePerHour! * durationMinutes / 60
        : 0.0;

    return Stack(
      children: [
        SingleChildScrollView(
          padding: EdgeInsets.only(
            bottom: 96 + MediaQuery.of(context).padding.bottom,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _CourtContextLine(
                courtName: courtName,
                courtAddress: courtAddress,
              ),
              _DateTabRow(
                dates: dates,
                selectedIndex: selectedDateIndex,
                onTap: onDateSelect,
              ),
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      'Khung giờ',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF111827),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      'Chạm để chọn',
                      style: TextStyle(
                        fontSize: 12,
                        color: const Color(0xFF6B7280).withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 2, 16, 10),
                child: Text(
                  '${daySlots.length} slot trống',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ),
              if (daySlots.isEmpty)
                const _EmptySlots()
              else
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: _SlotGrid(
                    slots: daySlots,
                    pricePerHour: pricePerHour,
                    selectedSlotId: selectedSlotId,
                    onTap: onToggle,
                  ),
                ),
            ],
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: _BottomCta(
            selected: selected,
            totalPrice: totalPrice,
            durationMinutes: durationMinutes,
            onContinue: selected != null
                ? () => context.push('/booking', extra: selected.id)
                : null,
          ),
        ),
      ],
    );
  }
}

// ── Error view ────────────────────────────────────────────────────────────────

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Color(0xFF9CA3AF)),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFF6B7280)),
            ),
            const SizedBox(height: 16),
            TextButton(onPressed: onRetry, child: const Text('Thử lại')),
          ],
        ),
      ),
    );
  }
}

// ── Empty slots ───────────────────────────────────────────────────────────────

class _EmptySlots extends StatelessWidget {
  const _EmptySlots();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 48, horizontal: 24),
      child: Center(
        child: Text(
          'Không có khung giờ trống trong ngày này.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
        ),
      ),
    );
  }
}

// ── Court context line ────────────────────────────────────────────────────────

class _CourtContextLine extends StatelessWidget {
  const _CourtContextLine({this.courtName, this.courtAddress});

  final String? courtName;
  final String? courtAddress;

  @override
  Widget build(BuildContext context) {
    final parts = <String>[
      if (courtAddress != null && courtAddress!.isNotEmpty) courtAddress!,
      if (courtName != null && courtName!.isNotEmpty) courtName!,
    ];
    final label = parts.isEmpty ? 'Sân thể thao' : parts.join(' · ');
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      child: Text(
        label,
        style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
        overflow: TextOverflow.ellipsis,
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

  final List<DateTime> dates;
  final int selectedIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      child: SizedBox(
        height: 76,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: dates.length,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (_, i) => _DateTabItem(
            date: dates[i],
            isActive: i == selectedIndex,
            isToday: i == 0,
            isTomorrow: i == 1,
            onTap: () => onTap(i),
          ),
        ),
      ),
    );
  }
}

class _DateTabItem extends StatelessWidget {
  const _DateTabItem({
    required this.date,
    required this.isActive,
    required this.isToday,
    required this.isTomorrow,
    required this.onTap,
  });

  final DateTime date;
  final bool isActive;
  final bool isToday;
  final bool isTomorrow;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final topLabel = isToday
        ? 'Hôm nay'
        : isTomorrow
            ? 'Mai'
            : _weekdayShort(date.weekday);
    final dayNum = date.day.toString();
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 76,
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF16A34A) : Colors.white,
          border: Border.all(
            color: isActive ? const Color(0xFF16A34A) : const Color(0xFFE5E7EB),
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              topLabel,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: isActive ? Colors.white : const Color(0xFF6B7280),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              dayNum,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: isActive ? Colors.white : const Color(0xFF111827),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _weekdayShort(int w) => switch (w) {
        1 => 'T2',
        2 => 'T3',
        3 => 'T4',
        4 => 'T5',
        5 => 'T6',
        6 => 'T7',
        _ => 'CN',
      };
}

// ── Slot grid + tile ──────────────────────────────────────────────────────────

class _SlotGrid extends StatelessWidget {
  const _SlotGrid({
    required this.slots,
    required this.pricePerHour,
    required this.selectedSlotId,
    required this.onTap,
  });

  final List<Slot> slots;
  final double? pricePerHour;
  final String? selectedSlotId;
  final ValueChanged<String> onTap;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 2.2,
      children: [
        for (final slot in slots)
          _SlotTile(
            slot: slot,
            pricePerHour: pricePerHour,
            isSelected: slot.id == selectedSlotId,
            onTap: () => onTap(slot.id),
          ),
      ],
    );
  }
}

class _SlotTile extends StatelessWidget {
  const _SlotTile({
    required this.slot,
    required this.pricePerHour,
    required this.isSelected,
    required this.onTap,
  });

  final Slot slot;
  final double? pricePerHour;
  final bool isSelected;
  final VoidCallback onTap;

  static final _timeFmt = DateFormat('HH:mm');

  @override
  Widget build(BuildContext context) {
    final timeLabel =
        '${_timeFmt.format(slot.startTime.toLocal())} – ${_timeFmt.format(slot.endTime.toLocal())}';
    final durationMinutes =
        slot.endTime.difference(slot.startTime).inMinutes;
    final price = pricePerHour != null
        ? (pricePerHour! * durationMinutes / 60).round()
        : null;
    final priceLabel = price != null ? '${(price / 1000).round()}k' : '—';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFDCFCE7) : Colors.white,
          border: Border.all(
            color: isSelected ? const Color(0xFF16A34A) : const Color(0xFFE5E7EB),
            width: isSelected ? 1.5 : 1.0,
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
                  const Padding(
                    padding: EdgeInsets.only(right: 6),
                    child: _SelectedBadge(),
                  ),
                Expanded(
                  child: Text(
                    timeLabel,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF111827),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              priceLabel,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: Color(0xFF111827),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SelectedBadge extends StatelessWidget {
  const _SelectedBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 20,
      height: 20,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0xFF16A34A),
        borderRadius: BorderRadius.circular(6),
      ),
      child: const Icon(Icons.check, size: 13, color: Colors.white),
    );
  }
}

// ── Bottom CTA ────────────────────────────────────────────────────────────────

class _BottomCta extends StatelessWidget {
  const _BottomCta({
    required this.selected,
    required this.totalPrice,
    required this.durationMinutes,
    required this.onContinue,
  });

  final Slot? selected;
  final double totalPrice;
  final int durationMinutes;
  final VoidCallback? onContinue;

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat.decimalPattern('vi_VN');
    final enabled = onContinue != null;
    final hours = durationMinutes / 60;
    final hoursLabel = hours == hours.roundToDouble()
        ? hours.toStringAsFixed(0)
        : hours.toStringAsFixed(1);

    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        12,
        12,
        12 + MediaQuery.of(context).padding.bottom,
      ),
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  selected == null
                      ? 'Chưa chọn khung'
                      : '1 khung đã chọn · $hoursLabel giờ',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF6B7280),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  selected == null || totalPrice == 0
                      ? '—'
                      : '${fmt.format(totalPrice.round())} đ',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF111827),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          FilledButton(
            onPressed: enabled ? onContinue : null,
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF16A34A),
              disabledBackgroundColor: const Color(0xFFD1D5DB),
              minimumSize: const Size(0, 48),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              selected == null ? 'Tiếp tục' : 'Đặt ngay',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: enabled ? Colors.white : const Color(0xFF9CA3AF),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
