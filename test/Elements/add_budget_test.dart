import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:budgetbuddy/bloc/Data/data_bloc.dart';
import 'package:budgetbuddy/Elements/add_budget_dialog.dart';

import '../mockito/mock_classes.mocks.dart';

void main() {
  late MockDataCubit mockDataBloc;

  setUp(() {
    mockDataBloc = MockDataCubit();
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: BlocProvider<DataCubit>.value(
        value: mockDataBloc,
        child: Scaffold(
          body: Builder(
            builder:
                (context) => ElevatedButton(
                  onPressed:
                      () => showDialog(
                        context: context,
                        builder: (context) => const AddBudgetDialog(),
                      ),
                  child: const Text('Show Dialog'),
                ),
          ),
        ),
      ),
    );
  }

  group('AddBudgetDialog Widget Tests', () {
    testWidgets('should render dialog with correct title and content', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createWidgetUnderTest());

      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      expect(find.text('Create New Budget'), findsOneWidget);
      expect(
        find.text('Set up a new budget to track your spending.'),
        findsOneWidget,
      );
      expect(find.byIcon(Icons.add_chart), findsOneWidget);
    });

    testWidgets('should render all required form fields', (
      WidgetTester tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(1000, 800));
      await tester.pumpWidget(createWidgetUnderTest());

      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      expect(find.text('Budget Name'), findsOneWidget);
      expect(find.text('Amount'), findsOneWidget);
      expect(find.text('Category'), findsOneWidget);
      expect(find.text('Period'), findsOneWidget);
      expect(find.textContaining('Alert Threshold:'), findsOneWidget);

      expect(find.byType(TextFormField), findsNWidgets(2));
      expect(find.byType(Slider), findsOneWidget);

      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Create Budget'), findsOneWidget);
    });

    testWidgets('should open category dropdown when tapped', (
      WidgetTester tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(1000, 800));
      await tester.pumpWidget(createWidgetUnderTest());

      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      final categoryFinder = find.widgetWithText(InputDecorator, 'Category');
      await tester.ensureVisible(categoryFinder);
      await tester.tap(categoryFinder);
      await tester.pumpAndSettle();

      expect(find.text('Groceries'), findsOneWidget);
      expect(find.text('Rent'), findsOneWidget);
      expect(find.text('Utilities'), findsOneWidget);
      expect(find.text('Entertainment'), findsOneWidget);
      expect(find.text('Travel'), findsOneWidget);
      expect(find.text('Dining'), findsOneWidget);
      expect(find.text('Shopping'), findsOneWidget);
      expect(find.text('Other'), findsOneWidget);
    });

    testWidgets('should open period dropdown when tapped', (
      WidgetTester tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(1000, 800));
      await tester.pumpWidget(createWidgetUnderTest());

      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(InputDecorator, 'Period'));
      await tester.pumpAndSettle();

      expect(find.text('Weekly'), findsOneWidget);
      expect(find.text('Biweekly'), findsOneWidget);
      expect(find.text('Monthly'), findsOneWidget);
    });

    testWidgets('should update alert threshold when slider is moved', (
      WidgetTester tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(1000, 800));
      await tester.pumpWidget(createWidgetUnderTest());

      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      expect(find.text('Alert Threshold: 80%'), findsOneWidget);

      final sliderFinder = find.byType(Slider);
      expect(sliderFinder, findsOneWidget);

      final Slider slider = tester.widget(sliderFinder);
      expect(slider.value, 0.8);

      await tester.runAsync(() async {
        slider.onChanged?.call(1.0);
      });

      await tester.pumpAndSettle();

      expect(find.text('Alert Threshold: 80%'), findsNothing);
      expect(find.text('Alert Threshold: 100%'), findsOneWidget);
    });

    testWidgets('should close dialog when Cancel button is pressed', (
      WidgetTester tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(1000, 800));

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(TextButton, 'Cancel'));
      await tester.pumpAndSettle();

      expect(find.text('Create New Budget'), findsNothing);

      await tester.binding.setSurfaceSize(null);
    });

    testWidgets('should allow entering text in input fields', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createWidgetUnderTest());

      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Budget Name'),
        'Groceries Budget',
      );
      await tester.pump();

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Amount'),
        '200.00',
      );
      await tester.pump();

      expect(find.text('Groceries Budget'), findsOneWidget);
      expect(find.text('200.00'), findsOneWidget);
    });

    testWidgets('should show error if fields are empty', (
      WidgetTester tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(1000, 800));
      await tester.pumpWidget(createWidgetUnderTest());

      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Create Budget'));
      await tester.pumpAndSettle();

      expect(find.text('Please fill in all fields.'), findsOneWidget);
    });

    testWidgets('should show error if amount is non-numeric', (
      WidgetTester tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(1000, 800));
      await tester.pumpWidget(createWidgetUnderTest());

      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      await tester.enterText(find.bySemanticsLabel('Budget Name'), 'Groceries');
      await tester.enterText(find.bySemanticsLabel('Amount'), 'abc');

      await tester.tap(find.widgetWithText(InputDecorator, 'Category'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Groceries').last);
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(InputDecorator, 'Period'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Monthly').last);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Create Budget'));
      await tester.pumpAndSettle();

      expect(find.text('Please enter a valid amount'), findsOneWidget);
    });

    testWidgets('should show error if amount is zero or negative', (
      WidgetTester tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(1000, 800));
      await tester.pumpWidget(createWidgetUnderTest());

      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      await tester.enterText(find.bySemanticsLabel('Budget Name'), 'Utilities');
      await tester.enterText(find.bySemanticsLabel('Amount'), '-50');

      await tester.tap(find.widgetWithText(InputDecorator, 'Category'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Utilities').last);
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(InputDecorator, 'Period'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Monthly').last);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Create Budget'));
      await tester.pumpAndSettle();

      expect(find.text('Please enter a valid amount'), findsOneWidget);
    });
  });
}
