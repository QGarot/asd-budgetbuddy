import 'package:budgetbuddy/AppData/app_colors.dart';
import 'package:budgetbuddy/pojos/expenses.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SpendingTrendChart extends StatelessWidget {
  final List<Expense> expenses;
  final double height;
  final int daysToShow;

  const SpendingTrendChart({
    super.key,
    required this.expenses,
    this.height = 250,
    this.daysToShow = 30, // Default to showing 30 days
  });

  @override
  Widget build(BuildContext context) {
    if (expenses.isEmpty) {
      return SizedBox(
        height: height,
        child: const Center(
          child: Text('No expense data available'),
        ),
      );
    }

    // Sort expenses by date
    final sortedExpenses = List<Expense>.from(expenses)
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));

    // Calculate date range
    final DateTime now = DateTime.now();
    final DateTime startDate = now.subtract(Duration(days: daysToShow));

    // Group expenses by date
    final Map<DateTime, double> dailyExpenses = {};
    
    // Initialize all dates in range with zero amounts
    for (int i = 0; i < daysToShow; i++) {
      final date = DateTime(
        startDate.year, 
        startDate.month, 
        startDate.day + i,
      );
      dailyExpenses[date] = 0;
    }
    
    // Sum expenses for each date
    for (final expense in sortedExpenses) {
      // Only include expenses within our date range
      if (expense.createdAt.isAfter(startDate) && 
          expense.createdAt.isBefore(now.add(const Duration(days: 1)))) {
        // Normalize to start of day
        final dateKey = DateTime(
          expense.createdAt.year,
          expense.createdAt.month,
          expense.createdAt.day,
        );
        dailyExpenses[dateKey] = (dailyExpenses[dateKey] ?? 0) + expense.amount;
      }
    }
    
    // Convert map to list of points
    final List<FlSpot> spots = [];
    double maxY = 0;
    
    dailyExpenses.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key))
      ..asMap().forEach((index, entry) {
        spots.add(FlSpot(index.toDouble(), entry.value));
        if (entry.value > maxY) {
          maxY = entry.value;
        }
      });

    // If all spots are zero, show empty chart
    final hasNonZero = spots.any((spot) => spot.y > 0);
    if (!hasNonZero) {
      return SizedBox(
        height: height,
        child: const Center(
          child: Text('No recent expense data available'),
        ),
      );
    }

    return SizedBox(
      height: height,
      child: LineChart(
        LineChartData(
          gridData: const FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: 100,
          ),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                getTitlesWidget: (value, meta) {
                  if (value % 5 != 0 && value != spots.length - 1) {
                    return const SizedBox.shrink();
                  }
                  
                  final index = value.toInt();
                  if (index < 0 || index >= dailyExpenses.keys.length) {
                    return const SizedBox.shrink();
                  }
                  
                  final date = dailyExpenses.keys.toList()
                    ..sort();
                  
                  if (index >= date.length) {
                    return const SizedBox.shrink();
                  }
                  
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      DateFormat('dd/MM').format(date[index]),
                      style: const TextStyle(
                        color: Colors.black54,
                        fontSize: 10,
                      ),
                    ),
                  );
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (value, meta) {
                  return Text(
                    '€${value.toInt()}',
                    style: const TextStyle(
                      color: Colors.black54,
                      fontSize: 10,
                    ),
                  );
                },
              ),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          borderData: FlBorderData(
            show: true,
            border: Border.all(color: Colors.black12),
          ),
          minX: 0,
          maxX: spots.length.toDouble() - 1,
          minY: 0,
          maxY: maxY * 1.2, // Add some padding at the top
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: AppColors.groceries,
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                color: AppColors.groceries.withOpacity(0.2),
              ),
            ),
          ],
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              tooltipBgColor: Colors.white.withOpacity(0.8),
              getTooltipItems: (List<LineBarSpot> touchedSpots) {
                return touchedSpots.map((LineBarSpot touchedSpot) {
                  final index = touchedSpot.x.toInt();
                  final value = touchedSpot.y;
                  final date = dailyExpenses.keys.toList()
                    ..sort();
                  
                  if (index >= date.length) {
                    return null;
                  }
                  
                  final formattedDate = DateFormat('dd MMM').format(date[index]);
                  
                  return LineTooltipItem(
                    '$formattedDate\n€${value.toStringAsFixed(2)}',
                    const TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                }).toList();
              },
            ),
          ),
        ),
      ),
    );
  }
}
