import 'package:flutter/material.dart';
import 'package:budgetbuddy/AppData/app_colors.dart';
import 'package:budgetbuddy/AppData/ui_constants.dart';
import 'package:budgetbuddy/AppData/app_text_styles.dart';

class HeaderBar extends StatelessWidget {
  final String title;

  const HeaderBar({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.primaryColor,
        boxShadow: UIConstants.standardShadow,
      ),
      padding: const EdgeInsets.all(12),
      child: Text(
        title,
        style: AppTextStyles.headerBarTitle,
      ),
    );
  }
}