import 'package:spb_core/spb_core.dart';
import 'package:test/test.dart';

void main() {
  group('Result', () {
    test('Success<T> exposes its value', () {
      final Result<int> r = Success<int>(42);
      expect(r, isA<Success<int>>());
      expect((r as Success<int>).value, 42);
    });

    test('Failure<T> exposes its AppFailure', () {
      const failure = NetworkFailure();
      final Result<int> r = Failure<int>(failure);
      expect(r, isA<Failure<int>>());
      expect((r as Failure<int>).failure, same(failure));
    });

    test('when() dispatches success branch', () {
      final Result<String> r = Success<String>('hi');
      final out = r.when(
        success: (v) => 'ok:$v',
        failure: (f) => 'err:${f.runtimeType}',
      );
      expect(out, 'ok:hi');
    });

    test('when() dispatches failure branch', () {
      final Result<String> r = Failure<String>(const AuthFailure('nope'));
      final out = r.when(
        success: (v) => 'ok:$v',
        failure: (f) => 'err:${(f as AuthFailure).message}',
      );
      expect(out, 'err:nope');
    });

    test('switch on sealed Result is exhaustive', () {
      String describe(Result<int> r) => switch (r) {
            Success<int>(value: final v) => 'success:$v',
            Failure<int>(failure: final f) => 'failure:${f.runtimeType}',
          };
      expect(describe(Success(1)), 'success:1');
      expect(describe(Failure(const ServerFailure(500))), 'failure:ServerFailure');
    });
  });
}
