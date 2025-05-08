import 'package:budgetbuddy/bloc/Data/id_generator.dart';
import 'package:budgetbuddy/pojos/expenses.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Budget {
  String id;
  String name;
  String category;
  DateTime createdAt;
  String resetPeriod;
  double alertThreshold;
  double totalAmount;
  double spentAmount = 0;
  List<Expense> expenses;
  IconData? icon; // optional icon field

  Budget({
    String? id,
    double? spentAmount,
    List<Expense>? expenses,
    this.icon,
    required this.name,
    required this.category,
    required this.createdAt,
    required this.resetPeriod,
    required this.alertThreshold,
    required this.totalAmount,
  }) : id = id ?? IdGenerator.generateRandomUniqueId(),
       spentAmount = spentAmount ?? 0,
       expenses = expenses ?? [];

  Budget copyWith({
    String? id,
    String? name,
    String? category,
    DateTime? createdAt,
    String? resetPeriod,
    double? alertThreshold,
    double? totalAmount,
    double? spentAmount,
    List<Expense>? expenses,
    IconData? icon,
  }) {
    return Budget(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      createdAt: createdAt ?? this.createdAt,
      resetPeriod: resetPeriod ?? this.resetPeriod,
      alertThreshold: alertThreshold ?? this.alertThreshold,
      totalAmount: totalAmount ?? this.totalAmount,
      spentAmount: spentAmount ?? this.spentAmount,
      expenses: expenses ?? this.expenses.map((e) => e.copyWith()).toList(),
      icon: icon ?? this.icon,
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
      createdAt:
          (data['createdAt'] is Timestamp)
              ? (data['createdAt'] as Timestamp).toDate()
              : DateTime.now(),
      resetPeriod: data['resetPeriod'] ?? '',
      alertThreshold: (data['alertThreshold'] as num).toDouble(),
      totalAmount: (data['totalAmount'] as num).toDouble(),
      spentAmount: (data['spentAmount'] as num).toDouble(),
      expenses: expenses,
      // icon will be assigned dynamically in UI using category
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'createdAt': Timestamp.fromDate(createdAt),
      'resetPeriod': resetPeriod,
      'alertThreshold': alertThreshold,
      'totalAmount': totalAmount,
      'spentAmount': spentAmount,
      // 'icon' is not stored in Firestore
    };
  }
}
