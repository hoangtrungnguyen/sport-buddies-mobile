// Map screen — EPIC-4 Court Discovery
//
// Direction A (pin-first + peek):
//   - Full-screen map with availability-coloured markers.
//   - Tap pin → PeekSheet slides up from bottom.
//   - Header: "Khám phá" + filtered count + search icon + sport chip row.
//   - Overlays: MapLegend (top-left), GPS FAB (top-right), AllFullBanner (top).
//   - States: loading, no-GPS, empty (no matches), all-full (amber banner).
//   - Filter sheet uses a draft so nothing applies until the CTA.
//
// Map provider strategy (MAP_PROVIDER env var):
//   'google'  → ReactiveGoogleMapBody
//   'vietmap' → _VietMapGLBody (vector tiles)
//   anything  → FlutterMap + OSM tiles

import 'package:customer/core/env/env.dart';
import 'package:customer/features/map/cubit/map_cubit.dart';
import 'package:customer/features/map/cubit/map_state.dart';
import 'package:customer/features/map/google_map_body.dart';
import 'package:customer/features/map/location_cubit.dart';
import 'package:customer/features/map/location_state.dart';
import 'package:customer/features/map/map_filter_cubit.dart';
import 'package:customer/features/map/map_filter_state.dart';
import 'package:customer/features/map/map_tile_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart' as ll;
import 'package:spb_core/spb_core.dart';
import 'package:vietmap_flutter_gl/vietmap_flutter_gl.dart' as vm;

// ---------------------------------------------------------------------------
// Design tokens (local constants — not in ThemeData yet)
// ---------------------------------------------------------------------------
const _primary = Color(0xFF16A34A);
const _primaryDark = Color(0xFF15803D);
const _primaryLight = Color(0xFFDCFCE7);
const _n100 = Color(0xFFF3F4F6);
const _n200 = Color(0xFFE5E7EB);
const _n300 = Color(0xFFD1D5DB);
const _n600 = Color(0xFF6B7280);
const _n700 = Color(0xFF374151);
const _n900 = Color(0xFF111827);
const _pinFull = Color(0xFF9AA3AF);
const _mapCanvas = Color(0xFFEAF2EA);
const _success = Color(0xFF22C55E);
const _successBg = Color(0xFFDCFCE7);
const _warningBg = Color(0xFFFEF9C3);
const _warningBorder = Color(0xFFFDE68A);
const _warningText = Color(0xFF92670B);

// ---------------------------------------------------------------------------
// Map infrastructure
// ---------------------------------------------------------------------------
const _hcmcLatLng = ll.LatLng(10.7769, 106.7009);
const _defaultZoom = 13.0;

final _tileProvider = MapTileProvider.fromEnv();

// ---------------------------------------------------------------------------
// MapScreen
// ---------------------------------------------------------------------------

class MapScreen extends StatelessWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => MapFilterCubit(),
      child: const Scaffold(
        backgroundColor: _mapCanvas,
        body: _MapContent(),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// _MapContent — main stateful body
// ---------------------------------------------------------------------------

class _MapContent extends StatefulWidget {
  const _MapContent();

  @override
  State<_MapContent> createState() => _MapContentState();
}

class _MapContentState extends State<_MapContent> {
  final _mapController = MapController();

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<MapCubit, MapState>(
      listener: (context, state) {
        if (state is MapError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      builder: (context, mapState) {
        return BlocBuilder<MapFilterCubit, MapFilterState>(
          builder: (context, filterState) {
            final userPos = _getUserPos(context);
            final allCourts =
                mapState is MapLoaded ? mapState.courts : <CourtAvailability>[];
            final filtered = mapState is MapLoaded
                ? mapState.applyFilter(
                    sports: filterState.selectedSports,
                    maxDistanceKm: filterState.maxDistanceKm,
                    userPos: userPos,
                    onlyWithOpenSlots: filterState.onlyWithOpenSlots,
                  )
                : <CourtAvailability>[];

            final openSlots =
                filtered.fold(0, (sum, c) => sum + c.openSlotCount);
            final isLoading =
                mapState is MapLoading || mapState is MapInitial;
            final isEmpty = mapState is MapLoaded && filtered.isEmpty;
            final isAllFull = mapState is MapLoaded &&
                filtered.isNotEmpty &&
                filtered.every((c) => c.openSlotCount == 0);
            final selectedCourt =
                mapState is MapLoaded ? mapState.selectedCourt : null;

            final filtersActive = filterState.selectedSports.isNotEmpty ||
                filterState.maxDistanceKm != null ||
                filterState.onlyWithOpenSlots;

            return Column(
              children: [
                _MapHeader(
                  courtCount: filtered.length,
                  openSlots: openSlots,
                  isLoading: isLoading,
                  isEmpty: isEmpty,
                  filtersActive: filtersActive,
                  selectedSports: filterState.selectedSports,
                  onSearch: () {},
                  onOpenFilter: () =>
                      _showFilterSheet(context, allCourts, userPos),
                  onSelectAll: () =>
                      context.read<MapFilterCubit>().filterBySports([]),
                  onToggleSport: (sport) {
                    final cubit = context.read<MapFilterCubit>();
                    final current = filterState.selectedSports;
                    if (current.length == 1 && current.contains(sport)) {
                      cubit.filterBySports([]);
                    } else {
                      cubit.filterBySports([sport]);
                    }
                  },
                ),
                Expanded(
                  child: Stack(
                    children: [
                      _buildMapWidget(
                        context: context,
                        courts: isEmpty ? [] : filtered,
                        onMarkerTap: (c) =>
                            context.read<MapCubit>().selectCourt(c),
                        onMapTap: () =>
                            context.read<MapCubit>().selectCourt(null),
                        userPos: userPos,
                        mapController: _mapController,
                      ),
                      if (isLoading)
                        const Center(
                          child: CircularProgressIndicator(color: _primary),
                        ),
                      if (isAllFull)
                        Positioned(
                          top: 12,
                          left: 12,
                          right: 12,
                          child: _AllFullBanner(onSlots: () {}),
                        ),
                      Positioned(
                        top: isAllFull ? 68 : 12,
                        left: 12,
                        child: const _MapLegend(),
                      ),
                      Positioned(
                        top: 12,
                        right: 16,
                        child: _GpsRecenterFab(
                          onTap: () => _recenter(context),
                        ),
                      ),
                      if (isEmpty && !isLoading)
                        _EmptyState(
                          onlyOpen: filterState.onlyWithOpenSlots,
                          onExpand: () {
                            final cubit = context.read<MapFilterCubit>();
                            cubit.filterByDistance(5.0);
                            if (cubit.state.onlyWithOpenSlots) {
                              cubit.toggleOnlyOpenSlots();
                            }
                          },
                          onReset: () =>
                              context.read<MapFilterCubit>().clearAll(),
                        ),
                      if (!isEmpty && selectedCourt != null)
                        Positioned(
                          left: 0,
                          right: 0,
                          bottom: 0,
                          child: _PeekSheet(
                            court: selectedCourt,
                            onClose: () =>
                                context.read<MapCubit>().selectCourt(null),
                            onOpenCourt: () =>
                                context.push('/court/${selectedCourt.courtId}'),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _recenter(BuildContext context) {
    try {
      final state = context.read<LocationCubit>().state;
      if (state is LocationLoaded) {
        _mapController.move(
          ll.LatLng(state.center.latitude, state.center.longitude),
          _defaultZoom,
        );
      }
    } catch (_) {}
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Đã căn giữa vị trí của bạn'),
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  static void _showFilterSheet(
    BuildContext ctx,
    List<CourtAvailability> courts,
    LatLng? userPos,
  ) {
    final filterCubit = ctx.read<MapFilterCubit>();
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

  static bool get _isGoogleKeyValid {
    var key = Env.googleMapApiKey.trim();
    if (key.length >= 2 &&
        ((key.startsWith('"') && key.endsWith('"')) ||
            (key.startsWith("'") && key.endsWith("'")))) {
      key = key.substring(1, key.length - 1).trim();
    }
    return key.isNotEmpty;
  }

  static Widget _buildMapWidget({
    required BuildContext context,
    required List<CourtAvailability> courts,
    required void Function(CourtAvailability) onMarkerTap,
    required VoidCallback onMapTap,
    LatLng? userPos,
    MapController? mapController,
  }) {
    if (Env.mapProvider.trim() == 'google' && _isGoogleKeyValid) {
      return ReactiveGoogleMapBody(
        courts: courts,
        onMarkerTap: onMarkerTap,
      );
    }
    if (_tileProvider case final VietMapGLProvider glProvider) {
      return _VietMapGLBody(
        provider: glProvider,
        courts: courts,
        onMarkerTap: onMarkerTap,
        userCenter: userPos,
      );
    }
    return _buildFlutterMap(
      courts: courts,
      onMarkerTap: onMarkerTap,
      onMapTap: onMapTap,
      userCenter: userPos,
      mapController: mapController,
    );
  }

  static Widget _buildFlutterMap({
    required List<CourtAvailability> courts,
    required void Function(CourtAvailability) onMarkerTap,
    required VoidCallback onMapTap,
    LatLng? userCenter,
    MapController? mapController,
  }) {
    final center = userCenter != null
        ? ll.LatLng(userCenter.lat, userCenter.lng)
        : _hcmcLatLng;
    final urlTemplate = switch (_tileProvider) {
      RasterTileProvider(:final urlTemplate) => urlTemplate,
      _ => 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
    };
    return FlutterMap(
      mapController: mapController,
      options: MapOptions(
        initialCenter: center,
        initialZoom: _defaultZoom,
        onTap: (_, __) => onMapTap(),
      ),
      children: [
        TileLayer(
          urlTemplate: urlTemplate,
          userAgentPackageName: 'vn.sportbuddies.customer',
        ),
        MarkerLayer(
          markers: courts
              .map((c) => _buildMarker(c, () => onMarkerTap(c)))
              .toList(),
        ),
      ],
    );
  }

  static Marker _buildMarker(CourtAvailability court, VoidCallback onTap) {
    return Marker(
      point: ll.LatLng(court.lat, court.lng),
      width: 32,
      height: 40,
      child: GestureDetector(
        onTap: onTap,
        child: Icon(
          Icons.location_pin,
          color: court.openSlotCount > 0 ? _primary : _pinFull,
          size: 32,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// _MapHeader
// ---------------------------------------------------------------------------

class _MapHeader extends StatelessWidget {
  const _MapHeader({
    required this.courtCount,
    required this.openSlots,
    required this.isLoading,
    required this.isEmpty,
    required this.filtersActive,
    required this.selectedSports,
    required this.onSearch,
    required this.onOpenFilter,
    required this.onSelectAll,
    required this.onToggleSport,
  });

  final int courtCount;
  final int openSlots;
  final bool isLoading;
  final bool isEmpty;
  final bool filtersActive;
  final Set<String> selectedSports;
  final VoidCallback onSearch;
  final VoidCallback onOpenFilter;
  final VoidCallback onSelectAll;
  final void Function(String sport) onToggleSport;

  String get _subtitle {
    if (isLoading) return 'Đang cập nhật…';
    if (isEmpty) return 'Không có sân khớp bộ lọc';
    return '$courtCount sân · $openSlots slot trống quanh đây';
  }

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;
    return Container(
      color: Colors.white,
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
                      const Text(
                        'Khám phá',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: _n900,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _subtitle,
                        style: const TextStyle(
                          fontSize: 12,
                          color: _n600,
                          height: 1.4,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Semantics(
                  label: 'Tìm kiếm',
                  child: InkWell(
                    onTap: onSearch,
                    borderRadius: BorderRadius.circular(99),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: _n200),
                        color: Colors.white,
                      ),
                      child: const Icon(Icons.search, size: 20, color: _n700),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
              ],
            ),
          ),
          _ChipRow(
            filtersActive: filtersActive,
            selectedSports: selectedSports,
            onOpenFilter: onOpenFilter,
            onSelectAll: onSelectAll,
            onToggleSport: onToggleSport,
          ),
          Container(height: 1, color: _n200),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// _ChipRow
// ---------------------------------------------------------------------------

const _kQuickSports = [
  ('football', 'Bóng đá', Icons.sports_soccer),
  ('pickleball', 'Pickleball', Icons.sports_tennis),
  ('badminton', 'Cầu lông', Icons.sports_tennis),
  ('tennis', 'Tennis', Icons.sports_tennis),
];

class _ChipRow extends StatelessWidget {
  const _ChipRow({
    required this.filtersActive,
    required this.selectedSports,
    required this.onOpenFilter,
    required this.onSelectAll,
    required this.onToggleSport,
  });

  final bool filtersActive;
  final Set<String> selectedSports;
  final VoidCallback onOpenFilter;
  final VoidCallback onSelectAll;
  final void Function(String) onToggleSport;

  @override
  Widget build(BuildContext context) {
    final allActive = selectedSports.isEmpty;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          // Filter pill
          _FilterPill(active: filtersActive, onTap: onOpenFilter),
          // Divider
          Container(
            width: 1,
            height: 20,
            color: _n200,
            margin: const EdgeInsets.symmetric(horizontal: 10),
          ),
          // Tất cả chip
          _QuickChip(
            label: 'Tất cả',
            icon: null,
            active: allActive,
            onTap: onSelectAll,
          ),
          const SizedBox(width: 8),
          // Sport chips
          ...(_kQuickSports.map(
            (e) => Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _QuickChip(
                label: e.$2,
                icon: e.$3,
                active: selectedSports.length == 1 &&
                    selectedSports.contains(e.$1),
                onTap: () => onToggleSport(e.$1),
              ),
            ),
          )),
        ],
      ),
    );
  }
}

class _FilterPill extends StatelessWidget {
  const _FilterPill({required this.active, required this.onTap});

  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: active ? _primaryLight : Colors.white,
              border: Border.all(
                color: active ? _primaryLight : _n200,
              ),
              borderRadius: BorderRadius.circular(99),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.tune,
                  size: 14,
                  color: active ? _primaryDark : _n700,
                ),
                const SizedBox(width: 5),
                Text(
                  'Bộ lọc',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: active ? _primaryDark : _n700,
                  ),
                ),
              ],
            ),
          ),
          if (active)
            Positioned(
              top: -2,
              right: -2,
              child: Container(
                width: 9,
                height: 9,
                decoration: BoxDecoration(
                  color: _primary,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 1.5),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _QuickChip extends StatelessWidget {
  const _QuickChip({
    required this.label,
    required this.icon,
    required this.active,
    required this.onTap,
  });

  final String label;
  final IconData? icon;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: active ? _primary : Colors.white,
          border: Border.all(color: active ? _primary : _n200),
          borderRadius: BorderRadius.circular(99),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 14,
                color: active ? Colors.white : _n700,
              ),
              const SizedBox(width: 5),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: active ? Colors.white : _n700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// _MapLegend
// ---------------------------------------------------------------------------

class _MapLegend extends StatelessWidget {
  const _MapLegend();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(242),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _n200),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _LegendRow(color: _primary, label: 'Còn slot'),
          const SizedBox(height: 6),
          _LegendRow(color: _pinFull, label: 'Hết slot'),
        ],
      ),
    );
  }
}

class _LegendRow extends StatelessWidget {
  const _LegendRow({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.location_pin, size: 14, color: color),
        const SizedBox(width: 5),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: _n700,
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// _GpsRecenterFab
// ---------------------------------------------------------------------------

class _GpsRecenterFab extends StatelessWidget {
  const _GpsRecenterFab({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Căn giữa vị trí',
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: const [
              BoxShadow(
                color: Color(0x1A000000),
                blurRadius: 12,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(Icons.gps_fixed, size: 20, color: _n700),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// _AllFullBanner
// ---------------------------------------------------------------------------

class _AllFullBanner extends StatelessWidget {
  const _AllFullBanner({required this.onSlots});

  final VoidCallback onSlots;

  @override
  Widget build(BuildContext context) {
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
          const Expanded(
            child: Text(
              'Tất cả sân quanh đây đang kín chỗ.',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: _warningText,
              ),
            ),
          ),
          GestureDetector(
            onTap: onSlots,
            child: const Text(
              'Xem slot trống →',
              style: TextStyle(
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
// _PeekSheet
// ---------------------------------------------------------------------------

class _PeekSheet extends StatelessWidget {
  const _PeekSheet({
    required this.court,
    required this.onClose,
    required this.onOpenCourt,
  });

  final CourtAvailability court;
  final VoidCallback onClose;
  final VoidCallback onOpenCourt;

  static IconData _sportIcon(List<String> sportTypes) {
    final t = (sportTypes.firstOrNull ?? '').toLowerCase();
    return switch (t) {
      'football' || 'bóng đá' || 'bóng đá 5v5' => Icons.sports_soccer,
      'badminton' || 'cầu lông' => Icons.sports_tennis,
      'pickleball' => Icons.sports_tennis,
      'tennis' => Icons.sports_tennis,
      _ => Icons.sports,
    };
  }

  static Color _sportColor(List<String> sportTypes) {
    final t = (sportTypes.firstOrNull ?? '').toLowerCase();
    return switch (t) {
      'football' || 'bóng đá' || 'bóng đá 5v5' => const Color(0xFF16A34A),
      'pickleball' => const Color(0xFF0EA5E9),
      'badminton' || 'cầu lông' => const Color(0xFFEF4444),
      'tennis' => const Color(0xFFEAB308),
      _ => _n600,
    };
  }

  @override
  Widget build(BuildContext context) {
    final hasSlots = court.openSlotCount > 0;
    final sportColor = _sportColor(court.sportTypes);

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Color(0x24000000),
            blurRadius: 28,
            offset: Offset(0, -10),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Grabber + close button row
          SizedBox(
            height: 24,
            child: Stack(
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: _n300,
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                ),
                Positioned(
                  right: 0,
                  top: 0,
                  child: GestureDetector(
                    onTap: onClose,
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: _n100,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.close, size: 16, color: _n600),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Court row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Sport thumb
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [sportColor, sportColor.withAlpha(204)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _sportIcon(court.sportTypes),
                  size: 32,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 12),
              // Info column
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
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: _n900,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Availability badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: hasSlots ? _successBg : _n100,
                            borderRadius: BorderRadius.circular(99),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  color: hasSlots ? _success : _n600,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                hasSlots
                                    ? '${court.openSlotCount} slot trống'
                                    : 'Hết slot',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color:
                                      hasSlots ? _primaryDark : _n600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (court.sportTypes.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        court.sportTypes.first,
                        style: const TextStyle(
                          fontSize: 12,
                          color: _n600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // CTA
          SizedBox(
            width: double.infinity,
            height: 46,
            child: FilledButton(
              onPressed: onOpenCourt,
              style: FilledButton.styleFrom(
                backgroundColor: _primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Xem sân & đặt',
                style: TextStyle(
                  fontSize: 15,
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

// ---------------------------------------------------------------------------
// _EmptyState
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
    return Positioned.fill(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x1E000000),
                  blurRadius: 24,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: const BoxDecoration(
                    color: _n100,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.search_off,
                    size: 32,
                    color: _n600,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  onlyOpen
                      ? 'Không còn slot trống ở đây'
                      : 'Không tìm thấy sân nào',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: _n900,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Thử mở rộng khoảng cách hoặc bỏ bớt bộ lọc để xem thêm lựa chọn.',
                  style: TextStyle(fontSize: 13, color: _n600, height: 1.4),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: onExpand,
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: _n200),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text(
                          'Mở rộng 5 km',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: _n700,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: FilledButton(
                        onPressed: onReset,
                        style: FilledButton.styleFrom(
                          backgroundColor: _primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text(
                          'Đặt lại bộ lọc',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// _FilterSheet — draft state, live count CTA
// ---------------------------------------------------------------------------

const _kFilterSports = [
  ('', 'Tất cả'),
  ('football', 'Bóng đá'),
  ('pickleball', 'Pickleball'),
  ('badminton', 'Cầu lông'),
  ('tennis', 'Tennis'),
  ('multi', 'Đa năng'),
];

const _kDistanceOptions = [1.0, 3.0, 5.0];

class _FilterSheet extends StatefulWidget {
  const _FilterSheet({
    required this.initialState,
    required this.courts,
    required this.userPos,
    required this.onApply,
  });

  final MapFilterState initialState;
  final List<CourtAvailability> courts;
  final LatLng? userPos;
  final void Function(MapFilterState) onApply;

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
    widget.onApply(MapFilterState(
      selectedSports: Set.from(_sports),
      maxDistanceKm: _distance,
      onlyWithOpenSlots: _onlyOpen,
    ));
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final count = _draftCount;
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Grabber
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: _n300,
                borderRadius: BorderRadius.circular(99),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Bộ lọc',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: _n900,
                ),
              ),
              TextButton(
                onPressed: () => setState(() {
                  _sports = {};
                  _distance = null;
                  _onlyOpen = false;
                }),
                child: const Text(
                  'Đặt lại',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: _primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          // Sports section
          const Text(
            'Môn thể thao',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: _n700,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _kFilterSports.map((e) {
              final slug = e.$1;
              final label = e.$2;
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
                child: _SheetChip(label: label, active: active),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          // Distance section
          const Text(
            'Khoảng cách',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: _n700,
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
                    onTap: () => setState(
                      () => _distance = active ? null : km,
                    ),
                    child: _SheetChip(
                      label: '${km.toInt()} km',
                      active: active,
                      centered: true,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          // Status section
          const Text(
            'Trạng thái',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: _n700,
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
                    color: _onlyOpen ? _primary : Colors.white,
                    border: Border.all(
                      color: _onlyOpen ? _primary : _n300,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: _onlyOpen
                      ? const Icon(Icons.check, size: 14, color: Colors.white)
                      : null,
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Chỉ hiển thị sân còn slot trống',
                    style: TextStyle(fontSize: 14, color: _n700),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // CTA
          SizedBox(
            width: double.infinity,
            height: 52,
            child: FilledButton(
              onPressed: _apply,
              style: FilledButton.styleFrom(
                backgroundColor: count > 0 ? _primary : _n700,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                count > 0 ? 'Hiển thị $count sân' : 'Xem kết quả · 0 sân',
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
        color: active ? _primary : Colors.white,
        border: Border.all(color: active ? _primary : _n200),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        label,
        textAlign: centered ? TextAlign.center : TextAlign.start,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: active ? Colors.white : _n700,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// _VietMapGLBody — unchanged from original
// ---------------------------------------------------------------------------

class _VietMapGLBody extends StatefulWidget {
  const _VietMapGLBody({
    required this.provider,
    required this.courts,
    required this.onMarkerTap,
    this.userCenter,
  });

  final VietMapGLProvider provider;
  final List<CourtAvailability> courts;
  final void Function(CourtAvailability) onMarkerTap;
  final LatLng? userCenter;

  @override
  State<_VietMapGLBody> createState() => _VietMapGLBodyState();
}

class _VietMapGLBodyState extends State<_VietMapGLBody> {
  vm.VietmapController? _controller;
  final Map<vm.Circle, CourtAvailability> _circleMap = {};

  @override
  void didUpdateWidget(_VietMapGLBody old) {
    super.didUpdateWidget(old);
    if (old.courts != widget.courts) _refreshMarkers();
  }

  Future<void> _refreshMarkers() async {
    final ctrl = _controller;
    if (ctrl == null) return;
    for (final circle in _circleMap.keys) {
      await ctrl.removeCircle(circle);
    }
    _circleMap.clear();
    await _addCourtCircles(ctrl);
  }

  Future<void> _addCourtCircles(vm.VietmapController ctrl) async {
    for (final court in widget.courts) {
      final circle = await ctrl.addCircle(
        vm.CircleOptions(
          geometry: vm.LatLng(court.lat, court.lng),
          circleRadius: 12,
          circleColor: court.openSlotCount > 0 ? _primary : _pinFull,
          circleStrokeWidth: 2,
          circleStrokeColor: Colors.white,
        ),
      );
      _circleMap[circle] = court;
    }
  }

  Future<void> _hidePOILayers(vm.VietmapController ctrl) async {
    final ids = (await ctrl.getLayerIds()).cast<String>();
    final poiIds = ids.where((id) => id.contains('poi')).toList();
    await Future.wait(
      poiIds.map((id) => ctrl.setLayerVisibility(id, false)),
    );
  }

  void _onCircleTapped(vm.Circle circle) {
    final court = _circleMap[circle];
    if (court != null) widget.onMarkerTap(court);
  }

  @override
  Widget build(BuildContext context) {
    final center = widget.userCenter;
    final initialPos = vm.CameraPosition(
      target: center != null
          ? vm.LatLng(center.lat, center.lng)
          : const vm.LatLng(10.7769, 106.7009),
      zoom: _defaultZoom,
    );

    return vm.VietmapGL(
      styleString: widget.provider.styleUrl,
      initialCameraPosition: initialPos,
      myLocationEnabled: true,
      myLocationRenderMode: vm.MyLocationRenderMode.compass,
      myLocationTrackingMode: vm.MyLocationTrackingMode.none,
      onMapCreated: (controller) {
        _controller = controller;
        controller.onCircleTapped.add(_onCircleTapped);
      },
      onStyleLoadedCallback: () async {
        final ctrl = _controller;
        if (ctrl == null) return;
        await _hidePOILayers(ctrl);
        await _addCourtCircles(ctrl);
      },
    );
  }
}
