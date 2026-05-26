// Map screen — CAPP-030 / grava-c9ca.1.1, CAPP-031 / grava-c9ca.2.1
//
// Renders a flutter_map widget centred on Ho Chi Minh City with colour-coded
// court markers:
//   - Green  (AppColors.primary): court has at least one open future slot.
//   - Grey   (0xFF9E9E9E):        court is fully booked or has no future slots.
//
// Tile source strategy:
//   • When [Env.vietmapApiKey] is non-empty (prod / staging), the tile URL
//     template points at the VietMap raster tile service with the key embedded.
//   • When the key is empty (local dev, unit tests, CI) the widget falls back
//     to OpenStreetMap tiles — no key required and no network call is made in
//     widget tests because flutter_map's TileLayer defers fetching.
//
// The API key is a compile-time constant injected via:
//   --dart-define=VIETMAP_API_KEY=<key>
//
// MapCubit is provided externally (BlocProvider in the router builder, §6.2).
// When no cubit is present in context (e.g. legacy widget tests that pump
// MapScreen directly), the map renders without any court markers — graceful
// degradation via [_MapBody] which checks for a cubit via [BlocProvider.of]
// with `listen: false` inside a try-catch.

import 'package:customer/core/env/env.dart';
import 'package:customer/features/map/cubit/map_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as ll;
import 'package:spb_core/spb_core.dart';

/// Default map centre: Ho Chi Minh City, Vietnam.
const _hcmcLatLng = ll.LatLng(10.7769, 106.7009);
const _defaultZoom = 13.0;

/// VietMap raster tile URL template (requires a valid API key).
/// Ref: https://maps.vietmap.vn/docs/map-api/raster-tile/
const _vietmapTileUrl =
    'https://maps.vietmap.vn/api/maps/raster/v1/{z}/{x}/{y}.png?apikey={key}';

/// OpenStreetMap fallback tile URL (no key required).
const _osmTileUrl = 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';

/// Returns the tile URL template, choosing VietMap when a key is available.
String _tileUrlTemplate() {
  const key = Env.vietmapApiKey;
  if (key.isEmpty) return _osmTileUrl;
  return _vietmapTileUrl.replaceAll('{key}', key);
}

/// Map screen — shows a zoomable map of Ho Chi Minh City.
///
/// Court availability markers are rendered when a [MapCubit] is present in the
/// widget tree above this screen. Without a cubit the map renders normally with
/// no markers (graceful degradation for widget tests that don't need them).
class MapScreen extends StatelessWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bản đồ sân gần bạn'),
      ),
      body: const _MapBody(),
    );
  }
}

// ---------------------------------------------------------------------------
// _MapBody — renders the map and optionally the court markers.
// ---------------------------------------------------------------------------

/// Internal body widget that resolves [MapCubit] presence at build time.
///
/// Keeping this as a separate [StatefulWidget] lets us call [MapCubit.loadCourts]
/// once in [initState] without triggering a rebuild storm.
class _MapBody extends StatefulWidget {
  const _MapBody();

  @override
  State<_MapBody> createState() => _MapBodyState();
}

class _MapBodyState extends State<_MapBody> {
  MapCubit? _cubit;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Resolve the cubit once (idempotent). If absent we get null and render
    // without markers.
    _cubit ??= _tryReadCubit(context);
    if (_cubit?.state is MapInitial) {
      _cubit!.loadCourts();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_cubit == null) {
      // No cubit in context — render plain map (backwards-compat with tests
      // that pump MapScreen without BlocProvider<MapCubit>).
      return _buildMap(context, courts: const []);
    }

    return BlocConsumer<MapCubit, MapState>(
      listener: (context, state) {
        if (state is MapError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      builder: (context, state) {
        final courts =
            state is MapLoaded ? state.courts : <CourtAvailability>[];
        final isLoading = state is MapLoading;

        return Stack(
          children: [
            _buildMap(context, courts: courts),
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
  }

  /// Attempts to read [MapCubit] from [context]; returns `null` when absent.
  static MapCubit? _tryReadCubit(BuildContext context) {
    try {
      return BlocProvider.of<MapCubit>(context, listen: false);
    } catch (_) {
      return null;
    }
  }

  /// Renders the base [FlutterMap] with optional court [markers].
  static Widget _buildMap(
    BuildContext context, {
    required List<CourtAvailability> courts,
  }) {
    return FlutterMap(
      options: const MapOptions(
        initialCenter: _hcmcLatLng,
        initialZoom: _defaultZoom,
      ),
      children: [
        TileLayer(
          urlTemplate: _tileUrlTemplate(),
          userAgentPackageName: 'vn.sportbuddies.customer',
        ),
        MarkerLayer(
          markers: courts.map(_buildMarker).toList(),
        ),
      ],
    );
  }

  /// Builds a coloured circular marker for [court].
  static Marker _buildMarker(CourtAvailability court) {
    return Marker(
      point: ll.LatLng(court.lat, court.lng),
      width: 24,
      height: 24,
      child: Tooltip(
        message: court.name,
        child: Container(
          decoration: BoxDecoration(
            color: court.markerColor,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
