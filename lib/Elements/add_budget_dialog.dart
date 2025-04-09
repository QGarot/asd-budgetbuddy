import 'package:budgetbuddy/AppData/app_colors.dart';
import 'package:budgetbuddy/Elements/standard_dialog_box.dart';
import 'package:budgetbuddy/Elements/standard_dropdown.dart';
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

  String? _errorMessage;
  bool _amountIsInvalid = false;

  final List<String> _categories = ['Groceries', 'Travel', 'Entertainment', 'Bills'];
  final List<String> _periods = ['Monthly', 'Weekly', 'Yearly'];

  @override
  Widget build(BuildContext context) {
    return StandardDialogBox(
      title: "Create New Budget",
      subtitle: "Set up a new budget to track your spending.",
      icon: Icons.add_chart,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: 'Budget Name',
              hintText: 'e.g., Groceries',
              border: const OutlineInputBorder(),
              errorText: _errorMessage != null && _nameController.text.trim().isEmpty ? '' : null,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _amountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: 'Amount',
              prefixText: '\$ ',
              border: const OutlineInputBorder(),
              errorText: _amountIsInvalid ? 'Enter a valid amount' : null,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: StandardDropdownField<String>(
                  label: 'Category',
                  selectedValue: _selectedCategory,
                  items: _categories,
                  onChanged: (value) => setState(() => _selectedCategory = value),
                  itemLabel: (item) => item,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: StandardDropdownField<String>(
                  label: 'Period',
                  selectedValue: _selectedPeriod,
                  items: _periods,
                  onChanged: (value) => setState(() => _selectedPeriod = value),
                  itemLabel: (item) => item,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            'Alert Threshold: ${(100 * _alertThreshold).toInt()}%',
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 8,
              trackShape: const RoundedRectSliderTrackShape(),
              activeTrackColor: AppColors.yellowColor,
              inactiveTrackColor: AppColors.yellowColorFaint,
              thumbColor: Colors.transparent,
              overlayColor: Colors.transparent,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 0),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 0),
              tickMarkShape: const RoundSliderTickMarkShape(tickMarkRadius: 0),
              showValueIndicator: ShowValueIndicator.never,
            ),
            child: Slider(
              value: _alertThreshold,
              onChanged: (value) => setState(() => _alertThreshold = value),
              min: 0.0,
              max: 1.0,
              divisions: 20,
            ),
          ),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [Text("0%"), Text("100%")],
          ),
          const SizedBox(height: 16),
          Text(
            "You'll receive an alert when your spending reaches this percentage of your budget",
            style: TextStyle(color: Colors.grey[600], fontSize: 13),
          ),
          if (_errorMessage != null)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.red),
              ),
            ),
        ],
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(bottom: 10, top: 8),
          child: TextButton(
            onPressed: () => Navigator.of(context).pop(),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
            ),
            child: const Text('Cancel'),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 12, bottom: 10, top: 8),
          child: ElevatedButton(
            onPressed: _createBudget,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 4,
            ),
            child: const Text('Create Budget'),
          ),
        ),
      ],
    );
  }

  void _createBudget() {
    final name = _nameController.text.trim();
    final amountText = _amountController.text.trim();
    final amount = double.tryParse(amountText);

    setState(() {
      _errorMessage = null;
      _amountIsInvalid = false;
    });

    if (name.isEmpty || amountText.isEmpty || _selectedCategory == null) {
      setState(() {
        _errorMessage = "Please fill in all fields.";
      });
      return;
    }

    if (amount == null || amount <= 0) {
      setState(() {
        _amountIsInvalid = true;
      });
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
        Navigator.of(context).pop();
      } else {
        setState(() {
          _errorMessage = "Failed to add budget.";
        });
      }
    });
  }
}