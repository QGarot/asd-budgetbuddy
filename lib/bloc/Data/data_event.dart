import 'package:budgetbuddy/bloc/Data/data_bloc.dart';
import 'package:budgetbuddy/pojos/budget.dart';
import 'package:budgetbuddy/pojos/expenses.dart';
import 'package:budgetbuddy/pojos/user_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DataEvent {
  //gets the data as it was last fetched from firestore
  static AllUserData? getFirebaseUserData(BuildContext context) {
    return context.read<DataCubit>().getFirebaseUserData();
  }

  //Loads the user data fresh from firestore
  static Future<AllUserData?> fetchFirebaseUserData(
    BuildContext context,
  ) async {
    return await context.read<DataCubit>().fetchFirebaseUserData();
  }

  static Future<bool> addBudget(BuildContext context, Budget budget) async {
    return context.read<DataCubit>().addBudget(budget);
  }

  static Future<bool> addExpense(
    BuildContext context,
    String budgetId,
    Expense expense,
  ) async {
    return context.read<DataCubit>().addExpense(budgetId, expense);
  }

  static Future<bool> updateBudget(
    BuildContext context,
    String budgetId, {
    String? name,
    String? category,
    double? alertThreshold,
  }) async {
    return context.read<DataCubit>().updateBudget(
      budgetId,
      name: name,
      category: category,
      alertThreshold: alertThreshold,
    );
  }

  // Add this to your DataEvent class
  static Future<bool> deleteBudget(
    BuildContext context,
    String budgetId,
  ) async {
    return context.read<DataCubit>().deleteBudget(budgetId);
  }
}
