import 'package:budgetbuddy/AppData/app_colors.dart';
import 'package:budgetbuddy/AppData/layout_constants.dart';
import 'package:budgetbuddy/Elements/dashboard_header.dart';
import 'package:budgetbuddy/Elements/expense_tab_view.dart';
import 'package:budgetbuddy/Elements/header_bar.dart';
import 'package:budgetbuddy/Elements/message_to_user.dart';
import 'package:budgetbuddy/bloc/Data/data_event.dart';
import 'package:budgetbuddy/pojos/budget.dart';
import 'package:budgetbuddy/pojos/expenses.dart';
import 'package:flutter/material.dart';

class CurrentBudget {
  static String budgetId = "";
}

class ExpenseScreen extends StatelessWidget {
  const ExpenseScreen({super.key});

  final String title = "Budget Dashboard";
  final String subtitle = "Manage and track your spending";
  final String buttonText = "Create Budget";

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        //Get budget
        final userData = DataEvent.getFirebaseUserData(context);
        Budget? budget = userData?.budgets.firstWhere(
          (budget) => budget.id == CurrentBudget.budgetId,
        );

        if (budget == null) {
          return const Center(
            child: Text("No budget found, this should never happen"),
          );
        }

        return Scaffold(
          backgroundColor: AppColors.backgroundColorHomescreen,
          body: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 🔹 Top bar (full width after sidebar)
                  const HeaderBar(
                    title: "Budget Dashboard",
                    showReturnButton: true,
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
                              const SizedBox(
                                height: LayoutConstants.spaceOverDashboard,
                              ),

                              // 🔹 Dashboard Header
                              DashboardHeader(
                                title: budget.name,
                                subtitle:
                                    "Track and manage your expenses for this budget",
                                buttonText: "Add Expense",
                                onPressed: () {
                                  DataEvent.addExpense(
                                    context,
                                    CurrentBudget.budgetId,
                                    Expense(
                                      merchant: "Ikea",
                                      amount: 199.99,
                                      createdAt: DateTime.now(),
                                      notes: "New Mattress",
                                    ),
                                  );
                                  // showDialog(
                                  //   context: context,
                                  //   builder:
                                  //       (dialogContext) =>
                                  //           const AddBudgetDialog(),
                                  // );
                                  MessageToUser.showMessage(
                                    context,
                                    "Expense added",
                                  );
                                },
                              ),

                              // 🔹 Expense prices here

                              // 🔹 All expenses here
                              Container(
                                height: 500, // Set an appropriate height
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
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
  }
}
