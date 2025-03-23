import 'dart:async';

import 'package:budgetbuddy/AppData/app_colors.dart';
import 'package:budgetbuddy/bloc/Data/data_event.dart';
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

    //Add a budget to test the app
    // await DataEvent.addBudget(
    //   context,
    //   Budget(
    //     id: "BudgetID2",
    //     name: "Ups",
    //     category: "Yup",
    //     alertThreshold: 0.8,
    //     totalAmount: 500,
    //   ),
    // );

    //Add an expense to test the app
    // await DataEvent.addExpense(
    //   context,
    //   "BudgetID",
    //   Expense(
    //     id: "ExpenseID3",
    //     merchant: "Ikea3",
    //     amount: 100.99,
    //     date: DateTime.now(),
    //     notes: "Ich gehe gerne zu Ikea 3",
    //   ),
    // );

    if (mounted) {
      Navigator.pushReplacementNamed(context, '/home');
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
