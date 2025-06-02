import 'package:budgetbuddy/Elements/Charts/spending_trend_chart.dart';
import 'package:budgetbuddy/pojos/expenses.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SpendingTrendChart Widget Tests', () {
    // Sample dates for consistent testing
    final baseDate = DateTime(2025, 1, 1);

    // Create sample expenses
    final List<Expense> sampleExpenses = [
      Expense(
        merchant: 'Grocery Store',
        amount: 50.0,
        createdAt: baseDate,
        category: 'Groceries',
        paymentMethod: 'Credit Card',
      ),
      Expense(
        merchant: 'Cinema',
        amount: 25.0,
        createdAt: baseDate.add(const Duration(days: 2)),
        category: 'Entertainment',
        paymentMethod: 'Cash',
      ),
      Expense(
        merchant: 'Electric Company',
        amount: 100.0,
        createdAt: baseDate.add(const Duration(days: 5)),
        category: 'Utilities',
        paymentMethod: 'Bank Transfer',
      ),
      Expense(
        merchant: 'Restaurant',
        amount: 75.0,
        createdAt: baseDate.add(const Duration(days: 7)),
        category: 'Dining',
        paymentMethod: 'Credit Card',
      ),
      Expense(
        merchant: 'Grocery Store',
        amount: 45.0,
        createdAt: baseDate.add(const Duration(days: 10)),
        category: 'Groceries',
        paymentMethod: 'Credit Card',
      ),
    ];

    Widget _wrapWithMaterialApp({required Widget child}) {
      return MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('en')],
        locale: const Locale('en'),
        home: Scaffold(body: child),
      );
    }

    testWidgets('renders correctly with expense data', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _wrapWithMaterialApp(
          child: SpendingTrendChart(expenses: sampleExpenses, daysToShow: 200),
        ),
      );

      // Allow animations to complete
      await tester.pumpAndSettle();

      // Verify that a LineChart widget is present
      expect(find.byType(LineChart), findsOneWidget);
    });

    testWidgets('renders correctly with empty expense list', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _wrapWithMaterialApp(child: SpendingTrendChart(expenses: [])),
      );

      // Allow animations to complete
      await tester.pumpAndSettle();

      // Grab the localized no-data string
      final BuildContext context = tester.element(
        find.byType(SpendingTrendChart),
      );
      final loc = AppLocalizations.of(context)!;
      final noDataText = loc.spendingTrendChart_noData;

      // Verify the localized no-data message appears
      expect(find.text(noDataText), findsOneWidget);

      // Verify no LineChart is rendered
      expect(find.byType(LineChart), findsNothing);
    });

    testWidgets('renders with custom height parameter', (
      WidgetTester tester,
    ) async {
      const double customHeight = 400.0;

      await tester.pumpWidget(
        _wrapWithMaterialApp(
          child: SpendingTrendChart(
            expenses: sampleExpenses,
            height: customHeight,
          ),
        ),
      );

      // Allow animations to complete
      await tester.pumpAndSettle();

      // Find the SizedBox that constrains the line chart
      final sizedBoxFinder = find.byWidgetPredicate(
        (widget) => widget is SizedBox && widget.height == customHeight,
      );
      expect(sizedBoxFinder, findsOneWidget);
    });

    testWidgets('respects daysToShow parameter', (WidgetTester tester) async {
      const int customDaysToShow = 15;
      // Add a recent expense so it falls within the customDaysToShow window
      final List<Expense> expensesWithRecent = [
        ...sampleExpenses,
        Expense(
          merchant: 'Recent Store',
          amount: 42.0,
          createdAt: DateTime.now().subtract(const Duration(days: 2)),
          category: 'Test',
          paymentMethod: 'Cash',
        ),
      ];

      await tester.pumpWidget(
        _wrapWithMaterialApp(
          child: SpendingTrendChart(
            expenses: expensesWithRecent,
            daysToShow: customDaysToShow,
          ),
        ),
      );

      // Allow animations to complete
      await tester.pumpAndSettle();

      // The LineChart should be rendered because there is recent data
      final lineChartFinder = find.byType(LineChart);
      expect(lineChartFinder, findsOneWidget);

      // Extract the PieChartData to do a basic sanity check
      final lineChart = tester.widget<LineChart>(lineChartFinder);
      final data = lineChart.data;

      // Basic properties: minY is zero, and there is one line bar
      expect(data.minY, 0);
      expect(data.lineBarsData.length, 1);

      // Ensure there are data points (spots) on the chart
      final lineBarData = data.lineBarsData[0];
      expect(lineBarData.spots.isNotEmpty, isTrue);
    });

    testWidgets('handles old expenses gracefully', (WidgetTester tester) async {
      // Create expenses all older than the default 30-day window
      final List<Expense> oldExpenses = [
        Expense(
          merchant: 'Old Store',
          amount: 100.0,
          createdAt: DateTime.now().subtract(const Duration(days: 60)),
          category: 'Shopping',
          paymentMethod: 'Credit Card',
        ),
        Expense(
          merchant: 'Ancient Store',
          amount: 200.0,
          createdAt: DateTime.now().subtract(const Duration(days: 90)),
          category: 'Shopping',
          paymentMethod: 'Cash',
        ),
      ];

      await tester.pumpWidget(
        _wrapWithMaterialApp(child: SpendingTrendChart(expenses: oldExpenses)),
      );

      await tester.pumpAndSettle();

      // Grab the localized "no recent data" string
      final BuildContext context = tester.element(
        find.byType(SpendingTrendChart),
      );
      final loc = AppLocalizations.of(context)!;
      final noRecentText = loc.spendingTrendChart_noRecentData;

      // Since there is no data in the last 30 days, expect the "no recent" message
      expect(find.text(noRecentText), findsOneWidget);

      // And no LineChart should appear
      expect(find.byType(LineChart), findsNothing);

      // Now increase daysToShow to include these old expenses
      await tester.pumpWidget(
        _wrapWithMaterialApp(
          child: SpendingTrendChart(
            expenses: oldExpenses,
            daysToShow: 100, // Now 60 and 90-day-old entries fall inside
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Now the LineChart should be visible
      expect(find.byType(LineChart), findsOneWidget);
    });
  });
}
