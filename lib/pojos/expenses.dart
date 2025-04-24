import 'package:budgetbuddy/bloc/Data/id_generator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Expense {
  String id;
  String merchant;
  double amount;
  DateTime createdAt;
  String notes;

  Expense({
    String? id,
    String? notes,
    required this.merchant,
    required this.amount,
    required this.createdAt,
  }) : id = id ?? IdGenerator.generateRandomUniqueId(),
       notes = notes ?? '';

  Expense copyWith({
    String? id,
    String? merchant,
    double? amount,
    DateTime? createdAt,
    String? notes,
  }) {
    return Expense(
      id: id ?? this.id,
      merchant: merchant ?? this.merchant,
      amount: amount ?? this.amount,
      createdAt: createdAt ?? this.createdAt,
      notes: notes ?? this.notes,
    );
  }

  factory Expense.fromFirestore(Map<String, dynamic> data) {
    return Expense(
      id: data['id'] ?? 0,
      merchant: data['merchant'] ?? '',
      amount: (data['amount'] as num).toDouble(),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      notes: data['notes'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'merchant': merchant,
      'amount': amount,
      'createdAt': createdAt,
      'notes': notes,
    };
  }
}
