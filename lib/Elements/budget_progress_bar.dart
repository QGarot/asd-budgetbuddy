import 'package:budgetbuddy/AppData/app_colors.dart';
import 'package:budgetbuddy/bloc/Data/summary_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class BudgetProgressBar extends StatelessWidget {
  final BudgetSummary summary;

  const BudgetProgressBar({
    super.key,
    required this.summary,
  });

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    // Calculate progress, handling the case when totalBudget is 0
    final progress = summary.totalBudget > 0 
        ? (summary.totalSpent / summary.totalBudget).clamp(0.0, 1.0)
        : 0.0;
        
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                loc.statisticsScreen_budgetUtilization,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
              Text(
                summary.totalBudget > 0 
                    ? '${(progress * 100).toStringAsFixed(1)}%'
                    : '0.0%',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            height: 12,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(6),
            ),
            child: Stack(
              children: [
                LayoutBuilder(
                  builder: (context, constraints) {
                    // Progress is already calculated and clamped above
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 500),
                      width: constraints.maxWidth * (progress > 1 ? 1 : progress),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            progress > 0.8 ? Colors.red[400]! : AppColors.primaryColor,
                            progress > 0.8 ? Colors.orange[400]! : Colors.lightBlue[300]!,
                          ],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(6),
                        // Add a subtle shadow to the filled portion for depth
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 1,
                            offset: const Offset(0, 1),
                            spreadRadius: 0,
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '€0', // Zero doesn't need translation
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              Text(
                '€${summary.totalBudget.toStringAsFixed(2)}', // Currency formatting
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
