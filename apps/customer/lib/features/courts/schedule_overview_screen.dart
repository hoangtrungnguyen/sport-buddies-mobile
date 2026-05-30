import 'package:customer/features/courts/cubit/schedule_overview_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:spb_core/spb_core.dart';

class ScheduleOverviewScreen extends StatefulWidget {
  const ScheduleOverviewScreen({super.key, required this.courtId});

  final String courtId;

  @override
  State<ScheduleOverviewScreen> createState() => _ScheduleOverviewScreenState();
}

class _ScheduleOverviewScreenState extends State<ScheduleOverviewScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ScheduleOverviewCubit>().load(widget.courtId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: const Text('Lịch tổng hợp'),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: BackButton(onPressed: () => context.pop()),
      ),
      body: BlocBuilder<ScheduleOverviewCubit, ScheduleOverviewState>(
        builder: (context, state) => switch (state) {
          ScheduleOverviewLoading() ||
          ScheduleOverviewInitial() =>
            const Center(child: CircularProgressIndicator()),
          ScheduleOverviewError(message: final msg) => Center(
              child: Text(msg,
                  style: const TextStyle(color: Color(0xFF6B7280)))),
          ScheduleOverviewLoaded() => _LoadedBody(
              state: state,
              onDateSelected: (d) =>
                  context.read<ScheduleOverviewCubit>().selectDate(d),
            ),
        },
      ),
    );
  }
}

class _LoadedBody extends StatelessWidget {
  const _LoadedBody({
    required this.state,
    required this.onDateSelected,
  });

  final ScheduleOverviewLoaded state;
  final ValueChanged<DateTime> onDateSelected;

  // Hours shown in grid: 06:00–22:00 inclusive.
  static const int _firstHour = 6;
  static const int _lastHour = 22;

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final dates = List.generate(7, (i) => DateTime(
          today.year,
          today.month,
          today.day + i,
        ));
    final hours = List.generate(
      _lastHour - _firstHour + 1,
      (i) => _firstHour + i,
    );

    return Column(
      children: [
        _DateTabBar(
          dates: dates,
          selected: state.selectedDate,
          onSelected: onDateSelected,
        ),
        _Legend(),
        Expanded(
          child: state.courts.isEmpty
              ? const Center(
                  child: Text('Không có sân nào trong cụm này.',
                      style: TextStyle(color: Color(0xFF6B7280))))
              : _ScheduleGrid(
                  courts: state.courts,
                  slotsByCourtId: state.slotsByCourtId,
                  hours: hours,
                  selectedDate: state.selectedDate,
                ),
        ),
      ],
    );
  }
}

class _DateTabBar extends StatelessWidget {
  const _DateTabBar({
    required this.dates,
    required this.selected,
    required this.onSelected,
  });

  final List<DateTime> dates;
  final DateTime selected;
  final ValueChanged<DateTime> onSelected;

  static final _dayFmt = DateFormat('E', 'vi');
  static final _numFmt = DateFormat('d');

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      height: 76,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        itemCount: dates.length,
        separatorBuilder: (_, __) => const SizedBox(width: 6),
        itemBuilder: (_, i) {
          final d = dates[i];
          final isToday = i == 0;
          final isActive = d.year == selected.year &&
              d.month == selected.month &&
              d.day == selected.day;
          return GestureDetector(
            onTap: () => onSelected(d),
            child: Container(
              width: 54,
              padding:
                  const EdgeInsets.symmetric(vertical: 6, horizontal: 6),
              decoration: BoxDecoration(
                color: isActive
                    ? const Color(0xFF111827)
                    : Colors.white,
                border: Border.all(
                  color: isActive
                      ? const Color(0xFF111827)
                      : const Color(0xFFE5E7EB),
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _dayFmt.format(d).toUpperCase(),
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w500,
                      color: isActive
                          ? Colors.white.withValues(alpha: 0.7)
                          : const Color(0xFF6B7280),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _numFmt.format(d),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color:
                          isActive ? Colors.white : const Color(0xFF111827),
                    ),
                  ),
                  if (isToday)
                    Text(
                      'hôm nay',
                      style: TextStyle(
                        fontSize: 8,
                        color: isActive
                            ? Colors.white.withValues(alpha: 0.7)
                            : const Color(0xFF6B7280),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
      child: Row(
        children: [
          _LegendDot(color: const Color(0xFFDCFCE7), label: 'Trống'),
          const SizedBox(width: 12),
          _LegendDot(color: const Color(0xFFF3F4F6), label: 'Đã đặt'),
          const SizedBox(width: 12),
          _LegendDot(color: const Color(0xFFE5E7EB), label: 'Đóng'),
        ],
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            border: Border.all(color: const Color(0xFFD1D5DB)),
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 4),
        Text(label,
            style: const TextStyle(
                fontSize: 11, color: Color(0xFF6B7280))),
      ],
    );
  }
}

class _ScheduleGrid extends StatelessWidget {
  const _ScheduleGrid({
    required this.courts,
    required this.slotsByCourtId,
    required this.hours,
    required this.selectedDate,
  });

  final List<Court> courts;
  final Map<String, List<Slot>> slotsByCourtId;
  final List<int> hours;
  final DateTime selectedDate;

  static const double _courtColWidth = 100.0;
  static const double _cellWidth = 72.0;
  static const double _cellHeight = 52.0;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row: empty corner + hour labels
            Row(
              children: [
                const _HeaderCell(width: _courtColWidth, label: ''),
                ...hours.map(
                  (h) => _HeaderCell(
                    width: _cellWidth,
                    label: '${h.toString().padLeft(2, '0')}:00',
                  ),
                ),
              ],
            ),
            const Divider(height: 1, color: Color(0xFFE5E7EB)),
            // Court rows
            ...courts.map((court) {
              final slots = slotsByCourtId[court.id] ?? [];
              return _CourtRow(
                court: court,
                slots: slots,
                hours: hours,
                selectedDate: selectedDate,
                courtColWidth: _courtColWidth,
                cellWidth: _cellWidth,
                cellHeight: _cellHeight,
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _HeaderCell extends StatelessWidget {
  const _HeaderCell({required this.width, required this.label});

  final double width;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: 32,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Center(
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: Color(0xFF6B7280),
          ),
        ),
      ),
    );
  }
}

class _CourtRow extends StatelessWidget {
  const _CourtRow({
    required this.court,
    required this.slots,
    required this.hours,
    required this.selectedDate,
    required this.courtColWidth,
    required this.cellWidth,
    required this.cellHeight,
  });

  final Court court;
  final List<Slot> slots;
  final List<int> hours;
  final DateTime selectedDate;
  final double courtColWidth;
  final double cellWidth;
  final double cellHeight;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Court name cell
            Container(
              width: courtColWidth,
              height: cellHeight,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(
                  right: BorderSide(color: Color(0xFFE5E7EB)),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    court.name,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF111827),
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                ],
              ),
            ),
            // Hour cells
            ...hours.map((h) {
              final slot = _slotForHour(h);
              return _SlotCell(
                slot: slot,
                width: cellWidth,
                height: cellHeight,
                onTap: slot != null && slot.accessPolicy == 'open'
                    ? () => context.push('/slot/${slot.id}')
                    : null,
              );
            }),
          ],
        ),
        const Divider(height: 1, color: Color(0xFFE5E7EB)),
      ],
    );
  }

  Slot? _slotForHour(int hour) {
    for (final s in slots) {
      final localStart = s.startTime.toLocal();
      if (localStart.hour == hour) return s;
    }
    return null;
  }
}

class _SlotCell extends StatelessWidget {
  const _SlotCell({
    required this.slot,
    required this.width,
    required this.height,
    this.onTap,
  });

  final Slot? slot;
  final double width;
  final double height;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color border;
    String label = '';

    if (slot == null) {
      bg = Colors.white;
      border = const Color(0xFFF3F4F6);
    } else {
      switch (slot!.accessPolicy) {
        case 'open':
          bg = const Color(0xFFDCFCE7);
          border = const Color(0xFF86EFAC);
          label = 'Trống';
        default:
          if (slot!.accessPolicy == 'blocked') {
            bg = const Color(0xFFE5E7EB);
            border = const Color(0xFFD1D5DB);
            label = 'Đóng';
          } else {
            bg = const Color(0xFFF3F4F6);
            border = const Color(0xFFE5E7EB);
            label = 'Đặt';
          }
      }
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        height: height,
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: bg,
          border: Border.all(color: border),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Center(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: Color(0xFF6B7280),
            ),
          ),
        ),
      ),
    );
  }
}
