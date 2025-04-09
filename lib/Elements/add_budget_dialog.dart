import 'package:budgetbuddy/AppData/app_colors.dart';
import 'package:budgetbuddy/bloc/Data/data_bloc.dart';
import 'package:budgetbuddy/pojos/budget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AddBudgetDialog extends StatefulWidget {
  const AddBudgetDialog({super.key});

  @override
  State<AddBudgetDialog> createState() => _AddBudgetDialogState();
}

class _AddBudgetDialogState extends State<AddBudgetDialog> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();

  String? _selectedCategory;
  String? _selectedPeriod;
  double _alertThreshold = 0.8;

  final List<String> _categories = ['Groceries', 'Travel', 'Entertainment', 'Bills'];
  final List<String> _periods = ['Monthly', 'Weekly', 'Yearly'];

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 32.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Create New Budget',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              const Text(
                'Set up a new budget to track your spending.',
                style: TextStyle(fontSize: 14, color: Colors.black54),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Budget Name',
                  hintText: 'e.g., Groceries',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Amount',
                  prefixText: '\$ ',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedCategory,
                      items: _categories
                          .map((category) =>
                              DropdownMenuItem(value: category, child: Text(category)))
                          .toList(),
                      onChanged: (value) => setState(() => _selectedCategory = value),
                      decoration: const InputDecoration(
                        labelText: 'Category',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedPeriod,
                      items: _periods
                          .map((period) =>
                              DropdownMenuItem(value: period, child: Text(period)))
                          .toList(),
                      onChanged: (value) => setState(() => _selectedPeriod = value),
                      decoration: const InputDecoration(
                        labelText: 'Period',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                'Alert Threshold: ${(100 * _alertThreshold).toInt()}%',
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              Slider(
                value: _alertThreshold,
                onChanged: (value) => setState(() => _alertThreshold = value),
                min: 0.0,
                max: 1.0,
                divisions: 20,
                activeColor: AppColors.yellowColor,
                inactiveColor: AppColors.yellowColorFaint,
              ),
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("0%"),
                  Text("100%"),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                "You'll receive an alert when your spending reaches this percentage of your budget",
                style: TextStyle(color: Colors.grey[600], fontSize: 13),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _createBudget,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 4,
                    ),
                    child: const Text('Create Budget'),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  void _createBudget() {
    final name = _nameController.text.trim();
    final amountText = _amountController.text.trim();

    if (name.isEmpty || amountText.isEmpty || _selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all required fields.')),
      );
      return;
    }

    final amount = double.tryParse(amountText);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid amount.')),
      );
      return;
    }

    final budget = Budget(
      name: name,
      category: _selectedCategory!,
      alertThreshold: _alertThreshold,
      totalAmount: amount,
    );

    final dataCubit = context.read<DataCubit>();
    dataCubit.addBudget(budget).then((success) {
      if (success) {
        Navigator.of(context).pop(); // Close dialog
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to add budget.')),
        );
      }
    });
  }
}