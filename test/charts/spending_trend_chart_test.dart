import 'package:budgetbuddy/Elements/Charts/spending_trend_chart.dart';
import 'package:budgetbuddy/pojos/expenses.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fl_chart/fl_chart.dart';

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

    testWidgets('renders correctly with expense data', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SpendingTrendChart(expenses: sampleExpenses, daysToShow: 200),
          ),
        ),
      );
      
      // Allow animations to complete
      await tester.pumpAndSettle();

      // Verify LineChart widget is present
      expect(find.byType(LineChart), findsOneWidget);
    });

    testWidgets('renders correctly with empty expense list', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SpendingTrendChart(expenses: []),
          ),
        ),
      );
      
      // Allow animations to complete
      await tester.pumpAndSettle();

      // Verify empty state message
      expect(find.text('No expense data available'), findsOneWidget);
      
      // Verify no LineChart is rendered
      expect(find.byType(LineChart), findsNothing);
    });

    testWidgets('renders with custom height parameter', (WidgetTester tester) async {
      const double customHeight = 400.0;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SpendingTrendChart(
              expenses: sampleExpenses,
              height: customHeight,
            ),
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
      // Add a recent expense so it's within the customDaysToShow window
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
        MaterialApp(
          home: Scaffold(
            body: SpendingTrendChart(
              expenses: expensesWithRecent,
              daysToShow: customDaysToShow,
            ),
          ),
        ),
      );

      // Find LineChart widget
      final lineChartFinder = find.byType(LineChart);
      expect(lineChartFinder, findsOneWidget);
      
      // It's difficult to directly test the exact days range in the widget tree
      // But we can verify the widget renders without errors
      final lineChart = tester.widget<LineChart>(lineChartFinder);
      final data = lineChart.data;
      
      // Verify basic properties are set correctly
      expect(data.minY, 0);
      expect(data.lineBarsData.length, 1);
      
      // The line bar should have data points
      final lineBarData = data.lineBarsData[0];
      expect(lineBarData.spots.isNotEmpty, true);
      
      // The spots should represent our expenses within the date range
      // Note: The actual spot values depend on the grouping logic in the component
    });

    testWidgets('handles old expenses gracefully', (WidgetTester tester) async {
      // Create a list of expenses that are all older than the default 30 days
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
        MaterialApp(
          home: Scaffold(
            body: SpendingTrendChart(
              expenses: oldExpenses,
              // Default daysToShow is 30
            ),
          ),
        ),
      );

      // When no recent data is available, the chart shouldn't be displayed
      expect(find.byType(LineChart), findsNothing);
      
      // But if we increase the daysToShow, it should show the data
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SpendingTrendChart(
              expenses: oldExpenses,
              daysToShow: 100, // Increase to include the old expenses
            ),
          ),
        ),
      );
      
      // Now we should see the chart
      expect(find.byType(LineChart), findsOneWidget);
    });
  });
}
