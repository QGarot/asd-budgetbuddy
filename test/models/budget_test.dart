import 'package:flutter_test/flutter_test.dart';
import 'package:budgetbuddy/pojos/budget.dart';
import 'package:budgetbuddy/pojos/expenses.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() {
  group('Budget', () {
    final testDate = DateTime(2024, 6, 1);

    final testExpense = Expense(
      merchant: 'Spotify',
      amount: 10.0,
      createdAt: testDate,
      category: 'Entertainment',
      paymentMethod: 'Credit Card',
    );

    test('constructor sets default values', () {
      final budget = Budget(
        name: 'Monthly Budget',
        category: 'General',
        createdAt: testDate,
        resetPeriod: 'Monthly',
        alertThreshold: 0.8,
        totalAmount: 1000.0,
      );

      expect(budget.id, isNotEmpty);
      expect(budget.spentAmount, equals(0));
      expect(budget.expenses, isEmpty);
      expect(budget.name, 'Monthly Budget');
    });

    test('copyWith creates modified copy', () {
      final original = Budget(
        name: 'Food',
        category: 'Groceries',
        createdAt: testDate,
        resetPeriod: 'Weekly',
        alertThreshold: 0.5,
        totalAmount: 500.0,
      );

      final modified = original.copyWith(name: 'Utilities', totalAmount: 300.0);

      expect(modified.name, 'Utilities');
      expect(modified.totalAmount, 300.0);
      expect(modified.category, original.category); // unchanged
      expect(modified.id, original.id); // should keep same ID
    });

    test('fromFirestore builds correctly from map', () {
      final data = {
        'id': 'budget123',
        'name': 'Home',
        'category': 'Housing',
        'createdAt': Timestamp.fromDate(testDate),
        'resetPeriod': 'Monthly',
        'alertThreshold': 0.75,
        'totalAmount': 1200.0,
        'spentAmount': 300.0,
      };

      final budget = Budget.fromFirestore(data, [testExpense]);

      expect(budget.id, 'budget123');
      expect(budget.name, 'Home');
      expect(budget.expenses.length, 1);
      expect(budget.createdAt, testDate);
    });

    test('toFirestore returns correct map', () {
      final budget = Budget(
        id: 'test-id',
        name: 'Travel',
        category: 'Leisure',
        createdAt: testDate,
        resetPeriod: 'Yearly',
        alertThreshold: 0.9,
        totalAmount: 5000.0,
        spentAmount: 500.0,
        expenses: [testExpense],
      );

      final map = budget.toFirestore();

      expect(map['id'], 'test-id');
      expect(map['name'], 'Travel');
      expect(map['category'], 'Leisure');
      expect(map['createdAt'], Timestamp.fromDate(testDate));
      expect(map['totalAmount'], 5000.0);
      expect(map.containsKey('icon'), isFalse); // icon is not saved
    });
  });
}
