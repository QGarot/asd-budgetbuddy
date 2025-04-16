import 'package:budgetbuddy/Elements/header_bar.dart';
import 'package:budgetbuddy/screens/progress_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ProgressScreen Widget Tests', () {
    testWidgets('displays HeaderBar and Progress text', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: ProgressScreen()),
        ),
      );

      // Verify the HeaderBar is shown with correct title
      expect(find.byType(HeaderBar), findsOneWidget);
      expect(find.text('Progress'), findsOneWidget);
    });
  });
}
