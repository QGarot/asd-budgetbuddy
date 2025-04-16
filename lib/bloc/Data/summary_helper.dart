import 'package:budgetbuddy/pojos/budget.dart';

/// A helper class to summarize total budget information
class BudgetSummary {
  //Vars
  final double totalBudget;
  final double totalSpent;
  final double remaining;

  // Constructor
  BudgetSummary({
    required this.totalBudget,
    required this.totalSpent,
    required this.remaining,
  });

  // Factory constructor to create a BudgetSummary from a list of Budget objects
  factory BudgetSummary.fromBudgets(List<Budget> budgets) {
    final total = budgets.fold(0.0, (sum, b) => sum + b.totalAmount);
    final spent = budgets.fold(0.0, (sum, b) => sum + b.spentAmount);
    return BudgetSummary(
      totalBudget: total,
      totalSpent: spent,
      remaining: total - spent,
    );
  }
}
