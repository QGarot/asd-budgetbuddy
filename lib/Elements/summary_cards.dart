import 'package:budgetbuddy/AppData/app_colors.dart';
import 'package:budgetbuddy/AppData/app_text_styles.dart';
import 'package:budgetbuddy/AppData/ui_constants.dart';
import 'package:budgetbuddy/bloc/Data/summary_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SummaryCards extends StatelessWidget {
  final BudgetSummary summary;

  const SummaryCards({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Row(
      children: [
        _buildCard(
          loc.summary_totalBudget,
          summary.totalBudget,
          summary.totalSpent / summary.totalBudget,
          color: AppColors.totalBudgetBar,
        ),
        const SizedBox(width: 12),
        _buildCard(
          loc.summary_totalSpent,
          summary.totalSpent,
          summary.totalSpent / summary.totalBudget,
          color: AppColors.dangerColor,
        ),
        const SizedBox(width: 12),
        _buildCard(
          loc.summary_remaining,
          summary.remaining,
          summary.remaining / summary.totalBudget,
          color: AppColors.groceries,
        ),
      ],
    );
  }

  Widget _buildCard(
    String title,
    double amount,
    double progress, {
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: UIConstants.borderRadius,
          boxShadow: UIConstants.standardShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: AppTextStyles.cardLabel),
            const SizedBox(height: 8),
            Text(
              "€${amount.toStringAsFixed(2)}",
              style: AppTextStyles.cardValue,
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              backgroundColor: Colors.grey[300],
              color: color,
            ),
          ],
        ),
      ),
    );
  }
}
