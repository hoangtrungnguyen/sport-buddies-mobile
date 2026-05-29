import 'dart:convert';
import 'dart:typed_data';

import 'package:dashboard/features/schedule/repository/manual_booking_repository.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

/// Canned HTTP adapter: returns [response] (or throws [error]) and records the
/// outgoing request for assertions. No real network I/O. Mirrors the adapter in
/// owner_auth_repository_test.dart.
class _FakeAdapter implements HttpClientAdapter {
  _FakeAdapter({this.response, this.error});

  final ResponseBody? response;
  final DioException? error;

  RequestOptions? capturedOptions;
  String? capturedBody;

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    capturedOptions = options;
    if (requestStream != null) {
      final chunks = await requestStream.toList();
      capturedBody = utf8.decode(chunks.expand((c) => c).toList());
    }
    if (error != null) throw error!;
    return response!;
  }
}

ResponseBody _json(Object? body, int status) => ResponseBody.fromString(
      body == null ? '' : jsonEncode(body),
      status,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );

HttpManualBookingRepository _repo(
  _FakeAdapter adapter, {
  String? token = 'tok_123',
}) {
  final dio = Dio(BaseOptions(baseUrl: 'http://test.local'));
  dio.httpClientAdapter = adapter;
  return HttpManualBookingRepository(dio: dio, accessToken: () => token);
}

Future<void> _create(
  HttpManualBookingRepository repo, {
  String? phone,
}) =>
    repo.createManualBooking(
      courtId: 'court-1',
      startAt: DateTime(2026, 5, 14, 18),
      endAt: DateTime(2026, 5, 14, 19, 30),
      customerName: 'Minh',
      customerPhone: phone,
      notes: 'walk-in',
    );

void main() {
  group('HttpManualBookingRepository.createManualBooking', () {
    test('201 completes; posts to the manual endpoint with Bearer + body',
        () async {
      final adapter = _FakeAdapter(response: _json({'id': 'b_1'}, 201));
      final repo = _repo(adapter);

      await _create(repo, phone: '+84901234567');

      expect(adapter.capturedOptions!.path, '/api/bookings/manual');
      expect(adapter.capturedOptions!.method, 'POST');
      expect(
        adapter.capturedOptions!.headers['Authorization'],
        'Bearer tok_123',
      );

      final sent = jsonDecode(adapter.capturedBody!) as Map<String, dynamic>;
      expect(sent['court_id'], 'court-1');
      expect(sent['customer_name'], 'Minh');
      expect(sent['customer_phone'], '+84901234567');
      expect(sent['notes'], 'walk-in');
      // UTC round-trip: the sent date+time, read as UTC, equals the picked instant.
      final sentStart =
          DateTime.parse('${sent['date']}T${sent['start_time']}:00Z');
      expect(sentStart, DateTime(2026, 5, 14, 18).toUtc());
    });

    test('200 also completes', () async {
      final adapter = _FakeAdapter(response: _json({'id': 'b_1'}, 200));
      await _create(_repo(adapter));
      expect(adapter.capturedOptions, isNotNull);
    });

    test('no Authorization header when there is no session token', () async {
      final adapter = _FakeAdapter(response: _json({'id': 'b'}, 201));
      await _create(_repo(adapter, token: null));
      expect(
        adapter.capturedOptions!.headers.containsKey('Authorization'),
        isFalse,
      );
    });

    test('409 → overlap', () async {
      final adapter =
          _FakeAdapter(response: _json({'error': 'Giờ này đã có slot'}, 409));
      expect(
        () => _create(_repo(adapter)),
        throwsA(isA<ManualBookingException>()
            .having((e) => e.code, 'code', 'overlap')
            .having((e) => e.statusCode, 'status', 409)),
      );
    });

    test('400 → invalid_input', () async {
      final adapter = _FakeAdapter(response: _json({'error': 'bad'}, 400));
      expect(
        () => _create(_repo(adapter)),
        throwsA(isA<ManualBookingException>()
            .having((e) => e.code, 'code', 'invalid_input')),
      );
    });

    test('403 → not_owner', () async {
      final adapter = _FakeAdapter(response: _json({}, 403));
      expect(
        () => _create(_repo(adapter)),
        throwsA(isA<ManualBookingException>()
            .having((e) => e.code, 'code', 'not_owner')),
      );
    });

    test('404 → court_not_found', () async {
      final adapter = _FakeAdapter(response: _json({}, 404));
      expect(
        () => _create(_repo(adapter)),
        throwsA(isA<ManualBookingException>()
            .having((e) => e.code, 'code', 'court_not_found')),
      );
    });

    test('503 → service_unavailable', () async {
      final adapter = _FakeAdapter(response: _json({}, 503));
      expect(
        () => _create(_repo(adapter)),
        throwsA(isA<ManualBookingException>()
            .having((e) => e.code, 'code', 'service_unavailable')),
      );
    });

    test('transport failure → network', () async {
      final adapter = _FakeAdapter(
        error: DioException(requestOptions: RequestOptions(path: '/x')),
      );
      expect(
        () => _create(_repo(adapter)),
        throwsA(isA<ManualBookingException>()
            .having((e) => e.code, 'code', 'network')),
      );
    });
  });
}
