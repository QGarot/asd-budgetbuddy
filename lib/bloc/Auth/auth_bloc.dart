// ignore_for_file: avoid_print

import 'package:budgetbuddy/pojos/user_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AuthCubit extends Cubit<AuthUserData?> {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  AuthUserData? _userAuth;

  AuthCubit({FirebaseAuth? auth, FirebaseFirestore? firestore})
      : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance,
        super(null) {
    _checkUser();
  }

  Future<void> _checkUser() async {
    final user = _auth.currentUser;
    if (user != null) {
      await _updateUser(user);
    }
  }

  Future<void> _updateUser(User? user) async {
    if (user != null) {
     
      _userAuth = AuthUserData(
        uid: user.uid,
        email: user.email,
      );

      emit(_userAuth);
    }
  }

  Future<void> signUp(UserRegistrationInfo credentials) async {
    try {
      final UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(
            email: credentials.email,
            password: credentials.password,
          );

      User? user = userCredential.user;

      if (user != null) {
        await _firestore.collection('users').doc(user.uid).set({
          'username': credentials.userName,
          'email': credentials.email,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      await _updateUser(user);
    } catch (e) {
      print("Sign Up Error: $e");
    }
  }

  Future<void> signIn(UserLoginInfo userLoginInfo) async {
    try {
      final UserCredential userCredential = await _auth
          .signInWithEmailAndPassword(
            email: userLoginInfo.email,
            password: userLoginInfo.password,
          );
      await _updateUser(userCredential.user);
    } catch (e) {
      print("Login Error: $e");
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    _userAuth = null;
    emit(null);
  }

  AuthUserData? getCredentials() {
    return _userAuth;
  }

  bool isLoggedIn() {
    return _userAuth != null;
  }
}
