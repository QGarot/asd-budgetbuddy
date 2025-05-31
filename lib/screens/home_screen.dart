import 'package:budgetbuddy/AppData/app_colors.dart';

import 'package:budgetbuddy/Elements/add_budget_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:budgetbuddy/bloc/Data/summary_helper.dart';
import 'package:budgetbuddy/Elements/summary_cards.dart';
import 'package:budgetbuddy/bloc/Data/data_bloc.dart';
import 'package:budgetbuddy/pojos/user_data.dart';
import 'package:budgetbuddy/Elements/budget_tab_view.dart';
import 'package:budgetbuddy/Elements/dashboard_header.dart';
import 'package:budgetbuddy/AppData/layout_constants.dart';

import 'package:budgetbuddy/Elements/header_bar.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  final String title = "Budget Dashboard";
  final String subtitle = "Manage and track your spending";
  final String buttonText = "Create Budget";

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double maxHeightTabView =
            MediaQuery.of(context).size.height *
                LayoutConstants.tabViewHeightProcent -
            40;
        if (MediaQuery.of(context).size.height < 820) {
          maxHeightTabView = 390;
        }

        return Scaffold(
          backgroundColor: AppColors.backgroundColorHomescreen,
          body: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 🔹 Top bar (full width after sidebar)
                  const HeaderBar(title: "Budget Dashboard"),

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
                              const SizedBox(
                                height: LayoutConstants.spaceOverDashboard,
                              ),

                              // 🔹 Dashboard Header
                              DashboardHeader(
                                title: title,
                                subtitle: subtitle,
                                buttonText: buttonText,
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder:
                                        (dialogContext) =>
                                            const AddBudgetDialog(),
                                  );
                                },
                              ),

                              const SizedBox(
                                height:
                                    LayoutConstants
                                        .spacebetweenDashboardBudgetOverview,
                              ),

                              // 🔹 Summary Cards
                              BlocBuilder<DataCubit, AllUserData?>(
                                builder: (context, userData) {
                                  final summary = BudgetSummary.fromBudgets(
                                    userData?.budgets ?? [],
                                  );
                                  return SummaryCards(summary: summary);
                                },
                              ),

                              const SizedBox(
                                height:
                                    LayoutConstants
                                        .spacebetweenBudgetOverviewTabView,
                              ),

                              // 🔹 Budgets Tab View
                              SizedBox(
                                height: maxHeightTabView,
                                child: const BudgetTabView(),
                              ),

                              const SizedBox(
                                height: LayoutConstants.spaceAfterTabview,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
