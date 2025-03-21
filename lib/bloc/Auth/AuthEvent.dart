import 'package:budgetbuddy/bloc/Auth/AuthBloc.dart';
import 'package:budgetbuddy/pojos/UserAuth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AuthEvent {
  static void signUp(BuildContext context, String email, String password) {
    context.read<AuthCubit>().signUp(email, password);
  }

  static void signIn(BuildContext context, String email, String password) {
    context.read<AuthCubit>().signIn(email, password);
  }

  static void signOut(BuildContext context) {
    context.read<AuthCubit>().signOut();
  }

  static UserAuth? getCredentials(BuildContext context) {
    return context.read<AuthCubit>().getCredentials();
  }

  static bool isLoggedIn(BuildContext context) {
    return context.read<AuthCubit>().isLoggedIn();
  }
}
