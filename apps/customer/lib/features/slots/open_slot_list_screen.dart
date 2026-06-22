// M3 "Slot trống" — open group slot discovery screen (SPB-034/035).
// Design: EPIC-4 Slot Detail · Material 3 · M3DiscoverSlots component.

import 'package:customer/core/l10n/error_messages.dart';
import 'package:customer/features/slots/cubit/open_slot_list_cubit.dart';
import 'package:customer/features/slots/slots_style.dart';
import 'package:customer/features/slots/widgets/open_slot_header.dart';
import 'package:customer/features/slots/widgets/open_slot_body.dart';
import 'package:customer/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spb_core/spb_core.dart';

class OpenSlotListScreen extends StatefulWidget {
  const OpenSlotListScreen({super.key});

  @override
  State<OpenSlotListScreen> createState() => _OpenSlotListScreenState();
}

class _OpenSlotListScreenState extends State<OpenSlotListScreen> {
  int _selectedFilter = 0;

  @override
  void initState() {
    super.initState();
    context.read<SlotListCubit>().loadAllGroupSlots();
  }

  List<Slot> _filtered(List<Slot> slots) {
    if (_selectedFilter == 0) return slots;
    final sport = [
      'football',
      'pickleball',
      'badminton',
      'tennis',
    ][_selectedFilter - 1];
    return slots.where((s) => s.sportType == sport).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: mdSurface,
      body: Column(
        children: [
          Header(
            selectedFilter: _selectedFilter,
            onFilterSelected: (i) => setState(() => _selectedFilter = i),
          ),
          Expanded(
            child: BlocBuilder<SlotListCubit, SlotListState>(
              builder: (context, state) => switch (state) {
                SlotListInitial() || SlotListLoading() => const Center(
                  child: CircularProgressIndicator(),
                ),
                SlotListError(message: final msg) => ErrorView(
                  message: appErrorMessage(AppLocalizations.of(context), msg),
                ),
                SlotListLoaded(slots: final slots) => RefreshIndicator(
                  color: mdPrimary,
                  onRefresh: () =>
                      context.read<SlotListCubit>().loadAllGroupSlots(),
                  child: SlotBody(slots: _filtered(slots)),
                ),
              },
            ),
          ),
        ],
      ),
    );
  }
}
