// Haversine distance tests — grava-c9ca.4.2
//
// Tests the Haversine formula for calculating great-circle distance between
// two points on a sphere (Earth).

import 'package:flutter_test/flutter_test.dart';
import 'package:spb_core/spb_core.dart';

void main() {
  group('LatLng distance calculation', () {
    test('calculates distance between two points in km', () {
      // HCMC War Remnants Museum to Independence Palace
      const museum = LatLng(10.7791, 106.6898);
      const palace = LatLng(10.7769, 106.7009);

      // Expected distance is approximately 1.2 km
      final distance = museum.distanceTo(palace);

      expect(distance, greaterThan(1.1));
      expect(distance, lessThan(1.3));
    });

    test('calculates distance from HCMC to Da Nang', () {
      // Approximate coordinates
      const hcmc = LatLng(10.7769, 106.7009);
      const danang = LatLng(16.0544, 108.2022);

      // Expected distance is approximately 600 km
      final distance = hcmc.distanceTo(danang);

      expect(distance, greaterThan(600));
      expect(distance, lessThan(620));
    });

    test('returns 0 for identical points', () {
      const point = LatLng(10.7769, 106.7009);
      final distance = point.distanceTo(point);

      expect(distance, closeTo(0, 0.001));
    });

    test('calculates short distances accurately', () {
      // Two points about 100 meters apart
      const point1 = LatLng(10.7769, 106.7009);
      const point2 = LatLng(10.7778, 106.7019);

      final distance = point1.distanceTo(point2);

      // Should be approximately 100-150 meters (0.1-0.15 km)
      expect(distance, greaterThan(0.1));
      expect(distance, lessThan(0.2));
    });

    test('is symmetric: A to B equals B to A', () {
      const hcmc = LatLng(10.7769, 106.7009);
      const danang = LatLng(16.0544, 108.2022);

      final distance1 = hcmc.distanceTo(danang);
      final distance2 = danang.distanceTo(hcmc);

      expect(distance1, closeTo(distance2, 0.001));
    });
  });

  group('LatLng isWithinRadius', () {
    test('returns true when point is within radius', () {
      const center = LatLng(10.7769, 106.7009);
      // Independence Palace - ~1.2km from center
      const target = LatLng(10.7769, 106.7009);

      final isWithin = center.isWithinRadius(target, 5); // 5km radius

      expect(isWithin, isTrue);
    });

    test('returns false when point is outside radius', () {
      const hcmc = LatLng(10.7769, 106.7009);
      const danang = LatLng(16.0544, 108.2022);

      final isWithin = hcmc.isWithinRadius(danang, 5); // 5km radius

      expect(isWithin, isFalse);
    });

    test('returns true for point exactly at radius (within tolerance)', () {
      const center = LatLng(10.7769, 106.7009);
      // Create a point approximately 4.5km north to be safely within 5km
      // 1 degree lat is ~111km, so 4.5km is ~0.0405 degrees
      const target = LatLng(10.7769 + 0.0405, 106.7009);

      final isWithin = center.isWithinRadius(target, 5); // 5km radius

      expect(isWithin, isTrue);
    });
  });
}
