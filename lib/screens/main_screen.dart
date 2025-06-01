import 'package:budgetbuddy/AppData/app_colors.dart';
import 'package:budgetbuddy/screens/expense_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:budgetbuddy/bloc/Navigation/sidebar_cubit.dart';
import 'package:budgetbuddy/Elements/sidebar.dart';
import 'package:budgetbuddy/screens/home_screen.dart';
import 'package:budgetbuddy/screens/progress_screen.dart';
import 'package:budgetbuddy/screens/settings_screen.dart';
import 'package:budgetbuddy/screens/help_screen.dart';
import 'package:budgetbuddy/screens/statistics_screen.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.of(context).size.width < 850) {
      return const Scaffold(
        backgroundColor: AppColors.primaryColor,
        body: Center(
          child: Text(
            'BudgetBuddy requires a larger screen width',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    if (MediaQuery.of(context).size.height < 470) {
      return const Scaffold(
        backgroundColor: AppColors.primaryColor,
        body: Center(
          child: Text(
            'BudgetBuddy requires a larger screen height',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return Scaffold(
      body: Row(
        children: [
          const Sidebar(), // Sidebar buttons will update the SidebarCubit

          Expanded(
            child: BlocBuilder<SidebarCubit, SidebarPage>(
              builder: (context, page) {
                // This decides what screen to show
                switch (page) {
                  case SidebarPage.dashboard:
                    return const HomeScreen();
                  case SidebarPage.progress:
                    return const ProgressScreen();
                  case SidebarPage.statistics:
                    return const StatisticsScreen();
                  case SidebarPage.settings:
                    return const SettingsScreen();
                  case SidebarPage.help:
                    return const HelpScreen();
                  case SidebarPage.showExpense:
                    return const ExpenseScreen();
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
