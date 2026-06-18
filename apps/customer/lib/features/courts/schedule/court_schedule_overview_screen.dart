import 'package:customer/core/services/booking_api_client.dart';
import 'package:customer/features/courts/schedule/cubit/court_schedule_overview_cubit.dart';
import 'package:customer/features/courts/schedule/cubit/court_schedule_overview_state.dart';
import 'package:customer/features/courts/schedule/court_schedule_style.dart';
import 'package:customer/features/courts/schedule/widgets/schedule_date_tabs.dart';
import 'package:customer/features/courts/schedule/widgets/schedule_grid.dart';
import 'package:customer/features/courts/schedule/widgets/schedule_legend.dart';
import 'package:customer/features/courts/schedule/widgets/schedule_selection_cart.dart';
import 'package:customer/features/courts/schedule/widgets/schedule_empty_states.dart';
import 'package:customer/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

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
          kVenueName,
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
          CourtScheduleOverviewLoading() => const Center(
            child: CircularProgressIndicator(),
          ),
          CourtScheduleOverviewFailure(message: final msg) => Center(
            child: Text(msg, style: const TextStyle(color: Color(0xFF6B7280))),
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
    final l10n = AppLocalizations.of(context);
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
                child: Text(
                  l10n.scheduleAllCourts,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ),
              DateTabRow(
                dates: state.dates,
                selectedIndex: state.selectedDateIndex,
                onTap: cubit.selectDate,
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
                child: Text(
                  _dateHeading(l10n, selectedDate),
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
                child: ScheduleGrid(
                  courts: state.courts,
                  hours: state.hours,
                  slots: state.currentSlots,
                  selected: state.currentDateSelection,
                  onTap: cubit.toggleSlot,
                ),
              ),
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 14, 16, 8),
                child: Legend(),
              ),
              if (!hasSelection)
                const Padding(
                  padding: EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: EmptyHintCard(),
                ),
            ],
          ),
        ),
        Positioned(
          left: 12,
          right: 12,
          bottom: 12 + MediaQuery.of(context).padding.bottom,
          child: hasSelection
              ? SelectionCart(
                  groups: groups,
                  count: state.totalSelectedCount,
                  total: state.grandTotal,
                  onClearAll: cubit.clearAll,
                  onContinue: () {
                    // Wire to booking wizard step 1 later.
                  },
                )
              : const EmptyCta(),
        ),
      ],
    );
  }

  static String _dateHeading(AppLocalizations l10n, DateTime d) {
    final today = DateTime.now();
    final isToday =
        d.year == today.year && d.month == today.month && d.day == today.day;
    final dd = d.day.toString().padLeft(2, '0');
    final mm = d.month.toString().padLeft(2, '0');
    if (isToday) return '${l10n.scheduleToday}, $dd/$mm';
    return '${fullWeekday(l10n, d.weekday)}, $dd/$mm';
  }
}
