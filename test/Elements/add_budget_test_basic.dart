import 'package:budgetbuddy/Elements/add_budget_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'fills text fields and selects options in dropdowns in AddBudgetDialog',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: const AddBudgetDialog())),
      );

      expect(find.text("Create New Budget"), findsOneWidget);

      final budgetNameField = find.widgetWithText(TextFormField, 'Budget Name');
      expect(budgetNameField, findsOneWidget);
      await tester.enterText(budgetNameField, 'My Budget');

      final amountField = find.widgetWithText(TextFormField, 'Amount');
      expect(amountField, findsOneWidget);
      await tester.enterText(amountField, '123.45');

      final categoryInput = find.widgetWithText(InputDecorator, 'Category');
      expect(categoryInput, findsOneWidget);
      await tester.tap(categoryInput);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Rent'));
      await tester.pumpAndSettle();

      final periodInput = find.widgetWithText(InputDecorator, 'Period');
      expect(periodInput, findsOneWidget);
      await tester.tap(periodInput);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Monthly'));
      await tester.pumpAndSettle();

      expect(find.text('My Budget'), findsOneWidget);
      expect(find.text('123.45'), findsOneWidget);

      expect(find.text('Rent'), findsOneWidget);
      expect(find.text('Monthly'), findsOneWidget);
    },
  );
}
