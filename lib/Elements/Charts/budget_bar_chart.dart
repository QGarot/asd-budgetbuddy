import 'dart:math' as math;

import 'package:budgetbuddy/AppData/app_colors.dart';
import 'package:budgetbuddy/pojos/budget.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class BudgetBarChart extends StatelessWidget {
  final List<Budget> budgets;
  final double height;
  final bool showOnlyTop;
  final int maxBudgetsToShow;

  const BudgetBarChart({
    super.key,
    required this.budgets,
    this.height = 300,
    this.showOnlyTop = true,
    this.maxBudgetsToShow = 5,
  });

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    if (budgets.isEmpty) {
      return SizedBox(
        height: height,
        child: Center(child: Text(loc.budgetBarChart_noData)),
      );
    }

    // Sort budgets by total amount (descending)
    final sortedBudgets = List<Budget>.from(budgets);
    if (showOnlyTop) {
      sortedBudgets.sort((a, b) => b.totalAmount.compareTo(a.totalAmount));
    }

    // Only show a limited number of budgets
    final displayBudgets = sortedBudgets.take(maxBudgetsToShow).toList();

    // Find the maximum value to set proper y-axis scale
    final maxValue = displayBudgets.fold<double>(
      0,
      (max, budget) =>
          math.max(max, math.max(budget.totalAmount, budget.spentAmount)),
    );

    return SizedBox(
      height: height,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: maxValue * 1.1, // 10% margin
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              tooltipBgColor: Colors.white.withOpacity(0.8),
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                final budget = displayBudgets[groupIndex];
                final amount =
                    rodIndex == 0
                        ? budget.totalAmount.toStringAsFixed(2)
                        : budget.spentAmount.toStringAsFixed(2);
                final label =
                    rodIndex == 0
                        ? loc.budgetBarChart_tooltipBudget(amount)
                        : loc.budgetBarChart_tooltipSpent(amount);
                return BarTooltipItem(
                  label,
                  const TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.bold,
                  ),
                );
              },
            ),
          ),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  if (value < 0 || value >= displayBudgets.length) {
                    return const SizedBox.shrink();
                  }

                  final budget = displayBudgets[value.toInt()];
                  final name = budget.name;

                  // Truncate long names
                  final displayName =
                      name.length > 10 ? '${name.substring(0, 8)}...' : name;

                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      displayName,
                      style: const TextStyle(
                        color: Colors.black54,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                  );
                },
                reservedSize: 30,
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  // Format the y-axis values with currency symbol
                  return Text(
                    '€${value.toInt()}',
                    style: const TextStyle(color: Colors.black54, fontSize: 10),
                  );
                },
                reservedSize: 40,
              ),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          borderData: FlBorderData(show: false),
          barGroups: List.generate(displayBudgets.length, (index) {
            final budget = displayBudgets[index];
            return BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: budget.totalAmount,
                  color: AppColors.totalBudgetBar,
                  width: 12,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(4),
                    topRight: Radius.circular(4),
                  ),
                ),
                BarChartRodData(
                  toY: budget.spentAmount,
                  color: AppColors.dangerColor,
                  width: 12,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(4),
                    topRight: Radius.circular(4),
                  ),
                ),
              ],
            );
          }),
          gridData: const FlGridData(show: false),
        ),
      ),
    );
  }
}
