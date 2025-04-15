import 'package:budgetbuddy/AppData/app_colors.dart';
import 'package:budgetbuddy/Elements/message_to_user.dart';
import 'package:budgetbuddy/Elements/standard_dialog_box.dart';
import 'package:budgetbuddy/bloc/Data/data_bloc.dart';
import 'package:budgetbuddy/pojos/budget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
  final Budget budget;

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
    required this.budget,
  });

  void _navigateToEditScreen(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => EditBudgetDialog(budget: budget),
      barrierDismissible: false,
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text(
          'Confirm Deletion',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Are you sure you want to delete "$title" budget? This action can not be undone.',
          style: const TextStyle(
            fontSize: 16,
            color: Colors.black87,
          ),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(
                color: Colors.deepPurple,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(4),
            ),
            child: TextButton(
              onPressed: () {
                context.read<DataCubit>().deleteBudget(budget.id);
                Navigator.pop(context);
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.transparent,
                elevation: 0,
              ),
              child: const Text(
                'Delete',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
        actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

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
              PopupMenuButton<String>(
                icon: const Icon(
                  Icons.arrow_drop_down,
                  size: 24,
                ),
                color: Colors.white,
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                onSelected: (value) {
                  if (value == 'edit') {
                    _navigateToEditScreen(context);
                  } else if (value == 'delete') {
                    _showDeleteConfirmation(context);
                  }
                },
                itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                  const PopupMenuItem<String>(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit),
                        SizedBox(width: 8),
                        Text('Edit'),
                      ],
                    ),
                  ),
                  const PopupMenuItem<String>(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Delete', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 4),
          if (!isCollapsed)
            Text(period, style: const TextStyle(color: Colors.black54)),
          const SizedBox(height: 16),

          // Always visible: bar + label
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "\$${spent.toStringAsFixed(2)} of \$${limit.toStringAsFixed(2)}",
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
                  "\$${remaining.toStringAsFixed(2)} remaining",
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const Spacer(),
                if (warning)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.dangerColor.withAlpha((255 * 0.1).toInt()),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.warning, size: 16, color: AppColors.dangerColor),
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

class EditBudgetDialog extends StatefulWidget {
  final Budget budget;

  const EditBudgetDialog({super.key, required this.budget});

  @override
  State<EditBudgetDialog> createState() => _EditBudgetDialogState();
}

class _EditBudgetDialogState extends State<EditBudgetDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _amountController;

  late String _selectedCategory;
  late String _selectedPeriod;
  late double _alertThreshold;

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
  void initState() {
    super.initState();
    // Imp -> Initialize controllers with existing budget data
    _nameController = TextEditingController(text: widget.budget.name);
    _amountController = TextEditingController(text: widget.budget.totalAmount.toString());
    _selectedCategory = widget.budget.category;
    _selectedPeriod = widget.budget.resetPeriod;
    _alertThreshold = widget.budget.alertThreshold;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StandardDialogBox(
      title: "Edit Budget",
      subtitle: "Update your budget details below.",
      icon: Icons.edit,
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
                          (value) => setState(() => _selectedCategory = value!),
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
                          (value) => setState(() => _selectedPeriod = value!),
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
            onPressed: _updateBudget,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 4,
            ),
            child: const Text('Save Changes'),
          ),
        ),
      ],
    );
  }

  void _updateBudget() {
    final form = _formKey.currentState;
    
    setState(() {
      _errorMessage = " ";
    });

    if (form == null || !form.validate()) return;

    if (_nameController.text.trim().isEmpty ||
        _amountController.text.trim().isEmpty) {
      setState(() {
        _errorMessage = "Please fill in the missing fields.";
      });
      return;
    }

    // Parse the amount
    final rawAmountText = _amountController.text.trim().replaceAll(',', '.');
    final parsedAmount = double.tryParse(rawAmountText);
    
    if (parsedAmount == null || parsedAmount <= 0) {
      setState(() {
        _errorMessage = "Please enter a valid amount.";
      });
      return;
    }

    // Update the budget using DataCubit with ALL the updated parameters
    final DataCubit dataCubit = context.read<DataCubit>();
    dataCubit.updateBudget(
      widget.budget.id,
      name: _nameController.text.trim(),
      category: _selectedCategory,
      alertThreshold: _alertThreshold,
      resetPeriod: _selectedPeriod,
      totalAmount: parsedAmount,
    ).then((success) {
      if (success) {
        MessageToUser.showMessage(context, "Budget updated successfully!");
        Navigator.of(context).pop();
      } else {
        setState(() {
          _errorMessage = "Failed to update budget.";
        });
      }
    }).catchError((error) {
      setState(() {
        _errorMessage = "An error occurred: $error";
      });
    });
  }
}