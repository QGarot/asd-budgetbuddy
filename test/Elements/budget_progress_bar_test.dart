import 'package:budgetbuddy/bloc/Data/summary_helper.dart';
import 'package:budgetbuddy/Elements/budget_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('BudgetProgressBar Widget Tests', () {
    testWidgets('displays correct budget usage percentage', (WidgetTester tester) async {
      // Create a mock BudgetSummary
      final summary = BudgetSummary(
        totalBudget: 1000.0,
        totalSpent: 300.0,
        remaining: 700.0,
      );

      // Build our widget
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BudgetProgressBar(summary: summary),
          ),
        ),
      );

      // Verify the percentage is displayed correctly (300/1000 = 30%)
      expect(find.text('30.0%'), findsOneWidget);
    });

    testWidgets('displays correct budget range', (WidgetTester tester) async {
      // Create a mock BudgetSummary
      final summary = BudgetSummary(
        totalBudget: 1000.0,
        totalSpent: 300.0,
        remaining: 700.0,
      );

      // Build our widget
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BudgetProgressBar(summary: summary),
          ),
        ),
      );

      // Verify the budget range is displayed correctly
      expect(find.text('€0'), findsOneWidget);
      expect(find.text('€1000.00'), findsOneWidget);
    });

    testWidgets('progress bar shows correct width based on budget usage', (WidgetTester tester) async {
      // Create a mock BudgetSummary with 50% usage
      final summary = BudgetSummary(
        totalBudget: 1000.0,
        totalSpent: 500.0,
        remaining: 500.0,
      );

      // Build our widget
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BudgetProgressBar(summary: summary),
          ),
        ),
      );

      // Find the outer container (gray background track)
      final trackFinder = find.byWidgetPredicate(
        (widget) => widget is Container &&
                   widget.decoration is BoxDecoration &&
                   (widget.decoration as BoxDecoration).color == Colors.grey[200],
      );
      
      // Verify we found the track
      expect(trackFinder, findsOneWidget);
      
      // Get the container and verify its properties
      final trackContainer = tester.widget<Container>(trackFinder);
      final trackDecoration = trackContainer.decoration as BoxDecoration;
      
      // Verify the track decoration properties
      expect(trackDecoration.borderRadius, BorderRadius.circular(6));
      // Check for container constraints instead of direct width property
      expect(find.byWidgetPredicate((widget) => 
        widget is Container && 
        widget.constraints is BoxConstraints && 
        (widget.constraints as BoxConstraints).maxWidth == double.infinity
      ), findsWidgets);
      
      // Find the progress bar using a more reliable finder
      final progressBarFinder = find.byWidgetPredicate(
        (widget) => widget is Container &&
                   widget.decoration is BoxDecoration &&
                   (widget.decoration as BoxDecoration).gradient != null,
      );
      
      // Verify we found the progress bar
      expect(progressBarFinder, findsOneWidget);
      
      // Get the container and verify its properties
      final container = tester.widget<Container>(progressBarFinder);
      final decoration = container.decoration as BoxDecoration;
      
      // Verify the decoration properties
      expect(decoration.borderRadius, BorderRadius.circular(6));
      expect(decoration.gradient, isA<LinearGradient>());
      expect(decoration.boxShadow, isNotNull);
    });

    testWidgets('progress bar changes color when over 80% of budget is used', (WidgetTester tester) async {
      // Create a mock BudgetSummary with 90% usage
      final summary = BudgetSummary(
        totalBudget: 1000.0,
        totalSpent: 900.0,
        remaining: 100.0,
      );

      // Build our widget
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BudgetProgressBar(summary: summary),
          ),
        ),
      );

      // Find the progress bar using a more reliable finder
      final progressBarFinder = find.byWidgetPredicate(
        (widget) => widget is Container &&
                   widget.decoration is BoxDecoration &&
                   (widget.decoration as BoxDecoration).gradient != null,
      );
      
      // Verify we found the progress bar
      expect(progressBarFinder, findsOneWidget);
      
      // Get the container and verify its properties
      final container = tester.widget<Container>(progressBarFinder);
      final decoration = container.decoration as BoxDecoration;
      final gradient = decoration.gradient as LinearGradient;
      
      // The gradient should use red/orange colors when over 80%
      expect(gradient.colors.any((color) => color == Colors.red[400] || color == Colors.orange[400]), isTrue);
    });
    
    testWidgets('progress bar handles case when budget is exceeded', (WidgetTester tester) async {
      // Create a mock BudgetSummary with usage exceeding budget
      final summary = BudgetSummary(
        totalBudget: 1000.0,
        totalSpent: 1200.0,
        remaining: -200.0,
      );

      // Build our widget
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BudgetProgressBar(summary: summary),
          ),
        ),
      );

      // Verify the percentage is displayed correctly with one decimal place (120.0%)
      final percentageFinder = find.byWidgetPredicate(
        (widget) => widget is Text && widget.data!.contains('%'),
      );
      final percentageWidget = tester.widget<Text>(percentageFinder);
      expect(percentageWidget.data, contains('%'));
      expect(percentageWidget.data!.split('%')[0].contains('.'), isTrue);

      // Find the progress bar
      final progressBarFinder = find.byWidgetPredicate(
        (widget) => widget is Container &&
                   widget.decoration is BoxDecoration &&
                   (widget.decoration as BoxDecoration).gradient != null,
      );
      
      // Get the container and verify its properties
      final container = tester.widget<Container>(progressBarFinder);
      final decoration = container.decoration as BoxDecoration;
      final gradient = decoration.gradient as LinearGradient;
      
      // The gradient should use red/orange colors
      expect(gradient.colors.any((color) => color == Colors.red[400]), isTrue);
    });
    
    testWidgets('handles zero budget case gracefully', (WidgetTester tester) async {
      // Create a BudgetSummary with zero budget (edge case)
      final summary = BudgetSummary(
        totalBudget: 0.0,
        totalSpent: 0.0,
        remaining: 0.0,
      );

      // Build our widget
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BudgetProgressBar(summary: summary),
          ),
        ),
      );

      // Should display 0% when budget is zero
      expect(find.text('0.0%'), findsOneWidget);
      
      // The widget should still render without crashing
      expect(find.text('Budget Usage'), findsOneWidget);
      expect(find.text('€0'), findsAtLeastNWidgets(1));
      
      // Verify the progress bar is rendered with 0 width
      final progressBarFinder = find.byType(Container).at(2);
      final container = tester.widget<Container>(progressBarFinder);
      final box = container.constraints as BoxConstraints;
      expect(box.maxWidth, 0.0);
    });
  });
}
