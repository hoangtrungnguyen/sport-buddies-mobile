import 'dart:convert';
import 'dart:typed_data';

import 'package:dashboard/features/auth/repository/owner_auth_repository.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

/// Canned HTTP adapter: returns [response] (or throws [error]) and records the
/// outgoing request for assertions. Avoids any real network I/O.
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

OwnerAuthRepository _repo(_FakeAdapter adapter) {
  final dio = Dio(BaseOptions(baseUrl: 'http://test.local'));
  dio.httpClientAdapter = adapter;
  return OwnerAuthRepository(dio: dio);
}

void main() {
  group('OwnerAuthRepository.signup', () {
    test('201 parses the created account', () async {
      final adapter = _FakeAdapter(
        response: _json({
          'message': 'Owner account created',
          'user': {'id': 'u_123', 'email': 'owner@example.com'},
        }, 201),
      );

      final result = await _repo(adapter)
          .signup(email: 'owner@example.com', password: 'abcd1234');

      expect(result.userId, 'u_123');
      expect(result.email, 'owner@example.com');
      expect(result.message, 'Owner account created');
      expect(result.requiresVerification, isFalse); // auto-confirm message
    });

    test('"Confirmation email sent" → requiresVerification true', () async {
      final adapter = _FakeAdapter(
        response: _json({
          'message': 'Confirmation email sent',
          'user': {'id': 'u_1', 'email': 'owner@example.com'},
        }, 201),
      );

      final result = await _repo(adapter)
          .signup(email: 'owner@example.com', password: 'abcd1234');

      expect(result.requiresVerification, isTrue);
    });

    test('unknown/auto-confirm message → requiresVerification false', () async {
      final adapter = _FakeAdapter(
        response: _json({
          'message': 'Owner account created',
          'user': {'id': 'u_1', 'email': 'owner@example.com'},
        }, 201),
      );

      final result = await _repo(adapter)
          .signup(email: 'owner@example.com', password: 'abcd1234');

      expect(result.requiresVerification, isFalse);
    });

    test('sends POST to /auth/owner/signup with a JSON email+password body',
        () async {
      final adapter = _FakeAdapter(
        response: _json({
          'message': 'Owner account created',
          'user': {'id': 'u_1', 'email': 'a@b.com'},
        }, 201),
      );

      await _repo(adapter).signup(email: 'a@b.com', password: 'secret123');

      expect(adapter.capturedOptions?.method, 'POST');
      expect(adapter.capturedOptions?.path, '/auth/owner/signup');
      expect(
        adapter.capturedOptions?.uri.toString(),
        'http://test.local/auth/owner/signup',
      );
      expect(
        jsonDecode(adapter.capturedBody!),
        {'email': 'a@b.com', 'password': 'secret123'},
      );
    });

    test('201 with missing user fields falls back gracefully', () async {
      final adapter = _FakeAdapter(response: _json({}, 201));

      final result = await _repo(adapter)
          .signup(email: 'fallback@example.com', password: 'abcd1234');

      expect(result.userId, '');
      expect(result.email, 'fallback@example.com'); // echoes the input
      expect(result.message, 'Owner account created');
    });

    test('409 maps to email_already_registered', () async {
      final adapter = _FakeAdapter(
        response: _json({'error': 'email_already_registered'}, 409),
      );

      await expectLater(
        () => _repo(adapter).signup(email: 'a@b.com', password: 'abcd1234'),
        throwsA(
          isA<OwnerSignupException>()
              .having((e) => e.code, 'code', 'email_already_registered')
              .having((e) => e.statusCode, 'statusCode', 409),
        ),
      );
    });

    test('409 with empty body still maps to email_already_registered',
        () async {
      final adapter = _FakeAdapter(response: _json(null, 409));

      await expectLater(
        () => _repo(adapter).signup(email: 'a@b.com', password: 'abcd1234'),
        throwsA(isA<OwnerSignupException>()
            .having((e) => e.code, 'code', 'email_already_registered')),
      );
    });

    test('409 with an unexpected error value never leaks raw server text',
        () async {
      // The server's `error` string is deliberately NOT echoed as the code —
      // 409 always means "email taken" per the contract.
      final adapter = _FakeAdapter(
        response: _json({'error': 'SOME_UNDOCUMENTED_CODE'}, 409),
      );

      await expectLater(
        () => _repo(adapter).signup(email: 'a@b.com', password: 'abcd1234'),
        throwsA(isA<OwnerSignupException>()
            .having((e) => e.code, 'code', 'email_already_registered')),
      );
    });

    test('400 maps to invalid_input', () async {
      final adapter = _FakeAdapter(response: _json({'detail': 'bad'}, 400));

      await expectLater(
        () => _repo(adapter).signup(email: 'a@b.com', password: 'x'),
        throwsA(isA<OwnerSignupException>()
            .having((e) => e.code, 'code', 'invalid_input')
            .having((e) => e.statusCode, 'statusCode', 400)),
      );
    });

    test('502 and 503 map to service_unavailable', () async {
      for (final status in [502, 503]) {
        final adapter = _FakeAdapter(response: _json(null, status));
        await expectLater(
          () => _repo(adapter).signup(email: 'a@b.com', password: 'abcd1234'),
          throwsA(isA<OwnerSignupException>()
              .having((e) => e.code, 'code', 'service_unavailable')
              .having((e) => e.statusCode, 'statusCode', status)),
        );
      }
    });

    test('unexpected status maps to unknown', () async {
      final adapter = _FakeAdapter(response: _json(null, 500));

      await expectLater(
        () => _repo(adapter).signup(email: 'a@b.com', password: 'abcd1234'),
        throwsA(isA<OwnerSignupException>()
            .having((e) => e.code, 'code', 'unknown')
            .having((e) => e.statusCode, 'statusCode', 500)),
      );
    });

    test('transport failure maps to network', () async {
      final adapter = _FakeAdapter(
        error: DioException.connectionError(
          requestOptions: RequestOptions(path: '/auth/owner/signup'),
          reason: 'connection refused',
        ),
      );

      await expectLater(
        () => _repo(adapter).signup(email: 'a@b.com', password: 'abcd1234'),
        throwsA(isA<OwnerSignupException>()
            .having((e) => e.code, 'code', 'network')),
      );
    });
  });

  group('OwnerAuthRepository.login', () {
    test('200 parses the token pair and user', () async {
      final adapter = _FakeAdapter(
        response: _json({
          'access_token': 'at-123',
          'refresh_token': 'rt-456',
          'user': {'id': 'u_9', 'email': 'owner@example.com'},
        }, 200),
      );

      final result = await _repo(adapter)
          .login(email: 'owner@example.com', password: 'Abcd1234');

      expect(result.accessToken, 'at-123');
      expect(result.refreshToken, 'rt-456');
      expect(result.userId, 'u_9');
      expect(result.email, 'owner@example.com');
    });

    test('sends POST to /auth/owner/login with a JSON body', () async {
      final adapter = _FakeAdapter(
        response: _json({
          'access_token': 'a',
          'refresh_token': 'r',
          'user': {'id': '1', 'email': 'a@b.com'},
        }, 200),
      );

      await _repo(adapter).login(email: 'a@b.com', password: 'secret123');

      expect(adapter.capturedOptions?.method, 'POST');
      expect(adapter.capturedOptions?.path, '/auth/owner/login');
      expect(
        jsonDecode(adapter.capturedBody!),
        {'email': 'a@b.com', 'password': 'secret123'},
      );
    });

    test('200 without tokens maps to unknown', () async {
      final adapter = _FakeAdapter(
        response: _json({'user': {'id': '1', 'email': 'a@b.com'}}, 200),
      );

      await expectLater(
        () => _repo(adapter).login(email: 'a@b.com', password: 'Abcd1234'),
        throwsA(isA<OwnerLoginException>()
            .having((e) => e.code, 'code', 'unknown')),
      );
    });

    test('401 maps to invalid_credentials', () async {
      final adapter = _FakeAdapter(response: _json({'detail': 'bad'}, 401));

      await expectLater(
        () => _repo(adapter).login(email: 'a@b.com', password: 'wrong'),
        throwsA(isA<OwnerLoginException>()
            .having((e) => e.code, 'code', 'invalid_credentials')
            .having((e) => e.statusCode, 'statusCode', 401)),
      );
    });

    test('403 with email_not_verified maps to email_not_verified', () async {
      final adapter = _FakeAdapter(
        response: _json({'error': 'email_not_verified'}, 403),
      );

      await expectLater(
        () => _repo(adapter).login(email: 'a@b.com', password: 'Abcd1234'),
        throwsA(isA<OwnerLoginException>()
            .having((e) => e.code, 'code', 'email_not_verified')
            .having((e) => e.statusCode, 'statusCode', 403)),
      );
    });

    test('403 with any other body maps to access_denied', () async {
      final adapter = _FakeAdapter(response: _json({'error': 'not_owner'}, 403));

      await expectLater(
        () => _repo(adapter).login(email: 'a@b.com', password: 'Abcd1234'),
        throwsA(isA<OwnerLoginException>()
            .having((e) => e.code, 'code', 'access_denied')
            .having((e) => e.statusCode, 'statusCode', 403)),
      );
    });

    test('400 maps to invalid_input', () async {
      final adapter = _FakeAdapter(response: _json(null, 400));

      await expectLater(
        () => _repo(adapter).login(email: 'a@b.com', password: 'x'),
        throwsA(isA<OwnerLoginException>()
            .having((e) => e.code, 'code', 'invalid_input')),
      );
    });

    test('502 and 503 map to service_unavailable', () async {
      for (final status in [502, 503]) {
        final adapter = _FakeAdapter(response: _json(null, status));
        await expectLater(
          () => _repo(adapter).login(email: 'a@b.com', password: 'Abcd1234'),
          throwsA(isA<OwnerLoginException>()
              .having((e) => e.code, 'code', 'service_unavailable')
              .having((e) => e.statusCode, 'statusCode', status)),
        );
      }
    });

    test('transport failure maps to network', () async {
      final adapter = _FakeAdapter(
        error: DioException.connectionError(
          requestOptions: RequestOptions(path: '/auth/owner/login'),
          reason: 'connection refused',
        ),
      );

      await expectLater(
        () => _repo(adapter).login(email: 'a@b.com', password: 'Abcd1234'),
        throwsA(isA<OwnerLoginException>()
            .having((e) => e.code, 'code', 'network')),
      );
    });
  });
}
