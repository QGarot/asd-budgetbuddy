import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:budgetbuddy/Elements/budget_list.dart';
import 'package:budgetbuddy/pojos/user_data.dart';
import 'package:budgetbuddy/pojos/budget.dart';
import 'package:budgetbuddy/bloc/Data/data_bloc.dart';
import 'package:mockito/mockito.dart';
import '../mockito/mock_classes.mocks.dart';

void main() {
  testWidgets('BudgetListWidget renders budgets correctly', (tester) async {
    final mockDataCubit = MockDataCubit();

    // Provide mocked budget data
    final mockBudgets = [
      Budget(
        name: 'Rent',
        category: 'Housing',
        resetPeriod: 'Monthly',
        alertThreshold: 0.8,
        totalAmount: 1000,
        spentAmount: 800,
      ),
      Budget(
        name: 'Groceries',
        category: 'Food',
        resetPeriod: 'Weekly',
        alertThreshold: 0.6,
        totalAmount: 200,
        spentAmount: 150,
      ),
    ];

    final mockUserData = AllUserData(
      username: 'TestUser',
      email: 'test@example.com',
      createdAt: DateTime.now(),
      budgets: mockBudgets,
    );

    when(mockDataCubit.state).thenReturn(mockUserData);
    when(mockDataCubit.stream).thenAnswer((_) => const Stream.empty());

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<DataCubit>.value(
          value: mockDataCubit,
          child: const Scaffold(body: BudgetListWidget()),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Check if both budget names show up
    expect(find.text('Rent'), findsOneWidget);
    expect(find.text('Groceries'), findsOneWidget);

    // Check if amounts are rendered correctly
    expect(find.textContaining('Total: €1000.00'), findsOneWidget);
    expect(find.textContaining('Spent: €800.00'), findsOneWidget);
    expect(find.textContaining('Total: €200.00'), findsOneWidget);
    expect(find.textContaining('Spent: €150.00'), findsOneWidget);
  });
}
