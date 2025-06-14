import 'package:budgetbuddy/AppData/app_colors.dart';
import 'package:budgetbuddy/AppData/category_icons.dart';
import 'package:budgetbuddy/AppData/layout_constants.dart';
import 'package:budgetbuddy/Elements/budget_card.dart';
import 'package:budgetbuddy/bloc/Data/data_bloc.dart';
import 'package:budgetbuddy/pojos/budget.dart';
import 'package:budgetbuddy/pojos/expand_collapse_all.dart';
import 'package:budgetbuddy/pojos/user_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class BudgetTabView extends StatefulWidget {
  const BudgetTabView({super.key});

  @override
  State<BudgetTabView> createState() => _BudgetTabViewState();
}

class _BudgetTabViewState extends State<BudgetTabView> {
  final List<String> _tabs = const ['All', 'Monthly', 'Biweekly', 'Weekly'];
  final Map<String, Set<String>> _collapsedIdsPerTab = {};
  bool _allExpanded = true;

  void _toggleCollapse(String tab, String id) {
    setState(() {
      _collapsedIdsPerTab.putIfAbsent(tab, () => <String>{});
      if (_collapsedIdsPerTab[tab]!.contains(id)) {
        _collapsedIdsPerTab[tab]!.remove(id);
      } else {
        _collapsedIdsPerTab[tab]!.add(id);
      }
    });
  }

  void _toggleExpandAllGlobally() {
    setState(() {
      _allExpanded = !_allExpanded;
      final budgets =
          context.read<DataCubit>().getFirebaseUserData()?.budgets ?? [];
      for (final tab in _tabs) {
        if (_allExpanded) {
          _collapsedIdsPerTab[tab]?.clear();
        } else {
          final filtered =
              tab == "All"
                  ? budgets
                  : budgets
                      .where(
                        (b) => b.resetPeriod.toLowerCase() == tab.toLowerCase(),
                      )
                      .toList();
          _collapsedIdsPerTab[tab] = filtered.map((b) => b.id).toSet();
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return DefaultTabController(
      length: _tabs.length,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    loc.budgetTab_title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    children: [
                      const SizedBox(width: 8),
                      Builder(
                        builder:
                            (tabContext) => ExpandAllButton(
                              allExpanded: _allExpanded,
                              onToggle: _toggleExpandAllGlobally,
                            ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            TabBar(
              isScrollable: true,
              labelColor: Colors.deepPurple,
              unselectedLabelColor: Colors.black45,
              indicatorColor: Colors.deepPurpleAccent,
              tabs:
                  _tabs.map((tabKey) {
                    String label;
                    switch (tabKey) {
                      case 'All':
                        label = loc.budgetTab_all;
                        break;
                      case 'Monthly':
                        label = loc.period_monthly;
                        break;
                      case 'Biweekly':
                        label = loc.period_biweekly;
                        break;
                      case 'Weekly':
                        label = loc.period_weekly;
                        break;
                      default:
                        label = tabKey;
                    }
                    return Tab(text: label);
                  }).toList(),
            ),
            const SizedBox(height: 16),
            Flexible(
              child: TabBarView(
                children:
                    _tabs.map((tabKey) {
                      return BlocBuilder<DataCubit, AllUserData?>(
                        builder: (context, userData) {
                          final List<Budget> budgets = userData?.budgets ?? [];
                          final filtered =
                              tabKey == "All"
                                  ? budgets
                                  : budgets
                                      .where(
                                        (b) =>
                                            b.resetPeriod.toLowerCase() ==
                                            tabKey.toLowerCase(),
                                      )
                                      .toList();

                          final ScrollController controller =
                              ScrollController();

                          return ClipRect(
                            child: Scrollbar(
                              controller: controller,
                              thumbVisibility: true,
                              child: SingleChildScrollView(
                                controller: controller,
                                padding: const EdgeInsets.only(right: 8),
                                child: Wrap(
                                  spacing: LayoutConstants.spacing,
                                  runSpacing: 16,
                                  alignment: WrapAlignment.start,
                                  children:
                                      filtered.map((b) {
                                        final color = _getColorByCategory(
                                          b.category,
                                        );
                                        final icon = CategoryIcons.getIcon(
                                          b.category,
                                        );
                                        final isWarning =
                                            b.spentAmount >=
                                            (b.totalAmount * b.alertThreshold);
                                        final isCollapsed =
                                            _collapsedIdsPerTab[tabKey]
                                                ?.contains(b.id) ??
                                            false;

                                        return SizedBox(
                                          width: LayoutConstants.getCardWidth(
                                            context,
                                          ),
                                          child: BudgetCard(
                                            title: b.name,
                                            spent: b.spentAmount,
                                            limit: b.totalAmount,
                                            color: color,
                                            warning: isWarning,
                                            period: b.resetPeriod,
                                            icon: icon,
                                            isCollapsed: isCollapsed,
                                            idOfBudget: b.id,
                                            onToggle:
                                                () => _toggleCollapse(
                                                  tabKey,
                                                  b.id,
                                                ),
                                            budget: b,
                                          ),
                                        );
                                      }).toList(),
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getColorByCategory(String category) {
    switch (category.toLowerCase()) {
      case "groceries":
        return AppColors.groceries;
      case "rent":
        return AppColors.rent;
      case "entertainment":
        return AppColors.entertainment;
      case "dining":
        return AppColors.dining;
      case "travel":
        return AppColors.travel;
      case "utilities":
        return AppColors.utilities;
      case "shopping":
        return AppColors.shopping;
      default:
        return AppColors.other;
    }
  }
}
