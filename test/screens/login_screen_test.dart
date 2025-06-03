import 'package:budgetbuddy/pojos/user_auth.dart';
import 'package:budgetbuddy/screens/login_screen.dart';
import 'package:budgetbuddy/screens/signup_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:budgetbuddy/bloc/Auth/auth_bloc.dart';

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

    Widget createLoginWidget() => MaterialApp(
          routes: {
            '/loading': (_) => const Scaffold(body: Text('Loading Screen')),
            '/signup': (_) => BlocProvider<AuthCubit>.value(
                  value: fakeAuthCubit,
                  child: const SignupScreen(),
                ),
          },
          home: BlocProvider<AuthCubit>.value(
            value: fakeAuthCubit,
            child: const LoginScreen(),
          ),
        );

    Widget createSignupWidget() => MaterialApp(
          routes: {
            '/loading': (_) => const Scaffold(body: Text('Loading Screen')),
            '/login': (_) => BlocProvider<AuthCubit>.value(
                  value: fakeAuthCubit,
                  child: const LoginScreen(),
                ),
          },
          home: BlocProvider<AuthCubit>.value(
            value: fakeAuthCubit,
            child: const SignupScreen(),
          ),
        );

    setUp(() => fakeAuthCubit = FakeAuthCubit());

    testWidgets('Login screen', (tester) async {
      await tester.pumpWidget(createLoginWidget());
      expect(find.text('Sign In'), findsOneWidget);
      expect(find.text('Enter your details to access your account'), findsOneWidget);
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text("Sign in"), findsOneWidget);
      expect(find.text("Don't have an account? "), findsOneWidget);
      expect(find.text("Create Account"), findsOneWidget);
    });

    testWidgets('Signup screen', (tester) async {
      await tester.pumpWidget(createSignupWidget());
      expect(find.text('Create Account'), findsOneWidget);
      expect(find.text('Enter your details to create a new account'), findsOneWidget);
      expect(find.text('Username'), findsOneWidget);
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Sign up'), findsOneWidget);
      expect(find.text('Already have an account?'), findsOneWidget);
      expect(find.text('Login'), findsOneWidget);
    });
  });
}
