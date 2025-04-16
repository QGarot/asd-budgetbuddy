import 'package:budgetbuddy/screens/help_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:budgetbuddy/Elements/header_bar.dart';

void main() {
  group('HelpScreen Widget Tests', () {
    testWidgets('displays HeaderBar and Help text', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: HelpScreen()),
        ),
      );

      // Header and title check
      expect(find.byType(HeaderBar), findsOneWidget);
      expect(find.text('Help'), findsOneWidget);

    });
  });
}
