import 'package:budgetbuddy/bloc/Data/progress_helper.dart';
import 'package:budgetbuddy/pojos/budget.dart';
import 'package:budgetbuddy/pojos/expenses.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('computeProgressSummary', () {
    test(
      'correctly computes monthly progress with one budget and one expense',
      () {
        final budget = Budget(
          name: 'Groceries',
          category: 'Food',
          createdAt: DateTime(2024, 12, 1),
          resetPeriod: 'Monthly',
          alertThreshold: 0.8,
          totalAmount: 100.0,
        );

        final expense = Expense(
          id: 'e1',
          merchant: 'Store A',
          amount: 40.0,
          createdAt: DateTime(2025, 4, 1),
        );

        budget.expenses.add(expense);

        final result = computeProgressSummary([budget]);

        expect(result.containsKey('2024-12'), true);
        expect(result.containsKey('2025-04'), true);
        expect(result['2025-04']!['limit'], 100.0);
        expect(result['2025-04']!['used'], 40.0);
        expect(result['2025-03']!['used'], 0.0);
      },
    );

    test(
      'correctly computes weekly progress with one budget and one expense',
      () {
        final budget = Budget(
          name: 'Transport',
          category: 'Travel',
          createdAt: DateTime(2025, 4, 1),
          resetPeriod: 'Weekly',
          alertThreshold: 0.5,
          totalAmount: 70.0,
        );

        final expense = Expense(
          id: 'e2',
          merchant: 'Train',
          amount: 20.0,
          createdAt: DateTime(2025, 4, 2),
        );

        budget.expenses.add(expense);

        final result = computeProgressSummary([budget]);

        final key = result.keys.firstWhere((k) => k.startsWith('2025-W'));
        expect(result[key]!['limit'], 70.0);
        expect(result[key]!['used'], 20.0);
      },
    );

    test(
      'correctly computes biweekly progress with one budget and one expense',
      () {
        final budget = Budget(
          name: 'Dining',
          category: 'Food',
          createdAt: DateTime(2025, 3, 18),
          resetPeriod: 'Biweekly',
          alertThreshold: 0.75,
          totalAmount: 200.0,
        );

        final expense = Expense(
          id: 'e3',
          merchant: 'Restaurant',
          amount: 60.0,
          createdAt: DateTime(2025, 3, 26),
        );

        budget.expenses.add(expense);

        final result = computeProgressSummary([budget]);

        final key = result.keys.firstWhere((k) => k.startsWith('2025-BW'));
        expect(result[key]!['limit'], 200.0);
        expect(result[key]!['used'], 60.0);
      },
    );

    test('returns empty map when no budgets are provided', () {
      final result = computeProgressSummary([]);
      expect(result, isEmpty);
    });

    test('budget with no expenses still propagates limits correctly', () {
      final budget = Budget(
        name: 'Utilities',
        category: 'Bills',
        createdAt: DateTime(2025, 3, 1),
        resetPeriod: 'Monthly',
        alertThreshold: 0.9,
        totalAmount: 200.0,
      );

      final result = computeProgressSummary([budget]);

      final now = DateTime.now();
      final currentKey = "${now.year}-${now.month.toString().padLeft(2, '0')}";

      // Should have a key for the current month
      expect(result.containsKey(currentKey), true);

      // Used should be 0 since there are no expenses
      expect(result[currentKey]!['used'], 0.0);

      // Limit should be present
      expect(result[currentKey]!['limit'], 200.0);
    });
  });
}