import 'package:budgetbuddy/Elements/Charts/charts_dashboard.dart';
import 'package:budgetbuddy/Elements/Charts/budget_pie_chart.dart';
import 'package:budgetbuddy/Elements/Charts/budget_bar_chart.dart';
import 'package:budgetbuddy/Elements/Charts/spending_trend_chart.dart';
import 'package:budgetbuddy/pojos/budget.dart';
import 'package:budgetbuddy/pojos/expenses.dart';
import 'package:flutter/material.dart';
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

    testWidgets('renders correctly with budget data', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: ChartsDashboard(budgets: sampleBudgets)),
        ),
      );

      // Verify the dashboard title is displayed
      expect(find.text('Budget Insights'), findsOneWidget);

      // Verify the tab buttons are displayed
      expect(find.text('Overview'), findsOneWidget);
      expect(find.text('Budget vs Spending'), findsOneWidget);
      expect(find.text('Trends'), findsOneWidget);

      // By default, the Overview tab should be selected and show the pie chart
      expect(find.text('Budget Distribution'), findsOneWidget);
      expect(find.byType(BudgetPieChart), findsOneWidget);

      // The other charts should not be visible yet
      expect(find.byType(BudgetBarChart), findsNothing);
      expect(find.byType(SpendingTrendChart), findsNothing);
    });

    testWidgets('renders correctly with empty budget list', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: ChartsDashboard(budgets: []))),
      );

      // The dashboard structure should still render
      expect(find.text('Budget Insights'), findsOneWidget);
      expect(find.text('Overview'), findsOneWidget);

      // The charts will handle their own empty states
      expect(find.byType(BudgetPieChart), findsOneWidget);
    });

    testWidgets('tab navigation shows correct initial state', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: ChartsDashboard(budgets: sampleBudgets)),
        ),
      );

      // Allow any initial animations to complete
      await tester.pumpAndSettle();

      // Initially, the Overview tab should be selected
      expect(find.text('Budget Distribution'), findsOneWidget);
      expect(find.byType(BudgetPieChart), findsOneWidget);
    });

    testWidgets('can navigate to Budget vs Spending tab', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: ChartsDashboard(budgets: sampleBudgets)),
        ),
      );

      // Allow any initial animations to complete
      await tester.pumpAndSettle();

      // Navigate to the Budget vs Spending tab
      await tester.tap(find.text('Budget vs Spending'));
      await tester.pumpAndSettle();

      // Now the bar chart should be visible
      // Find the title in the tab content (not the tab button)
      final titles = find.byWidgetPredicate(
        (widget) => widget is Text && 
                   widget.data == 'Budget vs Spending' &&
                   widget.style?.fontSize == 16.0,
      );
      expect(titles, findsOneWidget);
      expect(find.byType(BudgetBarChart), findsOneWidget);
    });

    testWidgets('can navigate to Trends tab', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: ChartsDashboard(budgets: sampleBudgets),
            ),
          ),
        ),
      );

      // Allow any initial animations to complete
      await tester.pumpAndSettle();

      // Find the horizontal scrollable area containing the tabs
      final horizontalScrollable = find.byWidgetPredicate(
        (widget) => widget is SingleChildScrollView && 
                   widget.scrollDirection == Axis.horizontal,
      );
      
      // Scroll to the right to make the Trends tab visible
      await tester.drag(horizontalScrollable, const Offset(-200, 0));
      await tester.pumpAndSettle();

      // Navigate to the Trends tab
      await tester.tap(find.text('Trends'));
      await tester.pumpAndSettle();

      // Now the line chart should be visible
      expect(find.text('Spending Trends (Last 30 Days)'), findsOneWidget);
      expect(find.byType(SpendingTrendChart), findsOneWidget);
    });

    testWidgets('legend displays budget names correctly', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: ChartsDashboard(budgets: sampleBudgets)),
        ),
      );

      // Check that the budget names appear in the legend
      for (final budget in sampleBudgets) {
        expect(find.text(budget.name), findsOneWidget);
      }
    });
  });
}
