// Unit tests for MapTileProvider strategy pattern.
//
// MapTileProvider.fromEnv() is tested indirectly here because Env values are
// compile-time constants — we test each concrete strategy directly.

import 'package:customer/features/map/map_tile_provider.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('GoogleMapsTileProvider', () {
    test('urlTemplate contains google host', () {
      const provider = GoogleMapsTileProvider();
      expect(provider.urlTemplate, contains('mt1.google.com'));
    });

    test('urlTemplate contains {x}, {y}, {z} placeholders', () {
      const provider = GoogleMapsTileProvider();
      expect(provider.urlTemplate, contains('{x}'));
      expect(provider.urlTemplate, contains('{y}'));
      expect(provider.urlTemplate, contains('{z}'));
    });

    test('urlTemplate without apiKey does NOT contain "key="', () {
      const provider = GoogleMapsTileProvider();
      expect(provider.urlTemplate, isNot(contains('key=')));
    });

    test('urlTemplate with apiKey appends key param', () {
      const provider = GoogleMapsTileProvider(apiKey: 'MY_KEY');
      expect(provider.urlTemplate, contains('key=MY_KEY'));
    });
  });

  group('VietMapGLProvider', () {
    test('styleUrl contains vietmap host', () {
      const provider = VietMapGLProvider(apiKey: 'vm_key');
      expect(provider.styleUrl, contains('vietmap.vn'));
    });

    test('styleUrl embeds apiKey', () {
      const provider = VietMapGLProvider(apiKey: 'vm_key');
      expect(provider.styleUrl, contains('vm_key'));
    });
  });

  group('OpenStreetMapTileProvider', () {
    test('urlTemplate points to openstreetmap.org', () {
      const provider = OpenStreetMapTileProvider();
      expect(provider.urlTemplate, contains('openstreetmap.org'));
    });

    test('urlTemplate contains {x}, {y}, {z} placeholders', () {
      const provider = OpenStreetMapTileProvider();
      expect(provider.urlTemplate, contains('{x}'));
      expect(provider.urlTemplate, contains('{y}'));
      expect(provider.urlTemplate, contains('{z}'));
    });
  });
}
