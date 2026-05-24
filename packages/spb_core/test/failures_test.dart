import 'package:spb_core/spb_core.dart';
import 'package:test/test.dart';

void main() {
  group('AppFailure', () {
    test('AuthFailure carries message and is an AppFailure', () {
      const f = AuthFailure('invalid credentials');
      expect(f, isA<AppFailure>());
      expect(f.message, 'invalid credentials');
    });

    test('NetworkFailure is an AppFailure', () {
      const f = NetworkFailure();
      expect(f, isA<AppFailure>());
    });

    test('ServerFailure carries status code and is an AppFailure', () {
      const f = ServerFailure(503);
      expect(f, isA<AppFailure>());
      expect(f.code, 503);
    });

    test('subclasses are distinct types', () {
      const auth = AuthFailure('x');
      const net = NetworkFailure();
      const srv = ServerFailure(500);
      expect(auth, isNot(isA<NetworkFailure>()));
      expect(auth, isNot(isA<ServerFailure>()));
      expect(net, isNot(isA<AuthFailure>()));
      expect(net, isNot(isA<ServerFailure>()));
      expect(srv, isNot(isA<AuthFailure>()));
      expect(srv, isNot(isA<NetworkFailure>()));
    });

    test('switch on sealed AppFailure is exhaustive', () {
      String describe(AppFailure f) => switch (f) {
            AuthFailure(message: final m) => 'auth:$m',
            NetworkFailure() => 'network',
            ServerFailure(code: final c) => 'server:$c',
          };
      expect(describe(const AuthFailure('oops')), 'auth:oops');
      expect(describe(const NetworkFailure()), 'network');
      expect(describe(const ServerFailure(404)), 'server:404');
    });
  });
}
