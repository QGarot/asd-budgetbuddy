import 'package:budgetbuddy/AppData/app_colors.dart';
import 'package:budgetbuddy/bloc/Data/data_bloc.dart';
import 'package:budgetbuddy/bloc/Data/progress_helper.dart';
import 'package:budgetbuddy/pojos/user_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class ProgressTabView extends StatefulWidget {
  const ProgressTabView({super.key});

  @override
  State<ProgressTabView> createState() => _ProgressTabViewState();
}

class _ProgressTabViewState extends State<ProgressTabView> {
  final List<String> _tabs = const ['Monthly', 'Biweekly', 'Weekly'];

  @override
  Widget build(BuildContext context) {
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
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                "Your Progress",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 16),
            TabBar(
              isScrollable: true,
              labelColor: Colors.deepPurple,
              unselectedLabelColor: Colors.black45,
              indicatorColor: Colors.deepPurpleAccent,
              tabs: _tabs.map((tab) => Tab(text: tab)).toList(),
            ),
            const SizedBox(height: 16),
            Flexible(
              child: TabBarView(
                children:
                    _tabs.map((tab) {
                      return BlocBuilder<DataCubit, AllUserData?>(
                        builder: (context, userData) {
                          final budgets = userData?.budgets ?? [];
                          final progressMap = computeProgressSummary(
                            budgets
                                .where(
                                  (b) =>
                                      b.resetPeriod.toLowerCase() ==
                                      tab.toLowerCase(),
                                )
                                .toList(),
                          );

                          final sortedKeys =
                              progressMap.keys.toList()
                                ..sort((a, b) => a.compareTo(b));

                          final Map<String, List<String>> groupedByYear = {};
                          for (final key in sortedKeys) {
                            final year = key.split('-').first;
                            groupedByYear.putIfAbsent(year, () => []).add(key);
                          }

                          return SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children:
                                  groupedByYear.entries.map((entry) {
                                    final year = entry.key;
                                    final keys = entry.value;

                                    return Padding(
                                      padding: const EdgeInsets.only(
                                        bottom: 24.0,
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12.0,
                                              vertical: 8,
                                            ),
                                            child: Text(
                                              "$year Budget Progress",
                                              style: const TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          ...keys.map((key) {
                                            final data = progressMap[key]!;
                                            final used = data["used"]!;
                                            final limit = data["limit"]!;
                                            final percent = (used / limit * 100)
                                                .clamp(0, 999);
                                            final isOver = used > limit;
                                            final progress =
                                                (used / limit)
                                                    .clamp(0, 1)
                                                    .toDouble();

                                            final barColor =
                                                isOver
                                                    ? AppColors.dangerColor
                                                    : AppColors.yellowColor;
                                            final bgColor =
                                                isOver
                                                    ? AppColors.dangerColorFaint
                                                    : AppColors
                                                        .yellowColorFaint;

                                            return Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 12.0,
                                                    vertical: 10,
                                                  ),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Text(
                                                        _formatLabelFromKey(
                                                          key,
                                                          tab.toLowerCase(),
                                                        ),
                                                        style: const TextStyle(
                                                          fontWeight:
                                                              FontWeight.w600,
                                                        ),
                                                      ),
                                                      Text(
                                                        "${used.toStringAsFixed(2)} € of ${limit.toStringAsFixed(2)} €",
                                                        style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          color:
                                                              isOver
                                                                  ? Colors.red
                                                                  : Colors
                                                                      .black,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 6),
                                                  Stack(
                                                    alignment:
                                                        Alignment.centerLeft,
                                                    children: [
                                                      Container(
                                                        height: 8,
                                                        decoration: BoxDecoration(
                                                          color: bgColor,
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                4,
                                                              ),
                                                        ),
                                                      ),
                                                      FractionallySizedBox(
                                                        widthFactor: progress,
                                                        child: Container(
                                                          height: 8,
                                                          decoration: BoxDecoration(
                                                            color: barColor,
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                  4,
                                                                ),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Text(
                                                        "${percent.toStringAsFixed(0)}% spent",
                                                        style: const TextStyle(
                                                          fontSize: 12,
                                                          color: Colors.black54,
                                                        ),
                                                      ),
                                                      Text(
                                                        isOver
                                                            ? "${(used - limit).toStringAsFixed(2)} € over budget"
                                                            : "${(limit - used).toStringAsFixed(2)} € remaining",
                                                        style: TextStyle(
                                                          fontSize: 12,
                                                          color:
                                                              isOver
                                                                  ? AppColors
                                                                      .dangerColor
                                                                  : Colors
                                                                      .black54,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            );
                                          }),
                                        ],
                                      ),
                                    );
                                  }).toList(),
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

  String _formatLabelFromKey(String key, String period) {
    if (period == "monthly") {
      final date = DateTime.parse("$key-01");
      return DateFormat("MMMM yyyy").format(date);
    } else if (period == "weekly") {
      final parts = key.split('-');
      final year = int.parse(parts[0]);
      final week = int.parse(parts[1].substring(1));
      final monday = _firstDayOfWeek(year, week);
      final sunday = monday.add(const Duration(days: 6));
      return "Week $week (${DateFormat("dd.MM").format(monday)} - ${DateFormat("dd.MM").format(sunday)})";
    } else if (period == "biweekly") {
      final parts = key.split('-');
      final year = int.parse(parts[0]);
      final week1 = int.parse(parts[1].substring(2));
      final week2 = int.parse(parts[2]);
      final monday = _firstDayOfWeek(year, week1);
      final sunday = _firstDayOfWeek(year, week2).add(const Duration(days: 6));
      return "Week $week1-$week2 (${DateFormat("dd.MM").format(monday)} - ${DateFormat("dd.MM").format(sunday)})";
    }
    return key;
  }

  DateTime _firstDayOfWeek(int year, int week) {
    final jan4 = DateTime.utc(year, 1, 4);
    final daysOffset = jan4.weekday - 1;
    return jan4
        .subtract(Duration(days: daysOffset))
        .add(Duration(days: (week - 1) * 7));
  }
}
