// ignore_for_file: constant_identifier_names

import 'package:budgetbuddy/Elements/message_to_user.dart';
import 'package:budgetbuddy/Elements/standard_dialog_box.dart';
import 'package:budgetbuddy/bloc/Data/data_event.dart';
import 'package:budgetbuddy/pojos/expenses.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';

/// These enums belong in your shared model layer so all dialogs reuse them.
enum ExpenseCategory {
  Groceries,
  Rent,
  Utilities,
  Entertainment,
  Travel,
  Dining,
  Shopping,
  Other,
}

enum PaymentMethod { Cash, CreditCard, DebitCard, OnlinePayment }

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

  ExpenseCategory? _selectedCategory;
  PaymentMethod? _selectedPaymentMethod;
  DateTime? _selectedDate;
  String? _errorMessage;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Dialog(
      backgroundColor: Colors.transparent,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: StandardDialogBox(
          title: loc.addExpenseDialog_title,
          subtitle: loc.addExpenseDialog_subtitle,
          icon: Icons.attach_money,
          content: _buildDialogContent(loc),
          actions: _buildDialogActions(loc),
        ),
      ),
    );
  }

  Widget _buildDialogContent(AppLocalizations loc) {
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
                    label: loc.addExpenseDialog_amountLabel,
                    hint: loc.addExpenseDialog_amountHint,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    validator: (value) {
                      final text = value?.trim();
                      final parsed = double.tryParse(
                        text?.replaceAll(',', '.') ?? '',
                      );
                      if (parsed == null || parsed <= 0) {
                        return loc.addExpenseDialog_invalidAmount;
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
                      labelText: loc.addExpenseDialog_dateLabel,
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
                              _dateController.text = DateFormat(
                                'dd/MM/yyyy',
                              ).format(picked);
                            });
                          }
                        },
                      ),
                    ),
                    keyboardType: TextInputType.datetime,
                    onChanged: (value) {
                      try {
                        _selectedDate = DateFormat(
                          'dd/MM/yyyy',
                        ).parseStrict(value);
                      } catch (_) {}
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return loc.addExpenseDialog_dateRequired;
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
              label: loc.addExpenseDialog_merchantLabel,
              hint: loc.addExpenseDialog_merchantHint,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return loc.addExpenseDialog_merchantRequired;
                }
                return null;
              },
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child:
                      StandardDialogBox.buildStandardDropdown<ExpenseCategory>(
                        context: context,
                        label: loc.addExpenseDialog_categoryLabel,
                        selectedValue: _selectedCategory,
                        items: ExpenseCategory.values,
                        onChanged:
                            (value) =>
                                setState(() => _selectedCategory = value),
                        itemLabel: (cat) {
                          switch (cat) {
                            case ExpenseCategory.Groceries:
                              return loc.category_groceries;
                            case ExpenseCategory.Rent:
                              return loc.category_rent;
                            case ExpenseCategory.Utilities:
                              return loc.category_utilities;
                            case ExpenseCategory.Entertainment:
                              return loc.category_entertainment;
                            case ExpenseCategory.Travel:
                              return loc.category_travel;
                            case ExpenseCategory.Dining:
                              return loc.category_dining;
                            case ExpenseCategory.Shopping:
                              return loc.category_shopping;
                            case ExpenseCategory.Other:
                              return loc.category_other;
                          }
                        },
                      ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: StandardDialogBox.buildStandardDropdown<PaymentMethod>(
                    context: context,
                    label: loc.addExpenseDialog_paymentMethodLabel,
                    selectedValue: _selectedPaymentMethod,
                    items: PaymentMethod.values,
                    onChanged:
                        (value) =>
                            setState(() => _selectedPaymentMethod = value),
                    itemLabel: (pm) {
                      switch (pm) {
                        case PaymentMethod.Cash:
                          return loc.paymentMethod_cash;
                        case PaymentMethod.CreditCard:
                          return loc.paymentMethod_creditCard;
                        case PaymentMethod.DebitCard:
                          return loc.paymentMethod_debitCard;
                        case PaymentMethod.OnlinePayment:
                          return loc.paymentMethod_onlinePayment;
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            StandardDialogBox.buildStandardFormField(
              controller: _notesController,
              label: loc.addExpenseDialog_notesLabel,
              hint: loc.addExpenseDialog_notesHint,
            ),
            if (_errorMessage != null) ...[
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  List<Widget> _buildDialogActions(AppLocalizations loc) => [
    TextButton(
      onPressed: () => Navigator.of(context).pop(),
      child: Text(loc.common_cancel),
    ),
    ElevatedButton(
      onPressed: _saveExpense,
      child: Text(loc.addExpenseDialog_save),
    ),
  ];

  void _saveExpense() async {
    setState(() => _errorMessage = null);
    final form = _formKey.currentState;
    if (form == null || !form.validate()) return;

    if (_selectedDate == null ||
        _selectedCategory == null ||
        _selectedPaymentMethod == null) {
      setState(
        () =>
            _errorMessage =
                AppLocalizations.of(context)!.addExpenseDialog_fillAll,
      );
      return;
    }

    final parsedAmount =
        double.tryParse(_amountController.text.replaceAll(',', '.')) ?? 0;

    final expense = Expense(
      merchant: _merchantController.text.trim(),
      amount: parsedAmount,
      createdAt: _selectedDate!,
      notes: _notesController.text.trim(),
      category: _selectedCategory!.name,
      paymentMethod: _selectedPaymentMethod!.name,
    );

    final success = await DataEvent.addExpense(
      context,
      widget.budgetId,
      expense,
    );

    if (!mounted) return;

    if (success) {
      MessageToUser.showMessage(
        context,
        AppLocalizations.of(context)!.addExpenseDialog_success,
      );
      Navigator.of(context).pop();
    } else {
      setState(
        () =>
            _errorMessage =
                AppLocalizations.of(context)!.addExpenseDialog_failure,
      );
    }
  }
}
