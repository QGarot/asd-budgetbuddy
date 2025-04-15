import 'package:budgetbuddy/AppData/app_colors.dart';
import 'package:budgetbuddy/AppData/ui_constants.dart';
import 'package:budgetbuddy/Elements/sidebar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:budgetbuddy/bloc/Data/summary_helper.dart';
import 'package:budgetbuddy/Elements/summary_cards.dart';
import 'package:budgetbuddy/bloc/Data/data_bloc.dart';
import 'package:budgetbuddy/pojos/user_data.dart';
import 'package:budgetbuddy/Elements/budget_tab_view.dart';
import 'package:budgetbuddy/Elements/dashboard_header.dart';
import 'package:budgetbuddy/AppData/layout_constants.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.of(context).size.width < 700) {
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

    return LayoutBuilder(
      builder: (context, constraints) {
        final double maxHeightTabView =
            MediaQuery.of(context).size.height *
            LayoutConstants.tabViewHeightProcent;

        return Scaffold(
          backgroundColor: Colors.grey[200],
          body: Stack(
            children: [
              const Material(elevation: 8, child: Sidebar()),

              Padding(
                padding: EdgeInsets.only(
                  left: LayoutConstants.getSidebarWidth(context),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // 🔹 Top bar (full width after sidebar)
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor,
                        boxShadow: UIConstants.standardShadow,
                      ),
                      padding: const EdgeInsets.all(12),
                      child: const Text(
                        "Budget Dashboard",
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                    ),

                    Expanded(
                      child: SingleChildScrollView(
                        child: Center(
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              maxWidth: LayoutConstants.getContentMaxWidth(
                                context,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                const SizedBox(height: 16),

                                // 🔹 Dashboard Header
                                const DashboardHeader(),

                                const SizedBox(height: 24),

                                // 🔹 Summary Cards
                                BlocBuilder<DataCubit, AllUserData?>(
                                  builder: (context, userData) {
                                    final summary = BudgetSummary.fromBudgets(
                                      userData?.budgets ?? [],
                                    );
                                    return SummaryCards(summary: summary);
                                  },
                                ),

                                const SizedBox(height: 24),

                                // 🔹 Budgets Tab View
                                SizedBox(
                                  height: maxHeightTabView,
                                  child: const BudgetTabView(),
                                ),

                                const SizedBox(height: 40),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
