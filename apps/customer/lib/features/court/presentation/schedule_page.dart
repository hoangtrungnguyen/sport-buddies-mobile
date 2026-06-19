import 'package:customer/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../data/court_repository.dart';
import '../domain/booking_draft.dart';
import '../domain/court.dart';
import '../domain/schedule.dart';
import '../theme/browse_pick_theme.dart';
import 'widgets/date_tabs.dart';
import 'schedule_grid_ref.dart';
import 'widgets/schedule_grid.dart';
import 'widgets/schedule_legend.dart';
import 'widgets/schedule_summary_card.dart';

/// Screen 08 · Sports center schedule (handoff SPB-045).
class SchedulePage extends StatefulWidget {
  const SchedulePage({
    super.key,
    required this.centerId,
    required this.courtRepository,
    required this.slotRepository,
  });

  final String centerId;
  final CourtRepository courtRepository;
  final SlotRepository slotRepository;

  @override
  State<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  late final CourtRepository _courtRepo = widget.courtRepository;
  late final SlotRepository _slotRepo = widget.slotRepository;

  late final List<DateTime> _dates = next7Days(DateTime.now());
  int _dateIndex = 0;

  // Cart spans dates within this center session (doc 02 derived-state note).
  final Set<GridRef> _selection = {};

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
    final day = await _slotRepo.getCenterSchedule(
      widget.centerId,
      _dates[_dateIndex],
    );
    if (mounted) setState(() => _day = day);
  }

  void _onDate(int i) {
    if (i == _dateIndex) return;
    setState(() => _dateIndex = i);
    _loadDay(); // keep selection
  }

  void _toggle(String courtId, int hour) {
    final ref = GridRef(courtId, hour);
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

    Court courtOf(String id) => center.courts.firstWhere(
      (c) => c.id == id,
      orElse: () => center.courts.first,
    );

    int startHourOf(int col) => col >= 0 && col < day.hourLabels.length
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
      courtLabel: single != null
          ? '${center.name} · ${single.name}'
          : center.name,
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
          title: Text(
            center?.name ?? AppLocalizations.of(context).scheduleTitle,
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            tooltip: AppLocalizations.of(context).commonBack,
            onPressed: () => context.pop(),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.ios_share),
              tooltip: AppLocalizations.of(context).courtDetailShare,
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
    final l10n = AppLocalizations.of(context);
    final day = _day;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
      children: [
        Text(
          l10n.scheduleAllCourts,
          style: text.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
        ),
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
          ScheduleGrid(
            center: center,
            day: day,
            selection: _selection,
            onToggle: _toggle,
          ),
        const SizedBox(height: 12),
        const Legend(),
        if (_selection.isNotEmpty) ...[
          const SizedBox(height: 16),
          SummaryCard(
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
    final l10n = AppLocalizations.of(context);
    final d = _dates[_dateIndex];
    final prefix = _dateIndex == 0 ? l10n.scheduleToday : l10n.scheduleDateWord;
    return '$prefix, ${d.day.toString().padLeft(2, '0')}/'
        '${d.month.toString().padLeft(2, '0')}';
  }
}
