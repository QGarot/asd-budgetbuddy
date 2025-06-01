import 'package:budgetbuddy/bloc/Data/data_bloc.dart';
import 'package:budgetbuddy/pojos/budget.dart';
import 'package:budgetbuddy/pojos/expenses.dart';
import 'package:budgetbuddy/pojos/user_data.dart';
import 'package:budgetbuddy/screens/expense_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

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
            merchant: 'Supermarket',
            amount: 50.0,
            createdAt: DateTime(2024, 1, 1),
            notes: 'Weekly groceries',
            category: 'Groceries',
            paymentMethod: 'Cash',
          ),
          Expense(
            merchant: 'Bakery',
            amount: 20.0,
            createdAt: DateTime(2024, 1, 2),
            notes: 'Bread and pastries',
            category: 'Groceries',
            paymentMethod: 'Credit Card',
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

      when(mockDataCubit.state).thenReturn(testUserData);
      when(mockDataCubit.stream).thenAnswer((_) => Stream.value(testUserData));
      when(mockDataCubit.getFirebaseUserData()).thenReturn(testUserData);
      when(mockDataCubit.addExpense(any, any)).thenAnswer((_) async => true);
      when(mockDataCubit.listenToExpenseChanges(any)).thenAnswer((_) {});
    });

    Widget createWidgetUnderTest() {
      return MaterialApp(
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
        home: BlocProvider<DataCubit>.value(
          value: mockDataCubit,
          child: const ExpenseScreen(),
        ),
      );
    }

    testWidgets('renders header bar with correct title and return button', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      CurrentBudget.budgetId = 'test-budget-1';

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text(AppLocalizations.of(tester.element(find.byType(ExpenseScreen)))!.expensesScreen_title), findsOneWidget);
      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
    });

    testWidgets('renders dashboard header with budget name and add expense button', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      CurrentBudget.budgetId = 'test-budget-1';

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text('Test Budget'), findsOneWidget);
      expect(find.text(AppLocalizations.of(tester.element(find.byType(ExpenseScreen)))!.expensesScreen_subtitle), findsOneWidget);
      expect(find.text(AppLocalizations.of(tester.element(find.byType(ExpenseScreen)))!.expensesScreen_addButton), findsOneWidget);
    });

    testWidgets('renders expenses tab view with correct tabs', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      CurrentBudget.budgetId = 'test-budget-1';

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text(AppLocalizations.of(tester.element(find.byType(ExpenseScreen)))!.expensesTab_allExpenses), findsOneWidget);
      expect(find.text(AppLocalizations.of(tester.element(find.byType(ExpenseScreen)))!.expensesTab_recent), findsOneWidget);
      expect(find.text(AppLocalizations.of(tester.element(find.byType(ExpenseScreen)))!.expensesTab_highest), findsOneWidget);
    });

    testWidgets('opens Add Expense dialog and check all input fields', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      CurrentBudget.budgetId = 'test-budget-1';

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      await tester.tap(find.text(AppLocalizations.of(tester.element(find.byType(ExpenseScreen)))!.expensesScreen_addButton));
      await tester.pumpAndSettle();

      final localizations = AppLocalizations.of(tester.element(find.byType(ExpenseScreen)))!;
      expect(find.bySemanticsLabel(localizations.addExpenseDialog_amountLabel), findsOneWidget);
      expect(find.bySemanticsLabel(localizations.addExpenseDialog_dateLabel), findsOneWidget);
      expect(find.bySemanticsLabel(localizations.addExpenseDialog_merchantLabel), findsOneWidget);
      expect(find.bySemanticsLabel(localizations.addExpenseDialog_categoryLabel), findsOneWidget);
      expect(find.bySemanticsLabel(localizations.addExpenseDialog_paymentMethodLabel), findsOneWidget);
      expect(find.bySemanticsLabel(localizations.addExpenseDialog_notesLabel), findsOneWidget);
      expect(find.text(localizations.common_cancel), findsOneWidget);
      expect(find.text(localizations.addExpenseDialog_save), findsOneWidget);
    });
  });
}
