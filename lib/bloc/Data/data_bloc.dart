import 'package:budgetbuddy/pojos/firebase_user_data.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DataCubit extends Cubit<FirestoreUserData?> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  FirestoreUserData? _userData;

  DataCubit() : super(null) {
    if (_auth.currentUser != null) {
      fetchFirebaseUserData();
    }
  }

  Future<FirestoreUserData?> fetchFirebaseUserData() async {
    try {
      DocumentSnapshot userDoc =
          await _firestore
              .collection('users')
              .doc(_auth.currentUser?.uid)
              .get();

      if (userDoc.exists) {
        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
        _userData = FirestoreUserData.fromFirestore(userData);
        return FirestoreUserData.fromFirestore(userData);
      } else {
        print("No user data found");
        return null;
      }
    } catch (e) {
      print("Error fetching user data: $e");
      return null;
    }
  }

  FirestoreUserData? getFirebaseUserData() {
    return _userData;
  }
}
