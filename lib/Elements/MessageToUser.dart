import 'package:budgetbuddy/Elements/AppColors.dart';
import 'package:flutter/material.dart';

class MessageToUser {
  static void showMessage(
    BuildContext context,
    String message, {
    int duration = 2,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: TextStyle(color: Colors.white)),
        duration: Duration(seconds: duration),
        backgroundColor: AppColors.primaryColor,
      ),
    );
  }
}
