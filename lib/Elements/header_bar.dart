import 'package:budgetbuddy/bloc/Navigation/sidebar_cubit.dart';
import 'package:budgetbuddy/screens/expense_screen.dart';
import 'package:flutter/material.dart';
import 'package:budgetbuddy/AppData/app_colors.dart';
import 'package:budgetbuddy/AppData/ui_constants.dart';
import 'package:budgetbuddy/AppData/app_text_styles.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HeaderBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showReturnButton;

  @override
  Size get preferredSize => const Size(double.infinity, 60);

  const HeaderBar({
    super.key,
    required this.title,
    this.showReturnButton = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.primaryColor,
        boxShadow: UIConstants.standardShadow,
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          if (showReturnButton)
            IconButton(
              padding: const EdgeInsets.fromLTRB(0, 0, 5, 0),
              constraints: const BoxConstraints(),
              icon: const Icon(Icons.arrow_back),
              color: Colors.white,
              onPressed: () {
                CurrentBudget.budgetId = "";
                final cubit = context.read<SidebarCubit>();
                cubit.selectPage(SidebarPage.dashboard);
              },
            ),
          Text(title, style: AppTextStyles.headerBarTitle),
        ],
      ),
    );
  }
}
