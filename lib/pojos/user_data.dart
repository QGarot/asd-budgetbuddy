import 'package:budgetbuddy/pojos/budget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AllUserData {
  String email;
  String username;
  DateTime createdAt;
  List<Budget> budgets;

  AllUserData({
    required this.email,
    required this.username,
    required this.createdAt,
    required this.budgets,
  });

  AllUserData copyWith({
    String? email,
    String? username,
    DateTime? createdAt,
    List<Budget>? budgets,
  }) {
    return AllUserData(
      email: email ?? this.email,
      username: username ?? this.username,
      createdAt: createdAt ?? this.createdAt,
      budgets: budgets ?? this.budgets.map((b) => b.copyWith()).toList(),
    );
  }

  // Factory constructor to convert Firestore data to an instance of FirebaseUserData
  factory AllUserData.fromFirestore(
    Map<String, dynamic> data,
    List<Budget> budgets,
  ) {
    return AllUserData(
      email: data['email'] ?? '',
      username: data['username'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      budgets: budgets,
    );
  }
}
