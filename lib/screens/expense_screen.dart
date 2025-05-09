import 'package:budgetbuddy/AppData/app_colors.dart';
import 'package:budgetbuddy/AppData/layout_constants.dart';
import 'package:budgetbuddy/Elements/dashboard_header.dart';
import 'package:budgetbuddy/Elements/expense_tab_view.dart';
import 'package:budgetbuddy/Elements/header_bar.dart';
import 'package:budgetbuddy/Elements/add_expense_dialog.dart';
import 'package:budgetbuddy/bloc/Data/data_bloc.dart';
import 'package:budgetbuddy/pojos/user_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CurrentBudget {
  static String budgetId = "";
}

class ExpenseScreen extends StatelessWidget {
  const ExpenseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return BlocBuilder<DataCubit, AllUserData?>(
          builder: (context, userData) {
            if (userData == null) {
              return const Center(child: CircularProgressIndicator());
            }

            final budget = userData.budgets.firstWhere(
              (budget) => budget.id == CurrentBudget.budgetId,
              orElse: () => throw Exception("Budget not found"),
            );

            // 🔹 Call the expense listener here
            context.read<DataCubit>().listenToExpenseChanges(CurrentBudget.budgetId);

            return Scaffold(
              backgroundColor: AppColors.backgroundColorHomescreen,
              body: Stack(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const HeaderBar(
                        title: "Budget Dashboard",
                        showReturnButton: true,
                      ),
                      Expanded(
                        child: SingleChildScrollView(
                          child: Center(
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                maxWidth: LayoutConstants.getContentMaxWidth(context),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  const SizedBox(height: LayoutConstants.spaceOverDashboard),

                                  DashboardHeader(
                                    title: budget.name,
                                    subtitle: "Track and manage your expenses for this budget",
                                    buttonText: "Add Expense",
                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        builder: (dialogContext) => AddExpenseDialog(
                                          budgetId: CurrentBudget.budgetId,
                                        ),
                                      );
                                    },
                                  ),

                                  const SizedBox(height: 16),

                                  Container(
                                    height: 500,
                                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.1),
                                          blurRadius: 4,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: ExpensesTabView(
                                      budgetId: CurrentBudget.budgetId,
                                    ),
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
      },
    );
  }
}
