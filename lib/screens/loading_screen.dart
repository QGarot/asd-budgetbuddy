import 'dart:async';

import 'package:budgetbuddy/AppData/app_colors.dart';
import 'package:budgetbuddy/bloc/Data/data_event.dart';
import 'package:budgetbuddy/screens/main_screen.dart';
import 'package:flutter/material.dart';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  LoadingScreenState createState() => LoadingScreenState();
}

class LoadingScreenState extends State<LoadingScreen> {
  @override
  void initState() {
    super.initState();
    loadAppData();
  }

  Future<void> loadAppData() async {
    await Future.delayed(Duration(seconds: 1));

    //Get user data
    await DataEvent.fetchFirebaseUserData(context);

    if (mounted) {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          settings: RouteSettings(name: '/main'),
          pageBuilder: (_, __, ___) => const MainScreen(),
          transitionDuration: Duration.zero,
          reverseTransitionDuration: Duration.zero,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryColor,
      body: Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      ),
    );
  }
}
