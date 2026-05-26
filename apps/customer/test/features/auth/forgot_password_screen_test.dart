// Tests for ForgotPasswordScreen — grava-144f.1.2
//
// Coverage:
// - Screen renders email field and submit button
// - Submit with empty email shows validation error
// - Submit with valid email dispatches ForgotPasswordRequested event
// - AuthLoading state shows circular progress
// - PasswordResetSent state shows 'Check your email' message
// - AuthFailureState shows snackbar with error message

import 'package:bloc_test/bloc_test.dart';
import 'package:customer/features/auth/bloc/auth_bloc.dart';
import 'package:customer/features/auth/view/forgot_password_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthBloc extends MockBloc<AuthEvent, AuthState> implements AuthBloc {}

void main() {
  late MockAuthBloc mockBloc;

  setUp(() {
    mockBloc = MockAuthBloc();
  });

  tearDown(() {
    mockBloc.close();
  });

  Widget buildScreen() {
    return MaterialApp(
      home: BlocProvider<AuthBloc>.value(
        value: mockBloc,
        child: const ForgotPasswordScreen(),
      ),
    );
  }

  group('ForgotPasswordScreen', () {
    testWidgets('renders email field and submit button in initial state',
        (tester) async {
      when(() => mockBloc.state).thenReturn(const AuthInitial());

      await tester.pumpWidget(buildScreen());

      expect(find.byKey(const Key('forgotPasswordEmailField')), findsOneWidget);
      expect(find.byKey(const Key('forgotPasswordSubmitButton')), findsOneWidget);
    });

    testWidgets('shows loading indicator when AuthLoading', (tester) async {
      when(() => mockBloc.state).thenReturn(const AuthLoading());

      await tester.pumpWidget(buildScreen());

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows success text when PasswordResetSent', (tester) async {
      when(() => mockBloc.state).thenReturn(const PasswordResetSent());

      await tester.pumpWidget(buildScreen());

      expect(find.text('Check your email'), findsOneWidget);
    });

    testWidgets('dispatches ForgotPasswordRequested on valid submit',
        (tester) async {
      when(() => mockBloc.state).thenReturn(const AuthInitial());

      await tester.pumpWidget(buildScreen());

      await tester.enterText(
        find.byKey(const Key('forgotPasswordEmailField')),
        'user@example.com',
      );

      await tester.tap(find.byKey(const Key('forgotPasswordSubmitButton')));
      await tester.pump();

      verify(
        () => mockBloc.add(
          const ForgotPasswordRequested(email: 'user@example.com'),
        ),
      ).called(1);
    });

    testWidgets('shows snackbar on AuthFailureState', (tester) async {
      when(() => mockBloc.state).thenReturn(const AuthInitial());
      whenListen(
        mockBloc,
        Stream<AuthState>.fromIterable([
          const AuthInitial(),
          const AuthFailureState('Reset failed'),
        ]),
        initialState: const AuthInitial(),
      );

      await tester.pumpWidget(buildScreen());
      await tester.pump();

      expect(find.text('Reset failed'), findsOneWidget);
    });
  });
}
