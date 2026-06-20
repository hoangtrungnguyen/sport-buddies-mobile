import 'package:customer/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../data/court_repository.dart';
import '../domain/booking_draft.dart';
import '../domain/court.dart';
import '../domain/time_slot.dart';
import '../theme/browse_pick_theme.dart';
import 'open_in_maps.dart';
import 'widgets/date_tabs.dart';
import 'widgets/open_slot_section.dart';
import 'widgets/slot_picker_photo_strip.dart';
import 'widgets/slot_picker_directions_card.dart';
import 'widgets/slot_picker_grid.dart';
import 'widgets/slot_picker_bottom_cart.dart';

/// Screen 09 · Slot picker (handoff SPB-041).
class SlotPickerPage extends StatefulWidget {
  const SlotPickerPage({
    super.key,
    required this.courtId,
    required this.courtRepository,
    required this.slotRepository,
  });

  final String courtId;
  final CourtRepository courtRepository;
  final SlotRepository slotRepository;

  @override
  State<SlotPickerPage> createState() => _SlotPickerPageState();
}

class _SlotPickerPageState extends State<SlotPickerPage> {
  late final CourtRepository _courtRepo = widget.courtRepository;
  late final SlotRepository _slotRepo = widget.slotRepository;

  late final List<DateTime> _dates = next7Days(DateTime.now());
  int _dateIndex = 0;

  // Insertion order drives the 1/2/3 markers (doc 02 §15).
  final List<TimeSlot> _selection = [];

  Court? _court;
  List<TimeSlot>? _slots;
  List<OpenGroupSlot> _groupSlots = const [];

  @override
  void initState() {
    super.initState();
    _loadCourt();
    _loadSlots();
  }

  Future<void> _loadCourt() async {
    final court = await _courtRepo.getCourt(widget.courtId);
    final groups = await _slotRepo.getOpenGroupSlots(widget.courtId);
    if (mounted) {
      setState(() {
        _court = court;
        _groupSlots = groups;
      });
    }
  }

  Future<void> _loadSlots() async {
    setState(() => _slots = null);
    final slots = await _slotRepo.getSlots(widget.courtId, _dates[_dateIndex]);
    if (mounted) setState(() => _slots = slots);
  }

  void _onDate(int i) {
    if (i == _dateIndex) return;
    setState(() => _dateIndex = i);
    _loadSlots(); // keep the cart (doc 02)
  }

  /// Edge E11 — assemble the [BookingDraft] from the cart and hand it to the
  /// booking wizard (handoff doc 03 §4 / booking-wizard doc 04 §1).
  void _continueToBooking() {
    final court = _court;
    if (court == null || _selection.isEmpty) return;
    final first = _selection.first;
    final draft = BookingDraft(
      centerId: court.centerId,
      courtId: widget.courtId,
      courtLabel: court.name,
      address: court.address,
      sport: court.sports.isNotEmpty ? court.sports.first : Sport.multi,
      date: DateTime(first.start.year, first.start.month, first.start.day),
      slots: _selection
          .map(
            (s) => SlotSelection(
              slotId: s.id,
              courtId: s.courtId,
              courtLabel: court.name,
              date: DateTime(s.start.year, s.start.month, s.start.day),
              start: s.start,
              end: s.end,
              priceVnd: s.priceVnd,
            ),
          )
          .toList(),
    );
    context.push('/browse/booking/confirm', extra: draft);
  }

  void _toggleSlot(TimeSlot slot) {
    setState(() {
      final idx = _selection.indexWhere((s) => s.id == slot.id);
      if (idx >= 0) {
        _selection.removeAt(idx);
      } else {
        _selection.add(slot);
      }
    });
  }

  // E9: tap the address card to open the court in the user's chosen map app.
  void _directions() {
    final court = _court;
    if (court == null) return;
    openCourtInMaps(context, court);
  }

  @override
  Widget build(BuildContext context) {
    final court = _court;
    return BrowsePickTheme(
      child: Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context).slotPickerTitle),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            tooltip: AppLocalizations.of(context).commonBack,
            onPressed: () => context.pop(),
          ),
        ),
        body: court == null
            ? const Center(child: CircularProgressIndicator())
            : _buildBody(court),
        bottomNavigationBar: BottomCartBar(
          selection: _selection,
          onContinue: _selection.isEmpty ? null : _continueToBooking,
        ),
      ),
    );
  }

  Widget _buildBody(Court court) {
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);
    final slots = _slots;
    final openCount = slots?.where((s) => s.isOpen).length ?? 0;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      children: [
        Text(
          court.name,
          style: text.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
        ),
        const SizedBox(height: 12),
        const PhotoStrip(),
        const SizedBox(height: 10),
        DirectionsCard(court: court, onTap: _directions),
        const SizedBox(height: 20),
        DateTabs(
          dates: _dates,
          selectedIndex: _dateIndex,
          onSelect: _onDate,
          minTabWidth: 54,
        ),
        const SizedBox(height: 20),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(l10n.wizardLabelSlots, style: text.titleMedium),
            const Spacer(),
            Text(
              l10n.slotPickerMultiHint,
              style: text.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          l10n.slotPickerOpenCount(openCount),
          style: text.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
        ),
        const SizedBox(height: 12),
        if (slots == null)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 48),
            child: Center(child: CircularProgressIndicator()),
          )
        else
          SlotGrid(slots: slots, selection: _selection, onToggle: _toggleSlot),
        const SizedBox(height: 28),
        OpenSlotSection(
          slots: _groupSlots,
          helper: l10n.slotPickerOpenHelper,
          trailing: OpenSlotTrailing.chevron,
        ),
      ],
    );
  }
}
