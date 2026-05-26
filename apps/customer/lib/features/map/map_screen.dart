// Map screen — CAPP-030 / grava-c9ca.1.3
//
// Renders a flutter_map widget centred on Ho Chi Minh City and overlays
// approved courts as map markers. Tapping a marker shows the court name in
// a bottom sheet.
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
import 'package:customer/features/map/court_repository_impl.dart';
import 'package:customer/features/map/map_cubit.dart';
import 'package:customer/features/map/map_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:spb_core/models/court.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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

/// Map screen — shows a zoomable map of Ho Chi Minh City with approved courts
/// overlaid as markers.
///
/// Wraps itself in a [BlocProvider<MapCubit>] so that it can be placed in the
/// route tree without a parent provider. The cubit triggers [MapCubit.loadCourts]
/// on first build via [BlocProvider.create].
class MapScreen extends StatelessWidget {
  const MapScreen({super.key, this.cubit});

  /// Optional cubit injection — used in tests to provide a pre-configured cubit
  /// without initialising Supabase.
  final MapCubit? cubit;

  @override
  Widget build(BuildContext context) {
    if (cubit != null) {
      return BlocProvider<MapCubit>.value(
        value: cubit!,
        child: const _MapBody(),
      );
    }

    return BlocProvider<MapCubit>(
      create: (_) => MapCubit(
        repository: SupabaseCourtRepository(
          client: Supabase.instance.client,
        ),
      )..loadCourts(),
      child: const _MapBody(),
    );
  }
}

/// Internal widget tree that reads from [MapCubit] via [BlocBuilder].
class _MapBody extends StatelessWidget {
  const _MapBody();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bản đồ sân gần bạn'),
      ),
      body: BlocBuilder<MapCubit, MapState>(
        builder: (context, state) {
          return Stack(
            children: [
              FlutterMap(
                options: const MapOptions(
                  initialCenter: _hcmcLatLng,
                  initialZoom: _defaultZoom,
                ),
                children: [
                  TileLayer(
                    urlTemplate: _tileUrlTemplate(),
                    userAgentPackageName: 'vn.sportbuddies.customer',
                  ),
                  if (state is MapLoaded)
                    MarkerLayer(
                      markers: state.courts.map(_buildMarker).toList(),
                    ),
                ],
              ),
              if (state is MapLoading)
                const Positioned(
                  top: 12,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                ),
              if (state is MapError)
                Positioned(
                  bottom: 16,
                  left: 16,
                  right: 16,
                  child: Material(
                    elevation: 4,
                    borderRadius: BorderRadius.circular(8),
                    color: Theme.of(context).colorScheme.errorContainer,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      child: Text(
                        'Không tải được sân. Thử lại sau.',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onErrorContainer,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Marker _buildMarker(Court court) {
    return Marker(
      point: LatLng(court.lat, court.lng),
      width: 40,
      height: 40,
      child: _CourtMarker(court: court),
    );
  }
}

/// Tappable marker pin that shows the court name in a modal bottom sheet.
class _CourtMarker extends StatelessWidget {
  const _CourtMarker({required this.court});

  final Court court;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showCourtSheet(context, court),
      child: const Icon(
        Icons.location_pin,
        color: Colors.red,
        size: 40,
      ),
    );
  }

  void _showCourtSheet(BuildContext context, Court court) {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => _CourtBottomSheet(court: court),
    );
  }
}

/// Bottom sheet displaying brief court info on marker tap.
class _CourtBottomSheet extends StatelessWidget {
  const _CourtBottomSheet({required this.court});

  final Court court;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            court.name,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            '${court.lat.toStringAsFixed(4)}, ${court.lng.toStringAsFixed(4)}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey.shade600,
                ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
