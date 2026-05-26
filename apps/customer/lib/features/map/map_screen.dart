// Map screen — grava-c9ca.3.1 (extends grava-c9ca.1.1)
//
// Renders a flutter_map widget centred on Ho Chi Minh City with a sport
// filter bar at the top.
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
import 'package:customer/features/map/map_cubit.dart';
import 'package:customer/features/map/map_state.dart';
import 'package:customer/features/map/sport_filter_bar.dart';
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

/// Map screen — shows a zoomable map of Ho Chi Minh City with sport filters.
///
/// Wraps itself in a [BlocProvider] for [MapCubit] so callers don't need to
/// provision the cubit externally.
class MapScreen extends StatelessWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => MapCubit(),
      child: const _MapView(),
    );
  }
}

class _MapView extends StatelessWidget {
  const _MapView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bản đồ sân gần bạn'),
      ),
      body: Column(
        children: [
          BlocBuilder<MapCubit, MapState>(
            builder: (context, state) => SportFilterBar(
              selectedSports: state.selectedSports,
              onSportsChanged: (sports) =>
                  context.read<MapCubit>().filterBySports(sports.toList()),
            ),
          ),
          Expanded(
            child: FlutterMap(
              options: const MapOptions(
                initialCenter: _hcmcLatLng,
                initialZoom: _defaultZoom,
              ),
              children: [
                TileLayer(
                  urlTemplate: _tileUrlTemplate(),
                  userAgentPackageName: 'vn.sportbuddies.customer',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
