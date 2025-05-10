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

  static Future<bool> deleteBudget(
    BuildContext context,
    String budgetId,
  ) async {
    return context.read<DataCubit>().deleteBudget(budgetId);
  }

  // Expense now ---------------------------------------

  static Future<bool> addExpense(BuildContext context, String budgetId, Expense expense) async {
    return context.read<DataCubit>().addExpense(budgetId, expense);
  }

  static Future<bool> updateExpense(
  BuildContext context,
  String budgetId,
  Expense updatedExpense,
) async {
  return context.read<DataCubit>().updateExpense(budgetId, updatedExpense);
}

static Future<bool> deleteExpense(
  BuildContext context,
  String budgetId,
  String expenseId,
) async {
  return context.read<DataCubit>().deleteExpense(budgetId, expenseId);
}

}
