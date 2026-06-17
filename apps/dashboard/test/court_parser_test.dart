import 'dart:convert';
import 'dart:typed_data';

import 'package:dashboard/features/courts/service/court_info_parser_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

/// Returns a canned response for every request — keeps the parser offline so
/// the test exercises the JSON→model mapping, not the live Gemini API.
class _StubAdapter implements HttpClientAdapter {
  _StubAdapter(this.body, {this.statusCode = 200});
  final String body;
  final int statusCode;
  RequestOptions? lastRequest;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    lastRequest = options;
    return ResponseBody.fromString(body, statusCode, headers: {
      Headers.contentTypeHeader: [Headers.jsonContentType],
    });
  }

  @override
  void close({bool force = false}) {}
}

/// Wraps [innerJson] in the Gemini `candidates → content → parts → text`
/// envelope the parser unwraps.
String _gemini(String innerJson) => jsonEncode({
      'candidates': [
        {
          'content': {
            'parts': [
              {'text': innerJson}
            ]
          }
        }
      ]
    });

(CourtInfoParserService, _StubAdapter) _serviceWith(
  String body, {
  int statusCode = 200,
  String apiKey = 'test-key',
}) {
  final adapter = _StubAdapter(body, statusCode: statusCode);
  final dio = Dio()..httpClientAdapter = adapter;
  return (CourtInfoParserService(apiKey: apiKey, dio: dio), adapter);
}

void main() {
  group('CourtInfoParserService.parse', () {
    test('maps the Gemini JSON envelope to a CourtParseResult', () async {
      final inner = jsonEncode({
        'name': 'Sân Pickleball ABC',
        'address': '123 Nguyễn Trãi, Q1',
        'phone': '0901234567',
        'lat': 10.77,
        'lng': 106.66,
        'openHour': 6,
        'closeHour': 22,
        'amenities': ['WiFi', 'Bãi đậu xe', 'Không hợp lệ'],
        'venues': [
          {
            'name': 'Sân 1',
            'sportType': 'Pickleball',
            'pricePerHour': 120000,
            'indoor': true,
          },
        ],
      });
      final (service, _) = _serviceWith(_gemini(inner));

      final r = await service.parse('bất kỳ nội dung nào');

      expect(r.isEmpty, isFalse);
      expect(r.name, 'Sân Pickleball ABC');
      expect(r.address, '123 Nguyễn Trãi, Q1');
      expect(r.phone, '0901234567');
      expect(r.lat, 10.77);
      expect(r.lng, 106.66);
      expect(r.openHour, 6);
      expect(r.closeHour, 22);
      // Unknown amenity filtered out; known ones kept.
      expect(r.amenities, ['WiFi', 'Bãi đậu xe']);
      expect(r.venues, hasLength(1));
      expect(r.venues.single.name, 'Sân 1');
      expect(r.venues.single.sportType, 'Pickleball');
      expect(r.venues.single.pricePerHour, 120000);
      expect(r.venues.single.indoor, isTrue);
    });

    test('keeps early-open / late-close hours (5h–23h)', () async {
      // Regression: the prompt used to cap hours at 6–22, so "mở 5h đến 23h"
      // came back null. The mapping itself must pass any hour through.
      final inner = jsonEncode({'name': 'Sân X', 'openHour': 5, 'closeHour': 23});
      final (service, _) = _serviceWith(_gemini(inner));

      final r = await service.parse('Sân X mở 5h đến 23h');

      expect(r.openHour, 5);
      expect(r.closeHour, 23);
    });

    test('sends the configured key to the generateContent endpoint', () async {
      final (service, adapter) = _serviceWith(_gemini('{"name":"X"}'));

      await service.parse('x');

      expect(adapter.lastRequest, isNotNull);
      expect(adapter.lastRequest!.queryParameters['key'], 'test-key');
      expect(adapter.lastRequest!.uri.toString(),
          contains('generativelanguage.googleapis.com'));
      expect(adapter.lastRequest!.uri.toString(), contains('generateContent'));
    });

    test('throws StateError when no API key is configured', () async {
      final (service, _) = _serviceWith(_gemini('{}'), apiKey: '');
      await expectLater(service.parse('x'), throwsA(isA<StateError>()));
    });

    test('surfaces a non-200 response as StateError', () async {
      final (service, _) =
          _serviceWith('{"error":{"code":404}}', statusCode: 404);
      await expectLater(service.parse('x'), throwsA(isA<StateError>()));
    });

    test('surfaces non-JSON AI text as StateError', () async {
      final (service, _) = _serviceWith(_gemini('xin chào — không phải JSON'));
      await expectLater(service.parse('x'), throwsA(isA<StateError>()));
    });
  });
}
