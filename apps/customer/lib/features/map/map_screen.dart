// Map screen — CAPP-030 / grava-c9ca.1.2
//
// Renders a flutter_map widget.  The map centre is resolved reactively:
//
//   1. While [LocationCubit] is fetching (permission dialog / GPS fix) the
//      map shows the HCMC default so the user sees something immediately.
//   2. Once the cubit settles on [LocationLoaded] the map pans to either the
//      real GPS coordinate or the HCMC fallback (when permission was denied).
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

import 'package:customer/core/env/env.dart';
import 'package:customer/features/map/location_cubit.dart';
import 'package:customer/features/map/location_service.dart';
import 'package:customer/features/map/location_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

/// Default map centre: Ho Chi Minh City, Vietnam.
const _hcmcLatLng = LatLng(10.7769, 106.7009);
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

/// Map screen — shows a zoomable map of Ho Chi Minh City, centred on the
/// user's GPS position when location permission is granted.
///
/// Wraps itself in a [BlocProvider] so callers don't need to inject the
/// [LocationCubit] manually.
///
/// [cubit] is an optional override used only in tests — pass a
/// pre-configured [LocationCubit] to avoid making real GPS calls.
class MapScreen extends StatelessWidget {
  const MapScreen({super.key, this.cubit});

  /// Optional cubit override for widget tests.
  ///
  /// When null, [MapScreen] creates a real [LocationCubit] backed by
  /// [GeolocatorLocationService] and immediately starts fetching.
  final LocationCubit? cubit;

  @override
  Widget build(BuildContext context) {
    final effectiveCubit = cubit ??
        (LocationCubit(const GeolocatorLocationService())..requestAndFetch());

    return BlocProvider<LocationCubit>.value(
      value: effectiveCubit,
      child: const _MapView(),
    );
  }
}

/// Inner stateless widget that reads [LocationCubit] from context.
class _MapView extends StatelessWidget {
  const _MapView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bản đồ sân gần bạn'),
      ),
      body: BlocBuilder<LocationCubit, LocationState>(
        builder: (context, state) {
          // While loading (or initial before first emission) show HCMC.
          final center = switch (state) {
            LocationLoaded(:final center) => center,
            _ => _hcmcLatLng,
          };

          return FlutterMap(
            options: MapOptions(
              initialCenter: center,
              initialZoom: _defaultZoom,
            ),
            children: [
              TileLayer(
                urlTemplate: _tileUrlTemplate(),
                userAgentPackageName: 'vn.sportbuddies.customer',
              ),
            ],
          );
        },
      ),
    );
  }
}
