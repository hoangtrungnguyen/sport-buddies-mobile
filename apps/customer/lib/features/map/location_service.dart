// Location feature — abstract service interface.
//
// Wrapping the static geolocator API behind an interface makes the cubit
// testable without a real device or platform channel.

import 'package:geolocator/geolocator.dart';

/// Thin abstraction over geolocator's static API.
///
/// The production implementation ([GeolocatorLocationService]) delegates
/// directly to geolocator. Tests inject a mock.
abstract class LocationService {
  /// Returns `true` when the device location service is turned on.
  Future<bool> isLocationServiceEnabled();

  /// Returns the current permission status without prompting the user.
  Future<LocationPermission> checkPermission();

  /// Opens the OS permission dialog and returns the result.
  Future<LocationPermission> requestPermission();

  /// Returns the device's current GPS position.
  ///
  /// Only call after confirming the service is enabled and permission is
  /// granted.
  Future<Position> getCurrentPosition();
}

/// Production implementation that delegates to the geolocator package.
class GeolocatorLocationService implements LocationService {
  const GeolocatorLocationService();

  @override
  Future<bool> isLocationServiceEnabled() =>
      Geolocator.isLocationServiceEnabled();

  @override
  Future<LocationPermission> checkPermission() =>
      Geolocator.checkPermission();

  @override
  Future<LocationPermission> requestPermission() =>
      Geolocator.requestPermission();

  @override
  Future<Position> getCurrentPosition() => Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
}
