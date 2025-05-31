import 'package:budgetbuddy/Elements/Charts/budget_bar_chart.dart';
import 'package:budgetbuddy/pojos/budget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fl_chart/fl_chart.dart';

void main() {
  group('BudgetBarChart Widget Tests', () {
    // Create sample budgets
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

    testWidgets('renders correctly with budget data', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BudgetBarChart(budgets: sampleBudgets),
          ),
        ),
      );

      // Verify BarChart widget is present
      expect(find.byType(BarChart), findsOneWidget);
    });

    testWidgets('renders correctly with empty budget list', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BudgetBarChart(budgets: []),
          ),
        ),
      );

      // Verify empty state message
      expect(find.text('No budget data available'), findsOneWidget);
      
      // Verify no BarChart is rendered
      expect(find.byType(BarChart), findsNothing);
    });

    testWidgets('renders with custom height parameter', (WidgetTester tester) async {
      const double customHeight = 400.0;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BudgetBarChart(
              budgets: sampleBudgets,
              height: customHeight,
            ),
          ),
        ),
      );

      // Find the SizedBox that constrains the bar chart
      final sizedBoxFinder = find.byWidgetPredicate(
        (widget) => widget is SizedBox && widget.height == customHeight,
      );
      
      expect(sizedBoxFinder, findsOneWidget);
    });

    testWidgets('limits displayed budgets based on maxBudgetsToShow', (WidgetTester tester) async {
      // Create a longer list of budgets
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
        MaterialApp(
          home: Scaffold(
            body: BudgetBarChart(
              budgets: manyBudgets,
              maxBudgetsToShow: maxToShow,
              showOnlyTop: true,
            ),
          ),
        ),
      );

      // Find BarChart widget
      final barChartFinder = find.byType(BarChart);
      final barChart = tester.widget<BarChart>(barChartFinder);
      
      // Get BarChartData
      final data = barChart.data;
      
      // Verify that only maxToShow bar groups are displayed
      expect(data.barGroups.length, maxToShow);
      
      // Verify the bars are for the top budgets (sorted by amount)
      // The highest budget values should be shown (indices 9, 8, 7 from the original list)
      final expectedValues = [1000.0, 900.0, 800.0]; // 100 * (9+1), 100 * (8+1), 100 * (7+1)
      
      for (int i = 0; i < maxToShow; i++) {
        final barGroup = data.barGroups[i];
        // Budget rod is the first rod in the group
        final budgetRod = barGroup.barRods[0];
        expect(budgetRod.toY, expectedValues[i]);
      }
    });

    testWidgets('bar chart does not sort budgets when showOnlyTop is false', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BudgetBarChart(
              budgets: sampleBudgets,
              showOnlyTop: false,
            ),
          ),
        ),
      );

      // Find BarChart widget
      final barChartFinder = find.byType(BarChart);
      final barChart = tester.widget<BarChart>(barChartFinder);
      
      // Get BarChartData
      final data = barChart.data;
      
      // Verify bar groups match the original order of the sample budgets
      for (int i = 0; i < data.barGroups.length; i++) {
        final barGroup = data.barGroups[i];
        // Budget rod is the first rod in the group
        final budgetRod = barGroup.barRods[0];
        final spendingRod = barGroup.barRods[1];
        
        // Verify the budget amount
        expect(budgetRod.toY, sampleBudgets[i].totalAmount);
        // Verify the spending amount
        expect(spendingRod.toY, sampleBudgets[i].spentAmount);
      }
    });
  });
}
