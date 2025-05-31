import 'package:flutter/material.dart';
import 'package:budgetbuddy/AppData/app_colors.dart';
import 'package:budgetbuddy/AppData/ui_constants.dart';
import 'package:budgetbuddy/Elements/add_budget_dialog.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class CreateBudgetButton extends StatelessWidget {
  const CreateBudgetButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: UIConstants.standardShadow,
        borderRadius: BorderRadius.circular(24),
      ),
      child: ElevatedButton.icon(
        onPressed: () {
          showDialog(
            context: context,
            builder: (dialogContext) => const AddBudgetDialog(),
          );
        },
        icon: const Icon(Icons.add, size: 18),
        label: Text(AppLocalizations.of(context)!.createBudgetButton_label),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          textStyle: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
