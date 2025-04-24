import 'package:budgetbuddy/Elements/budget_card.dart';
import 'package:budgetbuddy/pojos/budget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'BudgetCard displays title, amount and icon and triggers onToggle',
    (tester) async {
      bool toggled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BudgetCard(
              title: 'Groceries',
              spent: 120,
              limit: 200,
              color: Colors.green,
              warning: false,
              period: 'Monthly',
              icon: Icons.shopping_cart,
              idOfBudget: '1',
              isCollapsed: false,
              onToggle: () {
                toggled = true;
              },
              budget: Budget(
                name: "name",
                category: "Groceries",
                createdAt: DateTime(2025, 4, 10),
                resetPeriod: "Monthly",
                alertThreshold: 0.8,
                totalAmount: 200,
              ),
            ),
          ),
        ),
      );

      // Check visuals
      expect(find.text('Groceries'), findsOneWidget);
      expect(find.text(r'€120.00 of €200.00'), findsOneWidget);
      expect(find.byIcon(Icons.shopping_cart), findsOneWidget);
      expect(find.text('Monthly'), findsOneWidget);
    },
  );
}
