import 'package:budgetbuddy/Elements/Charts/budget_bar_chart.dart';
import 'package:budgetbuddy/Elements/Charts/budget_pie_chart.dart';
import 'package:budgetbuddy/Elements/Charts/charts_dashboard.dart';
import 'package:budgetbuddy/Elements/Charts/spending_trend_chart.dart';
import 'package:budgetbuddy/pojos/budget.dart';
import 'package:budgetbuddy/pojos/expenses.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ChartsDashboard Widget Tests', () {
    // Sample date for consistent testing
    final baseDate = DateTime(2025, 1, 1);

    // Create sample budgets with expenses
    final List<Budget> sampleBudgets = [
      Budget(
        name: 'Groceries',
        category: 'Necessities',
        createdAt: baseDate,
        resetPeriod: 'Monthly',
        alertThreshold: 0.8,
        totalAmount: 300.0,
        spentAmount: 150.0,
        expenses: [
          Expense(
            merchant: 'Grocery Store',
            amount: 50.0,
            createdAt: baseDate,
            category: 'Groceries',
            paymentMethod: 'Credit Card',
          ),
          Expense(
            merchant: 'Supermarket',
            amount: 100.0,
            createdAt: baseDate.add(const Duration(days: 7)),
            category: 'Groceries',
            paymentMethod: 'Credit Card',
          ),
        ],
      ),
      Budget(
        name: 'Entertainment',
        category: 'Leisure',
        createdAt: baseDate,
        resetPeriod: 'Monthly',
        alertThreshold: 0.8,
        totalAmount: 200.0,
        spentAmount: 80.0,
        expenses: [
          Expense(
            merchant: 'Cinema',
            amount: 25.0,
            createdAt: baseDate.add(const Duration(days: 2)),
            category: 'Entertainment',
            paymentMethod: 'Cash',
          ),
          Expense(
            merchant: 'Concert',
            amount: 55.0,
            createdAt: baseDate.add(const Duration(days: 14)),
            category: 'Entertainment',
            paymentMethod: 'Credit Card',
          ),
        ],
      ),
      Budget(
        name: 'Utilities',
        category: 'Housing',
        createdAt: baseDate,
        resetPeriod: 'Monthly',
        alertThreshold: 0.8,
        totalAmount: 500.0,
        spentAmount: 450.0,
        expenses: [
          Expense(
            merchant: 'Electric Company',
            amount: 100.0,
            createdAt: baseDate.add(const Duration(days: 5)),
            category: 'Utilities',
            paymentMethod: 'Bank Transfer',
          ),
          Expense(
            merchant: 'Water Bill',
            amount: 150.0,
            createdAt: baseDate.add(const Duration(days: 6)),
            category: 'Utilities',
            paymentMethod: 'Bank Transfer',
          ),
          Expense(
            merchant: 'Internet Provider',
            amount: 200.0,
            createdAt: baseDate.add(const Duration(days: 10)),
            category: 'Utilities',
            paymentMethod: 'Bank Transfer',
          ),
        ],
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

    testWidgets('renders correctly with budget data', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _wrapWithMaterialApp(child: ChartsDashboard(budgets: sampleBudgets)),
      );

      // Obtain the localization instance
      final BuildContext context = tester.element(find.byType(ChartsDashboard));
      final loc = AppLocalizations.of(context)!;

      // 1) The main dashboard title:
      expect(find.text(loc.chartsDashboard_title), findsOneWidget);

      // 2) The three tab buttons:
      expect(find.text(loc.chartsDashboard_tabOverview), findsOneWidget);
      expect(
        find.text(loc.chartsDashboard_tabBudgetVsSpending),
        findsOneWidget,
      );
      expect(find.text(loc.chartsDashboard_tabTrends), findsOneWidget);

      // 3) By default, "Overview" pane should be selected:
      //    Its pane heading is "Budget Distribution":
      expect(find.text(loc.chartsDashboard_overviewTitle), findsOneWidget);
      expect(find.byType(BudgetPieChart), findsOneWidget);

      // 4) The other two chart widgets (Bar + Line) must be hidden initially:
      expect(find.byType(BudgetBarChart), findsNothing);
      expect(find.byType(SpendingTrendChart), findsNothing);
    });

    testWidgets('renders correctly with empty budget list', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _wrapWithMaterialApp(child: ChartsDashboard(budgets: [])),
      );

      // Obtain localization
      final BuildContext context = tester.element(find.byType(ChartsDashboard));
      final loc = AppLocalizations.of(context)!;

      // The dashboard structure (title + tabs) should still render:
      expect(find.text(loc.chartsDashboard_title), findsOneWidget);
      expect(find.text(loc.chartsDashboard_tabOverview), findsOneWidget);

      // Even with empty budgets, we still see the PieChart widget—
      // it will internally show its no-data text.
      expect(find.byType(BudgetPieChart), findsOneWidget);

      // Check for the PieChart’s no-data text:
      final noDataText = loc.budgetPieChart_noData;
      expect(find.text(noDataText), findsOneWidget);
    });

    testWidgets('tab navigation shows correct initial state', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _wrapWithMaterialApp(child: ChartsDashboard(budgets: sampleBudgets)),
      );

      await tester.pumpAndSettle();

      // Obtain localization
      final BuildContext context = tester.element(find.byType(ChartsDashboard));
      final loc = AppLocalizations.of(context)!;

      // By default, Overview pane’s heading ("Budget Distribution") is visible:
      expect(find.text(loc.chartsDashboard_overviewTitle), findsOneWidget);
      expect(find.byType(BudgetPieChart), findsOneWidget);
    });

    testWidgets('can navigate to Budget vs Spending tab', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _wrapWithMaterialApp(child: ChartsDashboard(budgets: sampleBudgets)),
      );

      await tester.pumpAndSettle();

      // Obtain localization
      final BuildContext context = tester.element(find.byType(ChartsDashboard));
      final loc = AppLocalizations.of(context)!;

      // Tap the "Budget vs Spending" tab button:
      await tester.tap(find.text(loc.chartsDashboard_tabBudgetVsSpending));
      await tester.pumpAndSettle();

      // Now we want exactly the **pane heading** "Budget vs Spending" (fontSize==16),
      // not the tab button (fontSize==13). Use a predicate:
      final paneTitleFinder = find.byWidgetPredicate(
        (widget) =>
            widget is Text &&
            widget.data == loc.chartsDashboard_budgetVsSpendingTitle &&
            widget.style?.fontSize == 16.0,
      );
      expect(paneTitleFinder, findsOneWidget);

      // And the BarChart should appear:
      expect(find.byType(BudgetBarChart), findsOneWidget);
    });

    testWidgets('can navigate to Trends tab', (WidgetTester tester) async {
      // We wrap in a vertical SingleChildScrollView so the horizontally scrolling
      // tabs can slide off‐screen:
      await tester.pumpWidget(
        _wrapWithMaterialApp(
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: ChartsDashboard(budgets: sampleBudgets),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Obtain localization
      final BuildContext context = tester.element(find.byType(ChartsDashboard));
      final loc = AppLocalizations.of(context)!;

      // The "Trends" tab button may be off-screen horizontally, so scroll right:
      final horizontalTabs = find.byWidgetPredicate(
        (widget) =>
            widget is SingleChildScrollView &&
            widget.scrollDirection == Axis.horizontal,
      );
      await tester.drag(horizontalTabs, const Offset(-200, 0));
      await tester.pumpAndSettle();

      // Tap "Trends"
      await tester.tap(find.text(loc.chartsDashboard_tabTrends));
      await tester.pumpAndSettle();

      // Now the pane heading "Spending Trends (Last 30 Days)" (fontSize==16) should appear:
      final trendsTitleFinder = find.byWidgetPredicate(
        (widget) =>
            widget is Text &&
            widget.data == loc.chartsDashboard_trendsTitle &&
            widget.style?.fontSize == 16.0,
      );
      expect(trendsTitleFinder, findsOneWidget);

      // And the line chart should show up:
      expect(find.byType(SpendingTrendChart), findsOneWidget);
    });

    testWidgets('legend displays budget names correctly', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _wrapWithMaterialApp(child: ChartsDashboard(budgets: sampleBudgets)),
      );

      // Each budget name should appear somewhere in the legend area:
      for (final budget in sampleBudgets) {
        expect(find.text(budget.name), findsOneWidget);
      }
    });
  });
}
