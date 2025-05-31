import 'package:budgetbuddy/bloc/Data/data_bloc.dart';
import 'package:budgetbuddy/pojos/user_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class BudgetListWidget extends StatelessWidget {
  const BudgetListWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return SizedBox(
      height: 400,
      child: BlocBuilder<DataCubit, AllUserData?>(
        builder: (context, userData) {
          if (userData == null || userData.budgets.isEmpty) {
            return Center(child: Text(loc.budgetList_noBudgets));
          }

          return ListView.builder(
            itemCount: userData.budgets.length,
            itemBuilder: (context, index) {
              final budget = userData.budgets[index];

              final localizedCategory = _localizedCategory(
                context,
                budget.category,
              );

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: ListTile(
                  title: Text(
                    budget.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${loc.budgetList_categoryLabel} $localizedCategory",
                      ),
                      Text(
                        "${loc.budgetList_totalLabel} €${budget.totalAmount.toStringAsFixed(2)}",
                      ),
                      Text(
                        "${loc.budgetList_spentLabel} €${budget.spentAmount.toStringAsFixed(2)}",
                      ),
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

  String _localizedCategory(BuildContext context, String categoryKey) {
    final loc = AppLocalizations.of(context)!;
    switch (categoryKey) {
      case 'Groceries':
        return loc.category_groceries;
      case 'Rent':
        return loc.category_rent;
      case 'Utilities':
        return loc.category_utilities;
      case 'Entertainment':
        return loc.category_entertainment;
      case 'Travel':
        return loc.category_travel;
      case 'Dining':
        return loc.category_dining;
      case 'Shopping':
        return loc.category_shopping;
      case 'Other':
        return loc.category_other;
      default:
        return categoryKey;
    }
  }
}
