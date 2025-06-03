import 'package:budgetbuddy/AppData/app_colors.dart';
import 'package:budgetbuddy/Elements/Charts/budget_bar_chart.dart';
import 'package:budgetbuddy/Elements/Charts/budget_pie_chart.dart';
import 'package:budgetbuddy/Elements/Charts/spending_trend_chart.dart';
import 'package:budgetbuddy/pojos/budget.dart';
import 'package:budgetbuddy/pojos/expenses.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ChartsDashboard extends StatefulWidget {
  final List<Budget> budgets;

  const ChartsDashboard({super.key, required this.budgets});

  @override
  State<ChartsDashboard> createState() => _ChartsDashboardState();
}

class _ChartsDashboardState extends State<ChartsDashboard> {
  int _selectedTabIndex = 0;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    // Get all expenses from all budgets
    final List<Expense> allExpenses = [];
    for (final budget in widget.budgets) {
      allExpenses.addAll(budget.expenses);
    }

    return Container(
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
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  loc.chartsDashboard_title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(
                  width: 350,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildTabButton(
                          0,
                          loc.chartsDashboard_tabOverview,
                          loc,
                        ),
                        _buildTabButton(
                          1,
                          loc.chartsDashboard_tabBudgetVsSpending,
                          loc,
                        ),
                        _buildTabButton(2, loc.chartsDashboard_tabTrends, loc),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(16),
            child: IndexedStack(
              index: _selectedTabIndex,
              children: [
                // Tab 1: Overview with pie chart
                _buildOverviewTab(widget.budgets, loc),

                // Tab 2: Budget vs Spending bar chart
                _buildBudgetVsSpendingTab(widget.budgets, loc),

                // Tab 3: Spending trends
                _buildTrendsTab(allExpenses, loc),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(int index, String label, AppLocalizations loc) {
    final isSelected = _selectedTabIndex == index;

    return InkWell(
      onTap: () {
        setState(() {
          _selectedTabIndex = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        margin: const EdgeInsets.only(left: 8),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? AppColors.primaryColor.withOpacity(0.1)
                  : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border:
              isSelected
                  ? Border.all(color: AppColors.primaryColor)
                  : Border.all(color: Colors.transparent),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? AppColors.primaryColor : Colors.black54,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildOverviewTab(List<Budget> budgets, AppLocalizations loc) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          loc.chartsDashboard_overviewTitle,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Center(child: BudgetPieChart(budgets: budgets)),
        const SizedBox(height: 16),
        _buildLegend(budgets, loc),
      ],
    );
  }

  Widget _buildBudgetVsSpendingTab(List<Budget> budgets, AppLocalizations loc) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          loc.chartsDashboard_budgetVsSpendingTitle,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _LegendItem(
              color: AppColors.totalBudgetBar,
              label: loc.chartsDashboard_legendBudget,
            ),
            const SizedBox(width: 16),
            _LegendItem(
              color: AppColors.dangerColor,
              label: loc.chartsDashboard_legendSpent,
            ),
          ],
        ),
        const SizedBox(height: 16),
        BudgetBarChart(budgets: budgets),
      ],
    );
  }

  Widget _buildTrendsTab(List<Expense> expenses, AppLocalizations loc) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          loc.chartsDashboard_trendsTitle,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        SpendingTrendChart(expenses: expenses),
      ],
    );
  }

  Widget _buildLegend(List<Budget> budgets, AppLocalizations loc) {
    final List<Color> colors = [
      AppColors.groceries,
      AppColors.travel, // Using travel instead of transportation
      AppColors.entertainment,
      AppColors.rent, // Using rent instead of housing
      AppColors.utilities,
      AppColors.dangerColor,
      AppColors.totalBudgetBar,
      AppColors.shopping,
      AppColors.dining,
      AppColors.other,
    ];

    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children:
          budgets.asMap().entries.map((entry) {
            final index = entry.key;
            final budget = entry.value;
            final color = colors[index % colors.length];

            return _LegendItem(color: color, label: budget.name);
          }).toList(),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.black54),
        ),
      ],
    );
  }
}
