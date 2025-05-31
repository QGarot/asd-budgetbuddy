import 'package:flutter/material.dart';
import 'package:budgetbuddy/AppData/app_colors.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
    final loc = AppLocalizations.of(context)!;
    return TextButton.icon(
      onPressed: onToggle,
      icon: Icon(
        allExpanded ? Icons.expand_less : Icons.expand_more,
        color: AppColors.primaryColor,
      ),
      label: Text(
        allExpanded ? loc.collapseAll : loc.expandAll,
        style: const TextStyle(color: AppColors.primaryColor),
      ),
    );
  }
}
