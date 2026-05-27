// Map screen — CAPP-030 grava-c9ca.2.1 + grava-c9ca.3.1 + grava-c9ca.4.2/4.3
//
// Business logic wiring:
//   - MapCubit       (provided by router) — fetches courts + manages selection
//   - MapFilterCubit (provided locally)   — sport / distance / open-slot filter
//   - LocationCubit  (provided by router) — GPS for distance filter
//
// Filter pipeline:
//   MapLoaded.courts → applyFilter(filterState, userPos) → rendered markers
//
// Map provider strategy (MAP_PROVIDER env var):
//   • 'google'   → google_maps_flutter (native SDK, all platforms).
//   • 'vietmap'  → flutter_map + VietMap raster tiles.
//   • 'general'  → flutter_map + OpenStreetMap tiles (no key required).
//   • ''         → flutter_map + OSM fallback.

import 'package:customer/core/env/env.dart';
import 'package:customer/features/map/cubit/map_cubit.dart';
import 'package:customer/features/map/google_map_body.dart';
import 'package:customer/features/map/location_cubit.dart';
import 'package:customer/features/map/location_state.dart';
import 'package:customer/features/map/map_filter_cubit.dart';
import 'package:customer/features/map/map_filter_state.dart';
import 'package:customer/features/map/map_tile_provider.dart';
import 'package:customer/features/map/sport_filter_bar.dart';
import 'package:customer/features/slots/cubit/open_slot_list_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart' as ll;
import 'package:spb_core/spb_core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

const _hcmcLatLng = ll.LatLng(10.7769, 106.7009);
const _defaultZoom = 13.0;

// Active tile provider resolved once at startup from MAP_PROVIDER env var.
final _tileProvider = MapTileProvider.fromEnv();

/// Map screen with colour-coded court markers, sport/distance filters,
/// court selection preview, and slot-list toggle.
///
/// Expects [MapCubit] and [LocationCubit] in the widget tree (provided by the
/// router). Gracefully degrades when they are absent (tests, storybook).
class MapScreen extends StatelessWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => MapFilterCubit(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Bản đồ sân gần bạn'),
          actions: [
            Builder(
              builder: (ctx) => IconButton(
                icon: const Icon(Icons.filter_list),
                onPressed: () => _showFilterSheet(ctx),
                tooltip: 'Bộ lọc',
              ),
            ),
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () async {
                await Supabase.instance.client.auth.signOut();
                if (context.mounted) context.go('/login');
              },
              tooltip: 'Sign out',
            ),
          ],
        ),
        body: const _MapBody(),
      ),
    );
  }

  static void _showFilterSheet(BuildContext context) {
    final filterCubit = context.read<MapFilterCubit>();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: filterCubit,
        child: const _FilterSheet(),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Map body
// ---------------------------------------------------------------------------

class _MapBody extends StatefulWidget {
  const _MapBody();

  @override
  State<_MapBody> createState() => _MapBodyState();
}

class _MapBodyState extends State<_MapBody> {
  MapCubit? _cubit;
  bool _showSlotList = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _cubit ??= _tryReadCubit(context);
    if (_cubit?.state is MapInitial) {
      _cubit!.loadCourts();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        BlocBuilder<MapFilterCubit, MapFilterState>(
          builder: (context, filterState) => SportFilterBar(
            selectedSports: filterState.selectedSports,
            onSportsChanged: (sports) =>
                context.read<MapFilterCubit>().filterBySports(sports.toList()),
          ),
        ),
        Expanded(
          child: Stack(
            children: [
              _buildMapArea(context),
              // Bottom panel: slot list or court preview.
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: _showSlotList
                    ? _SlotListPanel(
                        onClose: () => setState(() => _showSlotList = false),
                      )
                    : _SelectedCourtPanel(cubit: _cubit),
              ),
              // View toggle — sits above the panel.
              Positioned(
                left: 0,
                right: 0,
                bottom: _showSlotList ? 348 : 176,
                child: Center(
                  child: _cubit == null
                      ? _ViewToggle(
                          isSlotView: _showSlotList,
                          openSlotCount: 0,
                          onToggle: (v) => _toggleSlotView(context, v),
                        )
                      : BlocBuilder<MapCubit, MapState>(
                          builder: (ctx, state) {
                            final total = state is MapLoaded
                                ? state.courts
                                    .fold<int>(0, (s, c) => s + c.openSlotCount)
                                : 0;
                            return _ViewToggle(
                              isSlotView: _showSlotList,
                              openSlotCount: total,
                              onToggle: (v) => _toggleSlotView(ctx, v),
                            );
                          },
                        ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _toggleSlotView(BuildContext context, bool show) {
    setState(() => _showSlotList = show);
    if (show) {
      final slotCubit = _MapBodyState._tryReadSlotCubit(context);
      if (slotCubit != null && slotCubit.state is SlotListInitial) {
        slotCubit.loadAllGroupSlots();
      }
    }
  }

  Widget _buildMapArea(BuildContext context) {
    if (_cubit == null) {
      return _buildFlutterMap(courts: const [], onMarkerTap: (_) {});
    }

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
            final filtered = mapState is MapLoaded
                ? mapState.applyFilter(
                    sports: filterState.selectedSports,
                    maxDistanceKm: filterState.maxDistanceKm,
                    userPos: userPos,
                    onlyWithOpenSlots: filterState.onlyWithOpenSlots,
                  )
                : const <CourtAvailability>[];

            final isLoading = mapState is MapLoading;
            final isEmpty = mapState is MapLoaded && filtered.isEmpty;

            if (isEmpty) {
              return const _EmptyState();
            }

            return Stack(
              children: [
                _buildMapWidget(
                  context: context,
                  courts: filtered,
                  onMarkerTap: (court) => _cubit!.selectCourt(court),
                  userPos: userPos,
                ),
                if (isLoading)
                  const Positioned(
                    top: 12,
                    left: 0,
                    right: 0,
                    child: Center(child: CircularProgressIndicator()),
                  ),
              ],
            );
          },
        );
      },
    );
  }

  // Reads the user's real GPS position from LocationCubit (spb_core LatLng).
  // Returns null when LocationCubit is absent or position is the HCMC default.
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

  /// Returns true only when GOOGLE_MAP_API_KEY is a non-empty, non-quoted string.
  ///
  /// Envied parses `GOOGLE_MAP_API_KEY=""` from `.env` as the literal two-char
  /// string `""` rather than an empty string.  We strip surrounding quotes and
  /// trim whitespace before checking to avoid rendering [ReactiveGoogleMapBody]
  /// with a bogus key (which causes a native crash on iOS).
  static bool get _isGoogleKeyValid {
    var key = Env.googleMapApiKey.trim();
    // Envied parses GOOGLE_MAP_API_KEY="" as the two-char string '""'.
    // Strip a single layer of surrounding single or double quotes if present.
    if (key.length >= 2 &&
        ((key.startsWith('"') && key.endsWith('"')) ||
            (key.startsWith("'") && key.endsWith("'")))) {
      key = key.substring(1, key.length - 1).trim();
    }
    return key.isNotEmpty;
  }

  /// Routes to the correct map implementation based on [Env.mapProvider].
  ///
  /// - `'google'`   → [ReactiveGoogleMapBody] (google_maps_flutter SDK)
  /// - `'vietmap'`  → [FlutterMap] + VietMap raster tiles
  /// - `'general'`  → [FlutterMap] + OpenStreetMap tiles
  /// - anything else → [FlutterMap] + OSM fallback
  static Widget _buildMapWidget({
    required BuildContext context,
    required List<CourtAvailability> courts,
    required void Function(CourtAvailability) onMarkerTap,
    LatLng? userPos,
  }) {
    if (Env.mapProvider.trim() == 'google' && _isGoogleKeyValid) {
      return ReactiveGoogleMapBody(
        courts: courts,
        onMarkerTap: onMarkerTap,
      );
    }
    return _buildFlutterMap(
      courts: courts,
      onMarkerTap: onMarkerTap,
      userCenter: userPos,
    );
  }

  /// Builds the flutter_map widget (VietMap / OSM raster tiles).
  ///
  /// [userCenter] moves the initial camera to the user's GPS position
  /// when resolved; falls back to the HCMC default.
  static Widget _buildFlutterMap({
    required List<CourtAvailability> courts,
    required void Function(CourtAvailability) onMarkerTap,
    LatLng? userCenter,
  }) {
    final center = userCenter != null
        ? ll.LatLng(userCenter.lat, userCenter.lng)
        : _hcmcLatLng;
    return FlutterMap(
      options: MapOptions(
        initialCenter: center,
        initialZoom: _defaultZoom,
      ),
      children: [
        TileLayer(
          urlTemplate: _tileProvider.urlTemplate,
          userAgentPackageName: 'vn.sportbuddies.customer',
        ),
        MarkerLayer(
          markers:
              courts.map((c) => _buildMarker(c, () => onMarkerTap(c))).toList(),
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
          color: court.markerColor,
          size: 32,
        ),
      ),
    );
  }

  static MapCubit? _tryReadCubit(BuildContext context) {
    try {
      return BlocProvider.of<MapCubit>(context, listen: false);
    } catch (_) {
      return null;
    }
  }

  static SlotListCubit? _tryReadSlotCubit(BuildContext context) {
    try {
      return BlocProvider.of<SlotListCubit>(context, listen: false);
    } catch (_) {
      return null;
    }
  }
}

// ---------------------------------------------------------------------------
// Empty state
// ---------------------------------------------------------------------------

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.location_off, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            'Không tìm thấy sân gần bạn',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(color: Colors.grey),
          ),
          const SizedBox(height: 8),
          const Text(
            // Keep this string in sync with map_screen_test.dart assertions.
            'Thử phóng to bản đồ hoặc thay đổi bộ lọc',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// View toggle (Map / Slot trống)
// ---------------------------------------------------------------------------

class _ViewToggle extends StatelessWidget {
  const _ViewToggle({
    required this.isSlotView,
    required this.onToggle,
    required this.openSlotCount,
  });

  final bool isSlotView;
  final ValueChanged<bool> onToggle;
  final int openSlotCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(99),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ToggleBtn(
            label: 'Bản đồ',
            active: !isSlotView,
            onTap: () => onToggle(false),
          ),
          const SizedBox(width: 2),
          _ToggleBtn(
            label: 'Slot trống · $openSlotCount',
            active: isSlotView,
            onTap: () => onToggle(true),
          ),
        ],
      ),
    );
  }
}

class _ToggleBtn extends StatelessWidget {
  const _ToggleBtn({
    required this.label,
    required this.active,
    required this.onTap,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 36,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: active ? const Color(0xFF16A34A) : Colors.transparent,
          borderRadius: BorderRadius.circular(99),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: active ? Colors.white : const Color(0xFF374151),
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Selected court preview panel
// ---------------------------------------------------------------------------

/// Always-visible bottom panel. Shows selected court info when a court has
/// been tapped; otherwise shows a prompt to tap a marker.
class _SelectedCourtPanel extends StatelessWidget {
  const _SelectedCourtPanel({required this.cubit});

  final MapCubit? cubit;

  @override
  Widget build(BuildContext context) {
    if (cubit == null) return _buildPanel(context, null);

    return BlocBuilder<MapCubit, MapState>(
      builder: (context, state) {
        final selected = state is MapLoaded ? state.selectedCourt : null;
        return _buildPanel(context, selected);
      },
    );
  }

  Widget _buildPanel(BuildContext context, CourtAvailability? court) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 24,
            offset: Offset(0, -8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFFE5E7EB),
              borderRadius: BorderRadius.circular(99),
            ),
          ),
          const SizedBox(height: 12),
          court == null
              ? _buildPlaceholder(context)
              : _buildCourtInfo(context, court),
        ],
      ),
    );
  }

  Widget _buildPlaceholder(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.touch_app_outlined,
            size: 18, color: Color(0xFF9CA3AF)),
        const SizedBox(width: 8),
        Text(
          'Chạm vào sân để xem chi tiết',
          style: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.copyWith(color: const Color(0xFF9CA3AF)),
        ),
      ],
    );
  }

  Widget _buildCourtInfo(BuildContext context, CourtAvailability court) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF16A34A), Color(0xFF22C55E)],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.sports_tennis, size: 26, color: Colors.white),
        ),
        const SizedBox(width: 12),
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
                        color: Color(0xFF111827),
                      ),
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: court.openSlotCount > 0
                          ? const Color(0xFFDCFCE7)
                          : const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(99),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: court.openSlotCount > 0
                                ? const Color(0xFF22C55E)
                                : const Color(0xFF9CA3AF),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          court.openSlotCount > 0
                              ? '${court.openSlotCount} slot trống'
                              : 'Hết slot',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: court.openSlotCount > 0
                                ? const Color(0xFF15803D)
                                : const Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                height: 40,
                child: FilledButton(
                  onPressed: () => context.push('/court/${court.courtId}'),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF16A34A),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Xem sân & đặt',
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
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Slot list panel (open-slot browse view)
// ---------------------------------------------------------------------------

class _SlotListPanel extends StatelessWidget {
  const _SlotListPanel({required this.onClose});

  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxHeight: 340),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 24,
            offset: Offset(0, -8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE5E7EB),
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
                const Spacer(),
                const Text(
                  'Slot trống',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF111827),
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: onClose,
                  child: const Icon(Icons.close,
                      size: 20, color: Color(0xFF6B7280)),
                ),
              ],
            ),
          ),
          Expanded(
            child: BlocBuilder<SlotListCubit, SlotListState>(
              builder: (context, state) => switch (state) {
                SlotListInitial() ||
                SlotListLoading() =>
                  const Center(child: CircularProgressIndicator()),
                SlotListLoaded(:final slots) when slots.isEmpty => const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Text(
                        'Không có slot chơi ghép nào\ntrong khu vực này.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ),
                  ),
                SlotListLoaded(:final slots) => ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                    itemCount: slots.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, i) => _SlotCard(slot: slots[i]),
                  ),
                SlotListError(:final message) => Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        message,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.red,
                        ),
                      ),
                    ),
                  ),
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _SlotCard extends StatelessWidget {
  const _SlotCard({required this.slot});

  final Slot slot;

  static const _sportColors = {
    'pickleball': Color(0xFF0EA5E9),
    'football': Color(0xFF16A34A),
    'badminton': Color(0xFFEF4444),
    'tennis': Color(0xFFEAB308),
  };

  static String _fmtTime(DateTime dt) =>
      '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';

  static String _slotTimeLabel(Slot slot) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final slotDay =
        DateTime(slot.startTime.year, slot.startTime.month, slot.startTime.day);
    final timeRange = '${_fmtTime(slot.startTime)} – ${_fmtTime(slot.endTime)}';
    if (slotDay == today) return 'Hôm nay · $timeRange';
    if (slotDay == today.add(const Duration(days: 1))) {
      return 'Ngày mai · $timeRange';
    }
    const dow = ['CN', 'T2', 'T3', 'T4', 'T5', 'T6', 'T7'];
    final d = dow[slot.startTime.weekday % 7];
    final date =
        '${slot.startTime.day.toString().padLeft(2, '0')}/${slot.startTime.month.toString().padLeft(2, '0')}';
    return '$d, $date · $timeRange';
  }

  @override
  Widget build(BuildContext context) {
    final color = _sportColors[slot.sportType] ?? const Color(0xFF6B7280);
    final remaining = slot.maxPlayers - slot.currentPlayers;

    return GestureDetector(
      onTap: () => context.push('/slot/${slot.id}'),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color(0xFFE5E7EB)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withAlpha(26),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.sports, color: color, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    slot.courtName,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF111827),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _slotTimeLabel(slot),
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${slot.currentPlayers}/${slot.maxPlayers} người',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF374151),
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: slot.isFull
                        ? const Color(0xFFF3F4F6)
                        : const Color(0xFFDCFCE7),
                    borderRadius: BorderRadius.circular(99),
                  ),
                  child: Text(
                    slot.isFull ? 'Đã đủ' : 'Còn $remaining chỗ',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: slot.isFull
                          ? const Color(0xFF9CA3AF)
                          : const Color(0xFF15803D),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                SizedBox(
                  height: 32,
                  child: FilledButton(
                    onPressed: slot.isFull
                        ? null
                        : () => context.push('/slot/${slot.id}'),
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF16A34A),
                      disabledBackgroundColor: const Color(0xFFE5E7EB),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                    ),
                    child: Text(
                      slot.isFull ? 'Đã đủ' : 'Xem',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: slot.isFull
                            ? const Color(0xFF9CA3AF)
                            : Colors.white,
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
// Filter bottom sheet
// ---------------------------------------------------------------------------

const _kSportChips = [
  _SportChipEntry(label: 'Tất cả', slug: ''),
  _SportChipEntry(label: 'Bóng đá', slug: 'football'),
  _SportChipEntry(label: 'Cầu lông', slug: 'badminton'),
  _SportChipEntry(label: 'Pickleball', slug: 'pickleball'),
  _SportChipEntry(label: 'Tennis', slug: 'tennis'),
  _SportChipEntry(label: 'Đa năng', slug: 'multi'),
];

const _kDistanceOptions = [1.0, 3.0, 5.0];

class _FilterSheet extends StatelessWidget {
  const _FilterSheet();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MapFilterCubit, MapFilterState>(
      builder: (context, state) {
        final cubit = context.read<MapFilterCubit>();
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE5E7EB),
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Bộ lọc',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF111827),
                    ),
                  ),
                  TextButton(
                    onPressed: cubit.clearAll,
                    child: const Text(
                      'Đặt lại',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF16A34A),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              const Text(
                'Môn thể thao',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF374151),
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _kSportChips.map((entry) {
                  final isAll = entry.slug.isEmpty;
                  final active = isAll
                      ? state.selectedSports.isEmpty
                      : state.selectedSports.contains(entry.slug);
                  return GestureDetector(
                    onTap: () {
                      if (isAll) {
                        cubit.filterBySports([]);
                      } else {
                        final updated = Set<String>.from(state.selectedSports);
                        if (updated.contains(entry.slug)) {
                          updated.remove(entry.slug);
                        } else {
                          updated.add(entry.slug);
                        }
                        cubit.filterBySports(updated.toList());
                      }
                    },
                    child: _FilterPill(label: entry.label, active: active),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              const Text(
                'Khoảng cách',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF374151),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: _kDistanceOptions.asMap().entries.map((e) {
                  final km = e.value;
                  final active = state.maxDistanceKm == km;
                  return Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(
                          right: e.key < _kDistanceOptions.length - 1 ? 8 : 0),
                      child: GestureDetector(
                        onTap: () => cubit.filterByDistance(active ? null : km),
                        child: _FilterPill(
                          label: '${km.toInt()} km',
                          active: active,
                          centered: true,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              const Text(
                'Trạng thái',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF374151),
                ),
              ),
              const SizedBox(height: 8),
              _CheckboxRow(
                label: 'Chỉ hiển thị sân còn slot trống',
                checked: state.onlyWithOpenSlots,
                onTap: cubit.toggleOnlyOpenSlots,
              ),
              const SizedBox(height: 12),
              // "Có slot mở chơi ghép" — pending open-slot feature
              _CheckboxRow(
                label: 'Có slot mở chơi ghép',
                checked: false,
                onTap: () {},
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF16A34A),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Áp dụng',
                    style: TextStyle(
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
      },
    );
  }
}

class _FilterPill extends StatelessWidget {
  const _FilterPill({
    required this.label,
    this.active = false,
    this.centered = false,
  });

  final String label;
  final bool active;
  final bool centered;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: active ? const Color(0xFF111827) : Colors.white,
        border: Border.all(
          color: active ? const Color(0xFF111827) : const Color(0xFFE5E7EB),
        ),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        label,
        textAlign: centered ? TextAlign.center : TextAlign.start,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: active ? Colors.white : const Color(0xFF374151),
        ),
      ),
    );
  }
}

class _CheckboxRow extends StatelessWidget {
  const _CheckboxRow({
    required this.label,
    required this.checked,
    required this.onTap,
  });

  final String label;
  final bool checked;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              color: checked ? const Color(0xFF16A34A) : Colors.white,
              border: Border.all(
                color:
                    checked ? const Color(0xFF16A34A) : const Color(0xFFD1D5DB),
                width: 2,
              ),
              borderRadius: BorderRadius.circular(6),
            ),
            child: checked
                ? const Icon(Icons.check, size: 14, color: Colors.white)
                : null,
          ),
          const SizedBox(width: 12),
          Text(
            label,
            style: const TextStyle(fontSize: 14, color: Color(0xFF374151)),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Data classes
// ---------------------------------------------------------------------------

@immutable
class _SportChipEntry {
  const _SportChipEntry({required this.label, required this.slug});
  final String label;
  final String slug;
}
