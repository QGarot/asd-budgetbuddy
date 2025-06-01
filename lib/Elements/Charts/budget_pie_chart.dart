import 'package:budgetbuddy/AppData/app_colors.dart';
import 'package:budgetbuddy/pojos/budget.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class BudgetPieChart extends StatelessWidget {
  final List<Budget> budgets;
  final double size;

  const BudgetPieChart({
    super.key,
    required this.budgets,
    this.size = 250,
  });

  @override
  Widget build(BuildContext context) {
    if (budgets.isEmpty) {
      return SizedBox(
        height: size,
        child: const Center(
          child: Text('No budget data available'),
        ),
      );
    }

    return SizedBox(
      height: size,
      width: size,
      child: Stack(
        children: [
          PieChart(
            PieChartData(
              sectionsSpace: 2,
              centerSpaceRadius: 50,
              sections: _generateSections(),
              pieTouchData: PieTouchData(
                touchCallback: (FlTouchEvent event, pieTouchResponse) {},
              ),
            ),
          ),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${budgets.length}',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Text(
                  'Budgets',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<PieChartSectionData> _generateSections() {
    final List<PieChartSectionData> sections = [];
    
    // Define a list of colors to use for the pie chart
    final List<Color> colors = [
      AppColors.groceries,
      AppColors.travel,         // Using travel instead of transportation
      AppColors.entertainment,
      AppColors.rent,           // Using rent instead of housing
      AppColors.utilities,
      AppColors.dangerColor,
      AppColors.totalBudgetBar,
      AppColors.shopping,
      AppColors.dining,
      AppColors.other,
    ];
    
    // Calculate total amount for percentage calculation
    final double totalAmount = budgets.fold(
        0, (sum, budget) => sum + budget.totalAmount);
    
    for (int i = 0; i < budgets.length; i++) {
      final budget = budgets[i];
      final double percentage = totalAmount > 0 
          ? (budget.totalAmount / totalAmount) * 100 
          : 0;
      
      // Use modulo to cycle through colors if we have more budgets than colors
      final Color color = colors[i % colors.length];
      
      sections.add(
        PieChartSectionData(
          color: color,
          value: budget.totalAmount,
          title: percentage >= 5 ? '${percentage.toStringAsFixed(1)}%' : '',
          radius: 80,
          titleStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      );
    }
    
    return sections;
  }
}
