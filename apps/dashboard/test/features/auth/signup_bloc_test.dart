import 'package:dashboard/features/auth/bloc/signup_bloc.dart';
import 'package:dashboard/features/auth/repository/owner_auth_repository.dart';
import 'package:flutter_test/flutter_test.dart';

/// Stubs [OwnerAuthRepository.signup] so the bloc can be exercised without a
/// real Dio/network. The parent ctor builds an (unused) default Dio.
class _StubRepo extends OwnerAuthRepository {
  _StubRepo({this.result, this.error});

  final OwnerSignupResult? result;
  final OwnerSignupException? error;
  int calls = 0;

  @override
  Future<OwnerSignupResult> signup({
    required String email,
    required String password,
  }) async {
    calls++;
    if (error != null) throw error!;
    return result!;
  }
}

void main() {
  group('SignupBloc', () {
    test('rejects an invalid email without calling the repository', () async {
      final repo = _StubRepo();
      final bloc = SignupBloc(repo);

      final expectation = expectLater(
        bloc.stream,
        emitsInOrder([isA<SignupRejected>()]),
      );

      bloc.add(const SignupEvent.submitted(
        email: 'not-an-email',
        password: 'abcd1234',
        confirmPassword: 'abcd1234',
      ));

      await expectation;
      expect(repo.calls, 0);
      await bloc.close();
    });

    test('rejects a weak password without calling the repository', () async {
      final repo = _StubRepo();
      final bloc = SignupBloc(repo);

      final expectation = expectLater(
        bloc.stream,
        emitsInOrder([isA<SignupRejected>()]),
      );

      bloc.add(const SignupEvent.submitted(
        email: 'owner@example.com',
        password: 'short',
        confirmPassword: 'short',
      ));

      await expectation;
      expect(repo.calls, 0);
      await bloc.close();
    });

    test('rejects a confirm-password mismatch', () async {
      final repo = _StubRepo();
      final bloc = SignupBloc(repo);

      final expectation = expectLater(
        bloc.stream,
        emitsInOrder([isA<SignupRejected>()]),
      );

      bloc.add(const SignupEvent.submitted(
        email: 'owner@example.com',
        password: 'abcd1234',
        confirmPassword: 'abcd9999',
      ));

      await expectation;
      expect(repo.calls, 0);
      await bloc.close();
    });

    test('emits submitting → success on a 201', () async {
      final repo = _StubRepo(
        result: const OwnerSignupResult(
          userId: 'u_1',
          email: 'owner@example.com',
          message: 'Owner account created',
          requiresVerification: false,
        ),
      );
      final bloc = SignupBloc(repo);

      final expectation = expectLater(
        bloc.stream,
        emitsInOrder([
          const SignupSubmitting(),
          const SignupSuccess(
              email: 'owner@example.com', requiresVerification: false),
        ]),
      );

      bloc.add(const SignupEvent.submitted(
        email: '  owner@example.com  ',
        password: 'abcd1234',
        confirmPassword: 'abcd1234',
      ));

      await expectation;
      expect(repo.calls, 1);
      await bloc.close();
    });

    test('emits submitting → rejected(code) when the API rejects', () async {
      final repo = _StubRepo(
        error: const OwnerSignupException('email_already_registered',
            statusCode: 409),
      );
      final bloc = SignupBloc(repo);

      final expectation = expectLater(
        bloc.stream,
        emitsInOrder([
          const SignupSubmitting(),
          isA<SignupRejected>().having(
            (s) => s.message,
            'message',
            'email_already_registered',
          ),
        ]),
      );

      bloc.add(const SignupEvent.submitted(
        email: 'owner@example.com',
        password: 'abcd1234',
        confirmPassword: 'abcd1234',
      ));

      await expectation;
      await bloc.close();
    });
  });
}
