import 'package:flutter_test/flutter_test.dart';
import 'package:budgetbuddy/pojos/expenses.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() {
  group('Expense', () {
    test('constructor generates id and empty notes if not provided', () {
      final expense = Expense(
        merchant: 'Amazon',
        amount: 99.99,
        createdAt: DateTime(2024, 5, 1),
        category: 'Shopping',
        paymentMethod: 'Credit Card',
      );

      expect(expense.id, isNotEmpty);
      expect(expense.notes, equals(''));
    });

    test('copyWith creates a modified copy', () {
      final original = Expense(
        merchant: 'Amazon',
        amount: 99.99,
        createdAt: DateTime(2024, 5, 1),
        category: 'Shopping',
        paymentMethod: 'Credit Card',
      );

      final copy = original.copyWith(amount: 42.0, merchant: 'eBay');

      expect(copy.amount, equals(42.0));
      expect(copy.merchant, equals('eBay'));
      expect(copy.category, equals(original.category)); // unchanged
    });

    test('fromFirestore builds correctly from data', () {
      final timestamp = Timestamp.fromDate(DateTime(2024, 5, 1));
      final data = {
        'id': 'abc123',
        'merchant': 'Amazon',
        'amount': 19.95,
        'createdAt': timestamp,
        'notes': 'Online order',
        'category': 'Shopping',
        'paymentMethod': 'Debit Card',
      };

      final expense = Expense.fromFirestore(data);

      expect(expense.id, equals('abc123'));
      expect(expense.createdAt, equals(DateTime(2024, 5, 1)));
    });

    test('toFirestore returns expected map', () {
      final date = DateTime(2024, 5, 1);
      final expense = Expense(
        id: 'xyz789',
        merchant: 'Netflix',
        amount: 12.99,
        createdAt: date,
        category: 'Entertainment',
        paymentMethod: 'Credit Card',
        notes: 'Subscription',
      );

      final map = expense.toFirestore();

      expect(map['id'], 'xyz789');
      expect(map['merchant'], 'Netflix');
      expect(map['createdAt'], date); // same object
    });
  });
}
