import 'package:budgetbuddy/bloc/Auth/auth_bloc.dart';
import 'package:budgetbuddy/pojos/user_auth.dart';
import 'package:budgetbuddy/screens/login_screen.dart';
import 'package:budgetbuddy/screens/signup_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeAuthCubit extends Cubit<AuthUserData?> implements AuthCubit {
  FakeAuthCubit() : super(null);

  bool loginSucceeds = false;
  bool signupSucceeds = false;

  @override
  Future<bool> signIn(UserLoginInfo info) async {
    return loginSucceeds;
  }

  @override
  Future<bool> signUp(UserRegistrationInfo info) async {
    return signupSucceeds;
  }

  @override
  Future<void> signOut() async {}

  @override
  AuthUserData? getCredentials() => null;

  @override
  bool isLoggedIn() => loginSucceeds || signupSucceeds;
}

void main() {
  group('Login & Signup Screen UI Coverage Only', () {
    late FakeAuthCubit fakeAuthCubit;

    setUp(() {
      fakeAuthCubit = FakeAuthCubit();
    });

    Widget createLoginWidget() {
      return MediaQuery(
        data: const MediaQueryData(size: Size(800, 600)),
        child: MaterialApp(
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('en')],
          locale: const Locale('en'),
          routes: {
            '/loading': (_) => const Scaffold(body: Text('Loading Screen')),
            '/signup':
                (_) => BlocProvider<AuthCubit>.value(
                  value: fakeAuthCubit,
                  child: const SignupScreen(),
                ),
          },
          home: BlocProvider<AuthCubit>.value(
            value: fakeAuthCubit,
            child: const LoginScreen(),
          ),
        ),
      );
    }

    Widget createSignupWidget() {
      return MediaQuery(
        data: const MediaQueryData(size: Size(800, 600)),
        child: MaterialApp(
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('en')],
          locale: const Locale('en'),
          routes: {
            '/loading': (_) => const Scaffold(body: Text('Loading Screen')),
            '/login':
                (_) => BlocProvider<AuthCubit>.value(
                  value: fakeAuthCubit,
                  child: const LoginScreen(),
                ),
          },
          home: BlocProvider<AuthCubit>.value(
            value: fakeAuthCubit,
            child: const SignupScreen(),
          ),
        ),
      );
    }

    testWidgets('Signup form shows validation errors when fields are invalid', (tester) async {
      await tester.pumpWidget(createSignupWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Sign up'));
      await tester.pump();

      expect(find.text('Username is required'), findsOneWidget);
      expect(find.text('Email is required'), findsOneWidget);
      expect(find.text('Password is required'), findsOneWidget);

      await tester.enterText(find.byType(TextFormField).at(0), 'John');
      await tester.enterText(find.byType(TextFormField).at(1), 'invalid-email');
      await tester.enterText(find.byType(TextFormField).at(2), '123');

      await tester.tap(find.text('Sign up'));
      await tester.pump();

      expect(find.text('Email is invalid'), findsOneWidget);
      expect(find.text('Password must be at least 8 characters'), findsOneWidget);
    });

    testWidgets('Login form validation shows errors on empty or invalid inputs', (tester) async {
      await tester.pumpWidget(createLoginWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Sign in'));
      await tester.pump();

      final context = tester.element(find.byType(LoginScreen));
      final localization = AppLocalizations.of(context)!;

      expect(find.text(localization.loginScreen_emailRequired), findsOneWidget);
      expect(find.text(localization.loginScreen_passwordRequired), findsOneWidget);

      await tester.enterText(find.byType(TextFormField).first, 'invalidemail');
      await tester.tap(find.text('Sign in'));
      await tester.pump();

      expect(find.text(localization.loginScreen_emailInvalid), findsOneWidget);
    });

    testWidgets('Login screen', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1000, 1000));
      await tester.pumpWidget(createLoginWidget());
      await tester.pumpAndSettle();

      expect(find.text('Sign In'), findsOneWidget);
      expect(
        find.text('Enter your details to access your account'),
        findsOneWidget,
      );
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Sign in'), findsOneWidget);

      expect(find.text("Don't have an account?"), findsOneWidget);
      expect(find.text('Create Account'), findsOneWidget);
    });

    testWidgets('Signup screen', (tester) async {
      await tester.pumpWidget(createSignupWidget());
      await tester.pumpAndSettle();

      expect(find.text('Create Account'), findsOneWidget);
      expect(
        find.text('Enter your details to create a new account'),
        findsOneWidget,
      );
      expect(find.text('Username'), findsOneWidget);
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Sign up'), findsOneWidget);
      expect(find.text('Already have an account?'), findsOneWidget);
      expect(find.text('Login'), findsOneWidget);
    });
  });
}
