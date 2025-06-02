import 'package:budgetbuddy/screens/help_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:budgetbuddy/Elements/header_bar.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  group('HelpScreen Widget Tests', () {
    testWidgets('displays HeaderBar and Help text', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('en'), // English
        ],
        locale: const Locale('en'), // Force English locale for tests
          home: Scaffold(body: HelpScreen()),
        ),
      );

      // Header and title check
      expect(find.byType(HeaderBar), findsOneWidget);
      expect(find.text('Help'), findsOneWidget);

    });
  });
}
