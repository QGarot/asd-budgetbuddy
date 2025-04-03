import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:budgetbuddy/bloc/Navigation/sidebar_cubit.dart';
import 'package:budgetbuddy/screens/home_screen.dart';
import 'package:budgetbuddy/screens/loading_screen.dart';
import 'package:budgetbuddy/screens/login_screen.dart';
import 'package:budgetbuddy/screens/signup_screen.dart';
import 'package:budgetbuddy/bloc/Auth/auth_event.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Budget Buddy',
      routes: {
        '/': (context) => AuthEvent.isLoggedIn(context)
            ? const LoadingScreen()
            : const LoginScreen(),
        '/loading': (context) => const LoadingScreen(),
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignupScreen(),

        '/home': (context) => BlocProvider(
              create: (_) => SidebarCubit(),
              child: const HomeScreen(),
            ),
      },
    );
  }
}
