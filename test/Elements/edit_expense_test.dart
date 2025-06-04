import 'package:budgetbuddy/pojos/expenses.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mockito/mockito.dart';
import 'package:budgetbuddy/bloc/Data/data_bloc.dart';
import 'package:budgetbuddy/Elements/edit_expense.dart';
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
          locale: const Locale('en'), // Force English locale for tests
      home: BlocProvider<DataCubit>.value(
        value: mockDataCubit,
        child: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (_) => EditExpenseDialog(
                    budgetId: 'test-budget-id',
                    expense: Expense(
                      id: 'test-expense-id',
                      merchant: 'Lunch',
                      amount: 10.0,
                      createdAt: DateTime.now(),
                      category: 'Dining',
                      paymentMethod: 'Card',
                      notes: 'Test note',
                    ),
                  ),
                );
              },
              child: const Text('Show Edit Dialog'),
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('EditExpenseDialog renders and allows input', (tester) async {
    await tester.pumpWidget(createTestWidget());

    await tester.tap(find.text('Show Edit Dialog'));
    await tester.pumpAndSettle();

    // Headings and actions
    expect(find.text('Edit Expense'), findsOneWidget);
    expect(find.text('Update the details of this expense.'), findsOneWidget);
    expect(find.text('Cancel'), findsOneWidget);
    expect(find.text('Save Changes'), findsOneWidget);

    // Labels inside form fields (these aren't always plain Text widgets)
    expect(find.widgetWithText(TextFormField, 'Amount *'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, 'Date *'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, 'Merchant *'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, 'Notes'), findsOneWidget);

    // Input and selection simulation
    await tester.enterText(find.byType(TextFormField).at(0), '800.00');
    await tester.enterText(find.byType(TextFormField).at(2), 'New Merchant');
    await tester.enterText(find.byType(TextFormField).last, 'Updated note');

    // Submit form
    await tester.tap(find.text('Save Changes'));
    await tester.pumpAndSettle();

  });
}
