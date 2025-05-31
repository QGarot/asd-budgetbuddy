import 'package:budgetbuddy/AppData/app_colors.dart';
import 'package:budgetbuddy/AppData/layout_constants.dart';
import 'package:budgetbuddy/Elements/Charts/charts_dashboard.dart';
import 'package:budgetbuddy/Elements/dashboard_header.dart';
import 'package:budgetbuddy/Elements/header_bar.dart';
import 'package:budgetbuddy/bloc/Data/data_bloc.dart';
import 'package:budgetbuddy/bloc/Data/summary_helper.dart';
import 'package:budgetbuddy/pojos/user_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  final String title = "Statistics Dashboard";
  final String subtitle = "Visualize your budget data";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColorHomescreen,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 🔹 Top bar
          const HeaderBar(title: "Statistics Dashboard"),

          // 🔹 Main content
          Expanded(
            child: SingleChildScrollView(
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: LayoutConstants.getContentMaxWidth(context),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 🔹 Page Title
                        DashboardHeader(
                          title: title,
                          subtitle: subtitle,
                          buttonText: "",
                          onPressed: () {},
                          showButton: false,
                        ),
                        const SizedBox(height: 24),

                        // 🔹 Summary section
                        BlocBuilder<DataCubit, AllUserData?>(
                          builder: (context, userData) {
                            if (userData == null || userData.budgets.isEmpty) {
                              return const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(32.0),
                                  child: Text(
                                    'No budget data available to visualize',
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.black54,
                                    ),
                                  ),
                                ),
                              );
                            }

                            final summary = BudgetSummary.fromBudgets(
                              userData.budgets,
                            );

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // 🔹 Analytics info cards
                                _buildAnalyticsCards(summary, userData),
                                const SizedBox(height: 32),

                                // 🔹 Charts Dashboard
                                ChartsDashboard(budgets: userData.budgets),
                                const SizedBox(height: 32),

                                // 🔹 Additional insights or future analytics components can be added here
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyticsCards(BudgetSummary summary, AllUserData userData) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Summary',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildInfoCard(
                'Budget Utilization',
                '${((summary.totalSpent / summary.totalBudget) * 100).toStringAsFixed(1)}%',
                summary.totalSpent < summary.totalBudget * 0.8
                    ? Colors.green
                    : summary.totalSpent < summary.totalBudget
                    ? Colors.orange
                    : Colors.red,
              ),
              const SizedBox(width: 16),
              _buildInfoCard(
                'Remaining Budget',
                '€${summary.remaining.toStringAsFixed(2)}',
                summary.remaining > 0 ? Colors.green : Colors.red,
              ),
              const SizedBox(width: 16),
              _buildInfoCard(
                'Active Budgets',
                '${userData.budgets.length}',
                AppColors.primaryColor,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String title, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 14, color: Colors.black54),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
