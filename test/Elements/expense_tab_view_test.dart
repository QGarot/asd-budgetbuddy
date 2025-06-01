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
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

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
            merchant: 'Supermarket',
            amount: 50.0,
            createdAt: DateTime(2024, 1, 1),
            category: 'Groceries',
            paymentMethod: 'Cash',
            notes: 'Weekly groceries',
          ),
          Expense(
            merchant: 'Bakery',
            amount: 20.0,
            createdAt: DateTime(2024, 1, 2),
            category: 'Groceries',
            paymentMethod: 'Credit Card',
            notes: 'Bread and pastries',
          ),
        ],
      );
      testUserData = AllUserData(
        username: 'Test',
        email: 'test@example.com',
        locale: 'en',
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
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en'), // English
          ],
          locale: const Locale('en'), // Force English locale for tests
          home: Scaffold(
            body: BlocProvider<DataCubit>.value(
              value: mockDataCubit,
              child: ExpensesTabView(budgetId: '1'),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Expenses'), findsOneWidget);
      expect(find.text('ALL EXPENSES'), findsOneWidget);
      expect(find.text('RECENT'), findsOneWidget);
      expect(find.text('HIGHEST'), findsOneWidget);
      expect(find.byType(TabBar), findsOneWidget);

      expect(find.text('Supermarket'), findsOneWidget);
      expect(find.text('Bakery'), findsOneWidget);
      expect(find.text('€50.00'), findsOneWidget);
      expect(find.text('€20.00'), findsOneWidget);

      await tester.tap(find.text('RECENT'));
      await tester.pumpAndSettle();

      final firstExpense = find.text('Bakery');
      final secondExpense = find.text('Supermarket');
      expect(
        tester.getTopLeft(firstExpense).dy <
            tester.getTopLeft(secondExpense).dy,
        true,
      );

      await tester.tap(find.text('HIGHEST'));
      await tester.pumpAndSettle();

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
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en'), // English
          ],
          locale: const Locale('en'), // Force English locale for tests
          home: Scaffold(
            body: BlocProvider<DataCubit>.value(
              value: mockDataCubit,
              child: ExpensesTabView(budgetId: '1'),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Supermarket'), findsNothing);
      expect(find.text('Bakery'), findsNothing);
    });

    testWidgets('displays expense item details correctly', (tester) async {
      when(mockDataCubit.state).thenReturn(testUserData);
      when(mockDataCubit.stream).thenAnswer((_) => Stream.value(testUserData));
      when(mockDataCubit.getFirebaseUserData()).thenReturn(testUserData);

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en'), // English
          ],
          locale: const Locale('en'), // Force English locale for tests
          home: Scaffold(
            body: BlocProvider<DataCubit>.value(
              value: mockDataCubit,
              child: ExpensesTabView(budgetId: '1'),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final firstExpenseItem =
          find
              .ancestor(
                of: find.text('Supermarket'),
                matching: find.byType(Padding),
              )
              .first;

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
