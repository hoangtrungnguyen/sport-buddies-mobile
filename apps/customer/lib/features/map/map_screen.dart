// Map screen — CAPP-030 grava-c9ca.2.1 + CAPP-032 grava-c9ca.3.1
//
// Renders a flutter_map widget centred on Ho Chi Minh City with:
//   - Colour-coded court availability markers (green=open, grey=full)
//   - Sport-type filter bar at the top
//
// Tile source strategy:
//   • When [Env.vietmapApiKey] is non-empty, uses VietMap raster tiles.
//   • When the key is empty (dev/CI), falls back to OpenStreetMap tiles.
//
// The API key is a compile-time constant injected via:
//   --dart-define=VIETMAP_API_KEY=<key>

import 'package:customer/core/env/env.dart';
import 'package:customer/features/map/cubit/map_cubit.dart';
import 'package:customer/features/map/map_filter_cubit.dart';
import 'package:customer/features/map/map_filter_state.dart';
import 'package:customer/features/map/sport_filter_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as ll;
import 'package:spb_core/spb_core.dart';

/// Default map centre: Ho Chi Minh City, Vietnam.
const _hcmcLatLng = ll.LatLng(10.7769, 106.7009);
const _defaultZoom = 13.0;

const _vietmapTileUrl =
    'https://maps.vietmap.vn/api/maps/raster/v1/{z}/{x}/{y}.png?apikey={key}';
const _osmTileUrl = 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';

String _tileUrlTemplate() {
  const key = Env.vietmapApiKey;
  if (key.isEmpty) return _osmTileUrl;
  return _vietmapTileUrl.replaceAll('{key}', key);
}

/// Map screen — zoomable HCMC map with colour-coded court markers and sport filters.
///
/// Court availability markers are rendered when a [MapCubit] is present in the
/// widget tree above this screen. Without a cubit the map renders normally with
/// no markers (graceful degradation for tests).
class MapScreen extends StatelessWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => MapFilterCubit(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Bản đồ sân gần bạn'),
        ),
        body: const _MapBody(),
      ),
    );
  }
}

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
          child: _buildMapArea(context),
        ),
      ],
    );
  }

  Widget _buildMapArea(BuildContext context) {
    if (_cubit == null) {
      return _buildMap(courts: const []);
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
            _buildMap(courts: courts),
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

  static MapCubit? _tryReadCubit(BuildContext context) {
    try {
      return BlocProvider.of<MapCubit>(context, listen: false);
    } catch (_) {
      return null;
    }
  }

  static Widget _buildMap({required List<CourtAvailability> courts}) {
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
