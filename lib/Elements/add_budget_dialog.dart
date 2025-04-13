import 'package:budgetbuddy/AppData/app_colors.dart';
import 'package:budgetbuddy/Elements/message_to_user.dart';
import 'package:budgetbuddy/Elements/standard_dialog_box.dart';
import 'package:budgetbuddy/bloc/Data/data_event.dart';
import 'package:budgetbuddy/pojos/budget.dart';
import 'package:flutter/material.dart';

class AddBudgetDialog extends StatefulWidget {
  const AddBudgetDialog({super.key});

  @override
  State<AddBudgetDialog> createState() => _AddBudgetDialogState();
}

class _AddBudgetDialogState extends State<AddBudgetDialog> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();

  String? _selectedCategory;
  String? _selectedPeriod;
  double _alertThreshold = 0.8;

  String? _errorMessage = " ";

  final List<String> _categories = [
    'Groceries',
    'Rent',
    'Utilities',
    'Entertainment',
    'Travel',
    'Dining',
    'Shopping',
    'Other',
  ];
  final List<String> _periods = ['Weekly', 'Biweekly', 'Monthly'];

  @override
  Widget build(BuildContext context) {
    return StandardDialogBox(
      title: "Create New Budget",
      subtitle: "Set up a new budget to track your spending.",
      icon: Icons.add_chart,
      content: SingleChildScrollView(
        child: StandardDialogBox.buildStandardForm(
          formKey: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              StandardDialogBox.buildStandardFormField(
                controller: _nameController,
                label: 'Budget Name',
                hint: 'e.g., Groceries',
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return null;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              StandardDialogBox.buildStandardFormField(
                controller: _amountController,
                label: 'Amount',
                hint: "0,00€",
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: (value) {
                  final text = value?.trim();
                  if (text == null || text.isEmpty) {
                    return null;
                  }
                  final parsed = double.tryParse(text.replaceAll(',', '.'));
                  if (parsed == null || parsed <= 0) {
                    return "Please enter a valid amount";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 13),
              Row(
                children: [
                  Expanded(
                    child: StandardDialogBox.buildStandardDropdown<String>(
                      context: context,
                      label: 'Category',
                      selectedValue: _selectedCategory,
                      items: _categories,
                      onChanged:
                          (value) => setState(() => _selectedCategory = value),
                      itemLabel: (item) => item,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: StandardDialogBox.buildStandardDropdown<String>(
                      context: context,
                      label: 'Period',
                      selectedValue: _selectedPeriod,
                      items: _periods,
                      onChanged:
                          (value) => setState(() => _selectedPeriod = value),
                      itemLabel: (item) => item,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
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
                  tickMarkShape: const RoundSliderTickMarkShape(
                    tickMarkRadius: 0,
                  ),
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
              const SizedBox(height: 13),
              Text(
                "You'll receive an alert when your spending reaches this percentage of your budget",
                style: TextStyle(color: Colors.grey[600], fontSize: 13),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
        ),
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
    final form = _formKey.currentState;
    final rawAmountText = _amountController.text.trim().replaceAll(',', '.');
    final parsed = double.tryParse(rawAmountText);
    final amount =
        parsed != null ? double.parse(parsed.toStringAsFixed(2)) : null;

    setState(() {
      _errorMessage = " ";
    });

    if (form == null || !form.validate()) return;

    if (_nameController.text.trim().isEmpty ||
        _amountController.text.trim().isEmpty ||
        _selectedCategory == null ||
        _selectedPeriod == null) {
      setState(() {
        _errorMessage = "Please fill in all fields.";
      });
      return;
    }

    final budget = Budget(
      name: _nameController.text.trim(),
      category: _selectedCategory!,
      resetPeriod: _selectedPeriod!,
      alertThreshold: _alertThreshold,
      totalAmount: amount!,
    );

    DataEvent.addBudget(context, budget)
        .then((success) {
          if (success) {
            MessageToUser.showMessage(context, "Budget added successfully!");
            Navigator.of(context).pop();
          } else {
            setState(() {
              _errorMessage = "Failed to add budget.";
            });
          }
        })
        .catchError((error) {
          setState(() {
            _errorMessage = "Failed to add budget.";
          });
        });
  }
}