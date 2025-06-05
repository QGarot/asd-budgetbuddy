// ignore_for_file: deprecated_member_use

import 'package:budgetbuddy/AppData/app_colors.dart';
import 'package:budgetbuddy/pojos/expenses.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
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
    final loc = AppLocalizations.of(context)!;

    if (expenses.isEmpty) {
      return SizedBox(
        height: height,
        child: Center(child: Text(loc.spendingTrendChart_noData)),
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
      final date = DateTime(startDate.year, startDate.month, startDate.day + i);
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

    // Convert map to list of points, ensuring no negative values
    final List<FlSpot> spots = [];
    double maxY = 0;

    // First pass: process all data points
    final sortedEntries =
        dailyExpenses.entries.toList()..sort((a, b) => a.key.compareTo(b.key));

    // Second pass: ensure no negative values and find maxY
    for (int i = 0; i < sortedEntries.length; i++) {
      final entry = sortedEntries[i];
      final y = entry.value < 0 ? 0.0 : entry.value.toDouble();
      spots.add(FlSpot(i.toDouble(), y));
      if (y > maxY) {
        maxY = y;
      }
    }

    // If all spots are zero, show empty chart
    final hasNonZero = spots.any((spot) => spot.y > 0);
    if (!hasNonZero) {
      return SizedBox(
        height: height,
        child: Center(child: Text(loc.spendingTrendChart_noRecentData)),
      );
    }

    return SizedBox(
      height: height,
      child: LineChart(
        LineChartData(
          clipData: FlClipData.all(),
          lineTouchData: LineTouchData(
            enabled: true,
            touchTooltipData: LineTouchTooltipData(
              tooltipBgColor: Colors.white.withOpacity(0.8),
              getTooltipItems: (List<LineBarSpot> touchedSpots) {
                return touchedSpots.map((LineBarSpot touchedSpot) {
                  final index = touchedSpot.x.toInt();
                  final value = touchedSpot.y;
                  final date = dailyExpenses.keys.toList()..sort();

                  if (index >= date.length) {
                    return null;
                  }

                  final formattedDate = DateFormat(
                    'dd MMM',
                  ).format(date[index]);

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
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: (maxY / 5).ceilToDouble(),
            getDrawingHorizontalLine: (value) {
              return FlLine(color: Colors.black12, strokeWidth: 1);
            },
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

                  final date = dailyExpenses.keys.toList()..sort();

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
                interval: (maxY / 5).ceilToDouble(),
                getTitlesWidget: (value, meta) {
                  if (value % ((maxY / 5).ceilToDouble()) != 0 && value != 0) {
                    return const SizedBox.shrink();
                  }
                  return Text(
                    '€${value.toInt()}',
                    style: const TextStyle(color: Colors.black54, fontSize: 10),
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
          maxY: (maxY * 1.2).toDouble(),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              preventCurveOverShooting: true,
              preventCurveOvershootingThreshold: 1.0,
              color: AppColors.groceries,
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                color: AppColors.groceries.withOpacity(0.2),
                cutOffY: 0,
                applyCutOffY: true,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
