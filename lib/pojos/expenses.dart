import 'package:budgetbuddy/bloc/Data/id_generator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Expense {
  String id;
  String merchant;
  double amount;
  DateTime date;
  String notes;

  Expense({
    String? id,
    String? notes,
    required this.merchant,
    required this.amount,
    required this.date,
  }) : id = id ?? IdGenerator.generateRandomUniqueId(),
       notes = notes ?? '';

  factory Expense.fromFirestore(Map<String, dynamic> data) {
    return Expense(
      id: data['id'] ?? 0,
      merchant: data['merchant'] ?? '',
      amount: (data['amount'] as num).toDouble(),
      date: (data['date'] as Timestamp).toDate(),
      notes: data['notes'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'merchant': merchant,
      'amount': amount,
      'date': date,
      'notes': notes,
    };
  }
}
