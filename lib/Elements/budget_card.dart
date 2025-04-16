import 'package:flutter/material.dart';
import 'package:budgetbuddy/AppData/app_colors.dart';

class BudgetCard extends StatelessWidget {
  final String title;
  final String period;
  final double spent;
  final double limit;
  final bool warning;
  final Color color;
  final IconData icon;
  final bool isCollapsed;
  final VoidCallback onToggle;

  const BudgetCard({
    super.key,
    required this.title,
    required this.spent,
    required this.limit,
    required this.period,
    required this.color,
    required this.warning,
    required this.icon,
    required this.isCollapsed,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final percent = (spent / limit).clamp(0.0, 1.0);
    final remaining = limit - spent;

    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: warning ? Border.all(color: AppColors.dangerColor) : null,
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
              IconButton(
                icon: Icon(
                  key: const Key('toggle_button'),
                  isCollapsed ? Icons.expand_more : Icons.expand_less,
                  size: 18,
                ),
                onPressed: onToggle,
              ),
            ],
          ),
          const SizedBox(height: 4),
          if (!isCollapsed)
            Text(period, style: TextStyle(color: Colors.black54)),
          const SizedBox(height: 16),

          // Always visible: bar + label
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "€${spent.toStringAsFixed(2)} of €${limit.toStringAsFixed(2)}",
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              Text("${(percent * 100).round()}%"),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: percent,
              minHeight: 6,
              backgroundColor: color.withAlpha((255 * 0.15).toInt()),
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),

          if (!isCollapsed) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Text(
                  "€${remaining.toStringAsFixed(2)} remaining",
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const Spacer(),
                if (warning)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.dangerColor.withAlpha(
                        (255 * 0.1).toInt(),
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: const [
                        Icon(
                          Icons.warning,
                          size: 16,
                          color: AppColors.dangerColor,
                        ),
                        SizedBox(width: 4),
                        Text(
                          "Approaching limit",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: AppColors.dangerColor,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  foregroundColor: AppColors.primaryColor,
                ),
                child: const Text("View Expenses"),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
