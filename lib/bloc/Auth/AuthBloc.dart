import 'package:budgetbuddy/pojos/UserAuth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AuthCubit extends Cubit<UserAuth?> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  UserAuth? _userAuth;

  AuthCubit() : super(null) {
    _checkUser();
  }

  void _checkUser() {
    final user = _auth.currentUser;
    if (user != null) {
      _userAuth = UserAuth(uid: user.uid, email: user.email);
      emit(_userAuth);
    }
  }

  void _updateUser(User? user) {
    if (user != null) {
      _userAuth = UserAuth(uid: user.uid, email: user.email);
      emit(_userAuth);
    }
  }

  Future<void> signUp(String email, String password) async {
    try {
      final UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);
      _updateUser(userCredential.user);
    } catch (e) {
      print("Sign Up Error: $e");
    }
  }

  Future<void> signIn(String email, String password) async {
    try {
      final UserCredential userCredential = await _auth
          .signInWithEmailAndPassword(email: email, password: password);
      _updateUser(userCredential.user);
    } catch (e) {
      print("Login Error: $e");
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    _userAuth = null;
    emit(null);
  }

  UserAuth? getCredentials() {
    return _userAuth;
  }

  bool isLoggedIn() {
    return _userAuth != null;
  }
}
