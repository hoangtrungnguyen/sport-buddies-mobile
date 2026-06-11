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
// Design tokens — Material Design 3 surface/color scale
// ---------------------------------------------------------------------------
// MD3 surface tokens
const _mdSurface = Color(0xFFF7FBF2);               // header bg (greenish tinted)
const _mdOnSurface = Color(0xFF181D17);              // primary text
const _mdOnSurfaceVariant = Color(0xFF42493F);       // secondary text
const _mdSurfaceContainerLowest = Color(0xFFFFFFFF); // peek sheet bg
const _mdSurfaceContainerLow = Color(0xFFF1F6EC);    // filter sheet bg, cards
const _mdSurfaceContainer = Color(0xFFEBF0E6);       // chip soft bg
const _mdSurfaceContainerHigh = Color(0xFFE5EAE1);   // full badge bg
const _mdSurfaceContainerHighest = Color(0xFFDFE4DA);// GPS FAB bg, search bar bg
const _mdPrimary = Color(0xFF15803D);
const _mdOnPrimary = Color(0xFFFFFFFF);
const _mdPrimaryContainer = Color(0xFFC9F2D2);       // active chip bg, slot badge bg
const _mdOnPrimaryContainer = Color(0xFF00210B);     // active chip text
const _mdOutline = Color(0xFF72796C);
const _mdOutlineVariant = Color(0xFFC2C8BB);         // chip border, drag handle

// MD3 shape scale
const _mdCornerSm = 8.0;     // chips, badges
const _mdCornerMd = 12.0;    // GPS FAB, thumbnails, cards
const _mdCornerLg = 16.0;    // larger cards
const _mdCornerXl = 28.0;    // bottom sheets
const double _mdCornerFull = 9999.0; // buttons, pills

// Alias kept for map/marker code
const _primary = _mdPrimary;

// Kept for all-full warning banner
const _mapCanvas = Color(0xFFEAF2EA);
const _pinFull = Color(0xFF9AA3AF);
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

class _MapContentState extends State<_MapContent>
    with SingleTickerProviderStateMixin {
  final _mapController = MapController();
  bool _searchOpen = false;

  late final AnimationController _peekCtrl;
  late final Animation<Offset> _peekSlide;
  CourtAvailability? _displayedCourt; // retained during slide-out

  @override
  void initState() {
    super.initState();
    _peekCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _peekSlide = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _peekCtrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _peekCtrl.dispose();
    _mapController.dispose();
    super.dispose();
  }

  void _animatePeek(CourtAvailability? court) {
    if (court != null) {
      setState(() => _displayedCourt = court);
      _peekCtrl.forward();
    } else {
      _peekCtrl.reverse().then((_) {
        if (mounted) setState(() => _displayedCourt = null);
      });
    }
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
        _animatePeek(state is MapLoaded ? state.selectedCourt : null);
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
            return Stack(
              children: [
                // ── main map content ──────────────────────────────────────
                Column(
                  children: [
                    _MapHeader(
                      courtCount: filtered.length,
                      openSlots: openSlots,
                      isLoading: isLoading,
                      isEmpty: isEmpty,
                      selectedSports: filterState.selectedSports,
                      onSearch: () => setState(() => _searchOpen = true),
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
                              child: _AllFullBanner(
                                courtCount: filtered.length,
                                onSlots: () => context.go('/slots'),
                              ),
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
                          // PeekSheet moved to outer Stack for slide animation
                        ],
                      ),
                    ),
                  ],
                ),
                // ── peek sheet with slide-up animation ────────────────────
                if (_displayedCourt != null)
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: SlideTransition(
                      position: _peekSlide,
                      child: _PeekSheet(
                        court: _displayedCourt!,
                        onClose: () =>
                            context.read<MapCubit>().selectCourt(null),
                        onOpenCourt: () =>
                            context.push('/browse/court/${_displayedCourt!.courtId}'),
                      ),
                    ),
                  ),
                // ── search overlay (covers header + map) ──────────────────
                if (_searchOpen)
                  Positioned.fill(
                    child: _SearchOverlay(
                      onBack: () => setState(() => _searchOpen = false),
                      onTapCourt: (court) {
                        setState(() => _searchOpen = false);
                        context.read<MapCubit>().selectCourt(court);
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
                      const Text(
                        'Khám phá',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: _mdOnSurface,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _subtitle,
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
                // Filter icon button
                Semantics(
                  label: 'Bộ lọc',
                  child: InkWell(
                    onTap: onOpenFilter,
                    borderRadius: BorderRadius.circular(99),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: _mdOutlineVariant),
                        color: _mdSurface,
                      ),
                      child: const Icon(Icons.tune, size: 20, color: _mdOnSurfaceVariant),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
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
                        border: Border.all(color: _mdOutlineVariant),
                        color: _mdSurface,
                      ),
                      child: const Icon(Icons.search, size: 20, color: _mdOnSurfaceVariant),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
              ],
            ),
          ),
          _ChipRow(
            selectedSports: selectedSports,
            onSelectAll: onSelectAll,
            onToggleSport: onToggleSport,
          ),
          Container(height: 1, color: _mdOutlineVariant),
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
    required this.selectedSports,
    required this.onSelectAll,
    required this.onToggleSport,
  });

  final Set<String> selectedSports;
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
          // Distance soft chip
          const _SoftChip(label: 'Trong 5 km'),
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
          color: active ? _mdPrimaryContainer : Colors.transparent,
          border: active ? null : Border.all(color: _mdOutlineVariant),
          borderRadius: BorderRadius.circular(_mdCornerSm),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (active) ...[
              const Icon(Icons.check, size: 14, color: _mdOnPrimaryContainer),
              const SizedBox(width: 4),
            ],
            if (icon != null) ...[
              Icon(
                icon,
                size: 14,
                color: active ? _mdOnPrimaryContainer : _mdOnSurfaceVariant,
              ),
              const SizedBox(width: 5),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: active ? _mdOnPrimaryContainer : _mdOnSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SoftChip extends StatelessWidget {
  const _SoftChip({required this.label});
  final String label;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: _mdSurfaceContainer,
        borderRadius: BorderRadius.circular(_mdCornerSm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: _mdPrimary,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 5),
          const Text(
            'Trong 5 km',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: _mdOnSurfaceVariant,
            ),
          ),
        ],
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
        color: _mdSurfaceContainerLow.withAlpha(242),
        borderRadius: BorderRadius.circular(_mdCornerMd),
        border: Border.all(color: _mdOutlineVariant),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 4,
          ),
        ],
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _LegendRow(color: _primary, label: 'Còn slot'),
          SizedBox(height: 6),
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
            color: _mdOnSurfaceVariant,
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
            color: _mdSurfaceContainerHighest,
            borderRadius: BorderRadius.circular(_mdCornerMd),
            boxShadow: const [
              BoxShadow(
                color: Color(0x1A000000),
                blurRadius: 12,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(Icons.gps_fixed, size: 20, color: _mdPrimary),
        ),
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
              'Tất cả $courtCount sân quanh đây đang kín chỗ.',
              style: const TextStyle(
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
      _ => _mdOnSurfaceVariant,
    };
  }

  @override
  Widget build(BuildContext context) {
    final hasSlots = court.openSlotCount > 0;
    final sportColor = _sportColor(court.sportTypes);

    return Container(
      decoration: const BoxDecoration(
        color: _mdSurfaceContainerLowest,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(_mdCornerXl),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 20,
            offset: Offset(0, -4),
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
                      color: _mdOutlineVariant,
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
                      decoration: const BoxDecoration(
                        color: _mdSurfaceContainerHigh,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.close, size: 16, color: _mdOnSurfaceVariant),
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
                              color: _mdOnSurface,
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
                                    ? '${court.openSlotCount} slot trống'
                                    : 'Hết slot',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: hasSlots ? _mdOnPrimaryContainer : _mdOnSurfaceVariant,
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
                          color: _mdOnSurfaceVariant,
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
                backgroundColor: _mdPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(_mdCornerFull),
                ),
              ),
              child: const Text(
                'Xem sân & đặt',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: _mdOnPrimary,
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
              color: _mdSurfaceContainerLowest,
              borderRadius: BorderRadius.circular(_mdCornerLg),
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
                    color: _mdSurfaceContainerHigh,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.search_off,
                    size: 32,
                    color: _mdOnSurfaceVariant,
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
                    color: _mdOnSurface,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Thử mở rộng khoảng cách hoặc bỏ bớt bộ lọc để xem thêm lựa chọn.',
                  style: TextStyle(fontSize: 13, color: _mdOnSurfaceVariant, height: 1.4),
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
                        child: const Text(
                          'Mở rộng 5 km',
                          style: TextStyle(
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
                        child: const Text(
                          'Đặt lại bộ lọc',
                          style: TextStyle(
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
        color: _mdSurfaceContainerLow,
        borderRadius: BorderRadius.vertical(top: Radius.circular(_mdCornerXl)),
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
                color: _mdOutlineVariant,
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
                child: const Text(
                  'Đặt lại',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: _mdPrimary,
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
              color: _mdOnSurfaceVariant,
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
                const Expanded(
                  child: Text(
                    'Chỉ hiển thị sân còn slot trống',
                    style: TextStyle(fontSize: 14, color: _mdOnSurfaceVariant),
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
                backgroundColor: count > 0 ? _mdPrimary : _mdOutline,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(_mdCornerFull),
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
        color: active ? _mdPrimaryContainer : Colors.transparent,
        border: active ? null : Border.all(color: _mdOutlineVariant),
        borderRadius: BorderRadius.circular(_mdCornerSm),
      ),
      child: Row(
        mainAxisSize: centered ? MainAxisSize.max : MainAxisSize.min,
        mainAxisAlignment: centered ? MainAxisAlignment.center : MainAxisAlignment.start,
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
// _SearchOverlay — fullscreen search over header + map
// ---------------------------------------------------------------------------

class _SearchOverlay extends StatefulWidget {
  const _SearchOverlay({
    required this.onBack,
    required this.onTapCourt,
  });

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
      color: _mdSurface,
      child: BlocBuilder<MapCubit, MapState>(
        builder: (context, mapState) {
          final allCourts =
              mapState is MapLoaded ? mapState.courts : <CourtAvailability>[];
          final q = _query.trim().toLowerCase();
          final results = q.isEmpty
              ? allCourts
              : allCourts
                  .where((c) => c.name.toLowerCase().contains(q))
                  .toList();

          final topPad = MediaQuery.of(context).padding.top;

          return Column(
            children: [
              // Search bar
              Container(
                padding: EdgeInsets.fromLTRB(12, topPad + 12, 12, 12),
                decoration: const BoxDecoration(
                  color: _mdSurface,
                  border: Border(bottom: BorderSide(color: _mdOutlineVariant)),
                ),
                child: Row(
                  children: [
                    Semantics(
                      label: 'Quay lại',
                      child: GestureDetector(
                        onTap: widget.onBack,
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: _mdSurfaceContainerHigh,
                          ),
                          child: const Icon(
                            Icons.arrow_back,
                            size: 20,
                            color: _mdOnSurfaceVariant,
                          ),
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
                            const Icon(Icons.search, size: 18, color: _mdOnSurfaceVariant),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextField(
                                controller: _ctrl,
                                autofocus: true,
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  hintText: 'Tìm sân, khu vực…',
                                  hintStyle: TextStyle(
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
                                  child: const Icon(
                                    Icons.close,
                                    size: 14,
                                    color: _mdOnSurfaceVariant,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Result count line
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    q.isEmpty
                        ? 'Tất cả ${allCourts.length} sân · gần nhất trước'
                        : '${results.length} kết quả cho "$_query"',
                    style: const TextStyle(fontSize: 12, color: _mdOnSurfaceVariant),
                  ),
                ),
              ),
              // Results list
              Expanded(
                child: results.isEmpty
                    ? _SearchEmpty(query: _query)
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                        itemCount: results.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: 10),
                        itemBuilder: (context, i) => _CourtListCard(
                          court: results[i],
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
            child: const Icon(Icons.search_off, size: 32, color: _mdOnSurfaceVariant),
          ),
          const SizedBox(height: 12),
          Text(
            'Không tìm thấy "$query"',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: _mdOnSurface,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Thử tên sân hoặc khu vực khác.',
            style: TextStyle(fontSize: 13, color: _mdOnSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

class _CourtListCard extends StatelessWidget {
  const _CourtListCard({required this.court, required this.onTap});
  final CourtAvailability court;
  final VoidCallback onTap;

  static Color _sportColor(List<String> sportTypes) {
    final t = (sportTypes.firstOrNull ?? '').toLowerCase();
    return switch (t) {
      'football' || 'bóng đá' || 'bóng đá 5v5' => const Color(0xFF16A34A),
      'pickleball' => const Color(0xFF0EA5E9),
      'badminton' || 'cầu lông' => const Color(0xFFEF4444),
      'tennis' => const Color(0xFFEAB308),
      _ => _mdOnSurfaceVariant,
    };
  }

  static IconData _sportIcon(List<String> sportTypes) {
    final t = (sportTypes.firstOrNull ?? '').toLowerCase();
    return switch (t) {
      'football' || 'bóng đá' || 'bóng đá 5v5' => Icons.sports_soccer,
      _ => Icons.sports_tennis,
    };
  }

  @override
  Widget build(BuildContext context) {
    final hasSlots = court.openSlotCount > 0;
    final sportColor = _sportColor(court.sportTypes);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: _mdSurfaceContainerLow,
          borderRadius: BorderRadius.circular(_mdCornerMd),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0F000000),
              blurRadius: 3,
              offset: Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          children: [
            // Thumb
            Container(
              width: 64,
              height: 64,
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
                size: 28,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 12),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          court.name,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: _mdOnSurface,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: hasSlots ? _mdPrimaryContainer : _mdSurfaceContainerHigh,
                          borderRadius: BorderRadius.circular(_mdCornerSm),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 5,
                              height: 5,
                              decoration: BoxDecoration(
                                color: hasSlots ? _mdPrimary : _mdOutline,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              hasSlots
                                  ? '${court.openSlotCount} slot trống'
                                  : 'Hết slot',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: hasSlots ? _mdOnPrimaryContainer : _mdOnSurfaceVariant,
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
                      style: const TextStyle(fontSize: 12, color: _mdOnSurfaceVariant),
                    ),
                  ],
                ],
              ),
            ),
          ],
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
