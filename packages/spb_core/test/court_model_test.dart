// Unit tests for the Court model — grava-c9ca.1.3
//
// These tests run in pure Dart (no Flutter, no Supabase) and verify:
//   1. Court can be constructed with the required fields.
//   2. Court.fromJson correctly parses a Supabase-style row map.
//   3. Equality and hashCode are consistent.
//   4. toString is human-readable.

import 'package:spb_core/models/court.dart';
import 'package:test/test.dart';

void main() {
  group('Court model', () {
    const court = Court(
      id: 'abc-123',
      name: 'Sân Tao Đàn',
      lat: 10.7769,
      lng: 106.7009,
    );

    test('constructs correctly', () {
      expect(court.id, 'abc-123');
      expect(court.name, 'Sân Tao Đàn');
      expect(court.lat, 10.7769);
      expect(court.lng, 106.7009);
    });

    test('fromJson parses a Supabase-style row', () {
      final json = {
        'id': 'abc-123',
        'name': 'Sân Tao Đàn',
        'lat': 10.7769,
        'lng': 106.7009,
      };
      final parsed = Court.fromJson(json);
      expect(parsed, court);
    });

    test('fromJson parses numeric fields stored as int', () {
      final json = {
        'id': 'xyz',
        'name': 'Sân B',
        'lat': 10,
        'lng': 106,
      };
      final parsed = Court.fromJson(json);
      expect(parsed.lat, 10.0);
      expect(parsed.lng, 106.0);
    });

    test('equality: two identical courts are equal', () {
      const c2 = Court(id: 'abc-123', name: 'Sân Tao Đàn', lat: 10.7769, lng: 106.7009);
      expect(court, c2);
    });

    test('equality: different id → not equal', () {
      const c2 = Court(id: 'other', name: 'Sân Tao Đàn', lat: 10.7769, lng: 106.7009);
      expect(court == c2, isFalse);
    });

    test('hashCode is consistent', () {
      const c2 = Court(id: 'abc-123', name: 'Sân Tao Đàn', lat: 10.7769, lng: 106.7009);
      expect(court.hashCode, c2.hashCode);
    });

    test('toString is human-readable', () {
      expect(court.toString(), contains('abc-123'));
      expect(court.toString(), contains('Sân Tao Đàn'));
    });
  });
}
