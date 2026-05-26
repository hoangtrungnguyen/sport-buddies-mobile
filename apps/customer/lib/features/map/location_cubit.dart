// Location feature — Cubit.
//
// Requests device location permission and emits a GPS coordinate or the
// HCMC default fallback (10.7769, 106.7009).
//
// State machine:
//   LocationInitial
//     → requestAndFetch()
//   LocationLoading
//     → service disabled  → LocationLoaded(hcmc, isDefault: true)
//     → denied/forever    → LocationLoaded(hcmc, isDefault: true)
//     → granted           → LocationLoaded(gps,  isDefault: false)
//     → exception         → LocationLoaded(hcmc, isDefault: true)

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import 'location_service.dart';
import 'location_state.dart';

/// Default map centre: Ho Chi Minh City, Vietnam.
const _hcmcCenter = LatLng(10.7769, 106.7009);

/// Manages device location permission and resolves a map center coordinate.
class LocationCubit extends Cubit<LocationState> {
  LocationCubit(this._service) : super(const LocationInitial());

  final LocationService _service;

  /// Requests location permission and fetches the current GPS position.
  ///
  /// Emits [LocationLoading] immediately, then settles on [LocationLoaded]
  /// with either the real GPS coordinate or the HCMC fallback.
  Future<void> requestAndFetch() async {
    emit(const LocationLoading());
    try {
      final serviceEnabled = await _service.isLocationServiceEnabled();
      if (!serviceEnabled) {
        emit(const LocationLoaded(center: _hcmcCenter, isDefault: true));
        return;
      }

      LocationPermission permission = await _service.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await _service.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        emit(const LocationLoaded(center: _hcmcCenter, isDefault: true));
        return;
      }

      final position = await _service.getCurrentPosition();
      emit(LocationLoaded(
        center: LatLng(position.latitude, position.longitude),
        isDefault: false,
      ));
    } catch (_) {
      emit(const LocationLoaded(center: _hcmcCenter, isDefault: true));
    }
  }
}
