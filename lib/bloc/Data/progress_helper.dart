import 'package:budgetbuddy/pojos/budget.dart';
import 'package:intl/intl.dart';

Map<String, Map<String, double>> computeProgressSummary(List<Budget> budgets) {
  final now = DateTime.now();
  final Map<String, Map<String, double>> result = {};

  for (final budget in budgets) {
    final period = budget.resetPeriod.toLowerCase();

    if (period != "monthly" && period != "weekly" && period != "biweekly") {
      continue;
    }

    DateTime pointer = budget.createdAt;

    while (!pointer.isAfter(now)) {
      final key = _generateTimeframeKey(pointer, period);

      result.putIfAbsent(key, () => {"limit": 0.0, "used": 0.0});

      result[key]!["limit"] = result[key]!["limit"]! + budget.totalAmount;

      pointer = _advanceDate(pointer, period);
    }

    for (final expense in budget.expenses) {
      final key = _generateTimeframeKey(expense.createdAt, period);

      result.putIfAbsent(key, () => {"limit": 0.0, "used": 0.0});

      result[key]!["used"] = result[key]!["used"]! + expense.amount;
    }
  }

  return result;
}

String _generateTimeframeKey(DateTime date, String period) {
  switch (period) {
    case "monthly":
      return "${date.year}-${date.month.toString().padLeft(2, '0')}";

    case "weekly":
      final week = _getIsoWeek(date);
      return "${date.year}-W${week.toString().padLeft(2, '0')}";

    case "biweekly":
      final week = _getIsoWeek(date);
      final start = week - (week % 2);
      final end = start + 1;
      return "${date.year}-BW$start-$end";

    default:
      throw Exception("Unknown resetPeriod: $period");
  }
}

DateTime _advanceDate(DateTime date, String period) {
  switch (period) {
    case "monthly":
      return DateTime(date.year, date.month + 1, 1);

    case "weekly":
      return date.add(const Duration(days: 7));

    case "biweekly":
      return date.add(const Duration(days: 14));

    default:
      return date;
  }
}

int _getIsoWeek(DateTime date) {
  final dayOfYear = int.parse(DateFormat("D").format(date));

  final week = ((dayOfYear - date.weekday + 10) / 7).floor();

  return week;
}
