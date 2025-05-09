import 'package:budgetbuddy/bloc/Data/id_generator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Expense {
  String id;
  String merchant;
  double amount;
  DateTime createdAt;
  String notes;
  String category;
  String paymentMethod;

  Expense({
    String? id,
    String? notes,
    required this.merchant,
    required this.amount,
    required this.createdAt,
    required this.category,
    required this.paymentMethod,
  })  : id = id ?? IdGenerator.generateRandomUniqueId(),
        notes = notes ?? '';

  Expense copyWith({
    String? id,
    String? merchant,
    double? amount,
    DateTime? createdAt,
    String? notes,
    String? category,
    String? paymentMethod,
  }) {
    return Expense(
      id: id ?? this.id,
      merchant: merchant ?? this.merchant,
      amount: amount ?? this.amount,
      createdAt: createdAt ?? this.createdAt,
      notes: notes ?? this.notes,
      category: category ?? this.category,
      paymentMethod: paymentMethod ?? this.paymentMethod,
    );
  }

  factory Expense.fromFirestore(Map<String, dynamic> data) {
    return Expense(
      id: data['id'] ?? '',
      merchant: data['merchant'] ?? '',
      amount: (data['amount'] ?? 0).toDouble(),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      notes: data['notes'] ?? '',
      category: data['category'] ?? '',
      paymentMethod: data['paymentMethod'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'merchant': merchant,
      'amount': amount,
      'createdAt': createdAt,
      'notes': notes,
      'category': category,
      'paymentMethod': paymentMethod,
    };
  }
}
