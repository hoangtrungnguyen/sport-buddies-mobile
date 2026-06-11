import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../data/court_repository.dart';
import '../data/fake_court_repository.dart';
import '../data/fake_slot_repository.dart';
import '../domain/court.dart';
import '../domain/schedule.dart';
import '../domain/time_slot.dart';
import '../theme/app_tokens.dart';
import '../theme/browse_pick_theme.dart';
import 'widgets/date_tabs.dart';
import 'widgets/open_slot_section.dart';

/// Screen 09 · Slot picker (handoff SPB-041).
class SlotPickerPage extends StatefulWidget {
  const SlotPickerPage({
    super.key,
    required this.courtId,
    this.courtRepository,
    this.slotRepository,
  });

  final String courtId;
  final CourtRepository? courtRepository;
  final SlotRepository? slotRepository;

  @override
  State<SlotPickerPage> createState() => _SlotPickerPageState();
}

class _SlotPickerPageState extends State<SlotPickerPage> {
  late final CourtRepository _courtRepo =
      widget.courtRepository ?? FakeCourtRepository();
  late final SlotRepository _slotRepo =
      widget.slotRepository ?? FakeSlotRepository();

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
    if (mounted) setState(() {
      _court = court;
      _groupSlots = groups;
    });
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

  // E9: external maps intent is out of scope this milestone — the handoff
  // sanctions a "Sắp ra mắt" snackbar fallback (doc 03 §E9).
  void _directions() => _snack('Chỉ đường — sắp ra mắt');

  void _snack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final court = _court;
    return BrowsePickTheme(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Chọn giờ'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            tooltip: 'Quay lại',
            onPressed: () => context.pop(),
          ),
        ),
        body: court == null
            ? const Center(child: CircularProgressIndicator())
            : _buildBody(court),
        bottomNavigationBar: _BottomCartBar(
          selection: _selection,
          onContinue: _selection.isEmpty
              ? null
              : () => context.push('/browse/booking/confirm'),
        ),
      ),
    );
  }

  Widget _buildBody(Court court) {
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final slots = _slots;
    final openCount = slots?.where((s) => s.isOpen).length ?? 0;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      children: [
        Text('${court.name} · ${_courtLabel(widget.courtId)}',
            style: text.bodySmall?.copyWith(color: scheme.onSurfaceVariant)),
        const SizedBox(height: 12),
        const _PhotoStrip(),
        const SizedBox(height: 10),
        _DirectionsCard(court: court, onTap: _directions),
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
            Text('Khung giờ', style: text.titleMedium),
            const Spacer(),
            Text('Chạm để chọn nhiều khung',
                style: text.bodySmall?.copyWith(color: scheme.onSurfaceVariant)),
          ],
        ),
        const SizedBox(height: 2),
        Text('$openCount slot trống · có thể đặt liên tiếp',
            style: text.bodySmall?.copyWith(color: scheme.onSurfaceVariant)),
        const SizedBox(height: 12),
        if (slots == null)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 48),
            child: Center(child: CircularProgressIndicator()),
          )
        else
          _SlotGrid(
            slots: slots,
            selection: _selection,
            onToggle: _toggleSlot,
          ),
        const SizedBox(height: 28),
        OpenSlotSection(
          slots: _groupSlots,
          helper: 'Chạm để xem chi tiết & xin chơi cùng',
          trailing: OpenSlotTrailing.chevron,
        ),
      ],
    );
  }
}

// ── §13 Photo strip ──────────────────────────────────────────────────────────

class _PhotoStrip extends StatelessWidget {
  const _PhotoStrip();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 118,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.zero,
        itemCount: 5,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) => ClipRRect(
          borderRadius: AppTokens.radiusLg,
          child: SizedBox(
            width: i == 0 ? 200 : 150,
            child: const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF16A34A), Color(0xFF0EA5E9)],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── §14 Directions card → external maps (edge E9) ────────────────────────────

class _DirectionsCard extends StatelessWidget {
  const _DirectionsCard({required this.court, required this.onTap});

  final Court court;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return Material(
      color: scheme.surfaceContainerLowest,
      borderRadius: AppTokens.radiusMd,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: AppTokens.radiusMd,
            border: Border.all(color: scheme.outlineVariant),
          ),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  width: 92,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFFDCFCE7), Color(0xFFBFDBFE)],
                    ),
                  ),
                  child: Icon(Icons.location_on, color: scheme.error, size: 28),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(court.address,
                            style: text.labelLarge,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 4),
                        Text(
                          '${court.distanceKm.toStringAsFixed(1)} km · ~6 phút lái xe',
                          style: text.bodySmall?.copyWith(
                            color: scheme.onSurfaceVariant,
                            fontFeatures: AppTokens.tnum,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.navigation_outlined,
                                size: 16, color: scheme.primary),
                            const SizedBox(width: 4),
                            Text('Chỉ đường',
                                style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: scheme.primary)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Center(
                    child: Icon(Icons.chevron_right,
                        color: scheme.onSurfaceVariant),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── §15 Slot grid (numbered multi-select) ────────────────────────────────────

class _SlotGrid extends StatelessWidget {
  const _SlotGrid({
    required this.slots,
    required this.selection,
    required this.onToggle,
  });

  final List<TimeSlot> slots;
  final List<TimeSlot> selection;
  final void Function(TimeSlot) onToggle;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 2.4,
      children: [
        for (final slot in slots)
          _SlotCell(
            slot: slot,
            order: selection.indexWhere((s) => s.id == slot.id),
            onTap: slot.isOpen ? () => onToggle(slot) : null,
          ),
      ],
    );
  }
}

class _SlotCell extends StatelessWidget {
  const _SlotCell({required this.slot, required this.order, this.onTap});

  final TimeSlot slot;

  /// Index in the selection list, or -1 if not selected.
  final int order;
  final VoidCallback? onTap;

  static String _hhmm(DateTime t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final selected = order >= 0;
    final timeLabel = '${_hhmm(slot.start)} – ${_hhmm(slot.end)}';
    final priceLabel = '${(slot.priceVnd / 1000).round()}k';
    final inert = !slot.isOpen;

    late final Color bg;
    late final BoxBorder border;
    if (selected) {
      bg = scheme.primaryContainer;
      border = Border.all(color: scheme.primary, width: 2);
    } else if (inert) {
      bg = scheme.surfaceContainer.withValues(alpha: 0.6);
      border = Border.all(color: scheme.outlineVariant);
    } else {
      bg = scheme.surfaceContainerLowest;
      border = Border.all(color: scheme.outlineVariant);
    }

    final timeColor = selected
        ? scheme.onPrimaryContainer
        : inert
            ? scheme.onSurfaceVariant
            : scheme.onSurface;

    return InkWell(
      onTap: onTap,
      borderRadius: AppTokens.radiusMd,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: AppTokens.radiusMd,
          border: border,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                if (selected) ...[
                  Container(
                    width: 20,
                    height: 20,
                    alignment: Alignment.center,
                    decoration:
                        BoxDecoration(color: scheme.primary, shape: BoxShape.circle),
                    child: Text(
                      '${order + 1}',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: scheme.onPrimary,
                        fontFeatures: AppTokens.tnum,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                ],
                Expanded(
                  child: Text(
                    timeLabel,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: timeColor,
                      fontFeatures: AppTokens.tnum,
                      decoration: slot.status == CellStatus.booked
                          ? TextDecoration.lineThrough
                          : null,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Text(
                  priceLabel,
                  style: TextStyle(
                    fontFamily: 'Sora',
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: timeColor,
                    fontFeatures: AppTokens.tnum,
                  ),
                ),
                if (inert) ...[
                  const Spacer(),
                  Text(
                    slot.status == CellStatus.booked ? 'Đã đặt' : 'Đóng',
                    style: TextStyle(
                      fontSize: 12,
                      color: slot.status == CellStatus.booked
                          ? scheme.error
                          : scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── §16 Sticky bottom cart bar (edge E11) ────────────────────────────────────

class _BottomCartBar extends StatelessWidget {
  const _BottomCartBar({required this.selection, required this.onContinue});

  final List<TimeSlot> selection;
  final VoidCallback? onContinue;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final count = selection.length;
    final total = selection.fold<int>(0, (s, e) => s + e.priceVnd);
    final minutes =
        selection.fold<int>(0, (m, e) => m + e.duration.inMinutes);
    final hours = (minutes / 60);
    final hoursLabel =
        hours == hours.roundToDouble() ? hours.toStringAsFixed(0) : hours.toStringAsFixed(1);
    final enabled = onContinue != null;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        border: Border(top: BorderSide(color: scheme.outlineVariant)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    count == 0
                        ? 'Chưa chọn khung'
                        : '$count khung đã chọn · $hoursLabel giờ',
                    style: text.bodySmall
                        ?.copyWith(color: scheme.onSurfaceVariant),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    count == 0 ? '—' : '${_thousands(total)} đ',
                    style: text.priceMedium(scheme),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            FilledButton(
              onPressed: onContinue,
              style: FilledButton.styleFrom(
                minimumSize: const Size(0, AppTokens.buttonStickyHeight),
                padding: const EdgeInsets.symmetric(horizontal: 24),
              ),
              child: Text(enabled ? 'Tiếp tục · $count khung' : 'Chọn khung giờ'),
            ),
          ],
        ),
      ),
    );
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

/// Court short label for the breadcrumb (the fake court carries the venue
/// name; the picker shows which court within it).
String _courtLabel(String courtId) => switch (courtId) {
      'court-b' => 'Sân B',
      'court-c' => 'Sân C',
      _ => 'Sân A',
    };
