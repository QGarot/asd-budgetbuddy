import 'package:budgetbuddy/bloc/Data/data_bloc.dart';
import 'package:budgetbuddy/pojos/budget.dart';
import 'package:budgetbuddy/pojos/expenses.dart';
import 'package:budgetbuddy/pojos/user_data.dart';
import 'package:budgetbuddy/screens/expense_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../mockito/mock_classes.mocks.dart';

void main() {
  group('ExpenseScreen Widget Tests', () {
    late MockDataCubit mockDataCubit;
    late Budget testBudget;
    late AllUserData testUserData;

    setUp(() {
      mockDataCubit = MockDataCubit();
      testBudget = Budget(
        id: 'test-budget-1',
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

      // Setup mock behavior
      when(mockDataCubit.state).thenReturn(testUserData);
      when(mockDataCubit.stream).thenAnswer((_) => Stream.value(testUserData));
      when(mockDataCubit.getFirebaseUserData()).thenReturn(testUserData);
      when(mockDataCubit.addExpense(any, any)).thenAnswer((_) async => true);
    });

    Widget createWidgetUnderTest() {
      return MaterialApp(
        home: BlocProvider<DataCubit>.value(
          value: mockDataCubit,
          child: const ExpenseScreen(),
        ),
      );
    }

    testWidgets('renders header bar with correct title and return button', (
      tester,
    ) async {
      // Set a larger screen size
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;

      // Set the current budget ID
      CurrentBudget.budgetId = 'test-budget-1';

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text('Budget Dashboard'), findsOneWidget);
      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
    });

    testWidgets(
      'renders dashboard header with budget name and add expense button',
      (tester) async {
        // Set a larger screen size
        tester.view.physicalSize = const Size(1920, 1080);
        tester.view.devicePixelRatio = 1.0;

        // Set the current budget ID
        CurrentBudget.budgetId = 'test-budget-1';

        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pumpAndSettle();

        expect(find.text('Test Budget'), findsOneWidget);
        expect(
          find.text('Track and manage your expenses for this budget'),
          findsOneWidget,
        );
        expect(find.text('Add Expense'), findsOneWidget);
      },
    );

    testWidgets('renders expenses tab view with correct tabs', (tester) async {
      // Set a larger screen size
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;

      // Set the current budget ID
      CurrentBudget.budgetId = 'test-budget-1';

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text('ALL EXPENSES'), findsOneWidget);
      expect(find.text('RECENT'), findsOneWidget);
      expect(find.text('HIGHEST'), findsOneWidget);
    });

    testWidgets('displays error message when budget is not found', (
      tester,
    ) async {
      // Set a larger screen size
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;

      // Set an invalid budget ID
      CurrentBudget.budgetId = 'non-existent-budget';

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(
        find.text('No budget found, this should never happen'),
        findsOneWidget,
      );
    });

    testWidgets('adds expense when add expense button is pressed', (
      tester,
    ) async {
      // Set a larger screen size
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;

      // Set the current budget ID
      CurrentBudget.budgetId = 'test-budget-1';

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Find and tap the Add Expense button
      await tester.tap(find.text('Add Expense'));
      await tester.pumpAndSettle();

      // Verify that addExpense was called
      verify(mockDataCubit.addExpense(any, any)).called(1);
    });
  });
}
