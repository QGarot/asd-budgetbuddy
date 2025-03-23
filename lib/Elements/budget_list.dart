import 'package:budgetbuddy/bloc/Data/data_bloc.dart';

import 'package:budgetbuddy/pojos/user_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BudgetListWidget extends StatelessWidget {
  const BudgetListWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 400,
      child: BlocBuilder<DataCubit, AllUserData?>(
        builder: (context, userData) {
          if (userData == null || userData.budgets.isEmpty) {
            return Center(child: Text("No budgets available"));
          }

          return ListView.builder(
            itemCount: userData.budgets.length,
            itemBuilder: (context, index) {
              final budget = userData.budgets[index];
              return Card(
                margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: ListTile(
                  title: Text(
                    budget.name,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Category: ${budget.category}'),
                      Text('Total: \$${budget.totalAmount.toStringAsFixed(2)}'),
                      Text('Spent: \$${budget.spentAmount.toStringAsFixed(2)}'),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
