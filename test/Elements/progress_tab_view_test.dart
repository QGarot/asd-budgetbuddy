import 'package:budgetbuddy/Elements/progress_tab_view.dart';
import 'package:budgetbuddy/bloc/Data/data_bloc.dart';
import 'package:budgetbuddy/pojos/budget.dart';
import 'package:budgetbuddy/pojos/expenses.dart';
import 'package:budgetbuddy/pojos/user_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import '../mockito/mock_classes.mocks.dart';

void main() {
  group('ProgressTabView Widget Tests', () {
    late MockDataCubit mockDataCubit;

    setUp(() {
      mockDataCubit = MockDataCubit();

      final budget = Budget(
        name: 'Groceries',
        category: 'Food',
        createdAt: DateTime(2024, 12, 1),
        resetPeriod: 'Monthly',
        alertThreshold: 0.8,
        totalAmount: 100,
      );

      final expense = Expense(
        id: 'e1',
        merchant: 'Store A',
        amount: 25.0,
        createdAt: DateTime(2025, 4, 1),
        category: 'Groceries',
        paymentMethod: 'Cash',
        notes: 'Weekly shopping',
      );

      budget.expenses.add(expense);

      final mockData = AllUserData(
        username: 'TestUser',
        email: 'test@example.com',
        locale: 'en',
        createdAt: DateTime(2024, 1, 1),
        budgets: [budget],
      );

      when(mockDataCubit.state).thenReturn(mockData);
      when(mockDataCubit.stream).thenAnswer((_) => const Stream.empty());
    });

    testWidgets('displays monthly progress correctly', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(size: Size(1200, 800)),
          child: MaterialApp(
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
                child: const ProgressTabView(),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Your Progress'), findsOneWidget);
      expect(find.text('Monthly'), findsOneWidget);
      expect(find.text('Biweekly'), findsOneWidget);
      expect(find.text('Weekly'), findsOneWidget);

      expect(find.textContaining('202'), findsWidgets);
      expect(find.text('April 2025'), findsOneWidget);
      expect(find.textContaining('25.00 € of 100.00 €'), findsOneWidget);
      expect(find.textContaining('75.00 € remaining'), findsOneWidget);
    });

    testWidgets('displays weekly progress correctly', (
      WidgetTester tester,
    ) async {
      final budget = Budget(
        name: 'Transport',
        category: 'Travel',
        createdAt: DateTime(2024, 12, 1),
        resetPeriod: 'Weekly',
        alertThreshold: 0.8,
        totalAmount: 50,
      );

      final expense = Expense(
        id: 'e2',
        merchant: 'Bus',
        amount: 15.0,
        createdAt: DateTime(2025, 4, 2),
        category: 'Transport',
        paymentMethod: 'Card',
        notes: 'Bus ticket',
      );

      budget.expenses.add(expense);

      final mockData = AllUserData(
        username: 'TestUser',
        email: 'test@example.com',
        locale: 'en',
        createdAt: DateTime(2024, 1, 1),
        budgets: [budget],
      );

      when(mockDataCubit.state).thenReturn(mockData);
      when(mockDataCubit.stream).thenAnswer((_) => const Stream.empty());

      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(size: Size(1200, 800)),
          child: MaterialApp(
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
                child: const ProgressTabView(),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      await tester.tap(find.text('Weekly'));
      await tester.pumpAndSettle();

      expect(find.textContaining('15.00 € of 50.00 €'), findsOneWidget);
      expect(find.textContaining('35.00 € remaining'), findsOneWidget);
    });

    testWidgets('displays biweekly progress correctly', (
      WidgetTester tester,
    ) async {
      final budget = Budget(
        name: 'Events',
        category: 'Entertainment',
        createdAt: DateTime(2024, 12, 1),
        resetPeriod: 'Biweekly',
        alertThreshold: 0.8,
        totalAmount: 200,
      );

      final expense = Expense(
        id: 'e3',
        merchant: 'Cinema',
        amount: 60.0,
        createdAt: DateTime(2025, 4, 2),
        category: 'Entertainment',
        paymentMethod: 'Credit Card',
        notes: 'Movie night',
      );

      budget.expenses.add(expense);

      final mockData = AllUserData(
        username: 'TestUser',
        email: 'test@example.com',
        locale: 'en',
        createdAt: DateTime(2024, 1, 1),
        budgets: [budget],
      );

      when(mockDataCubit.state).thenReturn(mockData);
      when(mockDataCubit.stream).thenAnswer((_) => const Stream.empty());

      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(size: Size(1200, 800)),
          child: MaterialApp(
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
                child: const ProgressTabView(),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      await tester.tap(find.text('Biweekly'));
      await tester.pumpAndSettle();

      expect(find.textContaining('60.00 € of 200.00 €'), findsOneWidget);
      expect(find.textContaining('140.00 € remaining'), findsOneWidget);
    });

    testWidgets('displays danger styling when over budget', (
      WidgetTester tester,
    ) async {
      final budget = Budget(
        name: 'Travel',
        category: 'Trips',
        createdAt: DateTime(2025, 4, 1),
        resetPeriod: 'Monthly',
        alertThreshold: 0.5,
        totalAmount: 50,
        spentAmount: 80,
        expenses: [
          Expense(
            id: 'e2',
            merchant: 'Train',
            amount: 80,
            createdAt: DateTime(2025, 4, 2),
            category: 'Travel',
            paymentMethod: 'Online Payment',
            notes: 'Train ticket',
          ),
        ],
      );

      final mockDataCubit = MockDataCubit();
      final mockData = AllUserData(
        username: 'TestUser',
        email: 'test@example.com',
        locale: 'en',
        createdAt: DateTime(2024, 1, 1),
        budgets: [budget],
      );

      when(mockDataCubit.state).thenReturn(mockData);
      when(mockDataCubit.stream).thenAnswer((_) => const Stream.empty());

      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(size: Size(1200, 800)),
          child: MaterialApp(
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
                child: const ProgressTabView(),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.textContaining('80.00 € of 50.00 €'), findsOneWidget);
      expect(find.textContaining('30.00 € over budget'), findsOneWidget);
    });

    testWidgets('renders correctly when there are no budgets', (
      WidgetTester tester,
    ) async {
      final mockDataCubit = MockDataCubit();

      when(mockDataCubit.state).thenReturn(
        AllUserData(
          username: 'TestUser',
          email: 'test@example.com',
          locale: 'en',
          createdAt: DateTime(2024, 1, 1),
          budgets: [],
        ),
      );
      when(mockDataCubit.stream).thenAnswer((_) => const Stream.empty());

      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(size: Size(1200, 800)),
          child: MaterialApp(
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
                child: const ProgressTabView(),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Your Progress'), findsOneWidget);
      expect(find.text('Monthly'), findsOneWidget);
      expect(find.text('Biweekly'), findsOneWidget);
      expect(find.text('Weekly'), findsOneWidget);

      expect(find.textContaining('Budget Progress'), findsNothing);
      expect(find.textContaining('€ of'), findsNothing);
    });
  });
}
