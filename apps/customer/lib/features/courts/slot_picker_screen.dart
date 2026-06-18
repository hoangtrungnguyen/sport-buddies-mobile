import 'package:customer/features/courts/cubit/slot_picker_cubit.dart';
import 'package:customer/features/courts/widgets/slot_picker_venue.dart';
import 'package:customer/features/courts/widgets/slot_picker_group_slots.dart';
import 'package:customer/features/courts/widgets/slot_picker_dates.dart';
import 'package:customer/features/courts/widgets/slot_picker_grid.dart';
import 'package:customer/features/courts/widgets/slot_picker_misc.dart';
import 'package:customer/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
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
        title: Text(
          AppLocalizations.of(context).slotPickerTitle,
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF111827),
        elevation: 0,
        leading: BackButton(onPressed: () => context.pop()),
        actions: [
          IconButton(
            icon: const Icon(Icons.ios_share_outlined, size: 22),
            onPressed: () {},
          ),
        ],
      ),
      body: BlocBuilder<SlotPickerCubit, SlotPickerState>(
        builder: (context, state) => switch (state) {
          SlotPickerLoading() => const Center(
            child: CircularProgressIndicator(),
          ),
          SlotPickerError(:final message) => ErrorView(
            message: message,
            onRetry: () => context.read<SlotPickerCubit>().load(widget.courtId),
          ),
          SlotPickerLoaded(
            :final slots,
            :final pricePerHour,
            :final photos,
            :final groupSlots,
            :final address,
            :final courtName,
          ) =>
            _LoadedBody(
              courtId: widget.courtId,
              courtName: courtName ?? widget.courtName,
              courtAddress: address ?? widget.courtAddress,
              slots: slots,
              pricePerHour: pricePerHour,
              photos: photos,
              groupSlots: groupSlots,
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
    required this.photos,
    required this.groupSlots,
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
  final List<String> photos;
  final List<Slot> groupSlots;
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
    final l10n = AppLocalizations.of(context);
    final dates = _buildDates();
    final selectedDate = dates[selectedDateIndex];
    final daySlots = _slotsForDate(selectedDate);
    final selected = selectedSlotId != null
        ? slots.where((s) => s.id == selectedSlotId).firstOrNull
        : null;

    final durationMinutes = selected != null
        ? selected.endTime.difference(selected.startTime).inMinutes
        : 0;
    final totalPrice = selected != null && pricePerHour != null
        ? pricePerHour! * durationMinutes / 60
        : 0.0;

    return Stack(
      fit: StackFit.expand,
      children: [
        SingleChildScrollView(
          padding: EdgeInsets.only(
            bottom: 96 + MediaQuery.of(context).padding.bottom,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CourtContextLine(
                courtName: courtName,
                courtAddress: courtAddress,
              ),
              if (photos.isNotEmpty) VenuePhotosStrip(photos: photos),
              if (courtAddress != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
                  child: DirectionsCard(address: courtAddress!),
                ),
              DateTabRow(
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
                    Text(
                      l10n.wizardLabelSlots,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF111827),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      l10n.slotPickerTapSelect,
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
                  l10n.availabilityOpenSlots(
                    daySlots.where((s) => s.isAvailable).length,
                  ),
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ),
              if (daySlots.isEmpty)
                const EmptySlots()
              else
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: SlotGrid(
                    slots: daySlots,
                    pricePerHour: pricePerHour,
                    selectedSlotId: selectedSlotId,
                    onTap: onToggle,
                  ),
                ),
              if (groupSlots.isNotEmpty)
                GroupSlotsSection(groupSlots: groupSlots, courtId: courtId),
            ],
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: BottomCta(
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
