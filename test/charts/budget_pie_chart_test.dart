import 'package:budgetbuddy/Elements/Charts/budget_pie_chart.dart';
import 'package:budgetbuddy/pojos/budget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fl_chart/fl_chart.dart';

void main() {
  group('BudgetPieChart Widget Tests', () {
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
            body: BudgetPieChart(budgets: sampleBudgets),
          ),
        ),
      );

      // Verify PieChart widget is present
      expect(find.byType(PieChart), findsOneWidget);
      
      // Verify the center text showing budget count
      expect(find.text('3'), findsOneWidget);
      expect(find.text('Budgets'), findsOneWidget);
    });

    testWidgets('renders correctly with empty budget list', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BudgetPieChart(budgets: []),
          ),
        ),
      );

      // Verify empty state message
      expect(find.text('No budget data available'), findsOneWidget);
      
      // Verify no PieChart is rendered
      expect(find.byType(PieChart), findsNothing);
    });

    testWidgets('renders with custom size parameter', (WidgetTester tester) async {
      const double customSize = 300.0;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BudgetPieChart(
              budgets: sampleBudgets,
              size: customSize,
            ),
          ),
        ),
      );

      // Find the SizedBox that constrains the pie chart
      final sizedBoxFinder = find.byWidgetPredicate(
        (widget) => widget is SizedBox && widget.height == customSize && widget.width == customSize,
      );
      
      expect(sizedBoxFinder, findsOneWidget);
    });

    testWidgets('generates correct sections based on budget amounts', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BudgetPieChart(budgets: sampleBudgets),
          ),
        ),
      );

      // Find PieChart widget
      final pieChartFinder = find.byType(PieChart);
      final pieChart = tester.widget<PieChart>(pieChartFinder);
      
      // Get PieChartData
      final data = pieChart.data;
      
      // Verify centerSpaceRadius
      expect(data.centerSpaceRadius, 50);
      
      // Verify section count
      expect(data.sections.length, 3);
      
      // Total budget amount: 300 + 200 + 500 = 1000
      // Expected percentages: 30%, 20%, 50%
      
      // Verify sections have correct values
      final totalAmount = sampleBudgets.fold(0.0, (sum, budget) => sum + budget.totalAmount);
      
      for (int i = 0; i < data.sections.length; i++) {
        final section = data.sections[i];
        final budget = sampleBudgets[i];
        final expectedValue = budget.totalAmount;
        
        expect(section.value, expectedValue);
        
        // Check if percentage is correctly displayed for sections with >=5% share
        final percentage = (budget.totalAmount / totalAmount) * 100;
        if (percentage >= 5) {
          expect(section.title, '${percentage.toStringAsFixed(1)}%');
        } else {
          expect(section.title, '');
        }
      }
    });
  });
}
