import 'package:budgetbuddy/Elements/Charts/budget_bar_chart.dart';
import 'package:budgetbuddy/pojos/budget.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('BudgetBarChart Widget Tests', () {
    // Sample budgets to use in tests
    final List<Budget> sampleBudgets = [
      Budget(
        name: 'Groceries',
        category: 'Necessities',
        createdAt: DateTime.now(),
        resetPeriod: 'Monthly',
        alertThreshold: 0.8,
        totalAmount: 300.0,
        spentAmount: 150.0,
      ),
      Budget(
        name: 'Entertainment',
        category: 'Leisure',
        createdAt: DateTime.now(),
        resetPeriod: 'Monthly',
        alertThreshold: 0.8,
        totalAmount: 200.0,
        spentAmount: 80.0,
      ),
      Budget(
        name: 'Utilities',
        category: 'Housing',
        createdAt: DateTime.now(),
        resetPeriod: 'Monthly',
        alertThreshold: 0.8,
        totalAmount: 500.0,
        spentAmount: 450.0,
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
        _wrapWithMaterialApp(child: BudgetBarChart(budgets: sampleBudgets)),
      );

      // Since we provided non-empty budgets, a BarChart should appear.
      expect(find.byType(BarChart), findsOneWidget);
    });

    testWidgets('renders correctly with empty budget list', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _wrapWithMaterialApp(child: BudgetBarChart(budgets: [])),
      );

      // Look up the localized no-data string. In your English ARB it's still:
      //   "budgetBarChart_noData": "No budget data available"
      final BuildContext context = tester.element(find.byType(BudgetBarChart));
      final noDataText = AppLocalizations.of(context)!.budgetBarChart_noData;

      // Verify the localized "no data" message is shown exactly once:
      expect(find.text(noDataText), findsOneWidget);

      // And because budgets is empty, there should be no BarChart:
      expect(find.byType(BarChart), findsNothing);
    });

    testWidgets('renders with custom height parameter', (
      WidgetTester tester,
    ) async {
      const double customHeight = 400.0;

      await tester.pumpWidget(
        _wrapWithMaterialApp(
          child: BudgetBarChart(budgets: sampleBudgets, height: customHeight),
        ),
      );

      // Find the SizedBox whose height equals our customHeight.
      final sizedBoxFinder = find.byWidgetPredicate(
        (widget) => widget is SizedBox && widget.height == customHeight,
      );
      expect(sizedBoxFinder, findsOneWidget);
    });

    testWidgets('limits displayed budgets based on maxBudgetsToShow', (
      WidgetTester tester,
    ) async {
      // Create a longer list of 10 budgets, each with increasing amounts.
      final List<Budget> manyBudgets = List.generate(
        10,
        (index) => Budget(
          name: 'Budget $index',
          category: 'Category',
          createdAt: DateTime.now(),
          resetPeriod: 'Monthly',
          alertThreshold: 0.8,
          totalAmount: 100.0 * (index + 1),
          spentAmount: 50.0 * (index + 1),
        ),
      );

      const int maxToShow = 3;

      await tester.pumpWidget(
        _wrapWithMaterialApp(
          child: BudgetBarChart(
            budgets: manyBudgets,
            maxBudgetsToShow: maxToShow,
            showOnlyTop: true,
          ),
        ),
      );

      // Find the BarChart widget in the tree:
      final barChartFinder = find.byType(BarChart);
      expect(barChartFinder, findsOneWidget);

      // Extract its BarChartData so we can inspect barGroups:
      final BarChart barChartWidget = tester.widget<BarChart>(barChartFinder);
      final BarChartData data = barChartWidget.data;

      // Because showOnlyTop = true, budgets are sorted by totalAmount descending,
      // and then we take the top `maxToShow`. That means indices 9, 8, 7 from the
      // original list (amounts 1000.0, 900.0, 800.0).
      expect(data.barGroups.length, maxToShow);

      final expectedValues = [1000.0, 900.0, 800.0];
      for (var i = 0; i < maxToShow; i++) {
        final rodList = data.barGroups[i].barRods;
        // rodList[0].toY is the `totalAmount` bar
        expect(rodList[0].toY, expectedValues[i]);
      }
    });

    testWidgets('bar chart does not sort budgets when showOnlyTop is false', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _wrapWithMaterialApp(
          child: BudgetBarChart(budgets: sampleBudgets, showOnlyTop: false),
        ),
      );

      final barChartFinder = find.byType(BarChart);
      expect(barChartFinder, findsOneWidget);

      final BarChart barChartWidget = tester.widget<BarChart>(barChartFinder);
      final BarChartData data = barChartWidget.data;

      // Now budgets should appear in the original order: [Groceries, Entertainment, Utilities].
      for (int i = 0; i < data.barGroups.length; i++) {
        final rods = data.barGroups[i].barRods;
        expect(rods[0].toY, sampleBudgets[i].totalAmount);
        expect(rods[1].toY, sampleBudgets[i].spentAmount);
      }
    });
  });
}
