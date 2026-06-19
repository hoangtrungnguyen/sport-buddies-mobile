import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:spb_core/core/theme/app_colors.dart';

import '../model/models.dart';
import '../util/schedule_format.dart';
import 'create_slot_controls.dart';
import 'create_slot_kind_picker.dart';
import 'side_sheet.dart';

/// Which flavour of the sheet is open — `init.mode` in the prototype's
/// `CreateDrawer` (`schedule-page.jsx`).
enum CreateSlotSheetMode { create, block }

/// Create-mode submit callback — mirrors the signature of
/// `VenueScheduleEvent.createSlotSubmitted` so the page can forward 1:1.
typedef CreateSlotSubmit = void Function(
  CreateSlotRequest request, {
  required bool repeat,
  required List<int> weekdays,
  required int weeks,
});

/// Block-mode submit callback — mirrors `VenueScheduleEvent.blockSubmitted`;
/// recurrence applies to block mode too (prototype CreateDrawer).
typedef BlockTimeSubmit = void Function(
  BlockTimeRequest request, {
  required bool repeat,
  required List<int> weekdays,
  required int weeks,
});

/// "Tạo slot mới" / "Khoá / chặn giờ" right drawer — `CreateDrawer` in
/// `schedule-page.jsx`. One sheet, two modes:
///
/// - [CreateSlotSheetMode.create] — type picker Slot trống / Slot mở (ghép) /
///   Slot riêng, open-slot extras (capacity + price/person), recurrence.
/// - [CreateSlotSheetMode.block] — type picker Khoá giờ / Bảo trì / Sân của
///   tôi.
///
/// Pure presentational: prefill comes from `VenueScheduleState.createPrefill`
/// / `blockPrefill` (empty-cell tap, drag-to-block, header buttons); submit
/// builds the request and calls [onCreateSubmitted] / [onBlockSubmitted] —
/// the bloc closes the sheet itself once the mutation lands, so the sheet
/// does NOT call [onClose] on submit.
///
/// The repeat section ("Lặp lại nhiều buổi") applies in BOTH modes, like the
/// prototype — block submits forward the recurrence selection too. With
/// repeat on and no weekday selected the submit button is disabled (the
/// label would promise "Tạo 0 slot").
class CreateSlotSheet extends StatefulWidget {
  const CreateSlotSheet({
    super.key,
    required this.mode,
    required this.venues,
    this.createPrefill,
    this.blockPrefill,
    required this.onClose,
    required this.onCreateSubmitted,
    required this.onBlockSubmitted,
  });

  final CreateSlotSheetMode mode;

  /// All venues of the court — the "Sân" dropdown options.
  final List<Venue> venues;

  /// Prefill when [mode] is create (`VenueScheduleState.createPrefill`).
  final CreateSlotRequest? createPrefill;

  /// Prefill when [mode] is block (`VenueScheduleState.blockPrefill`).
  final BlockTimeRequest? blockPrefill;

  /// Scrim tap / ✕ / "Huỷ" — dispatch `VenueScheduleEvent.sheetClosed()`.
  final VoidCallback onClose;

  /// "Tạo slot" / "Tạo N slot" — dispatch
  /// `VenueScheduleEvent.createSlotSubmitted(...)`.
  final CreateSlotSubmit onCreateSubmitted;

  /// "Khoá giờ" / "Tạo N slot" — dispatch
  /// `VenueScheduleEvent.blockSubmitted(...)`.
  final BlockTimeSubmit onBlockSubmitted;

  @override
  State<CreateSlotSheet> createState() => _CreateSlotSheetState();
}

class _CreateSlotSheetState extends State<CreateSlotSheet> {
  // Type-picker catalogues — copy from the prototype's `createKinds` /
  // `blockKinds` ('public' in the jsx == SlotState.open).
  //
  // TODO(BCORE-321/326): "Slot mở (ghép)" / "Slot riêng" are gated behind
  // [kMatchmakingEnabled] — the DB has no representation for them yet, so
  // only "Slot trống" can be created from real data.
  static const List<KindOption> _createKinds = [
    KindOption(SlotState.empty, 'Slot trống', 'Mở giờ trống để khách tự đặt'),
    if (kMatchmakingEnabled) ...[
      KindOption(SlotState.open, 'Slot mở (ghép)',
          'Khách lẻ ghép đội tới khi đủ người'),
      KindOption(
          SlotState.private, 'Slot riêng', 'Giữ chỗ, không hiển thị công khai'),
    ],
  ];
  static const List<KindOption> _blockKinds = [
    KindOption(SlotState.locked, 'Khoá giờ', 'Đóng cửa, không nhận đặt'),
    KindOption(SlotState.maintenance, 'Bảo trì', 'Sửa chữa, vệ sinh sân'),
    KindOption(SlotState.owner, 'Sân của tôi', 'Dùng cá nhân / nội bộ'),
  ];

  late SlotState _kind;
  late String _venueId;
  late double _start;
  late double _dur;
  bool _repeat = false;
  late List<int> _days; // 0=Mon..6=Sun, kept sorted like the jsx toggleDay
  int _weeks = 4;
  int _cap = 4;
  int _price = 70000;

  late final TextEditingController _capController;
  late final TextEditingController _priceController;
  late final TextEditingController _weeksController;

  bool get _isBlock => widget.mode == CreateSlotSheetMode.block;

  @override
  void initState() {
    super.initState();
    final cp = widget.createPrefill;
    final bp = widget.blockPrefill;

    // Mirrors the CreateDrawer useState defaults: kind locked|empty, court
    // from init, start 18:00, dur 1.5h, cap 4, price 70k, weeks 4, days
    // seeded with the tapped weekday (today's index when absent).
    _kind = _isBlock
        ? (bp?.blockType ?? SlotState.locked)
        : (cp?.slotType ?? SlotState.empty);
    _venueId = (_isBlock ? bp?.venueId : cp?.venueId) ??
        (widget.venues.isEmpty ? '' : widget.venues.first.id);
    _start = (_isBlock ? bp?.startHour : cp?.startHour) ?? 18;
    _dur = (_isBlock ? bp?.durationHours : cp?.durationHours) ?? 1.5;
    _cap = cp?.capacity ?? 4;
    _price = cp?.pricePerPerson ?? 70000;

    final prefillDate = _isBlock ? bp?.date : cp?.date;
    final seedWeekday = (_isBlock ? bp?.weekday : cp?.weekday) ??
        (prefillDate ?? DateTime.now()).weekday - 1;
    _days = [seedWeekday];

    _capController = TextEditingController(text: '$_cap');
    _priceController = TextEditingController(text: '$_price');
    _weeksController = TextEditingController(text: '$_weeks');
  }

  @override
  void dispose() {
    _capController.dispose();
    _priceController.dispose();
    _weeksController.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Derived values (mirroring the jsx)
  // ---------------------------------------------------------------------------

  /// `sessions = repeat ? days.length * weeks : 1`.
  int get _sessions => _repeat ? _days.length * _weeks : 1;

  List<KindOption> get _kinds => _isBlock ? _blockKinds : _createKinds;

  /// `SC_HOURS.flatMap(h => [h, h + 0.5])` — 06:00 … 22:30 in 30-min steps.
  List<double> get _startOptions {
    final options = <double>[
      for (var h = 6; h <= 22; h++) ...[h.toDouble(), h + 0.5],
    ];
    // Defensive: keep a prefilled value selectable even if off-grid.
    if (!options.contains(_start)) {
      options
        ..add(_start)
        ..sort();
    }
    return options;
  }

  /// 1 / 1.5 / 2 / 2.5 / 3h — plus the prefilled drag range when outside.
  List<double> get _durOptions {
    final options = <double>[1, 1.5, 2, 2.5, 3];
    if (!options.contains(_dur)) {
      options
        ..add(_dur)
        ..sort();
    }
    return options;
  }

  void _toggleDay(int i) {
    setState(() {
      if (_days.contains(i)) {
        _days.remove(i);
      } else {
        _days = [..._days, i]..sort();
      }
    });
  }

  /// False while repeat is on with no weekday selected — submitting would
  /// promise "Tạo 0 slot"; the prototype creates nothing in that case.
  bool get _canSubmit => !_repeat || _days.isNotEmpty;

  void _submit() {
    if (!_canSubmit) return;
    if (_isBlock) {
      widget.onBlockSubmitted(
        BlockTimeRequest(
          venueId: _venueId,
          startHour: _start,
          durationHours: _dur,
          date: widget.blockPrefill?.date,
          weekday: widget.blockPrefill?.weekday,
          blockType: _kind,
          note: widget.blockPrefill?.note,
        ),
        repeat: _repeat,
        weekdays: _days,
        weeks: _weeks,
      );
    } else {
      final isOpen = _kind == SlotState.open;
      widget.onCreateSubmitted(
        CreateSlotRequest(
          venueId: _venueId,
          startHour: _start,
          durationHours: _dur,
          date: widget.createPrefill?.date,
          weekday: widget.createPrefill?.weekday,
          slotType: _kind,
          capacity: isOpen ? _cap : null,
          pricePerPerson: isOpen ? _price : null,
          note: widget.createPrefill?.note,
        ),
        repeat: _repeat,
        weekdays: _days,
        weeks: _weeks,
      );
    }
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return ScheduleSideSheet(
      onDismiss: widget.onClose,
      // Defensive Material so text fields/dropdowns work wherever the page
      // mounts the overlay Stack.
      child: Material(
        type: MaterialType.transparency,
        child: Column(
          children: [
            _buildHead(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(22, 20, 22, 20),
                child: _buildBody(),
              ),
            ),
            _buildFoot(),
          ],
        ),
      ),
    );
  }

  /// `.drawer-head` — title + subtitle per mode, ghost ✕ button.
  Widget _buildHead() {
    return Container(
      padding: const EdgeInsets.fromLTRB(22, 18, 22, 18),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.neutral100)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isBlock ? 'Khoá / chặn giờ' : 'Tạo slot mới',
                  style: GoogleFonts.sora(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.neutral900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _isBlock
                      ? 'Đánh dấu giờ không nhận đặt sân'
                      : 'Mở giờ để khách đặt hoặc ghép đội',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    color: AppColors.neutral500,
                  ),
                ),
              ],
            ),
          ),
          GhostIconButton(icon: Icons.close, onTap: widget.onClose),
        ],
      ),
    );
  }

  /// `.drawer-body` — type picker, venue, time, extras, repeat.
  Widget _buildBody() {
    // Capacity + price/person only apply to matchmaking slots, which are
    // gated until the backend supports them (TODO BCORE-321/326).
    final showOpenExtras =
        kMatchmakingEnabled && !_isBlock && _kind == SlotState.open;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _field(
          _isBlock ? 'Loại chặn' : 'Loại slot',
          KindPicker(
            options: _kinds,
            active: _kind,
            onSelect: (s) => setState(() => _kind = s),
          ),
        ),
        const SizedBox(height: 16),
        _field('Sân', _buildVenueSelect()),
        const SizedBox(height: 16),
        _field('Giờ bắt đầu & thời lượng', _buildTimeSection()),
        const SizedBox(height: 16),
        if (showOpenExtras) ...[
          _buildOpenExtras(),
          const SizedBox(height: 16),
        ],
        _buildRepeatSection(),
      ],
    );
  }

  /// Repeated body scaffold: a label, a 7px gap, then [child] — the
  /// `.field` block in the prototype's drawer body.
  Widget _field(String label, Widget child) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: sheetLabelStyle),
        const SizedBox(height: 7),
        child,
      ],
    );
  }

  /// "Sân" dropdown — venue id → "name · sport" (or just name when the court
  /// has no venues yet).
  Widget _buildVenueSelect() {
    return SheetSelect<String>(
      value: widget.venues.any((v) => v.id == _venueId) ? _venueId : null,
      options: [for (final v in widget.venues) v.id],
      labelOf: (id) {
        final v = widget.venues.firstWhere((v) => v.id == id);
        return v.sportLabel.isEmpty ? v.name : '${v.name} · ${v.sportLabel}';
      },
      onChanged: (id) => setState(() => _venueId = id),
    );
  }

  /// Start + duration selects, with the derived "Kết thúc lúc HH:MM" hint.
  Widget _buildTimeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: SheetSelect<double>(
                value: _start,
                options: _startOptions,
                labelOf: hourLabel,
                onChanged: (h) => setState(() => _start = h),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: SheetSelect<double>(
                value: _dur,
                options: _durOptions,
                labelOf: _durLabel,
                onChanged: (d) => setState(() => _dur = d),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text.rich(
          TextSpan(
            text: 'Kết thúc lúc ',
            children: [
              TextSpan(
                text: hourLabel(_start + _dur),
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ],
          ),
          style: sheetHintStyle,
        ),
      ],
    );
  }

  /// Open-slot extras (Create + open only): max players + price/person.
  Widget _buildOpenExtras() {
    return Row(
      children: [
        Expanded(
          child: _field(
            'Số người tối đa',
            SheetNumberField(
              controller: _capController,
              onChanged: (v) => setState(() => _cap = int.tryParse(v) ?? 0),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _field(
            'Giá / người',
            SheetNumberField(
              controller: _priceController,
              onChanged: (v) => setState(() => _price = int.tryParse(v) ?? 0),
            ),
          ),
        ),
      ],
    );
  }

  /// "Lặp lại nhiều buổi" — BẬT/TẮT pill; when on: weekday toggles, weeks
  /// field and the batch preview card.
  Widget _buildRepeatSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Lặp lại nhiều buổi', style: sheetLabelStyle),
            ToggleButton(
              label: _repeat ? 'BẬT' : 'TẮT',
              on: _repeat,
              width: 46,
              height: 26,
              radius: 99,
              onTap: () => setState(() => _repeat = !_repeat),
            ),
          ],
        ),
        if (_repeat) ...[
          const SizedBox(height: 7),
          Text('Chọn các thứ trong tuần', style: sheetHintStyle),
          const SizedBox(height: 8),
          Row(
            children: [
              for (var i = 0; i < 7; i++) ...[
                if (i > 0) const SizedBox(width: 6),
                ToggleButton(
                  label: weekdayShortLabels[i],
                  on: _days.contains(i),
                  onTap: () => _toggleDay(i),
                ),
              ],
            ],
          ),
          const SizedBox(height: 14),
          _field(
            'Số tuần',
            SheetNumberField(
              controller: _weeksController,
              // `Math.max(1, +e.target.value)` in the jsx.
              onChanged: (v) => setState(() {
                final parsed = int.tryParse(v) ?? 1;
                _weeks = parsed < 1 ? 1 : parsed;
              }),
            ),
          ),
          const SizedBox(height: 12),
          BatchPreview(
            sessions: _sessions,
            days: _days,
            weeks: _weeks,
            start: _start,
            dur: _dur,
          ),
        ],
      ],
    );
  }

  /// `.drawer-foot` — "Huỷ" (flex 1) + primary submit (flex 2).
  Widget _buildFoot() {
    final submitLabel =
        _repeat ? 'Tạo $_sessions slot' : (_isBlock ? 'Khoá giờ' : 'Tạo slot');
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
      decoration: const BoxDecoration(
        color: AppColors.neutral50,
        border: Border(top: BorderSide(color: AppColors.neutral100)),
      ),
      child: Row(
        children: [
          Expanded(
            child: SheetButton(label: 'Huỷ', onTap: widget.onClose),
          ),
          const SizedBox(width: 10),
          Expanded(
            flex: 2,
            child: SheetButton(
              label: submitLabel,
              icon: _isBlock ? Icons.lock_outline : Icons.edit_calendar,
              primary: true,
              // Disabled while the label would read "Tạo 0 slot".
              onTap: _canSubmit ? _submit : null,
            ),
          ),
        ],
      ),
    );
  }

  /// "1.5" → "1.5 giờ", "2.0" → "2 giờ".
  static String _durLabel(double d) => '${d % 1 == 0 ? d.toInt() : d} giờ';
}
