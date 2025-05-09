import 'package:budgetbuddy/Elements/expense_tab_view.dart';
import 'package:budgetbuddy/bloc/Data/data_bloc.dart';
import 'package:budgetbuddy/pojos/budget.dart';
import 'package:budgetbuddy/pojos/expenses.dart';
import 'package:budgetbuddy/pojos/user_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../mockito/mock_classes.mocks.dart';

void main() {
  group('ExpensesTabView', () {
    late MockDataCubit mockDataCubit;
    late Budget testBudget;
    late AllUserData testUserData;

    setUp(() {
      mockDataCubit = MockDataCubit();
      testBudget = Budget(
        id: '1',
        name: 'Test Budget',
        category: 'Groceries',
        createdAt: DateTime(2024),
        resetPeriod: 'Monthly',
        alertThreshold: 0.8,
        totalAmount: 1000,
        expenses: [
          Expense(
            id: '1',
            merchant: 'Supermarket',
            amount: 50.0,
            createdAt: DateTime(2024, 1, 1),
            notes: 'Weekly groceries',
          ),
          Expense(
            id: '2',
            merchant: 'Bakery',
            amount: 20.0,
            createdAt: DateTime(2024, 1, 2),
            notes: 'Bread and pastries',
          ),
        ],
      );
      testUserData = AllUserData(
        username: 'Test',
        email: 'test@example.com',
        createdAt: DateTime(2024),
        budgets: [testBudget],
      );
    });

    testWidgets('renders and switches tabs', (tester) async {
      when(mockDataCubit.state).thenReturn(testUserData);
      when(mockDataCubit.stream).thenAnswer((_) => Stream.value(testUserData));
      when(mockDataCubit.getFirebaseUserData()).thenReturn(testUserData);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BlocProvider<DataCubit>.value(
              value: mockDataCubit,
              child: ExpensesTabView(budgetId: '1'),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Check if the main elements are rendered
      expect(find.text('Expenses'), findsOneWidget);
      expect(find.text('ALL EXPENSES'), findsOneWidget);
      expect(find.text('RECENT'), findsOneWidget);
      expect(find.text('HIGHEST'), findsOneWidget);
      expect(find.byType(TabBar), findsOneWidget);

      // Check if expenses are displayed
      expect(find.text('Supermarket'), findsOneWidget);
      expect(find.text('Bakery'), findsOneWidget);
      expect(find.text('€50.00'), findsOneWidget);
      expect(find.text('€20.00'), findsOneWidget);

      // Test tab switching
      await tester.tap(find.text('RECENT'));
      await tester.pumpAndSettle();

      // Verify the order of expenses (most recent first)
      final firstExpense = find.text('Bakery');
      final secondExpense = find.text('Supermarket');
      expect(
        tester.getTopLeft(firstExpense).dy <
            tester.getTopLeft(secondExpense).dy,
        true,
      );

      // Test HIGHEST tab
      await tester.tap(find.text('HIGHEST'));
      await tester.pumpAndSettle();

      // Verify the order of expenses (highest amount first)
      final highestExpense = find.text('Supermarket');
      final lowerExpense = find.text('Bakery');
      expect(
        tester.getTopLeft(highestExpense).dy <
            tester.getTopLeft(lowerExpense).dy,
        true,
      );
    });

    testWidgets('displays empty state when no expenses', (tester) async {
      final emptyBudget = testBudget.copyWith(expenses: []);
      final emptyUserData = testUserData.copyWith(budgets: [emptyBudget]);

      when(mockDataCubit.state).thenReturn(emptyUserData);
      when(mockDataCubit.stream).thenAnswer((_) => Stream.value(emptyUserData));
      when(mockDataCubit.getFirebaseUserData()).thenReturn(emptyUserData);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BlocProvider<DataCubit>.value(
              value: mockDataCubit,
              child: ExpensesTabView(budgetId: '1'),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify no expense items are shown
      expect(find.text('Supermarket'), findsNothing);
      expect(find.text('Bakery'), findsNothing);
    });

    testWidgets('throws error when budget not found', (tester) async {
      when(mockDataCubit.state).thenReturn(testUserData);
      when(mockDataCubit.stream).thenAnswer((_) => Stream.value(testUserData));
      when(mockDataCubit.getFirebaseUserData()).thenReturn(testUserData);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BlocProvider<DataCubit>.value(
              value: mockDataCubit,
              child: ExpensesTabView(budgetId: 'non-existent-id'),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify error message is shown
      expect(
        find.text('Budget not found for the given id: non-existent-id'),
        findsOneWidget,
      );
    });

    testWidgets('displays expense item details correctly', (tester) async {
      when(mockDataCubit.state).thenReturn(testUserData);
      when(mockDataCubit.stream).thenAnswer((_) => Stream.value(testUserData));
      when(mockDataCubit.getFirebaseUserData()).thenReturn(testUserData);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BlocProvider<DataCubit>.value(
              value: mockDataCubit,
              child: ExpensesTabView(budgetId: '1'),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Find the first expense item container
      final firstExpenseItem =
          find
              .ancestor(
                of: find.text('Supermarket'),
                matching: find.byType(Padding),
              )
              .first;

      // Verify expense item details within the first expense item
      expect(
        find.descendant(
          of: firstExpenseItem,
          matching: find.text('Supermarket'),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: firstExpenseItem,
          matching: find.text('1/1/2024 • Weekly groceries'),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(of: firstExpenseItem, matching: find.text('€50.00')),
        findsOneWidget,
      );
      expect(
        find.descendant(of: firstExpenseItem, matching: find.text('Groceries')),
        findsOneWidget,
      );

      // Verify action buttons are present
      expect(
        find.descendant(
          of: firstExpenseItem,
          matching: find.byIcon(Icons.receipt),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: firstExpenseItem,
          matching: find.byIcon(Icons.notes_rounded),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: firstExpenseItem,
          matching: find.byIcon(Icons.edit),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: firstExpenseItem,
          matching: find.byIcon(Icons.delete),
        ),
        findsOneWidget,
      );
    });
  });
}
