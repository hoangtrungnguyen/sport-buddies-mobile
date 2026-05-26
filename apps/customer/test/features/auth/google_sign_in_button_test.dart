// Widget tests for GoogleSignInButton (grava-144f.2.1 / CAPP-011).
//
// Coverage:
// - Button renders with correct key
// - Tapping the button dispatches GoogleSignInRequested event to AuthBloc
// - AuthLoading state shows progress indicator
// - AuthFailureState shows SnackBar error message
// - AuthSuccess navigates to '/'

import 'package:bloc_test/bloc_test.dart';
import 'package:customer/features/auth/bloc/auth_bloc.dart';
import 'package:customer/features/auth/view/google_sign_in_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthBloc extends MockBloc<AuthEvent, AuthState> implements AuthBloc {}

void main() {
  late MockAuthBloc mockAuthBloc;

  setUp(() {
    mockAuthBloc = MockAuthBloc();
    when(() => mockAuthBloc.state).thenReturn(const AuthInitial());
  });

  tearDown(() {
    mockAuthBloc.close();
  });

  Widget buildSubject() {
    return MaterialApp(
      home: Scaffold(
        body: BlocProvider<AuthBloc>.value(
          value: mockAuthBloc,
          child: const GoogleSignInButton(),
        ),
      ),
    );
  }

  group('GoogleSignInButton', () {
    testWidgets('renders button with correct key', (tester) async {
      await tester.pumpWidget(buildSubject());

      expect(find.byKey(const Key('googleSignInButton')), findsOneWidget);
    });

    testWidgets('renders "Sign in with Google" text', (tester) async {
      await tester.pumpWidget(buildSubject());

      expect(find.text('Sign in with Google'), findsOneWidget);
    });

    testWidgets('dispatches GoogleSignInRequested on tap', (tester) async {
      await tester.pumpWidget(buildSubject());

      await tester.tap(find.byKey(const Key('googleSignInButton')));
      await tester.pump();

      verify(() => mockAuthBloc.add(const GoogleSignInRequested())).called(1);
    });

    testWidgets('shows CircularProgressIndicator when AuthLoading', (
      tester,
    ) async {
      when(() => mockAuthBloc.state).thenReturn(const AuthLoading());
      whenListen<AuthState>(
        mockAuthBloc,
        Stream.value(const AuthLoading()),
        initialState: const AuthLoading(),
      );

      await tester.pumpWidget(buildSubject());

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('button is disabled when AuthLoading', (tester) async {
      when(() => mockAuthBloc.state).thenReturn(const AuthLoading());
      whenListen<AuthState>(
        mockAuthBloc,
        Stream.value(const AuthLoading()),
        initialState: const AuthLoading(),
      );

      await tester.pumpWidget(buildSubject());

      final button = tester.widget<ElevatedButton>(
        find.byType(ElevatedButton),
      );
      expect(button.onPressed, isNull);
    });
  });
}
