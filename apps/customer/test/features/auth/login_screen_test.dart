import 'package:bloc_test/bloc_test.dart';
import 'package:customer/features/auth/bloc/auth_bloc.dart';
import 'package:customer/features/auth/view/login_screen.dart';
import 'package:customer/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthBloc extends MockBloc<AuthEvent, AuthState> implements AuthBloc {}

void main() {
  late MockAuthBloc mockBloc;

  setUp(() {
    mockBloc = MockAuthBloc();
    when(() => mockBloc.state).thenReturn(const AuthInitial());
  });

  tearDown(() {
    mockBloc.close();
  });

  Widget buildScreen({Locale locale = const Locale('vi')}) {
    return MaterialApp(
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: BlocProvider<AuthBloc>.value(
        value: mockBloc,
        child: const LoginScreen(),
      ),
    );
  }

  group('LoginScreen', () {
    testWidgets('renders all fields and links', (tester) async {
      await tester.pumpWidget(buildScreen());

      expect(find.byKey(const Key('loginEmailField')), findsOneWidget);
      expect(find.byKey(const Key('loginPasswordField')), findsOneWidget);
      expect(find.byKey(const Key('forgotPasswordLink')), findsOneWidget);
      expect(find.byKey(const Key('resendVerificationLink')), findsOneWidget);
      expect(find.byKey(const Key('loginButton')), findsOneWidget);
      expect(find.byKey(const Key('goToSignUpLink')), findsOneWidget);
    });

    testWidgets('resend link dispatches ResendVerificationRequested with email',
        (tester) async {
      await tester.pumpWidget(buildScreen());

      // Enter email
      await tester.enterText(
        find.byKey(const Key('loginEmailField')),
        'test@example.com',
      );
      await tester.pump();

      // Tap resend
      await tester.tap(find.byKey(const Key('resendVerificationLink')));
      await tester.pump();

      verify(() => mockBloc.add(
            const ResendVerificationRequested(email: 'test@example.com'),
          )).called(1);
    });

    testWidgets('shows validation error when resend tapped with empty email',
        (tester) async {
      await tester.pumpWidget(buildScreen(locale: const Locale('vi')));

      // Clear email field (pre-seeded in debug mode)
      await tester.enterText(find.byKey(const Key('loginEmailField')), '');
      await tester.pump();

      // Tap resend with empty email
      await tester.tap(find.byKey(const Key('resendVerificationLink')));
      await tester.pumpAndSettle();

      expect(find.text('Vui lòng nhập email.'), findsOneWidget);
    });
  });
}
