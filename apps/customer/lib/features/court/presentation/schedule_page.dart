import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../data/court_repository.dart';
import '../data/fake_court_repository.dart';
import '../data/fake_slot_repository.dart';
import '../domain/booking_draft.dart';
import '../domain/court.dart';
import '../domain/schedule.dart';
import '../theme/app_tokens.dart';
import '../theme/browse_pick_theme.dart';
import 'widgets/date_tabs.dart';

/// A selected grid cell — one court row × one hour column.
class _GridRef {
  const _GridRef(this.courtId, this.hour);
  final String courtId;
  final int hour;

  @override
  bool operator ==(Object other) =>
      other is _GridRef && other.courtId == courtId && other.hour == hour;

  @override
  int get hashCode => Object.hash(courtId, hour);
}

/// Screen 08 · Sports center schedule (handoff SPB-045).
class SchedulePage extends StatefulWidget {
  const SchedulePage({
    super.key,
    required this.centerId,
    this.courtRepository,
    this.slotRepository,
  });

  final String centerId;
  final CourtRepository? courtRepository;
  final SlotRepository? slotRepository;

  @override
  State<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  late final CourtRepository _courtRepo =
      widget.courtRepository ?? FakeCourtRepository();
  late final SlotRepository _slotRepo =
      widget.slotRepository ?? FakeSlotRepository();

  late final List<DateTime> _dates = next7Days(DateTime.now());
  int _dateIndex = 0;

  // Cart spans dates within this center session (doc 02 derived-state note).
  final Set<_GridRef> _selection = {};

  SportsCenter? _center;
  ScheduleDay? _day;

  static const _cellPriceVnd = 360000; // 2h block @ 180k/h

  @override
  void initState() {
    super.initState();
    _loadCenter();
    _loadDay();
  }

  Future<void> _loadCenter() async {
    final center = await _courtRepo.getCenter(widget.centerId);
    if (mounted) setState(() => _center = center);
  }

  Future<void> _loadDay() async {
    setState(() => _day = null);
    final day =
        await _slotRepo.getCenterSchedule(widget.centerId, _dates[_dateIndex]);
    if (mounted) setState(() => _day = day);
  }

  void _onDate(int i) {
    if (i == _dateIndex) return;
    setState(() => _dateIndex = i);
    _loadDay(); // keep selection
  }

  void _toggle(String courtId, int hour) {
    final ref = _GridRef(courtId, hour);
    setState(() {
      if (!_selection.remove(ref)) _selection.add(ref);
    });
  }

  /// Edge E7 — assemble the [BookingDraft] from the selected grid cells and
  /// hand it to the booking wizard. The grid spans multiple courts, so each
  /// cell becomes a [SlotSelection] carrying its own court; the summary-card
  /// identity is the single court when only one is selected, else the center.
  void _continueToBooking() {
    final center = _center;
    final day = _day;
    if (center == null || day == null || _selection.isEmpty) return;

    final raw = _dates[_dateIndex];
    final date = DateTime(raw.year, raw.month, raw.day);
    final isoDate = date.toIso8601String().substring(0, 10);

    Court courtOf(String id) => center.courts
        .firstWhere((c) => c.id == id, orElse: () => center.courts.first);

    int startHourOf(int col) =>
        col >= 0 && col < day.hourLabels.length
            ? int.tryParse(day.hourLabels[col].substring(0, 2)) ?? 0
            : 0;

    // Stable order: by court row, then by time column.
    final refs = _selection.toList()
      ..sort((a, b) {
        final ca = center.courts.indexWhere((c) => c.id == a.courtId);
        final cb = center.courts.indexWhere((c) => c.id == b.courtId);
        return ca != cb ? ca.compareTo(cb) : a.hour.compareTo(b.hour);
      });

    final slots = refs.map((ref) {
      final court = courtOf(ref.courtId);
      final sh = startHourOf(ref.hour);
      final start = DateTime(date.year, date.month, date.day, sh);
      return SlotSelection(
        slotId: '${ref.courtId}_${isoDate}_$sh',
        courtId: ref.courtId,
        courtLabel: court.name,
        date: date,
        start: start,
        end: start.add(const Duration(hours: 2)),
        priceVnd: _cellPriceVnd,
      );
    }).toList();

    final courtIds = slots.map((s) => s.courtId).toSet();
    final single = courtIds.length == 1 ? courtOf(courtIds.first) : null;
    final identity = single ?? center.courts.first;

    final draft = BookingDraft(
      centerId: widget.centerId,
      courtId: single?.id ?? widget.centerId,
      courtLabel:
          single != null ? '${center.name} · ${single.name}' : center.name,
      address: identity.address,
      sport: identity.sports.isNotEmpty ? identity.sports.first : Sport.multi,
      date: date,
      slots: slots,
    );

    context.push('/browse/booking/confirm', extra: draft);
  }

  @override
  Widget build(BuildContext context) {
    final center = _center;
    return BrowsePickTheme(
      child: Scaffold(
        appBar: AppBar(
          title: Text(center?.name ?? 'Lịch sân'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            tooltip: 'Quay lại',
            onPressed: () => context.pop(),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.ios_share),
              tooltip: 'Chia sẻ',
              onPressed: () {},
            ),
          ],
        ),
        body: center == null
            ? const Center(child: CircularProgressIndicator())
            : _buildBody(center),
      ),
    );
  }

  Widget _buildBody(SportsCenter center) {
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final day = _day;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
      children: [
        Text('Lịch tất cả các sân',
            style: text.bodySmall?.copyWith(color: scheme.onSurfaceVariant)),
        const SizedBox(height: 12),
        DateTabs(dates: _dates, selectedIndex: _dateIndex, onSelect: _onDate),
        const SizedBox(height: 20),
        Text(_sectionDateLabel(), style: text.titleMedium),
        const SizedBox(height: 12),
        if (day == null)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 48),
            child: Center(child: CircularProgressIndicator()),
          )
        else
          _ScheduleGrid(
            center: center,
            day: day,
            selection: _selection,
            onToggle: _toggle,
          ),
        const SizedBox(height: 12),
        const _Legend(),
        if (_selection.isNotEmpty) ...[
          const SizedBox(height: 16),
          _SummaryCard(
            center: center,
            day: day,
            selection: _selection,
            cellPriceVnd: _cellPriceVnd,
            onClear: () => setState(_selection.clear),
            onContinue: _continueToBooking,
          ),
        ],
      ],
    );
  }

  String _sectionDateLabel() {
    final d = _dates[_dateIndex];
    final prefix = _dateIndex == 0 ? 'Hôm nay' : 'Ngày';
    return '$prefix, ${d.day.toString().padLeft(2, '0')}/'
        '${d.month.toString().padLeft(2, '0')}';
  }
}

// ── §10 Schedule grid ────────────────────────────────────────────────────────

class _ScheduleGrid extends StatelessWidget {
  const _ScheduleGrid({
    required this.center,
    required this.day,
    required this.selection,
    required this.onToggle,
  });

  final SportsCenter center;
  final ScheduleDay day;
  final Set<_GridRef> selection;
  final void Function(String courtId, int hour) onToggle;

  static const _labelWidth = 92.0;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLowest,
        borderRadius: AppTokens.radiusMd,
        border: Border.all(color: scheme.outlineVariant),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          _headerRow(scheme),
          for (var ri = 0; ri < center.courts.length; ri++)
            _courtRow(context, scheme, center.courts[ri], ri),
        ],
      ),
    );
  }

  Widget _headerRow(ColorScheme scheme) {
    return Container(
      color: scheme.surfaceContainerLow,
      child: Row(
        children: [
          const SizedBox(width: _labelWidth, height: 36),
          for (final h in day.hourLabels)
            Expanded(
              child: Center(
                child: Text(
                  h.substring(0, 5),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: scheme.onSurfaceVariant,
                    fontFeatures: AppTokens.tnum,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _courtRow(
      BuildContext context, ColorScheme scheme, Court court, int rowIndex) {
    final statuses = day.rows[court.id] ?? const [];
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(
          top: rowIndex == 0
              ? BorderSide.none
              : BorderSide(color: scheme.outlineVariant),
        ),
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Court-name link → 09 (edge E6).
            SizedBox(
              width: _labelWidth,
              child: InkWell(
                onTap: () => context.push('/browse/court/${court.id}/slots'),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  child: Row(
                    children: [
                      Flexible(
                        child: Text(
                          court.name,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: scheme.primary,
                            decoration: TextDecoration.underline,
                            decorationColor: scheme.primary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Icon(Icons.chevron_right, size: 14, color: scheme.primary),
                    ],
                  ),
                ),
              ),
            ),
            for (var ci = 0; ci < statuses.length; ci++)
              Expanded(
                child: _Cell(
                  status: statuses[ci],
                  selected: selection.contains(_GridRef(court.id, ci)),
                  onTap: statuses[ci] == CellStatus.open
                      ? () => onToggle(court.id, ci)
                      : null,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _Cell extends StatelessWidget {
  const _Cell({required this.status, required this.selected, this.onTap});

  final CellStatus status;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    late final Color bg;
    late final Widget glyph;
    if (selected) {
      bg = scheme.primaryContainer;
      glyph = Icon(Icons.check, size: 16, color: scheme.onPrimaryContainer);
    } else {
      switch (status) {
        case CellStatus.open:
          bg = scheme.surfaceContainerLowest;
          glyph = Text('•',
              style: TextStyle(fontSize: 16, color: scheme.onSurfaceVariant));
        case CellStatus.booked:
          bg = scheme.surfaceContainerHigh;
          glyph =
              Text('Đặt', style: TextStyle(fontSize: 10, color: scheme.outline));
        case CellStatus.blocked:
          bg = scheme.surfaceContainerHigh;
          glyph =
              Text('—', style: TextStyle(fontSize: 12, color: scheme.outline));
      }
    }

    return InkWell(
      onTap: onTap,
      child: Container(
        height: AppTokens.gridCellHeight,
        margin: selected ? const EdgeInsets.all(1) : EdgeInsets.zero,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: selected
              ? const BorderRadius.all(Radius.circular(AppTokens.cornerXs))
              : null,
          border: selected
              ? Border.all(color: scheme.primary, width: 2)
              : Border(left: BorderSide(color: scheme.outlineVariant)),
        ),
        alignment: Alignment.center,
        child: glyph,
      ),
    );
  }
}

// ── §11 Legend ───────────────────────────────────────────────────────────────

class _Legend extends StatelessWidget {
  const _Legend();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        _swatch(scheme.surfaceContainerLowest, scheme.outlineVariant,
            'Còn trống', scheme),
        const SizedBox(width: 16),
        _swatch(scheme.surfaceContainerHigh, scheme.outlineVariant, 'Đã đặt',
            scheme),
        const SizedBox(width: 16),
        _swatch(scheme.primaryContainer, scheme.primary, 'Đang chọn', scheme),
      ],
    );
  }

  Widget _swatch(Color bg, Color border, String label, ColorScheme scheme) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: bg,
            borderRadius:
                const BorderRadius.all(Radius.circular(AppTokens.cornerXs)),
            border: Border.all(color: border),
          ),
        ),
        const SizedBox(width: 6),
        Text(label,
            style: TextStyle(fontSize: 11, color: scheme.onSurfaceVariant)),
      ],
    );
  }
}

// ── §12 Selection summary card → wizard (edge E7) ────────────────────────────

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.center,
    required this.day,
    required this.selection,
    required this.cellPriceVnd,
    required this.onClear,
    required this.onContinue,
  });

  final SportsCenter center;
  final ScheduleDay? day;
  final Set<_GridRef> selection;
  final int cellPriceVnd;
  final VoidCallback onClear;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final onCt = scheme.onPrimaryContainer;
    final rows = selection.toList();
    final total = rows.length * cellPriceVnd;

    Court courtOf(String id) => center.courts
        .firstWhere((c) => c.id == id, orElse: () => center.courts.first);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.primaryContainer,
        borderRadius: AppTokens.radiusLg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Đang chọn · ${rows.length} khung',
                  style: text.labelLarge?.copyWith(color: onCt)),
              const Spacer(),
              InkWell(
                onTap: onClear,
                child: Text('Xoá tất cả',
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: onCt)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          for (final ref in rows)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                children: [
                  Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: scheme.primary,
                      borderRadius: const BorderRadius.all(
                          Radius.circular(AppTokens.cornerXs)),
                    ),
                    child: Icon(Icons.check, size: 12, color: scheme.onPrimary),
                  ),
                  const SizedBox(width: 8),
                  Text(courtOf(ref.courtId).name,
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: onCt)),
                  const SizedBox(width: 8),
                  Text(
                    _timeLabel(ref.hour),
                    style: TextStyle(
                        fontSize: 12,
                        color: onCt.withValues(alpha: 0.75),
                        fontFeatures: AppTokens.tnum),
                  ),
                  const Spacer(),
                  Text(_thousandsK(cellPriceVnd),
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: onCt,
                          fontFeatures: AppTokens.tnum)),
                ],
              ),
            ),
          Divider(color: onCt.withValues(alpha: 0.18), height: 16),
          Row(
            children: [
              Text('Tổng', style: text.labelLarge?.copyWith(color: onCt)),
              const Spacer(),
              Text(
                '${_thousands(total)} đ',
                style: text.priceMedium(scheme).copyWith(color: onCt),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: onContinue,
              style: FilledButton.styleFrom(
                minimumSize: const Size(0, AppTokens.buttonSummaryHeight),
              ),
              child: const Text('Tiếp tục đặt sân'),
            ),
          ),
        ],
      ),
    );
  }

  String _timeLabel(int hour) {
    final labels = day?.hourLabels ?? const [];
    if (hour >= labels.length) return '';
    final start = labels[hour].substring(0, 5);
    final h = int.tryParse(start.substring(0, 2)) ?? 0;
    final end = '${(h + 2).toString().padLeft(2, '0')}:00';
    return '$start – $end';
  }
}

String _thousands(int v) {
  final s = v.toString();
  final buf = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
    buf.write(s[i]);
  }
  return buf.toString();
}

String _thousandsK(int v) => '${(v / 1000).round()}k';
