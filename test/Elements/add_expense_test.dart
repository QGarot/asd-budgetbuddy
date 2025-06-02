import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mockito/mockito.dart';
import 'package:budgetbuddy/Elements/add_expense_dialog.dart';
import 'package:budgetbuddy/bloc/Data/data_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

class FakeDataCubit extends Mock implements DataCubit {}

void main() {
  late FakeDataCubit mockDataCubit;

  setUp(() {
    mockDataCubit = FakeDataCubit();
  });

  Widget createTestWidget() {
    return MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'), // English
      ],
      locale: const Locale('en'), // Force English locale for tests,
      home: BlocProvider<DataCubit>.value(
        value: mockDataCubit,
        child: Scaffold(
          body: Builder(
            builder:
                (context) => ElevatedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder:
                          (_) => const AddExpenseDialog(
                            budgetId: 'test-budget-id',
                          ),
                    );
                  },
                  child: const Text('Show Dialog'),
                ),
          ),
        ),
      ),
    );
  }

  group('AddExpenseDialog', () {
    testWidgets('shows the dialog with title and icon', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      expect(find.text('Add Expense'), findsOneWidget);
      expect(find.byIcon(Icons.attach_money), findsOneWidget);
    });

    testWidgets('renders all form fields correctly', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1000, 800));
      await tester.pumpWidget(createTestWidget());
      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      expect(find.text('Amount *'), findsOneWidget);
      expect(find.text('Merchant *'), findsOneWidget);
      expect(find.text('Date *'), findsOneWidget);
      expect(find.text('Category'), findsOneWidget);
      expect(find.text('Payment Method'), findsOneWidget);
      expect(find.text('Notes'), findsOneWidget);
    });

    testWidgets('shows validation errors when fields are empty', (
      tester,
    ) async {
      await tester.pumpWidget(createTestWidget());
      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Save Expense'));
      await tester.pumpAndSettle();

      expect(find.text('Please enter a valid amount'), findsOneWidget);
      expect(find.text('Date is required'), findsOneWidget);
      expect(find.text('Merchant is required'), findsOneWidget);
    });

    testWidgets('accepts input into form fields', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      await tester.enterText(find.bySemanticsLabel('Amount *'), '50.25');
      await tester.enterText(find.bySemanticsLabel('Merchant *'), 'Aldi');
      await tester.enterText(find.bySemanticsLabel('Date *'), '12/05/2025');
      await tester.enterText(find.bySemanticsLabel('Notes'), 'Grocery run');

      expect(find.text('50.25'), findsOneWidget);
      expect(find.text('Aldi'), findsOneWidget);
      expect(find.text('12/05/2025'), findsOneWidget);
      expect(find.text('Grocery run'), findsOneWidget);
    });

    testWidgets('closes the dialog on cancel', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(find.text('Add Expense'), findsNothing);
    });
  });
}
