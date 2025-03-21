import 'package:budgetbuddy/screens/CounterScreen.dart';
import 'package:budgetbuddy/screens/LoginScreen.dart';
import 'package:budgetbuddy/screens/SignupScreen.dart';
import 'package:budgetbuddy/screens/TextScreen.dart';
import 'package:flutter/material.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    //final auth = FirebaseAuth.instance;
    //var user = auth.currentUser;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Budget Buddy',
      routes: {
        '/': (context) => LoginScreen(),
        '/login': (context) => LoginScreen(),
        '/signup': (context) => SignupScreen(),
        //'/': (context) => CounterScreen(),
        '/home': (context) => TextScreen(),
        //'/': (context) => user == null ? const LoginScreen() : const LoadingScreen(),
      },
    );
  }
}
