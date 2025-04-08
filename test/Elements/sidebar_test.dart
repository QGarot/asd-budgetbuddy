import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:budgetbuddy/Elements/sidebar.dart';
import 'package:budgetbuddy/bloc/Navigation/sidebar_cubit.dart';
import 'package:budgetbuddy/bloc/Data/data_bloc.dart';
import 'package:budgetbuddy/pojos/user_data.dart';

import '../mockito/mock_classes.mocks.dart';
import 'package:mockito/mockito.dart';

void main() {
  testWidgets('Sidebar updates cubit and visually indicates selected item', (
    WidgetTester tester,
  ) async {
    final cubit = SidebarCubit();

    final mockDataCubit = MockDataCubit();
    when(mockDataCubit.state).thenReturn(
      AllUserData(
        username: 'TestUser',
        email: 'test@example.com',
        createdAt: DateTime(2024, 1, 1),
        budgets: [],
      ),
    );
    when(mockDataCubit.stream).thenAnswer((_) => const Stream.empty());

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MultiBlocProvider(
            providers: [
              BlocProvider<DataCubit>.value(value: mockDataCubit),
              BlocProvider<SidebarCubit>.value(value: cubit),
            ],
            child: const Row(children: [Sidebar()]),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text("Dashboard"), findsOneWidget);
    expect(find.text("Settings"), findsOneWidget);
    expect(find.text("Help"), findsOneWidget);
    expect(find.text("BudgetBuddy"), findsOneWidget);
    expect(find.text("TestUser"), findsOneWidget);
    expect(find.text("test@example.com"), findsOneWidget);

    await tester.tap(find.text("Settings"));
    await tester.pump();

    expect(cubit.state, SidebarPage.settings);

    final settingsTile = tester.widget<ListTile>(
      find.widgetWithText(ListTile, "Settings"),
    );

    final settingsText = settingsTile.title as Text;
    expect(settingsText.style?.color, equals(Colors.white));

    final settingsIcon = settingsTile.leading as Icon;
    expect(settingsIcon.color, equals(Colors.white));
  });
}
