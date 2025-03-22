import 'package:budgetbuddy/bloc/Data/data_bloc.dart';
import 'package:budgetbuddy/pojos/firebase_user_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DataEvent {
  //gets the data as it was last fetched from firestore
  static FirestoreUserData? getFirebaseUserData(BuildContext context) {
    return context.read<DataCubit>().getFirebaseUserData();
  }

  //Loads the user data fresh from firestore
  static Future<FirestoreUserData?> fetchFirebaseUserData(
    BuildContext context,
  ) async {
    return await context.read<DataCubit>().fetchFirebaseUserData();
  }
}
