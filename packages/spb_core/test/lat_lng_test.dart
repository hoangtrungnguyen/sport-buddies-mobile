import 'package:spb_core/spb_core.dart';
import 'package:test/test.dart';

void main() {
  group('LatLng', () {
    test('stores lat and lng', () {
      const p = LatLng(10.0, 20.0);
      expect(p.lat, 10.0);
      expect(p.lng, 20.0);
    });

    test('value equality holds for identical coordinates', () {
      const a = LatLng(1.5, 2.5);
      const b = LatLng(1.5, 2.5);
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('value equality fails for different coordinates', () {
      const a = LatLng(1.5, 2.5);
      const b = LatLng(1.5, 2.6);
      expect(a, isNot(equals(b)));
    });

    test('hcmcDefault is the HCMC city center constant', () {
      expect(LatLng.hcmcDefault.lat, 10.776);
      expect(LatLng.hcmcDefault.lng, 106.701);
    });

    test('hcmcDefault is a compile-time const reused across references', () {
      expect(identical(LatLng.hcmcDefault, LatLng.hcmcDefault), isTrue);
    });

    test('toString is human-readable', () {
      const p = LatLng(10.776, 106.701);
      expect(p.toString(), contains('10.776'));
      expect(p.toString(), contains('106.701'));
    });
  });
}
