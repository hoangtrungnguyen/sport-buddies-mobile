// Map screen — CAPP-030 / grava-c9ca.1.1
//
// Renders a flutter_map widget centred on Ho Chi Minh City.
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
import 'package:flutter/material.dart';
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

/// Map screen — shows a zoomable map of Ho Chi Minh City.
///
/// This is a placeholder screen (no BLoC / cubit yet) that will grow as
/// sibling tasks (grava-c9ca.1.2, grava-c9ca.1.3) add location and court
/// marker support.
class MapScreen extends StatelessWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bản đồ sân gần bạn'),
      ),
      body: FlutterMap(
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
    );
  }
}
