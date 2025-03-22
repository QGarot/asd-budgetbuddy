import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreUserData {
  final String email;
  final String username;
  final DateTime createdAt;

  FirestoreUserData({
    required this.email,
    required this.username,
    required this.createdAt,
  });

  // Factory constructor to convert Firestore data to an instance of FirebaseUserData
  factory FirestoreUserData.fromFirestore(Map<String, dynamic> data) {
    return FirestoreUserData(
      email: data['email'] ?? '',
      username: data['username'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }
}
