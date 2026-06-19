// Discovery list screen — EPIC-4 Court Discovery (SPB-030)
//
// The primary discovery surface: nearby courts as cards, nearest-first.
// Replaces the former map screen as the `/` (Khám phá) tab.
//
//   - Header: "Khám phá" + live count subtitle + filter icon + search icon.
//   - Chip rail: "Tất cả" + sport quick-chips (kept in sync with the sheet).
//   - Body: count line, court cards (distance-sorted), all-full banner,
//     empty state, footer line.
//   - Tap a card → PeekSheet slides up → "Xem sân & đặt" hands off to EPIC-5.
//   - Filter sheet uses a draft so nothing applies until the CTA.
//   - Full-screen search overlay over name, distance-sorted.
//
// State is reused from the map feature (framework-agnostic):
//   DiscoveryCubit (court availability) · DiscoveryFilterCubit (filters) · LocationCubit.

import 'package:customer/features/discovery/cubit/discovery_cubit.dart';
import 'package:customer/features/discovery/discovery_style.dart';
import 'package:customer/features/discovery/widgets/court_card.dart';
import 'package:customer/features/discovery/widgets/filter_sheet.dart';
import 'package:customer/features/discovery/widgets/search_overlay.dart';
import 'package:customer/features/discovery/widgets/discovery_header.dart';
import 'package:customer/features/discovery/widgets/discovery_sections.dart';
import 'package:customer/l10n/app_localizations.dart';
import 'package:customer/features/discovery/location_cubit.dart';
import 'package:customer/features/discovery/location_state.dart';
import 'package:customer/features/discovery/discovery_filter_cubit.dart';
import 'package:customer/features/discovery/discovery_filter_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:spb_core/spb_core.dart';

// ---------------------------------------------------------------------------
// DiscoveryListScreen
// ---------------------------------------------------------------------------

class DiscoveryListScreen extends StatelessWidget {
  const DiscoveryListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => DiscoveryFilterCubit(),
      child: const Scaffold(backgroundColor: mdN50, body: _DiscoveryContent()),
    );
  }
}

// ---------------------------------------------------------------------------
// _DiscoveryContent — main stateful body
// ---------------------------------------------------------------------------

class _DiscoveryContent extends StatefulWidget {
  const _DiscoveryContent();

  @override
  State<_DiscoveryContent> createState() => _DiscoveryContentState();
}

class _DiscoveryContentState extends State<_DiscoveryContent> {
  bool _searchOpen = false;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<DiscoveryCubit, DiscoveryState>(
      listener: (context, state) {
        if (state is DiscoveryError) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      builder: (context, mapState) {
        return BlocBuilder<DiscoveryFilterCubit, DiscoveryFilterState>(
          builder: (context, filterState) {
            final userPos = _getUserPos(context);
            final allCourts = mapState is DiscoveryLoaded
                ? mapState.courts
                : <CourtAvailability>[];
            final filtered = mapState is DiscoveryLoaded
                ? mapState.applyFilter(
                    sports: filterState.selectedSports,
                    maxDistanceKm: filterState.maxDistanceKm,
                    userPos: userPos,
                    onlyWithOpenSlots: filterState.onlyWithOpenSlots,
                  )
                : <CourtAvailability>[];

            // Single source of truth: distance-sorted (nearest first).
            final listCourts = [...filtered];
            if (userPos != null) {
              listCourts.sort(
                (a, b) => courtDistanceKm(
                  a,
                  userPos,
                )!.compareTo(courtDistanceKm(b, userPos)!),
              );
            }

            final openSlots = filtered.fold(
              0,
              (sum, c) => sum + c.openSlotCount,
            );
            final isLoading =
                mapState is DiscoveryLoading || mapState is DiscoveryInitial;
            final isEmpty = mapState is DiscoveryLoaded && filtered.isEmpty;
            final isAllFull =
                mapState is DiscoveryLoaded &&
                filtered.isNotEmpty &&
                filtered.every((c) => c.openSlotCount == 0);

            return Stack(
              children: [
                Column(
                  children: [
                    DiscoveryHeader(
                      courtCount: filtered.length,
                      openSlots: openSlots,
                      isLoading: isLoading,
                      isEmpty: isEmpty,
                      onSearch: () => setState(() => _searchOpen = true),
                      onOpenFilter: () =>
                          _showFilterSheet(context, allCourts, userPos),
                      onNotifications: () => context.push('/notifications'),
                    ),
                    Expanded(
                      child: _buildBody(
                        context: context,
                        isLoading: isLoading,
                        isEmpty: isEmpty,
                        isAllFull: isAllFull,
                        onlyOpen: filterState.onlyWithOpenSlots,
                        courts: listCourts,
                        openSlots: openSlots,
                        userPos: userPos,
                      ),
                    ),
                  ],
                ),
                // ── search overlay ────────────────────────────────────────
                if (_searchOpen)
                  Positioned.fill(
                    child: SearchOverlay(
                      userPos: userPos,
                      onBack: () => setState(() => _searchOpen = false),
                      onTapCourt: (court) {
                        setState(() => _searchOpen = false);
                        context.push('/browse/court/${court.courtId}');
                      },
                    ),
                  ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildBody({
    required BuildContext context,
    required bool isLoading,
    required bool isEmpty,
    required bool isAllFull,
    required bool onlyOpen,
    required List<CourtAvailability> courts,
    required int openSlots,
    required LatLng? userPos,
  }) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator(color: mdPrimary));
    }
    if (isEmpty) {
      return EmptyState(
        onlyOpen: onlyOpen,
        onExpand: () {
          final cubit = context.read<DiscoveryFilterCubit>();
          cubit.filterByDistance(5.0);
          if (cubit.state.onlyWithOpenSlots) cubit.toggleOnlyOpenSlots();
        },
        onReset: () => context.read<DiscoveryFilterCubit>().clearAll(),
      );
    }
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 150),
      children: [
        if (isAllFull) ...[
          AllFullBanner(
            courtCount: courts.length,
            onSlots: () => context.go('/slots'),
          ),
          const SizedBox(height: 12),
        ],
        CountLine(courtCount: courts.length, openSlots: openSlots),
        const SizedBox(height: 10),
        ...courts.map(
          (c) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: CourtCard(
              court: c,
              distanceKm: courtDistanceKm(c, userPos),
              onTap: () => context.push('/browse/court/${c.courtId}'),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Center(
          child: Text(
            AppLocalizations.of(context).discoveryFooterEnd,
            style: const TextStyle(fontSize: 12, color: Color(0xFF9AA3AF)),
          ),
        ),
      ],
    );
  }

  static void _showFilterSheet(
    BuildContext ctx,
    List<CourtAvailability> courts,
    LatLng? userPos,
  ) {
    final filterCubit = ctx.read<DiscoveryFilterCubit>();
    showModalBottomSheet<void>(
      context: ctx,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => FilterSheet(
        initialState: filterCubit.state,
        courts: courts,
        userPos: userPos,
        onApply: (newState) => filterCubit.setAll(newState),
      ),
    );
  }

  static LatLng? _getUserPos(BuildContext context) {
    try {
      final state = BlocProvider.of<LocationCubit>(
        context,
        listen: false,
      ).state;
      if (state is LocationLoaded && !state.isDefault) {
        return LatLng(state.center.latitude, state.center.longitude);
      }
    } catch (_) {}
    return null;
  }
}
