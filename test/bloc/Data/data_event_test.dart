import 'package:budgetbuddy/pojos/user_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mockito/mockito.dart';

import 'package:budgetbuddy/bloc/Data/data_bloc.dart';
import 'package:budgetbuddy/pojos/budget.dart';
import 'package:budgetbuddy/bloc/Data/data_event.dart';

import '../../mockito/mock_classes.mocks.dart'; // assure-toi que ce chemin est correct

void main() {
  late MockDataCubit mockDataCubit;

  setUp(() {
    mockDataCubit = MockDataCubit();
    when(mockDataCubit.stream).thenAnswer((_) => const Stream.empty());
  });

  testWidgets('DataEvent.addBudget calls DataCubit.addBudget correctly', (tester) async {
    final testBudget = Budget(
      id: 'b1',
      name: 'Test Budget',
      category: 'Test',
      alertThreshold: 100,
      resetPeriod: 'monthly',
      totalAmount: 500,
      expenses: [],
      spentAmount: 0,
      createdAt: DateTime.now(),
    );

    when(mockDataCubit.addBudget(any)).thenAnswer((_) async => true);

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<DataCubit>.value(
          value: mockDataCubit,
          child: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () async {
                  final result = await DataEvent.addBudget(context, testBudget);
                  expect(result, isTrue);
                },
                child: const Text('Add Budget'),
              );
            },
          ),
        ),
      ),
    );

    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();

    verify(mockDataCubit.addBudget(testBudget)).called(1);
  });

  testWidgets('DataEvent.deleteBudget calls DataCubit.deleteBudget', (tester) async {
    when(mockDataCubit.deleteBudget(any)).thenAnswer((_) async => true);

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<DataCubit>.value(
          value: mockDataCubit,
          child: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () async {
                  final result = await DataEvent.deleteBudget(context, 'budget1');
                  expect(result, isTrue);
                },
                child: const Text('Delete Budget'),
              );
            },
          ),
        ),
      ),
    );

    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();

    verify(mockDataCubit.deleteBudget('budget1')).called(1);
  });

  testWidgets('DataEvent.getFirebaseUserData calls DataCubit.getFirebaseUserData', (tester) async {
    final dummyUserData = AllUserData(
      email: 'test@example.com',
      username: 'TestUser',
      createdAt: DateTime(2025, 1, 1),
      budgets: [],
      locale: 'en',
    );

    when(mockDataCubit.getFirebaseUserData()).thenReturn(dummyUserData);

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<DataCubit>.value(
          value: mockDataCubit,
          child: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () {
                  final result = DataEvent.getFirebaseUserData(context);
                  expect(result, equals(dummyUserData));
                },
                child: const Text('Get Data'),
              );
            },
          ),
        ),
      ),
    );

    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();

    verify(mockDataCubit.getFirebaseUserData()).called(1);
  });

  testWidgets('DataEvent.getFirebaseUserData calls DataCubit.getFirebaseUserData', (tester) async {
    final dummyUserData = AllUserData(
      email: 'test@example.com',
      username: 'TestUser',
      createdAt: DateTime(2025, 1, 1),
      budgets: [],
      locale: 'en',
    );

    when(mockDataCubit.getFirebaseUserData()).thenReturn(dummyUserData);

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<DataCubit>.value(
          value: mockDataCubit,
          child: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () {
                  final result = DataEvent.getFirebaseUserData(context);
                  expect(result, equals(dummyUserData));
                },
                child: const Text('Get Data'),
              );
            },
          ),
        ),
      ),
    );

    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();

    verify(mockDataCubit.getFirebaseUserData()).called(1);
  });
}
