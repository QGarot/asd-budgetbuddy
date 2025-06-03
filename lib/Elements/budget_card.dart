import 'package:budgetbuddy/AppData/app_colors.dart';
import 'package:budgetbuddy/Elements/message_to_user.dart';
import 'package:budgetbuddy/Elements/standard_dialog_box.dart';
import 'package:budgetbuddy/bloc/Data/data_bloc.dart';
import 'package:budgetbuddy/bloc/Navigation/sidebar_cubit.dart';
import 'package:budgetbuddy/pojos/budget.dart';
import 'package:budgetbuddy/screens/expense_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
  final String idOfBudget;

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
    required this.idOfBudget,
  });

  void _navigateToEditScreen(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => EditBudgetDialog(budget: budget),
      barrierDismissible: false,
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: Colors.white,
            title: Text(
              loc.budgetCard_confirmDeletionTitle,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            content: Text(
              loc.budgetCard_confirmDeletionContent(title),
              style: const TextStyle(fontSize: 16, color: Colors.black87),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  loc.common_cancel,
                  style: const TextStyle(
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
                  child: Text(
                    loc.budgetCard_delete,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
            actionsPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final percent = (spent / limit).clamp(0.0, 1.0);
    final remaining = limit - spent;

    String localizedPeriod;
    switch (period.toLowerCase()) {
      case 'weekly':
        localizedPeriod = loc.period_weekly;
        break;
      case 'biweekly':
        localizedPeriod = loc.period_biweekly;
        break;
      case 'monthly':
        localizedPeriod = loc.period_monthly;
        break;
      default:
        localizedPeriod = period;
    }

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
                icon: const Icon(Icons.arrow_drop_down, size: 24),
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
                itemBuilder:
                    (BuildContext context) => <PopupMenuEntry<String>>[
                      PopupMenuItem<String>(
                        value: 'edit',
                        child: Row(
                          children: [
                            const Icon(Icons.edit),
                            const SizedBox(width: 8),
                            Text(loc.budgetCard_menuEdit),
                          ],
                        ),
                      ),
                      PopupMenuItem<String>(
                        value: 'delete',
                        child: Row(
                          children: [
                            const Icon(Icons.delete, color: Colors.red),
                            const SizedBox(width: 8),
                            Text(
                              loc.budgetCard_menuDelete,
                              style: const TextStyle(color: Colors.red),
                            ),
                          ],
                        ),
                      ),
                    ],
              ),
            ],
          ),
          const SizedBox(height: 4),
          if (!isCollapsed)
            Text(
              localizedPeriod,
              style: const TextStyle(color: Colors.black54),
            ),
          const SizedBox(height: 16),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  "€${spent.toStringAsFixed(2)} ${loc.budgetCard_of} €${limit.toStringAsFixed(2)}",
                  style: const TextStyle(fontWeight: FontWeight.w600),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 4),
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
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "€${remaining.toStringAsFixed(2)} ${loc.budgetCard_remaining}",
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                if (warning)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.dangerColor.withAlpha(
                        (255 * 0.1).toInt(),
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.warning,
                          size: 16,
                          color: AppColors.dangerColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          loc.budgetCard_warningApproachingLimit,
                          style: const TextStyle(
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
                onPressed: () {
                  CurrentBudget.budgetId = idOfBudget;
                  final cubit = context.read<SidebarCubit>();
                  cubit.selectPage(SidebarPage.showExpense);
                },
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  foregroundColor: AppColors.primaryColor,
                ),
                child: Text(loc.budgetCard_viewExpenses),
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

  late BudgetCategory _selectedCategory;
  late BudgetPeriod _selectedPeriod;
  late double _alertThreshold;

  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.budget.name);
    _amountController = TextEditingController(
      text: widget.budget.totalAmount.toStringAsFixed(2),
    );
    _selectedCategory = BudgetCategory.values.firstWhere(
      (c) => c.name == widget.budget.category,
      orElse: () => BudgetCategory.Other,
    );
    _selectedPeriod = BudgetPeriod.values.firstWhere(
      (p) => p.name == widget.budget.resetPeriod,
      orElse: () => BudgetPeriod.Monthly,
    );
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
    final loc = AppLocalizations.of(context)!;
    return StandardDialogBox(
      title: loc.editBudgetDialog_title,
      subtitle: loc.editBudgetDialog_subtitle,
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
                label: loc.editBudgetDialog_budgetNameLabel,
                hint: loc.editBudgetDialog_budgetNameHint,
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
                label: loc.editBudgetDialog_amountLabel,
                hint: loc.editBudgetDialog_amountHint,
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
                          label: loc.editBudgetDialog_categoryLabel,
                          selectedValue: _selectedCategory,
                          items: BudgetCategory.values,
                          onChanged:
                              (value) =>
                                  setState(() => _selectedCategory = value!),
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
                          label: loc.editBudgetDialog_periodLabel,
                          selectedValue: _selectedPeriod,
                          items: BudgetPeriod.values,
                          onChanged:
                              (value) =>
                                  setState(() => _selectedPeriod = value!),
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
                      children: [Text("0%"), Text("100%")],
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
            child: Text(loc.editBudgetDialog_saveChanges),
          ),
        ),
      ],
    );
  }

  void _updateBudget() {
    final loc = AppLocalizations.of(context)!;
    final form = _formKey.currentState;

    setState(() {
      _errorMessage = null;
    });

    if (form == null || !form.validate()) return;

    if (_nameController.text.trim().isEmpty ||
        _amountController.text.trim().isEmpty) {
      setState(() {
        _errorMessage = loc.editBudgetDialog_fillMissingFields;
      });
      return;
    }

    final rawAmountText = _amountController.text.trim().replaceAll(',', '.');
    final parsedAmount = double.tryParse(rawAmountText);

    if (parsedAmount == null || parsedAmount <= 0) {
      setState(() {
        _errorMessage = loc.addBudgetDialog_invalidAmount;
      });
      return;
    }

    final DataCubit dataCubit = context.read<DataCubit>();
    dataCubit
        .updateBudget(
          widget.budget.id,
          name: _nameController.text.trim(),
          category: _selectedCategory.name,
          alertThreshold: _alertThreshold,
          resetPeriod: _selectedPeriod.name,
          totalAmount: parsedAmount,
        )
        .then((success) {
          if (success) {
            MessageToUser.showMessage(context, loc.editBudgetDialog_success);
            Navigator.of(context).pop();
          } else {
            setState(() {
              _errorMessage = loc.editBudgetDialog_failure;
            });
          }
        })
        .catchError((error) {
          setState(() {
            _errorMessage = loc.editBudgetDialog_errorOccurred(
              error.toString(),
            );
          });
        });
  }
}
