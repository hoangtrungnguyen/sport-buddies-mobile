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
      child: const Scaffold(
        backgroundColor: mdN50,
        body: _DiscoveryContent(),
      ),
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
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      builder: (context, mapState) {
        return BlocBuilder<DiscoveryFilterCubit, DiscoveryFilterState>(
          builder: (context, filterState) {
            final userPos = _getUserPos(context);
            final allCourts =
                mapState is DiscoveryLoaded ? mapState.courts : <CourtAvailability>[];
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
              listCourts.sort((a, b) => courtDistanceKm(a, userPos)!
                  .compareTo(courtDistanceKm(b, userPos)!));
            }

            final openSlots =
                filtered.fold(0, (sum, c) => sum + c.openSlotCount);
            final isLoading = mapState is DiscoveryLoading || mapState is DiscoveryInitial;
            final isEmpty = mapState is DiscoveryLoaded && filtered.isEmpty;
            final isAllFull = mapState is DiscoveryLoaded &&
                filtered.isNotEmpty &&
                filtered.every((c) => c.openSlotCount == 0);

            return Stack(
              children: [
                Column(
                  children: [
                    _DiscoveryHeader(
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
      return _EmptyState(
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
          _AllFullBanner(
            courtCount: courts.length,
            onSlots: () => context.go('/slots'),
          ),
          const SizedBox(height: 12),
        ],
        _CountLine(courtCount: courts.length, openSlots: openSlots),
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
      final state =
          BlocProvider.of<LocationCubit>(context, listen: false).state;
      if (state is LocationLoaded && !state.isDefault) {
        return LatLng(state.center.latitude, state.center.longitude);
      }
    } catch (_) {}
    return null;
  }
}

// ---------------------------------------------------------------------------
// _DiscoveryHeader
// ---------------------------------------------------------------------------

class _DiscoveryHeader extends StatelessWidget {
  const _DiscoveryHeader({
    required this.courtCount,
    required this.openSlots,
    required this.isLoading,
    required this.isEmpty,
    required this.onSearch,
    required this.onOpenFilter,
    required this.onNotifications,
  });

  final int courtCount;
  final int openSlots;
  final bool isLoading;
  final bool isEmpty;
  final VoidCallback onSearch;
  final VoidCallback onOpenFilter;
  final VoidCallback onNotifications;

  String _subtitle(AppLocalizations l10n) {
    if (isLoading) return l10n.discoveryUpdating;
    if (isEmpty) return l10n.discoveryNoMatch;
    return l10n.discoverySubtitle(courtCount, openSlots);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final topPad = MediaQuery.of(context).padding.top;
    return Container(
      color: mdSurface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(16, topPad + 12, 8, 0),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.discoveryTitle,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: mdOnSurface,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _subtitle(l10n),
                        style: const TextStyle(
                          fontSize: 12,
                          color: mdOnSurfaceVariant,
                          height: 1.4,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                _HeaderIconButton(
                  label: l10n.commonFilter,
                  icon: Icons.tune,
                  onTap: onOpenFilter,
                ),
                const SizedBox(width: 8),
                _HeaderIconButton(
                  label: l10n.commonSearch,
                  icon: Icons.search,
                  onTap: onSearch,
                ),
                const SizedBox(width: 8),
                _HeaderIconButton(
                  label: l10n.commonNotifications,
                  icon: Icons.notifications_none,
                  onTap: onNotifications,
                ),
                const SizedBox(width: 8),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Container(height: 1, color: mdOutlineVariant),
        ],
      ),
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  const _HeaderIconButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: label,
      button: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(99),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: mdOutlineVariant),
            color: mdSurface,
          ),
          child: Icon(icon, size: 20, color: mdOnSurfaceVariant),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// _CountLine
// ---------------------------------------------------------------------------

class _CountLine extends StatelessWidget {
  const _CountLine({required this.courtCount, required this.openSlots});

  final int courtCount;
  final int openSlots;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: l10n.discoveryCourtsCount(courtCount),
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: mdOnSurfaceVariant,
                ),
              ),
              TextSpan(
                text: ' · ${l10n.availabilityOpenSlots(openSlots)}',
                style: const TextStyle(
                  fontSize: 13,
                  color: mdOnSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        Text(
          l10n.discoverySortNearest,
          style: const TextStyle(fontSize: 13, color: mdOnSurfaceVariant),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// _AllFullBanner
// ---------------------------------------------------------------------------

class _AllFullBanner extends StatelessWidget {
  const _AllFullBanner({required this.courtCount, required this.onSlots});

  final int courtCount;
  final VoidCallback onSlots;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        color: warningBg,
        border: Border.all(color: warningBorder),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: Color(0xFFF59E0B),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              l10n.discoveryAllFullTitle,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: warningText,
              ),
            ),
          ),
          GestureDetector(
            onTap: onSlots,
            child: Text(
              l10n.discoveryAllFullAction,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: warningText,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// _EmptyState (doc 02 §6)
// ---------------------------------------------------------------------------

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.onlyOpen,
    required this.onExpand,
    required this.onReset,
  });

  final bool onlyOpen;
  final VoidCallback onExpand;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(32, 0, 32, 60),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(
                color: mdSurfaceContainerHigh,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.search_off,
                  size: 32, color: mdOnSurfaceVariant),
            ),
            const SizedBox(height: 12),
            Text(
              onlyOpen ? l10n.discoveryEmptyNoOpen : l10n.discoveryEmptyNoCourts,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: mdOnSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              l10n.discoveryEmptyBody,
              style: const TextStyle(
                  fontSize: 13, color: mdOnSurfaceVariant, height: 1.4),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onExpand,
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: mdOutlineVariant),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(mdCornerFull),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(
                      l10n.discoveryEmptyExpand,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: mdOnSurfaceVariant,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton(
                    onPressed: onReset,
                    style: FilledButton.styleFrom(
                      backgroundColor: mdPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(mdCornerFull),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(
                      l10n.discoveryEmptyResetFilters,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: mdOnPrimary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

