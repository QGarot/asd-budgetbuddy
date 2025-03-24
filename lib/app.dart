import 'package:budgetbuddy/bloc/Auth/auth_event.dart';
import 'package:budgetbuddy/screens/counter_screen.dart';
import 'package:budgetbuddy/screens/loading_screen.dart';
import 'package:budgetbuddy/screens/login_screen.dart';
import 'package:budgetbuddy/screens/signup_screen.dart';
import 'package:flutter/material.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Budget Buddy',
      routes: {
        '/':
            (context) =>
                AuthEvent.isLoggedIn(context) ? LoadingScreen() : LoginScreen(),
        '/loading': (context) => LoadingScreen(),
        '/login': (context) => LoginScreen(),
        '/signup': (context) => SignupScreen(),
        '/home': (context) => CounterScreen(),
      },
    );
  }
}
