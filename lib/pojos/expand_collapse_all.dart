import 'package:flutter/material.dart';
import 'package:budgetbuddy/AppData/app_colors.dart';

class ExpandAllButton extends StatelessWidget {
  final bool allExpanded;
  final VoidCallback onToggle;

  const ExpandAllButton({
    super.key,
    required this.allExpanded,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: onToggle,
      icon: Icon(
        allExpanded ? Icons.expand_less : Icons.expand_more,
        color: AppColors.primaryColor,
      ),
      label: Text(
        allExpanded ? "Collapse All" : "Expand All",
        style: const TextStyle(color: AppColors.primaryColor),
      ),
    );
  }
}
