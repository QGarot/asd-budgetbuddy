import 'package:budgetbuddy/screens/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:budgetbuddy/Elements/header_bar.dart';

void main() {
  group('SettingsScreen Widget Tests', () {
    testWidgets('displays HeaderBar and Settings text', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: SettingsScreen()),
        ),
      );

      // Header and title check
      expect(find.byType(HeaderBar), findsOneWidget);
      expect(find.text('Settings'), findsOneWidget);

    });
  });
}
