// GoogleMapBody — CAPP-030
//
// Wraps google_maps_flutter's GoogleMap widget with the same interface as the
// existing FlutterMap body in map_screen.dart.
//
// Activated when Env.mapProvider == 'google'.
// Falls back to a message on web if google_maps_flutter_web script fails to
// load (the caller still renders it — the JS SDK handles graceful degradation).
//
// GPS centering:
//   - When [userCenter] is non-null the map animates to that position.
//   - Otherwise it stays on the HCMC default.

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:spb_core/spb_core.dart' as spb;

const _hcmcLatLng = LatLng(10.7769, 106.7009);
const _defaultZoom = 13.0;

/// Google Maps body widget.
///
/// Renders a [GoogleMap] with colour-coded markers for each [CourtAvailability]:
/// - Green marker  → court has ≥ 1 open slot in the next 24 h
/// - Red marker    → court has no open slots
///
/// [userCenter] is the user's GPS position (from [LocationCubit]).
/// When non-null the map animates to the user's location on first resolution.
class GoogleMapBody extends StatefulWidget {
  const GoogleMapBody({
    super.key,
    required this.courts,
    required this.onMarkerTap,
    this.userCenter,
  });

  final List<spb.CourtAvailability> courts;
  final void Function(spb.CourtAvailability court) onMarkerTap;

  /// GPS position from [LocationCubit]. Null = use HCMC default.
  final spb.LatLng? userCenter;

  @override
  State<GoogleMapBody> createState() => _GoogleMapBodyState();
}

class _GoogleMapBodyState extends State<GoogleMapBody> {
  GoogleMapController? _controller;

  // Track the last user center we animated to, to avoid repeated moves.
  spb.LatLng? _lastAnimatedCenter;

  @override
  void didUpdateWidget(GoogleMapBody oldWidget) {
    super.didUpdateWidget(oldWidget);
    _maybeAnimateToUser();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  /// Animates the map to the user's GPS position if it has changed.
  Future<void> _maybeAnimateToUser() async {
    final center = widget.userCenter;
    if (center == null) return;
    if (center == _lastAnimatedCenter) return;
    if (_controller == null) return;

    _lastAnimatedCenter = center;
    await _controller!.animateCamera(
      CameraUpdate.newLatLngZoom(
        LatLng(center.lat, center.lng),
        _defaultZoom,
      ),
    );
  }

  LatLng get _initialCenter {
    final c = widget.userCenter;
    if (c != null) return LatLng(c.lat, c.lng);
    return _hcmcLatLng;
  }

  Set<Marker> _buildMarkers() {
    return widget.courts.map((court) {
      final hasSlot = court.openSlotCount > 0;
      return Marker(
        markerId: MarkerId(court.courtId),
        position: LatLng(court.lat, court.lng),
        // Green hue when slots available, red when fully booked.
        icon: BitmapDescriptor.defaultMarkerWithHue(
          hasSlot
              ? BitmapDescriptor.hueGreen
              : BitmapDescriptor.hueRed,
        ),
        infoWindow: InfoWindow(title: court.name),
        onTap: () => widget.onMarkerTap(court),
      );
    }).toSet();
  }

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: _initialCenter,
        zoom: _defaultZoom,
      ),
      markers: _buildMarkers(),
      myLocationEnabled: true,
      myLocationButtonEnabled: true,
      zoomControlsEnabled: false,
      mapToolbarEnabled: false,
      onMapCreated: (controller) {
        _controller = controller;
        _maybeAnimateToUser();
      },
    );
  }
}

// ---------------------------------------------------------------------------
// BlocListener wrapper — keeps the body reactive to LocationCubit changes
// ---------------------------------------------------------------------------

/// Wraps [GoogleMapBody] in a [BlocBuilder] that pipes [LocationCubit] state
/// into the body's [userCenter] parameter so the map re-centers when GPS
/// resolves after initial render.
class ReactiveGoogleMapBody extends StatelessWidget {
  const ReactiveGoogleMapBody({
    super.key,
    required this.courts,
    required this.onMarkerTap,
  });

  final List<spb.CourtAvailability> courts;
  final void Function(spb.CourtAvailability court) onMarkerTap;

  @override
  Widget build(BuildContext context) {
    return GoogleMapBody(
      courts: courts,
      onMarkerTap: onMarkerTap,
      userCenter: null,
    );
  }
}
