import 'package:budgetbuddy/Elements/budget_tab_view.dart';
import 'package:budgetbuddy/bloc/Data/data_bloc.dart';
import 'package:budgetbuddy/pojos/user_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:mockito/mockito.dart';

import '../mockito/mock_classes.mocks.dart';

void main() {
  testWidgets('BudgetTabView renders and switches tabs', (tester) async {
    final mockDataCubit = MockDataCubit();
    when(mockDataCubit.state).thenReturn(
      AllUserData(
        username: 'Test',
        email: 'test@example.com',
        locale: 'en',
        createdAt: DateTime(2024),
        budgets: [],
      ),
    );
    when(mockDataCubit.stream).thenAnswer((_) => const Stream.empty());

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
        home: Scaffold(
          body: BlocProvider<DataCubit>.value(
            value: mockDataCubit,
            child: const BudgetTabView(),
          ),
        ),
      ),
    );

    expect(find.text('Your Budgets'), findsOneWidget);
    expect(find.text('All'), findsOneWidget);
    expect(find.text('Monthly'), findsOneWidget);
    expect(find.byType(TabBar), findsOneWidget);

    // Tap the 'Weekly' tab
    await tester.tap(find.text('Weekly'));
    await tester.pumpAndSettle();

    expect(find.text('Weekly'), findsOneWidget);
  });
}
