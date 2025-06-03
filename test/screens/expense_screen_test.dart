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

      expect(find.text('Budget Dashboard'), findsOneWidget);
      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
    });

    testWidgets('renders dashboard header with budget name and add expense button', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      CurrentBudget.budgetId = 'test-budget-1';

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text('Test Budget'), findsOneWidget);
      expect(find.text('Track and manage your expenses for this budget'), findsOneWidget);
      expect(find.text('Add Expense'), findsOneWidget);
    });

    testWidgets('renders expenses tab view with correct tabs', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      CurrentBudget.budgetId = 'test-budget-1';

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text('ALL EXPENSES'), findsOneWidget);
      expect(find.text('RECENT'), findsOneWidget);
      expect(find.text('HIGHEST'), findsOneWidget);
    });

    testWidgets('opens Add Expense dialog and check all input fields', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      CurrentBudget.budgetId = 'test-budget-1';

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Add Expense'));
      await tester.pumpAndSettle();

      expect(find.bySemanticsLabel('Amount *'), findsOneWidget);
      expect(find.bySemanticsLabel('Date *'), findsOneWidget);
      expect(find.bySemanticsLabel('Merchant *'), findsOneWidget);
      expect(find.bySemanticsLabel('Category'), findsOneWidget);
      expect(find.bySemanticsLabel('Payment Method'), findsOneWidget);
      expect(find.bySemanticsLabel('Notes'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Save Expense'), findsOneWidget);
    });
  });
}
