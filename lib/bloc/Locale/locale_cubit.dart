import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class LocaleCubit extends Cubit<Locale> {
  final FirebaseAuth _auth;
  final FirebaseFirestore _db;

  LocaleCubit(this._auth, this._db) : super(_deviceLocale()) {
    _auth.authStateChanges().listen((user) {
      if (user == null) {
        emit(_deviceLocale());
      } else {
        _db
            .collection('users')
            .doc(user.uid)
            .get()
            .then((snap) {
              final code = snap.data()?['settings']?['locale'] as String?;
              if (code != null && ['en', 'de', 'ar'].contains(code)) {
                emit(Locale(code));
              }
            })
            .catchError((_) {
              emit(_deviceLocale());
            });
      }
    });
  }

  static Locale _deviceLocale() {
    final device = WidgetsBinding.instance.window.locale;
    return ['en', 'de', 'ar'].contains(device.languageCode)
        ? Locale(device.languageCode)
        : const Locale('en');
  }

  Future<void> setLocale(Locale locale) async {
    emit(locale);
    final user = _auth.currentUser;
    if (user != null) {
      await _db.collection('users').doc(user.uid).set({
        'settings': {'locale': locale.languageCode},
      }, SetOptions(merge: true));
    }
  }
}
