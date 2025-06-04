import 'package:budgetbuddy/AppData/category_icons.dart';
import 'package:budgetbuddy/Elements/edit_expense.dart';
import 'package:budgetbuddy/pojos/expenses.dart';
import 'package:budgetbuddy/pojos/user_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:budgetbuddy/bloc/Data/data_bloc.dart';
import 'package:budgetbuddy/Elements/message_to_user.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ExpensesTabView extends StatefulWidget {
  const ExpensesTabView({super.key, required this.budgetId});

  final String budgetId;

  @override
  State<ExpensesTabView> createState() => _ExpensesTabViewState();
}

class _ExpensesTabViewState extends State<ExpensesTabView> {
  final List<String> _tabs = const ['allExpenses', 'recent', 'highest'];

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return BlocBuilder<DataCubit, AllUserData?>(
      builder: (context, userData) {
        if (userData == null) {
          return const Center(child: CircularProgressIndicator());
        }

        final budget = userData.budgets.firstWhere(
          (b) => b.id == widget.budgetId,
        );

        return DefaultTabController(
          length: _tabs.length,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(20, 10, 0, 20),
                  child: Text(
                    loc.expensesTab_title,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                TabBar(
                  isScrollable: true,
                  labelColor: Colors.deepPurple,
                  unselectedLabelColor: Colors.black45,
                  indicatorColor: Colors.deepPurpleAccent,
                  tabs: _tabs.map((tabKey) {
                    String label;
                    switch (tabKey) {
                      case 'allExpenses':
                        label = loc.expensesTab_allExpenses;
                        break;
                      case 'recent':
                        label = loc.expensesTab_recent;
                        break;
                      case 'highest':
                        label = loc.expensesTab_highest;
                        break;
                      default:
                        label = tabKey;
                    }
                    return Tab(text: label);
                  }).toList(),
                ),
                Expanded(
                  child: TabBarView(
                    children:
                        _tabs.map((tab) {
                          final expenses = _getExpensesByTab(
                            tab,
                            budget.expenses,
                          );

                          return ListView.separated(
                            padding: EdgeInsets.zero,
                            itemCount: expenses.length,
                            separatorBuilder:
                                (_, __) => const Divider(height: 1),
                            itemBuilder: (context, index) {
                              final expense = expenses[index];
                              return ExpenseListItem(
                                expense: expense,
                                category: budget.category,
                                budgetId: budget.id,
                                categoryKey: budget.category,
                              );
                            },
                          );
                        }).toList(),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  List<Expense> _getExpensesByTab(String tab, List<Expense> allExpenses) {
    if (tab == 'recent') {
      // Sort by most recent date
      final sorted = List<Expense>.from(allExpenses)
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return sorted;
    } else if (tab == 'highest') {
      // Sort by highest amount
      final sorted = List<Expense>.from(allExpenses)
        ..sort((a, b) => b.amount.compareTo(a.amount));
      return sorted;
    }
    // 'allExpenses' tab - return all expenses
    return allExpenses;
  }
}

class ExpenseListItem extends StatelessWidget {
  final Expense expense;
  final String category;
  final String budgetId;
  final String categoryKey;

  const ExpenseListItem({
    super.key,
    required this.expense,
    required this.category,
    required this.budgetId,
    required this.categoryKey
  });

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final localizedCategory = _localizedCategory(context, categoryKey);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(
                        expense.merchant,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(width: 8),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            CategoryIcons.getIcon(categoryKey),
                            size: 14,
                            color: Colors.grey[700],
                          ),
                          SizedBox(width: 4),
                          Text(
                            localizedCategory,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4),
                Text(
                  "${_formatDate(expense.createdAt)} • ${expense.notes.length > 18 ? expense.notes.substring(0, 18) + '…' : expense.notes}",
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ],
            ),
          ),
          Text(
            "€${expense.amount.toStringAsFixed(2)}",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          SizedBox(width: 16),
          Row(
            children: [
              Tooltip(
                message: loc.expensesTab_tooltipNotes,
                child: IconButton(
                  icon: const Icon(Icons.notes_rounded, color: Colors.grey),
                  onPressed: () {
                    TextEditingController notesController =
                        TextEditingController(text: expense.notes);

                    showDialog(
                      context: context,
                      builder:
                          (context) => AlertDialog(
                            title: Text(loc.expensesTab_editNotes),
                            content: SizedBox(
                              height: 300,
                              width: 400,
                              child: TextField(
                                controller: notesController,
                                maxLines: null,
                                expands: true,
                                textAlignVertical: TextAlignVertical.top,
                                keyboardType: TextInputType.multiline,
                                decoration: InputDecoration(
                                  hintText: loc.expensesTab_enterYourNotes,
                                  border: OutlineInputBorder(),
                                  contentPadding: EdgeInsets.all(12),
                                ),
                              ),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: Text(loc.common_cancel),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  String updatedText = notesController.text;
                                  context.read<DataCubit>().updateExpense(
                                    budgetId,
                                    expense.copyWith(notes: updatedText),
                                  );
                                  Navigator.pop(context);
                                  MessageToUser.showMessage(
                                    context,
                                    loc.expensesTab_notesUpdated,
                                  );
                                },
                                child: Text(loc.common_save),
                              ),
                            ],
                          ),
                    );
                  },
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ),
              SizedBox(width: 8),
              Tooltip(
                message: loc.expensesTab_tooltipEdit,
                child: IconButton(
                  icon: Icon(Icons.edit, color: Colors.grey),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder:
                          (context) => EditExpenseDialog(
                            budgetId: budgetId,
                            expense: expense,
                          ),
                    );
                  },
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints(),
                ),
              ),
              SizedBox(width: 8),
              Tooltip(
                message: loc.expensesTab_tooltipDelete,
                child: IconButton(
                  icon: Icon(Icons.delete, color: Colors.grey),
                  onPressed: () {
                    context.read<DataCubit>().deleteExpense(
                      budgetId,
                      expense.id,
                    );
                    MessageToUser.showMessage(context, loc.expensesTab_expenseDeleted);
                  },
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return "${date.day}/${date.month}/${date.year}";
  }

  String _localizedCategory(BuildContext context, String categoryKey) {
    final loc = AppLocalizations.of(context)!;
    switch (categoryKey) {
      case 'Groceries':
        return loc.category_groceries;
      case 'Rent':
        return loc.category_rent;
      case 'Utilities':
        return loc.category_utilities;
      case 'Entertainment':
        return loc.category_entertainment;
      case 'Travel':
        return loc.category_travel;
      case 'Dining':
        return loc.category_dining;
      case 'Shopping':
        return loc.category_shopping;
      case 'Other':
        return loc.category_other;
      default:
        return categoryKey;
    }
  }
}
