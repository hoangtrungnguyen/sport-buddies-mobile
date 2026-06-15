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
// Design tokens — Material Design 3 surface/color scale (SportBuddies brand)
// ---------------------------------------------------------------------------
const _mdSurface = Color(0xFFF7FBF2); // header bg (greenish tinted)
const _mdOnSurface = Color(0xFF181D17); // primary text
const _mdOnSurfaceVariant = Color(0xFF42493F); // secondary text
const _mdSurfaceContainerLowest = Color(0xFFFFFFFF); // peek/card bg
const _mdSurfaceContainerLow = Color(0xFFF1F6EC); // filter sheet bg
const _mdSurfaceContainerHigh = Color(0xFFE5EAE1); // full badge bg
const _mdSurfaceContainerHighest = Color(0xFFDFE4DA); // search bar bg
const _mdPrimary = Color(0xFF15803D);
const _mdOnPrimary = Color(0xFFFFFFFF);
const _mdPrimaryContainer = Color(0xFFC9F2D2); // active chip bg
const _mdOnPrimaryContainer = Color(0xFF00210B); // active chip text
const _mdOutline = Color(0xFF72796C);
const _mdOutlineVariant = Color(0xFFC2C8BB); // chip border, divider
const _mdN50 = Color(0xFFF3F6F0); // list body bg

// MD3 shape scale
const _mdCornerSm = 8.0; // chips, badges
const _mdCornerMd = 12.0; // thumbnails
const _mdCornerLg = 16.0; // cards
const _mdCornerXl = 28.0; // bottom sheets
const double _mdCornerFull = 9999.0; // buttons, pills

// Warning palette — all-full banner
const _warningBg = Color(0xFFFEF9C3);
const _warningBorder = Color(0xFFFDE68A);
const _warningText = Color(0xFF92670B);

// ---------------------------------------------------------------------------
// Per-sport accent (doc 01 §5)
// ---------------------------------------------------------------------------
Color _sportColor(List<String> sportTypes) {
  final t = (sportTypes.firstOrNull ?? '').toLowerCase();
  return switch (t) {
    'football' || 'bóng đá' || 'bóng đá 5v5' => const Color(0xFF16A34A),
    'pickleball' => const Color(0xFF0EA5E9),
    'badminton' || 'cầu lông' => const Color(0xFFEF4444),
    'tennis' => const Color(0xFFEAB308),
    _ => _mdOnSurfaceVariant,
  };
}

IconData _sportIcon(List<String> sportTypes) {
  final t = (sportTypes.firstOrNull ?? '').toLowerCase();
  return switch (t) {
    'football' || 'bóng đá' || 'bóng đá 5v5' => Icons.sports_soccer,
    'badminton' || 'cầu lông' => Icons.sports_tennis,
    'pickleball' => Icons.sports_tennis,
    'tennis' => Icons.sports_tennis,
    _ => Icons.sports,
  };
}

/// Distance in km from [userPos] to the court, or null when location is
/// unavailable. Rounded for display.
double? _distanceKm(CourtAvailability c, LatLng? userPos) {
  if (userPos == null) return null;
  return userPos.distanceTo(LatLng(c.lat, c.lng));
}

String _formatKm(double km) =>
    km < 10 ? km.toStringAsFixed(1) : km.toStringAsFixed(0);

/// Localized label for a sport filter slug ('' = all). Falls back to the raw
/// slug for unknown values.
String _sportLabelFor(AppLocalizations l10n, String slug) => switch (slug) {
      '' => l10n.sportAll,
      'football' => l10n.sportFootball,
      'pickleball' => l10n.sportPickleball,
      'badminton' => l10n.sportBadminton,
      'tennis' => l10n.sportTennis,
      'multi' => l10n.sportMulti,
      _ => slug,
    };

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
        backgroundColor: _mdN50,
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
              listCourts.sort((a, b) => _distanceKm(a, userPos)!
                  .compareTo(_distanceKm(b, userPos)!));
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
                    child: _SearchOverlay(
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
      return const Center(child: CircularProgressIndicator(color: _mdPrimary));
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
            child: _CourtCard(
              court: c,
              distanceKm: _distanceKm(c, userPos),
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
      builder: (_) => _FilterSheet(
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
      color: _mdSurface,
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
                          color: _mdOnSurface,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _subtitle(l10n),
                        style: const TextStyle(
                          fontSize: 12,
                          color: _mdOnSurfaceVariant,
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
          Container(height: 1, color: _mdOutlineVariant),
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
            border: Border.all(color: _mdOutlineVariant),
            color: _mdSurface,
          ),
          child: Icon(icon, size: 20, color: _mdOnSurfaceVariant),
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
                  color: _mdOnSurfaceVariant,
                ),
              ),
              TextSpan(
                text: ' · ${l10n.availabilityOpenSlots(openSlots)}',
                style: const TextStyle(
                  fontSize: 13,
                  color: _mdOnSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        Text(
          l10n.discoverySortNearest,
          style: const TextStyle(fontSize: 13, color: _mdOnSurfaceVariant),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// _CourtCard — list row (doc 02 §2)
// ---------------------------------------------------------------------------

class _CourtCard extends StatelessWidget {
  const _CourtCard({
    required this.court,
    required this.distanceKm,
    required this.onTap,
  });

  final CourtAvailability court;
  final double? distanceKm;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final hasSlots = court.openSlotCount > 0;
    final sportColor = _sportColor(court.sportTypes);
    final sportLabel = court.sportTypes.firstOrNull ?? l10n.sportGeneric;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _mdSurfaceContainerLowest,
          borderRadius: BorderRadius.circular(_mdCornerLg),
          border: Border.all(color: _mdOutlineVariant),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0F000000),
              blurRadius: 3,
              offset: Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Leading sport tile with sport-label chip
            SizedBox(
              width: 84,
              height: 84,
              child: Stack(
                children: [
                  Opacity(
                    opacity: hasSlots ? 1 : 0.7,
                    child: Container(
                      width: 84,
                      height: 84,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [sportColor, sportColor.withAlpha(204)],
                        ),
                        borderRadius: BorderRadius.circular(_mdCornerMd),
                      ),
                      child: Icon(
                        _sportIcon(court.sportTypes),
                        size: 34,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Positioned(
                    left: 6,
                    bottom: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(235),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        sportLabel,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF2B2F28),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            // Body
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          court.name,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: hasSlots
                                ? _mdOnSurface
                                : _mdOnSurfaceVariant,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      _AvailabilityBadge(openSlotCount: court.openSlotCount),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.place_outlined,
                          size: 16, color: Color(0xFF9AA3AF)),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          sportLabel,
                          style: const TextStyle(
                            fontSize: 13,
                            color: _mdOnSurfaceVariant,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (distanceKm != null) ...[
                        const Text(
                          ' · ',
                          style: TextStyle(
                              fontSize: 13, color: _mdOnSurfaceVariant),
                        ),
                        Text(
                          l10n.distanceKm(_formatKm(distanceKm!)),
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF42493F),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AvailabilityBadge extends StatelessWidget {
  const _AvailabilityBadge({required this.openSlotCount});

  final int openSlotCount;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final hasSlots = openSlotCount > 0;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: hasSlots ? _mdPrimaryContainer : _mdSurfaceContainerHigh,
        borderRadius: BorderRadius.circular(_mdCornerSm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: hasSlots ? _mdPrimary : _mdOutline,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            hasSlots
                ? l10n.availabilityOpenSlots(openSlotCount)
                : l10n.availabilityFull,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: hasSlots ? _mdOnPrimaryContainer : _mdOnSurfaceVariant,
            ),
          ),
        ],
      ),
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
        color: _warningBg,
        border: Border.all(color: _warningBorder),
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
                color: _warningText,
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
                color: _warningText,
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
                color: _mdSurfaceContainerHigh,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.search_off,
                  size: 32, color: _mdOnSurfaceVariant),
            ),
            const SizedBox(height: 12),
            Text(
              onlyOpen ? l10n.discoveryEmptyNoOpen : l10n.discoveryEmptyNoCourts,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: _mdOnSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              l10n.discoveryEmptyBody,
              style: const TextStyle(
                  fontSize: 13, color: _mdOnSurfaceVariant, height: 1.4),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onExpand,
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: _mdOutlineVariant),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(_mdCornerFull),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(
                      l10n.discoveryEmptyExpand,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: _mdOnSurfaceVariant,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton(
                    onPressed: onReset,
                    style: FilledButton.styleFrom(
                      backgroundColor: _mdPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(_mdCornerFull),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(
                      l10n.discoveryEmptyResetFilters,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: _mdOnPrimary,
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

// ---------------------------------------------------------------------------
// _FilterSheet — draft state, live count CTA (doc 02 screen 03)
// ---------------------------------------------------------------------------

// Sport filter slugs ('' = all); labels resolved via [_sportLabelFor].
const _kFilterSportSlugs = ['', 'football', 'pickleball', 'badminton', 'tennis', 'multi'];

const _kDistanceOptions = [1.0, 3.0, 5.0];

class _FilterSheet extends StatefulWidget {
  const _FilterSheet({
    required this.initialState,
    required this.courts,
    required this.userPos,
    required this.onApply,
  });

  final DiscoveryFilterState initialState;
  final List<CourtAvailability> courts;
  final LatLng? userPos;
  final void Function(DiscoveryFilterState) onApply;

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  late Set<String> _sports;
  late double? _distance;
  late bool _onlyOpen;

  @override
  void initState() {
    super.initState();
    _sports = Set.from(widget.initialState.selectedSports);
    _distance = widget.initialState.maxDistanceKm;
    _onlyOpen = widget.initialState.onlyWithOpenSlots;
  }

  int get _draftCount {
    final userPos = widget.userPos;
    return widget.courts.where((c) {
      if (_onlyOpen && c.openSlotCount == 0) return false;
      if (_sports.isNotEmpty && !c.sportTypes.any(_sports.contains)) {
        return false;
      }
      if (_distance != null && userPos != null) {
        final courtPos = LatLng(c.lat, c.lng);
        if (!userPos.isWithinRadius(courtPos, _distance!)) return false;
      }
      return true;
    }).length;
  }

  void _apply() {
    widget.onApply(DiscoveryFilterState(
      selectedSports: Set.from(_sports),
      maxDistanceKm: _distance,
      onlyWithOpenSlots: _onlyOpen,
    ));
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final count = _draftCount;
    return Container(
      decoration: const BoxDecoration(
        color: _mdSurfaceContainerLow,
        borderRadius: BorderRadius.vertical(top: Radius.circular(_mdCornerXl)),
      ),
      padding: EdgeInsets.fromLTRB(
        20,
        12,
        20,
        24 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: _mdOutlineVariant,
                borderRadius: BorderRadius.circular(99),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.commonFilter,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: _mdOnSurface,
                ),
              ),
              TextButton(
                onPressed: () => setState(() {
                  _sports = {};
                  _distance = null;
                  _onlyOpen = false;
                }),
                child: Text(
                  l10n.commonReset,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: _mdPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            l10n.filterSports,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: _mdOnSurfaceVariant,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _kFilterSportSlugs.map((slug) {
              final isAll = slug.isEmpty;
              final active = isAll ? _sports.isEmpty : _sports.contains(slug);
              return GestureDetector(
                onTap: () => setState(() {
                  if (isAll) {
                    _sports = {};
                  } else if (_sports.contains(slug)) {
                    _sports = Set.from(_sports)..remove(slug);
                  } else {
                    _sports = Set.from(_sports)..add(slug);
                  }
                }),
                child: _SheetChip(
                    label: _sportLabelFor(l10n, slug), active: active),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          Text(
            l10n.filterDistance,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: _mdOnSurfaceVariant,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: _kDistanceOptions.asMap().entries.map((e) {
              final km = e.value;
              final active = _distance == km;
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    right: e.key < _kDistanceOptions.length - 1 ? 8 : 0,
                  ),
                  child: GestureDetector(
                    onTap: () =>
                        setState(() => _distance = active ? null : km),
                    child: _SheetChip(
                      label: l10n.distanceKm('${km.toInt()}'),
                      active: active,
                      centered: true,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          Text(
            l10n.filterStatus,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: _mdOnSurfaceVariant,
            ),
          ),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: () => setState(() => _onlyOpen = !_onlyOpen),
            child: Row(
              children: [
                Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: _onlyOpen ? _mdPrimary : Colors.white,
                    border: Border.all(
                      color: _onlyOpen ? _mdPrimary : _mdOutlineVariant,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: _onlyOpen
                      ? const Icon(Icons.check, size: 14, color: Colors.white)
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    l10n.filterOnlyOpen,
                    style: const TextStyle(
                        fontSize: 14, color: _mdOnSurfaceVariant),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: FilledButton(
              onPressed: _apply,
              style: FilledButton.styleFrom(
                backgroundColor: count > 0 ? _mdPrimary : _mdOutline,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(_mdCornerFull),
                ),
              ),
              child: Text(
                count > 0 ? l10n.filterApply(count) : l10n.filterApplyZero,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SheetChip extends StatelessWidget {
  const _SheetChip({
    required this.label,
    required this.active,
    this.centered = false,
  });

  final String label;
  final bool active;
  final bool centered;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
      decoration: BoxDecoration(
        color: active ? _mdPrimaryContainer : Colors.transparent,
        border: active ? null : Border.all(color: _mdOutlineVariant),
        borderRadius: BorderRadius.circular(_mdCornerSm),
      ),
      child: Row(
        mainAxisSize: centered ? MainAxisSize.max : MainAxisSize.min,
        mainAxisAlignment:
            centered ? MainAxisAlignment.center : MainAxisAlignment.start,
        children: [
          if (active) ...[
            const Icon(Icons.check, size: 14, color: _mdOnPrimaryContainer),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            textAlign: centered ? TextAlign.center : TextAlign.start,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: active ? _mdOnPrimaryContainer : _mdOnSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// _SearchOverlay — fullscreen live search (doc 02 screen 05)
// ---------------------------------------------------------------------------

class _SearchOverlay extends StatefulWidget {
  const _SearchOverlay({
    required this.userPos,
    required this.onBack,
    required this.onTapCourt,
  });

  final LatLng? userPos;
  final VoidCallback onBack;
  final void Function(CourtAvailability) onTapCourt;

  @override
  State<_SearchOverlay> createState() => _SearchOverlayState();
}

class _SearchOverlayState extends State<_SearchOverlay> {
  final _ctrl = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: _mdN50,
      child: BlocBuilder<DiscoveryCubit, DiscoveryState>(
        builder: (context, mapState) {
          final l10n = AppLocalizations.of(context);
          final allCourts =
              mapState is DiscoveryLoaded ? mapState.courts : <CourtAvailability>[];
          final q = _query.trim().toLowerCase();
          // Search ignores the map filters; matches name, distance-sorted.
          final results = (q.isEmpty
              ? [...allCourts]
              : allCourts
                  .where((c) => c.name.toLowerCase().contains(q))
                  .toList());
          final userPos = widget.userPos;
          if (userPos != null) {
            results.sort((a, b) => _distanceKm(a, userPos)!
                .compareTo(_distanceKm(b, userPos)!));
          }

          final topPad = MediaQuery.of(context).padding.top;

          return Column(
            children: [
              Container(
                padding: EdgeInsets.fromLTRB(12, topPad + 12, 12, 12),
                decoration: const BoxDecoration(
                  color: _mdSurface,
                  border: Border(bottom: BorderSide(color: _mdOutlineVariant)),
                ),
                child: Row(
                  children: [
                    Semantics(
                      label: l10n.commonBack,
                      button: true,
                      child: GestureDetector(
                        onTap: widget.onBack,
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: _mdSurfaceContainerHigh,
                          ),
                          child: const Icon(Icons.arrow_back,
                              size: 20, color: _mdOnSurfaceVariant),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Container(
                        height: 46,
                        decoration: BoxDecoration(
                          color: _mdSurfaceContainerHighest,
                          borderRadius: BorderRadius.circular(_mdCornerFull),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x12000000),
                              blurRadius: 8,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            const SizedBox(width: 12),
                            const Icon(Icons.search,
                                size: 18, color: _mdOnSurfaceVariant),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextField(
                                controller: _ctrl,
                                autofocus: true,
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintText: l10n.searchHint,
                                  hintStyle: const TextStyle(
                                    fontSize: 14,
                                    color: _mdOnSurfaceVariant,
                                  ),
                                  isDense: true,
                                  contentPadding: EdgeInsets.zero,
                                ),
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: _mdOnSurface,
                                ),
                                onChanged: (v) => setState(() => _query = v),
                              ),
                            ),
                            if (_query.isNotEmpty)
                              GestureDetector(
                                onTap: () {
                                  _ctrl.clear();
                                  setState(() => _query = '');
                                },
                                child: Container(
                                  width: 24,
                                  height: 24,
                                  margin: const EdgeInsets.only(right: 8),
                                  decoration: const BoxDecoration(
                                    color: _mdSurfaceContainerHigh,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.close,
                                      size: 14, color: _mdOnSurfaceVariant),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    q.isEmpty
                        ? l10n.searchAllCourts(allCourts.length)
                        : l10n.searchResultsFor(results.length, _query),
                    style: const TextStyle(
                        fontSize: 12, color: _mdOnSurfaceVariant),
                  ),
                ),
              ),
              Expanded(
                child: results.isEmpty
                    ? _SearchEmpty(query: _query)
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                        itemCount: results.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (context, i) => _CourtCard(
                          court: results[i],
                          distanceKm: _distanceKm(results[i], userPos),
                          onTap: () => widget.onTapCourt(results[i]),
                        ),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SearchEmpty extends StatelessWidget {
  const _SearchEmpty({required this.query});
  final String query;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: const BoxDecoration(
              color: _mdSurfaceContainerHigh,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.search_off,
                size: 32, color: _mdOnSurfaceVariant),
          ),
          const SizedBox(height: 12),
          Text(
            l10n.searchNoResults(query),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: _mdOnSurface,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            l10n.searchTryOther,
            style: const TextStyle(fontSize: 13, color: _mdOnSurfaceVariant),
          ),
        ],
      ),
    );
  }
}
