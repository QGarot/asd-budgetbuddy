import 'package:budgetbuddy/bloc/Data/data_bloc.dart';
import 'package:budgetbuddy/pojos/user_data.dart';
import 'package:budgetbuddy/screens/statistics_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../mockito/mock_classes.mocks.dart';

void main() {
  testWidgets('StatisticsScreen renders title, subtitle, and no-data message', (
    WidgetTester tester,
  ) async {
    final mockDataCubit = MockDataCubit();

    when(mockDataCubit.state).thenReturn(
      AllUserData(
        username: 'TestUser',
        email: 'test@example.com',
        locale: 'en',
        createdAt: DateTime(2024, 1, 1),
        budgets: [],
      ),
    );
    when(mockDataCubit.stream).thenAnswer((_) => const Stream.empty());

    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(size: Size(1080, 1920)),
        child: MaterialApp(
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('en')],
          locale: const Locale('en'),
          home: Scaffold(
            body: BlocProvider<DataCubit>.value(
              value: mockDataCubit,
              child: const StatisticsScreen(),
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Statistics Dashboard'), findsNWidgets(2));
    expect(find.text('Visualize your budget data'), findsOneWidget);
    expect(find.text('No budget data available to visualize'), findsOneWidget);
  });
}
