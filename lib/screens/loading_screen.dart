// ignore_for_file: use_build_context_synchronously

import 'dart:async';

import 'package:budgetbuddy/AppData/app_colors.dart';
import 'package:budgetbuddy/bloc/Data/data_event.dart';
import 'package:budgetbuddy/bloc/Locale/locale_cubit.dart';
import 'package:budgetbuddy/screens/main_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
    final localeCubit = BlocProvider.of<LocaleCubit>(context);

    await Future.delayed(Duration(seconds: 1));

    final userData = await DataEvent.fetchFirebaseUserData(context);

    if (userData != null) {
      final localeCode = userData.locale;

      if (localeCode.isNotEmpty) {
        localeCubit.setLocale(Locale(localeCode));
      } else {
        localeCubit.setLocale(const Locale('en'));

        final userId = FirebaseAuth.instance.currentUser?.uid;
        if (userId != null) {
          await FirebaseFirestore.instance.collection('users').doc(userId).set({
            'settings': {'locale': 'en'},
          }, SetOptions(merge: true));
        }
      }
    }

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
