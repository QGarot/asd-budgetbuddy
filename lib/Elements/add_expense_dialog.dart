import 'package:budgetbuddy/Elements/message_to_user.dart';
import 'package:budgetbuddy/Elements/standard_dialog_box.dart';
import 'package:budgetbuddy/bloc/Data/data_event.dart';
import 'package:budgetbuddy/pojos/expenses.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AddExpenseDialog extends StatefulWidget {
  final String budgetId;

  const AddExpenseDialog({super.key, required this.budgetId});

  @override
  State<AddExpenseDialog> createState() => _AddExpenseDialogState();
}

class _AddExpenseDialogState extends State<AddExpenseDialog> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _merchantController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();

  String? _selectedCategory;
  String? _selectedPaymentMethod;
  DateTime? _selectedDate;
  String? _errorMessage = " ";

  final List<String> _categories = [
    'Groceries', 'Rent', 'Utilities', 'Entertainment', 'Travel', 'Dining', 'Shopping', 'Other'
  ];
  final List<String> _paymentMethods = ['Cash', 'Credit Card', 'Debit Card', 'Online Payment'];

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: StandardDialogBox(
          title: "Add Expense",
          subtitle: "Enter the details of your new expense.",
          icon: Icons.attach_money,
          content: _buildDialogContent(),
          actions: _buildDialogActions(),
        ),
      ),
    );
  }

  Widget _buildDialogContent() {
    return SingleChildScrollView(
      child: StandardDialogBox.buildStandardForm(
        formKey: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: StandardDialogBox.buildStandardFormField(
                    controller: _amountController,
                    label: 'Amount *',
                    hint: '€',
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    validator: (value) {
                      final text = value?.trim();
                      final parsed = double.tryParse(text?.replaceAll(',', '.') ?? '');
                      if (parsed == null || parsed <= 0) {
                        return 'Please enter a valid amount';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _dateController,
                    decoration: InputDecoration(
                      labelText: 'Date *',
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.calendar_today),
                        onPressed: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                          );
                          if (picked != null) {
                            setState(() {
                              _selectedDate = picked;
                              _dateController.text = DateFormat('dd/MM/yyyy').format(picked);
                            });
                          }
                        },
                      ),
                    ),
                    keyboardType: TextInputType.datetime,
                    onChanged: (value) {
                      try {
                        final parsed = DateFormat('dd/MM/yyyy').parseStrict(value);
                        _selectedDate = parsed;
                      } catch (_) {}
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Date is required';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            StandardDialogBox.buildStandardFormField(
              controller: _merchantController,
              label: 'Merchant *',
              hint: 'e.g. Supermarket',
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Merchant is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: StandardDialogBox.buildStandardDropdown(
                    context: context,
                    label: 'Category',
                    selectedValue: _selectedCategory,
                    items: _categories,
                    onChanged: (value) => setState(() => _selectedCategory = value),
                    itemLabel: (item) => item,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: StandardDialogBox.buildStandardDropdown(
                    context: context,
                    label: 'Payment Method',
                    selectedValue: _selectedPaymentMethod,
                    items: _paymentMethods,
                    onChanged: (value) => setState(() => _selectedPaymentMethod = value),
                    itemLabel: (item) => item,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            StandardDialogBox.buildStandardFormField(
              controller: _notesController,
              label: 'Notes',
              hint: 'Optional notes.',
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
    );
  }

  List<Widget> _buildDialogActions() {
    return [
      TextButton(
        onPressed: () => Navigator.of(context).pop(),
        child: const Text('Cancel'),
      ),
      ElevatedButton(
        onPressed: _saveExpense,
        child: const Text('Save Expense'),
      ),
    ];
  }

  void _saveExpense() async {
    setState(() => _errorMessage = " ");
    final form = _formKey.currentState;
    if (form == null || !form.validate()) return;

    if (_selectedDate == null ||
        _selectedCategory == null ||
        _selectedPaymentMethod == null) {
      setState(() => _errorMessage = 'Please fill in all required fields.');
      return;
    }

    final parsedAmount = double.tryParse(_amountController.text.replaceAll(',', '.')) ?? 0;

    final expense = Expense(
      merchant: _merchantController.text.trim(),
      amount: parsedAmount,
      createdAt: _selectedDate!,
      notes: _notesController.text.trim(),
      category: _selectedCategory!,
      paymentMethod: _selectedPaymentMethod!,
    );

    final success = await DataEvent.addExpense(context, widget.budgetId, expense);

    if (!mounted) return;

    if (success) {
      MessageToUser.showMessage(context, "Expense saved successfully!");
      Navigator.of(context).pop();
    } else {
      setState(() => _errorMessage = "Failed to save expense.");
    }
  }
}
