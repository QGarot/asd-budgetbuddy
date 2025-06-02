import 'package:budgetbuddy/Elements/standard_dialog_box.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  group('StandardDialogBox Widget Tests', () {
    testWidgets('renders dialog with header, content, and actions', (
      WidgetTester tester,
    ) async {
      const testTitle = 'Test Title';
      const testSubtitle = 'Test Subtitle';
      const testContentText = 'Test content goes here';
      const testIcon = Icons.ac_unit;

      final actions = <Widget>[
        TextButton(onPressed: () {}, child: const Text('Cancel')),
        ElevatedButton(onPressed: () {}, child: const Text('OK')),
      ];

      await tester.pumpWidget(
        MaterialApp(
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
          home: Builder(
            builder: (context) {
              return Scaffold(
                body: Center(
                  child: ElevatedButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder:
                            (_) => StandardDialogBox(
                              title: testTitle,
                              subtitle: testSubtitle,
                              content: const Text(testContentText),
                              actions: actions,
                              icon: testIcon,
                            ),
                      );
                    },
                    child: const Text('Show Dialog'),
                  ),
                ),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      expect(find.text(testTitle), findsOneWidget);
      expect(find.text(testSubtitle), findsOneWidget);
      expect(find.byIcon(testIcon), findsOneWidget);

      expect(find.text(testContentText), findsOneWidget);

      expect(find.widgetWithText(TextButton, 'Cancel'), findsOneWidget);
      expect(find.widgetWithText(ElevatedButton, 'OK'), findsOneWidget);
    });
  });

  group('Static Builder Methods Tests', () {
    testWidgets(
      'buildStandardFormField creates a TextFormField with label and hint',
      (WidgetTester tester) async {
        final controller = TextEditingController();
        const labelText = 'Email';
        const hintText = 'Enter your email';

        final textFormField = StandardDialogBox.buildStandardFormField(
          controller: controller,
          label: labelText,
          hint: hintText,
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Padding(
                padding: const EdgeInsets.all(16.0),
                child: textFormField,
              ),
            ),
          ),
        );

        expect(find.text(labelText), findsOneWidget);
        expect(find.text(hintText), findsOneWidget);
      },
    );

    testWidgets(
      'buildStandardForm returns a Form with the given key and child widget',
      (WidgetTester tester) async {
        final formKey = GlobalKey<FormState>();
        const childText = 'Test Form Child';

        final formWidget = StandardDialogBox.buildStandardForm(
          formKey: formKey,
          child: const Text(childText),
        );

        await tester.pumpWidget(MaterialApp(home: Scaffold(body: formWidget)));

        expect(find.byType(Form), findsOneWidget);
        expect(find.text(childText), findsOneWidget);
      },
    );

    testWidgets(
      'buildDropdownField displays selected value in InputDecorator',
      (WidgetTester tester) async {

        final items = ['Item A', 'Item B', 'Item C'];
        String? selectedValue = items[1];

        String itemLabel(String item) => item;

        void onChanged(String? value) {
          selectedValue = value;
        }

        final dropdownWidget = StandardDialogBox.buildDropdownField<String>(
          selectedValue: selectedValue,
          items: items,
          onChanged: onChanged,
          itemLabel: itemLabel,
          label: 'Select an item',
        );

        await tester.pumpWidget(
          MaterialApp(home: Scaffold(body: Center(child: dropdownWidget))),
        );

      
        expect(find.text(itemLabel(selectedValue!)), findsOneWidget);
        expect(find.byIcon(Icons.arrow_drop_down), findsOneWidget);
      },
    );

    testWidgets(
      'buildStandardDropdown displays selected value in InputDecorator',
      (WidgetTester tester) async {
        final items = ['Option 1', 'Option 2', 'Option 3'];
        String? selectedValue = items[0];
        String itemLabel(String item) => item;

        void onChanged(String? newValue) {
          selectedValue = newValue;
        }

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (BuildContext context) {
                  final dropdownWidget =
                      StandardDialogBox.buildStandardDropdown<String>(
                        context: context,
                        label: 'Choose Option',
                        selectedValue: selectedValue,
                        items: items,
                        onChanged: onChanged,
                        itemLabel: itemLabel,
                      );
                  return Center(child: dropdownWidget);
                },
              ),
            ),
          ),
        );

        expect(find.text(selectedValue!), findsOneWidget);
        expect(find.byIcon(Icons.arrow_drop_down), findsOneWidget);
      },
    );
  });

  group('Interaction Tests for Dropdowns', () {
    testWidgets('tap on dropdown field opens menu and selects an item', (
      WidgetTester tester,
    ) async {
      final items = ['Alpha', 'Beta', 'Gamma'];
      String? selectedValue = items[0];
      String itemLabel(String item) => item;

      void onChanged(String? value) {
        selectedValue = value;
      }

      final dropdownWidget = StandardDialogBox.buildDropdownField<String>(
        selectedValue: selectedValue,
        items: items,
        onChanged: onChanged,
        itemLabel: itemLabel,
        label: 'Pick One',
      );

      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: Center(child: dropdownWidget))),
      );

      final dropdownFinder = find.widgetWithText(InputDecorator, 'Pick One');
      expect(dropdownFinder, findsOneWidget);

      await tester.tap(dropdownFinder);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Gamma'));
      await tester.pumpAndSettle();

      expect(selectedValue, equals('Gamma'));

      final updatedDropdown = StandardDialogBox.buildDropdownField<String>(
        selectedValue: selectedValue,
        items: items,
        onChanged: onChanged,
        itemLabel: itemLabel,
        label: 'Pick One',
      );

      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: Center(child: updatedDropdown))),
      );
      await tester.pumpAndSettle();

      expect(find.text('Gamma'), findsOneWidget);
    });
  });
}
