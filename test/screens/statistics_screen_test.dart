import 'package:budgetbuddy/Elements/Charts/charts_dashboard.dart';
import 'package:budgetbuddy/bloc/Data/data_bloc.dart';
import 'package:budgetbuddy/pojos/budget.dart';
import 'package:budgetbuddy/pojos/expenses.dart';
import 'package:budgetbuddy/pojos/user_data.dart';
import 'package:budgetbuddy/screens/statistics_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../mockito/mock_classes.mocks.dart';

void main() {

  testWidgets('StatisticsScreen displays summary and chart with valid budgets', (WidgetTester tester) async {
    final mockDataCubit = MockDataCubit();

    // Some samples
    final budgets = [
      Budget(
        name: 'Food',
        category: 'Food',
        createdAt: DateTime(2024, 1, 1),
        resetPeriod: 'Monthly',
        alertThreshold: 0.8,
        totalAmount: 400,
        expenses: [
          Expense(
            merchant: 'Supermarket',
            amount: 100,
            createdAt: DateTime.now(),
            category: 'Food',
            paymentMethod: 'Card',
          ),
          Expense(
            merchant: 'Bakery',
            amount: 50,
            createdAt: DateTime.now(),
            category: 'Food',
            paymentMethod: 'Cash',
          ),
        ],
      ),
      Budget(
        name: 'Transport',
        category: 'Mobility',
        createdAt: DateTime(2024, 1, 1),
        resetPeriod: 'Monthly',
        alertThreshold: 0.7,
        totalAmount: 300,
        expenses: [
          Expense(
            merchant: 'Bus',
            amount: 80,
            createdAt: DateTime.now(),
            category: 'Mobility',
            paymentMethod: 'Card',
          ),
        ],
      ),
    ];

    final userData = AllUserData(
      username: 'TestUser',
      email: 'test@example.com',
      locale: 'en',
      createdAt: DateTime.now(),
      budgets: budgets,
    );

    when(mockDataCubit.state).thenReturn(userData);
    when(mockDataCubit.stream).thenAnswer((_) => const Stream.empty());

    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(size: Size(1080, 1920)),
        child: MaterialApp(
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('en')],
          locale: const Locale('en'),
          home: Scaffold(
            body: BlocProvider<DataCubit>.value(
              value: mockDataCubit,
              child: const StatisticsScreen(),
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Statistics Dashboard'), findsNWidgets(2));
    expect(find.text('Visualize your budget data'), findsOneWidget);

    expect(find.text('Summary'), findsOneWidget);
    expect(find.text('Budget Utilization'), findsOneWidget);
    expect(find.text('Remaining Budget'), findsOneWidget);
    expect(find.text('Active Budgets'), findsOneWidget);

    expect(find.byType(ChartsDashboard), findsOneWidget);
  });

  testWidgets('StatisticsScreen renders title, subtitle, and no-data message', (
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
        data: const MediaQueryData(size: Size(1080, 1920)),
        child: MaterialApp(
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('en')],
          locale: const Locale('en'),
          home: Scaffold(
            body: BlocProvider<DataCubit>.value(
              value: mockDataCubit,
              child: const StatisticsScreen(),
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Statistics Dashboard'), findsNWidgets(2));
    expect(find.text('Visualize your budget data'), findsOneWidget);
    expect(find.text('No budget data available to visualize'), findsOneWidget);
  });
}
