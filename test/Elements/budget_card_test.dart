import 'package:budgetbuddy/Elements/budget_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('BudgetCard displays title, amount and icon and triggers onToggle', (tester) async {
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
            isCollapsed: false,
            onToggle: () {
              toggled = true;
            },
          ),
        ),
      ),
    );

    // Check visuals
    expect(find.text('Groceries'), findsOneWidget);
    expect(find.text(r'$120.00 of $200.00'), findsOneWidget);
    expect(find.byIcon(Icons.shopping_cart), findsOneWidget);
    expect(find.text('Monthly'), findsOneWidget);

    // Tap toggle using the key
    await tester.tap(find.byKey(const Key('toggle_button')));
    await tester.pump();

    // Confirm callback triggered
    expect(toggled, isTrue);
  });
}
