import 'package:budgetbuddy/bloc/Auth/auth_bloc.dart';
import 'package:budgetbuddy/bloc/Data/data_bloc.dart';
import 'package:budgetbuddy/bloc/Navigation/sidebar_cubit.dart';
import 'package:budgetbuddy/pojos/user_auth.dart';
import 'package:budgetbuddy/pojos/user_data.dart';
import 'package:budgetbuddy/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../mockito/mock_classes.mocks.dart';

// Currently skipped !



void main() {
  testWidgets('HomeScreen renders dashboard title and subtitle', (
    WidgetTester tester,
  ) async {
    final mockAuthCubit = MockAuthCubit();
    final mockDataCubit = MockDataCubit();

    when(mockAuthCubit.state).thenReturn(
      AuthUserData(
        uid: 'test-uid',
        email: 'test@example.com',
        username: 'TestUser',
      ),
    );
    when(mockAuthCubit.stream).thenAnswer((_) => const Stream.empty());

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
      MediaQuery(
        data: const MediaQueryData(
          size: Size(1440, 1024),
        ), // Desktop-like width
        child: MaterialApp(
          home: Scaffold(
            body: MultiBlocProvider(
              providers: [
                BlocProvider<AuthCubit>.value(value: mockAuthCubit),
                BlocProvider<SidebarCubit>(create: (_) => SidebarCubit()),
                BlocProvider<DataCubit>.value(value: mockDataCubit),
              ],
              child: const HomeScreen(),
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Budget Dashboard'), findsNWidgets(2));
    expect(find.text('Manage and track your spending'), findsOneWidget);
    expect(find.text('Dashboard'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);
  },
  skip: true,
  
  );
}
