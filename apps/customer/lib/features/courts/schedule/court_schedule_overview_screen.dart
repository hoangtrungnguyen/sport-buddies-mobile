import 'package:customer/core/services/booking_api_client.dart';
import 'package:customer/features/courts/schedule/cubit/court_schedule_overview_cubit.dart';
import 'package:customer/features/courts/schedule/cubit/court_schedule_overview_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

const _kVenueName = 'Pickle Hub Sài Gòn';

/// Multi-court venue schedule. Renders a grid of courts × time slots; users
/// multi-select slots into a cart and continue to the booking wizard.
class CourtScheduleOverviewScreen extends StatelessWidget {
  const CourtScheduleOverviewScreen({
    super.key,
    required this.sportsCenterId,
    required this.apiClient,
  });

  final String sportsCenterId;
  final BookingApiClient apiClient;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CourtScheduleOverviewCubit(
        sportsCenterId: sportsCenterId,
        apiClient: apiClient,
      ),
      child: const _View(),
    );
  }
}

class _View extends StatelessWidget {
  const _View();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: const Text(
          _kVenueName,
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
        ),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF111827),
        elevation: 0,
        leading: BackButton(onPressed: () => context.pop()),
        actions: [
          IconButton(
            icon: const Icon(Icons.ios_share, size: 20),
            onPressed: () {},
          ),
        ],
      ),
      body: BlocBuilder<CourtScheduleOverviewCubit, CourtScheduleOverviewState>(
        builder: (context, state) => switch (state) {
          CourtScheduleOverviewLoading() =>
            const Center(child: CircularProgressIndicator()),
          CourtScheduleOverviewFailure(message: final msg) => Center(
              child: Text(
                msg,
                style: const TextStyle(color: Color(0xFF6B7280)),
              ),
            ),
          CourtScheduleOverviewLoaded() => _LoadedBody(state: state),
        },
      ),
    );
  }
}

class _LoadedBody extends StatelessWidget {
  const _LoadedBody({required this.state});

  final CourtScheduleOverviewLoaded state;

  static const _stickyEmptyH = 132.0;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<CourtScheduleOverviewCubit>();
    final groups = state.buildCartGroups();
    final hasSelection = groups.isNotEmpty;
    final selectedDate = state.dates[state.selectedDateIndex];
    // Rough estimate so the scroll view doesn't hide content behind the sticky
    // cart panel. ~200 chrome + 22 per item + 24 per date header.
    final stickyHeight = hasSelection
        ? 200.0 + state.totalSelectedCount * 22.0 + groups.length * 24.0
        : _stickyEmptyH;

    return Stack(
      children: [
        SingleChildScrollView(
          padding: EdgeInsets.only(
            bottom: 16 + stickyHeight + MediaQuery.of(context).padding.bottom,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                color: Colors.white,
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: const Text(
                  'Lịch tất cả các sân',
                  style: TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                ),
              ),
              _DateTabRow(
                dates: state.dates,
                selectedIndex: state.selectedDateIndex,
                onTap: cubit.selectDate,
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
                child: Text(
                  _dateHeading(selectedDate),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF111827),
                  ),
                ),
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: _ScheduleGrid(
                  courts: state.courts,
                  hours: state.hours,
                  slots: state.currentSlots,
                  selected: state.currentDateSelection,
                  onTap: cubit.toggleSlot,
                ),
              ),
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 14, 16, 8),
                child: _Legend(),
              ),
              if (!hasSelection)
                const Padding(
                  padding: EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: _EmptyHintCard(),
                ),
            ],
          ),
        ),
        Positioned(
          left: 12,
          right: 12,
          bottom: 12 + MediaQuery.of(context).padding.bottom,
          child: hasSelection
              ? _SelectionCart(
                  groups: groups,
                  count: state.totalSelectedCount,
                  total: state.grandTotal,
                  onClearAll: cubit.clearAll,
                  onContinue: () {
                    // Wire to booking wizard step 1 later.
                  },
                )
              : const _EmptyCta(),
        ),
      ],
    );
  }

  static String _dateHeading(DateTime d) {
    final today = DateTime.now();
    final isToday = d.year == today.year &&
        d.month == today.month &&
        d.day == today.day;
    final dd = d.day.toString().padLeft(2, '0');
    final mm = d.month.toString().padLeft(2, '0');
    if (isToday) return 'Hôm nay, $dd/$mm';
    return '${_fullWeekday(d.weekday)}, $dd/$mm';
  }

  static String _fullWeekday(int w) => switch (w) {
        1 => 'Thứ hai',
        2 => 'Thứ ba',
        3 => 'Thứ tư',
        4 => 'Thứ năm',
        5 => 'Thứ sáu',
        6 => 'Thứ bảy',
        _ => 'Chủ nhật',
      };
}

// ── Date tabs ────────────────────────────────────────────────────────────────

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
        height: 64,
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
    final dd = date.day.toString().padLeft(2, '0');
    final mm = date.month.toString().padLeft(2, '0');
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 80,
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF16A34A) : Colors.white,
          border: Border.all(
            color: isActive
                ? const Color(0xFF16A34A)
                : const Color(0xFFE5E7EB),
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
              '$dd/$mm',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
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

// ── Grid ─────────────────────────────────────────────────────────────────────

class _ScheduleGrid extends StatelessWidget {
  const _ScheduleGrid({
    required this.courts,
    required this.hours,
    required this.slots,
    required this.selected,
    required this.onTap,
  });

  final List<ScheduleCourt> courts;
  final List<int> hours;
  final Map<String, ScheduleSlot> slots;
  final Set<String> selected;
  final ValueChanged<String> onTap;

  static const _courtColW = 88.0;
  static const _cellW = 40.0;
  static const _cellH = 40.0;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE5E7EB)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const SizedBox(width: _courtColW, height: 32),
              for (final h in hours)
                SizedBox(
                  width: _cellW,
                  height: 32,
                  child: Center(
                    child: Text(
                      '${h.toString().padLeft(2, '0')}:00',
                      style: const TextStyle(
                        fontSize: 10,
                        color: Color(0xFF6B7280),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const Divider(height: 1, color: Color(0xFFE5E7EB)),
          for (var i = 0; i < courts.length; i++) ...[
            _CourtRow(
              court: courts[i],
              hours: hours,
              slots: slots,
              selected: selected,
              onTap: onTap,
            ),
            if (i < courts.length - 1)
              const Divider(height: 1, color: Color(0xFFF3F4F6)),
          ],
        ],
      ),
    );
  }
}

class _CourtRow extends StatelessWidget {
  const _CourtRow({
    required this.court,
    required this.hours,
    required this.slots,
    required this.selected,
    required this.onTap,
  });

  final ScheduleCourt court;
  final List<int> hours;
  final Map<String, ScheduleSlot> slots;
  final Set<String> selected;
  final ValueChanged<String> onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => context.push(
              '/court/${court.id}/slots',
              extra: <String, String?>{
                'name': '${court.name} · ${court.sport}',
                'address': _kVenueName,
              },
            ),
            child: SizedBox(
              width: _ScheduleGrid._courtColW,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      court.name,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF111827),
                      ),
                    ),
                    Text(
                      court.sport,
                      style: const TextStyle(
                        fontSize: 10,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          for (final h in hours)
            _Cell(
              key: ValueKey('${court.id}|$h'),
              slotKey: '${court.id}|$h',
              slot: slots['${court.id}|$h'],
              isSelected: selected.contains('${court.id}|$h'),
              onTap: onTap,
            ),
        ],
      ),
    );
  }
}

class _Cell extends StatelessWidget {
  const _Cell({
    super.key,
    required this.slotKey,
    required this.slot,
    required this.isSelected,
    required this.onTap,
  });

  final String slotKey;
  final ScheduleSlot? slot;
  final bool isSelected;
  final ValueChanged<String> onTap;

  @override
  Widget build(BuildContext context) {
    Widget content;
    Color bg = Colors.white;
    Color? border;
    final isOpen = slot?.status == SlotStatus.open;
    final isBooked = slot?.status == SlotStatus.booked;
    final isClosed = slot == null || slot!.status == SlotStatus.closed;

    if (isClosed) {
      content = Container(
        width: 12,
        height: 1.5,
        color: const Color(0xFFD1D5DB),
      );
    } else if (isBooked) {
      content = const Text(
        'Đặt',
        style: TextStyle(
          fontSize: 11,
          color: Color(0xFF9CA3AF),
          fontWeight: FontWeight.w500,
          decoration: TextDecoration.lineThrough,
        ),
      );
      bg = const Color(0xFFF3F4F6);
    } else if (isSelected) {
      content = const Icon(Icons.check, size: 18, color: Color(0xFF16A34A));
      bg = const Color(0xFFDCFCE7);
      border = const Color(0xFF16A34A);
    } else {
      content = Container(
        width: 4,
        height: 4,
        decoration: const BoxDecoration(
          color: Color(0xFFD1D5DB),
          shape: BoxShape.circle,
        ),
      );
    }

    final cell = Container(
      margin: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: bg,
        border: border != null ? Border.all(color: border, width: 1.5) : null,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Center(child: content),
    );

    return SizedBox(
      width: _ScheduleGrid._cellW,
      height: _ScheduleGrid._cellH,
      child: isOpen
          ? GestureDetector(
              onTap: () => onTap(slotKey),
              behavior: HitTestBehavior.opaque,
              child: cell,
            )
          : cell,
    );
  }
}

// ── Legend ───────────────────────────────────────────────────────────────────

class _Legend extends StatelessWidget {
  const _Legend();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        _LegendItem(
          color: Colors.white,
          border: Color(0xFFE5E7EB),
          label: 'Còn trống',
        ),
        SizedBox(width: 16),
        _LegendItem(
          color: Color(0xFFF3F4F6),
          border: Color(0xFFE5E7EB),
          label: 'Đã đặt',
        ),
        SizedBox(width: 16),
        _LegendItem(
          color: Color(0xFFDCFCE7),
          border: Color(0xFF16A34A),
          label: 'Đang chọn',
        ),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({
    required this.color,
    required this.border,
    required this.label,
  });

  final Color color;
  final Color border;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: color,
            border: Border.all(color: border, width: 1.5),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
        ),
      ],
    );
  }
}

// ── Selection cart ───────────────────────────────────────────────────────────

class _SelectionCart extends StatelessWidget {
  const _SelectionCart({
    required this.groups,
    required this.count,
    required this.total,
    required this.onClearAll,
    required this.onContinue,
  });

  final List<CartGroup> groups;
  final int count;
  final int total;
  final VoidCallback onClearAll;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat.decimalPattern('vi_VN');
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      decoration: BoxDecoration(
        color: const Color(0xFFDCFCE7),
        border: Border.all(color: const Color(0xFF16A34A)),
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 12,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Đang chọn · $count khung',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF166534),
                  ),
                ),
              ),
              GestureDetector(
                onTap: onClearAll,
                child: const Text(
                  'Xoá tất cả',
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF166534),
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          for (var g = 0; g < groups.length; g++) ...[
            if (g > 0) const SizedBox(height: 8),
            _CartGroupSection(group: groups[g]),
          ],
          const SizedBox(height: 8),
          const SizedBox(height: 1, child: _DottedDivider()),
          const SizedBox(height: 8),
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Tổng',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF166534),
                  ),
                ),
              ),
              Text(
                '${fmt.format(total)} đ',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF166534),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: onContinue,
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF16A34A),
              minimumSize: const Size(double.infinity, 48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Tiếp tục đặt sân',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CartGroupSection extends StatelessWidget {
  const _CartGroupSection({required this.group});

  final CartGroup group;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Text(
            _groupHeader(group.date),
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Color(0xFF15803D),
              letterSpacing: 0.3,
            ),
          ),
        ),
        for (final item in group.items)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 3),
            child: Row(
              children: [
                const Icon(Icons.check_box,
                    size: 16, color: Color(0xFF16A34A)),
                const SizedBox(width: 6),
                Expanded(
                  flex: 5,
                  child: Text(
                    '${item.courtName} · ${item.sport}',
                    style: const TextStyle(
                        fontSize: 12, color: Color(0xFF111827)),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Expanded(
                  flex: 4,
                  child: Text(
                    item.timeLabel,
                    style: const TextStyle(
                        fontSize: 12, color: Color(0xFF111827)),
                  ),
                ),
                Text(
                  '${(item.price / 1000).round()}k',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF111827),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  static String _groupHeader(DateTime d) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final diff = DateTime(d.year, d.month, d.day).difference(today).inDays;
    final dd = d.day.toString().padLeft(2, '0');
    final mm = d.month.toString().padLeft(2, '0');
    final label = switch (diff) {
      0 => 'HÔM NAY',
      1 => 'MAI',
      _ => _weekdayFull(d.weekday).toUpperCase(),
    };
    return '$label · $dd/$mm';
  }

  static String _weekdayFull(int w) => switch (w) {
        1 => 'Thứ hai',
        2 => 'Thứ ba',
        3 => 'Thứ tư',
        4 => 'Thứ năm',
        5 => 'Thứ sáu',
        6 => 'Thứ bảy',
        _ => 'Chủ nhật',
      };
}

class _DottedDivider extends StatelessWidget {
  const _DottedDivider();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DottedPainter(),
      child: const SizedBox.expand(),
    );
  }
}

class _DottedPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF86EFAC)
      ..strokeWidth = 1;
    const dashW = 3.0;
    const gapW = 3.0;
    double x = 0;
    while (x < size.width) {
      canvas.drawLine(Offset(x, 0), Offset(x + dashW, 0), paint);
      x += dashW + gapW;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ── Empty-state widgets ──────────────────────────────────────────────────────

class _EmptyHintCard extends StatelessWidget {
  const _EmptyHintCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        border: Border.all(color: const Color(0xFFFDE68A)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.touch_app_outlined, size: 20, color: Color(0xFFB45309)),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Chạm vào ô trống để chọn khung giờ',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF92400E),
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Có thể chọn nhiều khung liên tục để đặt lâu hơn.',
                  style: TextStyle(fontSize: 12, color: Color(0xFF92400E)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyCta extends StatelessWidget {
  const _EmptyCta();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE5E7EB)),
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 12,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.info_outline, size: 16, color: Color(0xFF6B7280)),
              SizedBox(width: 6),
              Flexible(
                child: Text(
                  'Chọn ít nhất 1 khung giờ để tiếp tục',
                  style: TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          FilledButton(
            onPressed: null,
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFD1D5DB),
              disabledBackgroundColor: const Color(0xFFE5E7EB),
              minimumSize: const Size(double.infinity, 48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Tiếp tục đặt sân',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Color(0xFF9CA3AF),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
