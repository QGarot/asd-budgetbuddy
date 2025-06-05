import 'package:budgetbuddy/Elements/Charts/budget_pie_chart.dart';
import 'package:budgetbuddy/pojos/budget.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('BudgetPieChart Widget Tests', () {
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

    // Helper to wrap a widget in MaterialApp with localization
    Widget wrapWithMaterialApp({required Widget child}) {
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
        wrapWithMaterialApp(child: BudgetPieChart(budgets: sampleBudgets)),
      );

      // Verify that a PieChart widget is present
      expect(find.byType(PieChart), findsOneWidget);

      // Now grab the localized strings from AppLocalizations
      final BuildContext context = tester.element(find.byType(BudgetPieChart));
      final loc = AppLocalizations.of(context)!;

      // The center text should show the count '3'
      expect(find.text('3'), findsOneWidget);
      // And the center label should use the localized “Budgets” string
      expect(find.text(loc.budgetPieChart_budgets), findsOneWidget);
    });

    testWidgets('renders correctly with empty budget list', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        wrapWithMaterialApp(child: BudgetPieChart(budgets: [])),
      );

      // Grab the localized “no data” string
      final BuildContext context = tester.element(find.byType(BudgetPieChart));
      final loc = AppLocalizations.of(context)!;
      final noDataText = loc.budgetPieChart_noData;

      // Verify that the localized no-data message is shown
      expect(find.text(noDataText), findsOneWidget);

      // Verify that no PieChart is rendered when budgets is empty
      expect(find.byType(PieChart), findsNothing);
    });

    testWidgets('renders with custom size parameter', (
      WidgetTester tester,
    ) async {
      const double customSize = 300.0;

      await tester.pumpWidget(
        wrapWithMaterialApp(
          child: BudgetPieChart(budgets: sampleBudgets, size: customSize),
        ),
      );

      // Find the SizedBox that has both height and width equal to customSize
      final sizedBoxFinder = find.byWidgetPredicate(
        (widget) =>
            widget is SizedBox &&
            widget.height == customSize &&
            widget.width == customSize,
      );
      expect(sizedBoxFinder, findsOneWidget);
    });

    testWidgets('generates correct sections based on budget amounts', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        wrapWithMaterialApp(child: BudgetPieChart(budgets: sampleBudgets)),
      );

      // Find the PieChart widget
      final pieChartFinder = find.byType(PieChart);
      expect(pieChartFinder, findsOneWidget);

      // Extract PieChartData so we can inspect `sections`
      final PieChart pieChart = tester.widget<PieChart>(pieChartFinder);
      final PieChartData data = pieChart.data;

      // By default, centerSpaceRadius should be 50 (per implementation)
      expect(data.centerSpaceRadius, 50);

      // We provided 3 budgets, so there should be 3 sections
      expect(data.sections.length, 3);

      // Calculate totalAmount to check percentages
      final totalAmount = sampleBudgets.fold<double>(
        0.0,
        (sum, budget) => sum + budget.totalAmount,
      );

      for (int i = 0; i < data.sections.length; i++) {
        final section = data.sections[i];
        final budget = sampleBudgets[i];
        final expectedValue = budget.totalAmount;

        // Each section.value should equal that budget's totalAmount
        expect(section.value, expectedValue);

        // If the percentage is ≥ 5%, its title should be “XX.X%”
        final percentage = (budget.totalAmount / totalAmount) * 100;
        if (percentage >= 5) {
          final expectedTitle = '${percentage.toStringAsFixed(1)}%';
          expect(section.title, expectedTitle);
        } else {
          expect(section.title, '');
        }
      }
    });
  });
}
