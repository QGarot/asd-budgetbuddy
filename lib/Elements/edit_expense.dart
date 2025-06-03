import 'package:budgetbuddy/Elements/message_to_user.dart';
import 'package:budgetbuddy/Elements/standard_dialog_box.dart';
import 'package:budgetbuddy/bloc/Data/data_event.dart';
import 'package:budgetbuddy/pojos/expenses.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class EditExpenseDialog extends StatefulWidget {
  final String budgetId;
  final Expense expense;

  const EditExpenseDialog({
    super.key,
    required this.budgetId,
    required this.expense,
  });

  @override
  State<EditExpenseDialog> createState() => _EditExpenseDialogState();
}

class _EditExpenseDialogState extends State<EditExpenseDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _amountController;
  late TextEditingController _merchantController;
  late TextEditingController _notesController;
  late TextEditingController _dateController;

  late String _selectedCategory;
  late String _selectedPaymentMethod;
  late DateTime _selectedDate;

  String? _errorMessage = " ";

  final List<String> _categories = [
    'Groceries', 'Rent', 'Utilities', 'Entertainment', 'Travel', 'Dining', 'Shopping', 'Other'
  ];
  final List<String> _paymentMethods = ['Cash', 'Credit Card', 'Debit Card', 'Online Payment'];

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(text: widget.expense.amount.toStringAsFixed(2));
    _merchantController = TextEditingController(text: widget.expense.merchant);
    _notesController = TextEditingController(text: widget.expense.notes);
    _selectedCategory = widget.expense.category;
    _selectedPaymentMethod = widget.expense.paymentMethod;
    _selectedDate = widget.expense.createdAt;
    _dateController = TextEditingController(text: DateFormat('dd/MM/yyyy').format(_selectedDate));
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: StandardDialogBox(
          title: "Edit Expense",
          subtitle: "Update the details of this expense.",
          icon: Icons.edit,
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
                            initialDate: _selectedDate,
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
                    onChanged: (value) => setState(() => _selectedCategory = value!),
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
                    onChanged: (value) => setState(() => _selectedPaymentMethod = value!),
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
                _errorMessage ?? '',
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
        onPressed: _updateExpense,
        child: const Text('Save Changes'),
      ),
    ];
  }

  void _updateExpense() async {
    setState(() => _errorMessage = " ");
    final form = _formKey.currentState;
    if (form == null || !form.validate()) return;

    final parsedAmount = double.tryParse(_amountController.text.replaceAll(',', '.')) ?? 0;

    final updated = widget.expense.copyWith(
      merchant: _merchantController.text.trim(),
      amount: parsedAmount,
      createdAt: _selectedDate,
      notes: _notesController.text.trim(),
      category: _selectedCategory,
      paymentMethod: _selectedPaymentMethod,
    );

    final success = await DataEvent.updateExpense(context, widget.budgetId, updated);

    if (!mounted) return;

    if (success) {
      MessageToUser.showMessage(context, "Expense updated successfully!");
      Navigator.of(context).pop();
    } else {
      setState(() => _errorMessage = "Failed to update expense.");
    }
  }
}
