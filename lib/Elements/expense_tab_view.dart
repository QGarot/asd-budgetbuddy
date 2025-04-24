import 'package:budgetbuddy/AppData/category_icons.dart';
import 'package:budgetbuddy/bloc/Data/data_event.dart';
import 'package:budgetbuddy/pojos/budget.dart';
import 'package:budgetbuddy/pojos/expenses.dart';
import 'package:budgetbuddy/pojos/user_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:budgetbuddy/bloc/Data/data_bloc.dart';

class ExpensesTabView extends StatefulWidget {
  const ExpensesTabView({super.key, required this.budgetId});

  final String budgetId;

  @override
  State<ExpensesTabView> createState() => _ExpensesTabViewState();
}

class _ExpensesTabViewState extends State<ExpensesTabView> {
  final List<String> _tabs = const ['ALL EXPENSES', 'RECENT', 'HIGHEST'];

  @override
  Widget build(BuildContext context) {
    Budget? budget = DataEvent.getFirebaseUserData(
      context,
    )?.budgets.firstWhere((budget) => budget.id == widget.budgetId);

    if (budget == null) {
      throw Exception("Budget not found for the given id: ${widget.budgetId}");
    }

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
              padding: const EdgeInsets.fromLTRB(20, 10, 0, 20),
              child: Text(
                "Expenses",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            TabBar(
              isScrollable: true,
              labelColor: Colors.deepPurple,
              unselectedLabelColor: Colors.black45,
              indicatorColor: Colors.deepPurpleAccent,
              tabs: _tabs.map((tab) => Tab(text: tab)).toList(),
            ),
            Expanded(
              child: TabBarView(
                children:
                    _tabs.map((tab) {
                      return BlocBuilder<DataCubit, AllUserData?>(
                        builder: (context, userData) {
                          final List<Expense> expenses = _getExpensesByTab(
                            tab,
                            userData?.budgets
                                    .firstWhere(
                                      (budget) => budget.id == widget.budgetId,
                                    )
                                    .expenses ??
                                [],
                          );

                          return ListView.separated(
                            padding: EdgeInsets.zero,
                            itemCount: expenses.length,
                            separatorBuilder:
                                (context, index) => Divider(height: 1),
                            itemBuilder: (context, index) {
                              final expense = expenses[index];
                              return ExpenseListItem(
                                expense: expense,
                                category: budget.category,
                              );
                            },
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
  }

  List<Expense> _getExpensesByTab(String tab, List<Expense> allExpenses) {
    if (tab == 'RECENT') {
      // Sort by most recent date
      final sorted = List<Expense>.from(allExpenses)
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return sorted;
    } else if (tab == 'HIGHEST') {
      // Sort by highest amount
      final sorted = List<Expense>.from(allExpenses)
        ..sort((a, b) => b.amount.compareTo(a.amount));
      return sorted;
    }
    // 'ALL EXPENSES' tab - return all expenses
    return allExpenses;
  }
}

class ExpenseListItem extends StatelessWidget {
  final Expense expense;
  final String category;

  const ExpenseListItem({
    super.key,
    required this.expense,
    required this.category,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      expense.merchant,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
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
                            CategoryIcons.getIcon(category),
                            size: 14,
                            color: Colors.grey[700],
                          ),
                          SizedBox(width: 4),
                          Text(
                            category,
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
                  "${_formatDate(expense.createdAt)} • ${expense.notes}",
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
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
              IconButton(
                icon: Icon(Icons.receipt_outlined, color: Colors.grey),
                onPressed: () {},
                padding: EdgeInsets.zero,
                constraints: BoxConstraints(),
              ),
              SizedBox(width: 8),
              IconButton(
                icon: Icon(Icons.check_circle_outline, color: Colors.grey),
                onPressed: () {},
                padding: EdgeInsets.zero,
                constraints: BoxConstraints(),
              ),
              SizedBox(width: 8),
              IconButton(
                icon: Icon(Icons.edit_outlined, color: Colors.grey),
                onPressed: () {},
                padding: EdgeInsets.zero,
                constraints: BoxConstraints(),
              ),
              SizedBox(width: 8),
              IconButton(
                icon: Icon(Icons.delete_outline, color: Colors.grey),
                onPressed: () {},
                padding: EdgeInsets.zero,
                constraints: BoxConstraints(),
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
}
