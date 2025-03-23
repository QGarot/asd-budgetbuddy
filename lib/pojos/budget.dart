import 'package:budgetbuddy/bloc/Data/id_generator.dart';
import 'package:budgetbuddy/pojos/expenses.dart';

class Budget {
  String id;
  String name;
  String category;
  double alertThreshold;
  double totalAmount;
  double spentAmount = 0;
  List<Expense> expenses;

  Budget({
    String? id,
    double? spentAmount,
    List<Expense>? expenses,
    required this.name,
    required this.category,
    required this.alertThreshold,
    required this.totalAmount,
  }) : id = id ?? IdGenerator.generateRandomUniqueId(),
       spentAmount = spentAmount ?? 0,
       expenses = expenses ?? [];

  Budget copyWith({
    String? id,
    String? name,
    String? category,
    double? alertThreshold,
    double? totalAmount,
    double? spentAmount,
    List<Expense>? expenses,
  }) {
    return Budget(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      alertThreshold: alertThreshold ?? this.alertThreshold,
      totalAmount: totalAmount ?? this.totalAmount,
      spentAmount: spentAmount ?? this.spentAmount,
      expenses: expenses ?? this.expenses.map((e) => e.copyWith()).toList(),
    );
  }

  factory Budget.fromFirestore(
    Map<String, dynamic> data,
    List<Expense> expenses,
  ) {
    return Budget(
      id: data['id'] ?? 0,
      name: data['name'] ?? '',
      category: data['category'] ?? '',
      alertThreshold: (data['alertThreshold'] as num).toDouble(),
      totalAmount: (data['totalAmount'] as num).toDouble(),
      spentAmount: (data['spentAmount'] as num).toDouble(),
      expenses: expenses,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'alertThreshold': alertThreshold,
      'totalAmount': totalAmount,
      'spentAmount': spentAmount,
      //'expenses': expenses.map((e) => e.toFirestore()).toList(),
    };
  }
}
