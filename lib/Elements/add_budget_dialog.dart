import 'package:budgetbuddy/AppData/app_colors.dart';
import 'package:budgetbuddy/Elements/message_to_user.dart';
import 'package:budgetbuddy/Elements/standard_dialog_box.dart';
import 'package:budgetbuddy/bloc/Data/data_event.dart';
import 'package:budgetbuddy/pojos/budget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// Move these enums into your shared model/pocos so they're reusable everywhere.
enum BudgetCategory {
  Groceries,
  Rent,
  Utilities,
  Entertainment,
  Travel,
  Dining,
  Shopping,
  Other,
}

enum BudgetPeriod { Weekly, Biweekly, Monthly }

class AddBudgetDialog extends StatefulWidget {
  const AddBudgetDialog({super.key});

  @override
  State<AddBudgetDialog> createState() => _AddBudgetDialogState();
}

class _AddBudgetDialogState extends State<AddBudgetDialog> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();

  BudgetCategory? _selectedCategory;
  BudgetPeriod? _selectedPeriod;
  double _alertThreshold = 0.8;
  String? _errorMessage;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return StandardDialogBox(
      title: loc.addBudgetDialog_title,
      subtitle: loc.addBudgetDialog_subtitle,
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
                label: loc.addBudgetDialog_budgetNameLabel,
                hint: loc.addBudgetDialog_budgetNameHint,
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
                label: loc.addBudgetDialog_amountLabel,
                hint: loc.addBudgetDialog_amountHint,
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
                    return loc.addBudgetDialog_invalidAmount;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 13),
              Row(
                children: [
                  Expanded(
                    child:
                        StandardDialogBox.buildStandardDropdown<BudgetCategory>(
                          context: context,
                          label: loc.addBudgetDialog_categoryLabel,
                          selectedValue: _selectedCategory,
                          items: BudgetCategory.values,
                          onChanged:
                              (value) =>
                                  setState(() => _selectedCategory = value),
                          itemLabel: (cat) {
                            switch (cat) {
                              case BudgetCategory.Groceries:
                                return loc.category_groceries;
                              case BudgetCategory.Rent:
                                return loc.category_rent;
                              case BudgetCategory.Utilities:
                                return loc.category_utilities;
                              case BudgetCategory.Entertainment:
                                return loc.category_entertainment;
                              case BudgetCategory.Travel:
                                return loc.category_travel;
                              case BudgetCategory.Dining:
                                return loc.category_dining;
                              case BudgetCategory.Shopping:
                                return loc.category_shopping;
                              case BudgetCategory.Other:
                                return loc.category_other;
                            }
                          },
                        ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child:
                        StandardDialogBox.buildStandardDropdown<BudgetPeriod>(
                          context: context,
                          label: loc.addBudgetDialog_periodLabel,
                          selectedValue: _selectedPeriod,
                          items: BudgetPeriod.values,
                          onChanged:
                              (value) =>
                                  setState(() => _selectedPeriod = value),
                          itemLabel: (p) {
                            switch (p) {
                              case BudgetPeriod.Weekly:
                                return loc.period_weekly;
                              case BudgetPeriod.Biweekly:
                                return loc.period_biweekly;
                              case BudgetPeriod.Monthly:
                                return loc.period_monthly;
                            }
                          },
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                loc.addBudgetDialog_alertThreshold(
                  (100 * _alertThreshold).toInt(),
                ),
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              Directionality(
                textDirection: TextDirection.ltr,
                child: Column(
                  children: [
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        trackHeight: 8,
                        trackShape: const RoundedRectSliderTrackShape(),
                        activeTrackColor: AppColors.yellowColor,
                        inactiveTrackColor: AppColors.yellowColorFaint,
                        thumbColor: Colors.transparent,
                        overlayColor: Colors.transparent,
                        thumbShape: const RoundSliderThumbShape(
                          enabledThumbRadius: 0,
                        ),
                        overlayShape: const RoundSliderOverlayShape(
                          overlayRadius: 0,
                        ),
                        tickMarkShape: const RoundSliderTickMarkShape(
                          tickMarkRadius: 0,
                        ),
                        showValueIndicator: ShowValueIndicator.never,
                      ),
                      child: Slider(
                        value: _alertThreshold,
                        onChanged:
                            (value) => setState(() => _alertThreshold = value),
                        min: 0.0,
                        max: 1.0,
                        divisions: 20,
                      ),
                    ),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [Text('0%'), Text('100%')],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 13),
              Text(
                loc.addBudgetDialog_alertDescription,
                style: TextStyle(color: Colors.grey[600], fontSize: 13),
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
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(bottom: 10, top: 8),
          child: TextButton(
            onPressed: () => Navigator.of(context).pop(),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
            ),
            child: Text(loc.common_cancel),
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
            child: Text(loc.addBudgetDialog_createBudget),
          ),
        ),
      ],
    );
  }

  void _createBudget() {
    final form = _formKey.currentState;
    final raw = _amountController.text.trim().replaceAll(',', '.');
    final parsed = double.tryParse(raw);
    final amount =
        parsed != null ? double.parse(parsed.toStringAsFixed(2)) : null;

    setState(() => _errorMessage = null);

    if (form == null || !form.validate()) return;

    if (_nameController.text.trim().isEmpty ||
        raw.isEmpty ||
        _selectedCategory == null ||
        _selectedPeriod == null) {
      setState(() {
        _errorMessage =
            AppLocalizations.of(context)!.addBudgetDialog_fillAllFields;
      });
      return;
    }

    final budget = Budget(
      name: _nameController.text.trim(),
      // Store English key names in Firestore:
      category: _selectedCategory!.name,
      resetPeriod: _selectedPeriod!.name,
      alertThreshold: _alertThreshold,
      totalAmount: amount!,
      createdAt: DateTime.now(),
    );

    DataEvent.addBudget(context, budget)
        .then((success) {
          if (success) {
            MessageToUser.showMessage(
              context,
              AppLocalizations.of(context)!.addBudgetDialog_addedSuccess,
            );
            Navigator.of(context).pop();
          } else {
            setState(() {
              _errorMessage =
                  AppLocalizations.of(context)!.addBudgetDialog_addFailed;
            });
          }
        })
        .catchError((_) {
          setState(() {
            _errorMessage =
                AppLocalizations.of(context)!.addBudgetDialog_addFailed;
          });
        });
  }
}
