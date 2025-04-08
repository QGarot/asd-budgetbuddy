import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:budgetbuddy/screens/home_screen.dart';
import 'package:budgetbuddy/screens/loading_screen.dart';
import 'package:budgetbuddy/screens/login_screen.dart';
import 'package:budgetbuddy/screens/signup_screen.dart';

class App extends StatelessWidget {
  App({super.key});

  final User? user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Budget Buddy',
      routes: {
        '/':
            (context) =>
                user == null ? const LoginScreen() : const LoadingScreen(),
        '/loading': (context) => const LoadingScreen(),
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignupScreen(),
        '/home': (context) => const HomeScreen(),
      },
    );
  }
}
