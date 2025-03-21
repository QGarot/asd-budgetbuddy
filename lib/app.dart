import 'package:budgetbuddy/bloc/Auth/AuthEvent.dart';
import 'package:budgetbuddy/screens/CounterScreen.dart';
import 'package:budgetbuddy/screens/LoginScreen.dart';
import 'package:budgetbuddy/screens/SignupScreen.dart';
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
                AuthEvent.isLoggedIn(context) ? CounterScreen() : LoginScreen(),
        '/login': (context) => LoginScreen(),
        '/signup': (context) => SignupScreen(),
        '/home': (context) => CounterScreen(),
      },
    );
  }
}
