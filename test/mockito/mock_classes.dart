import 'package:mockito/annotations.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:budgetbuddy/bloc/Auth/auth_bloc.dart';
import 'package:budgetbuddy/bloc/Data/data_bloc.dart';

// Central mock generator for all tests
@GenerateMocks([
  FirebaseAuth,
  FirebaseFirestore,
  User,
  UserCredential,
  DocumentSnapshot<Map<String, dynamic>>,
  DocumentReference<Map<String, dynamic>>,
  CollectionReference<Map<String, dynamic>>,
  QuerySnapshot<Map<String, dynamic>>,
  QueryDocumentSnapshot<Map<String, dynamic>>,
  AuthCubit,
  DataCubit,
  WriteBatch,
])
void main() {}