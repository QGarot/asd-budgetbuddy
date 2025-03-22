import 'package:budgetbuddy/bloc/Auth/auth_bloc.dart';
import 'package:budgetbuddy/pojos/user_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AuthEvent {
  static Future<void> signUp(
    BuildContext context,
    UserRegistrationInfo userRegistrationInfo,
  ) async {
    await context.read<AuthCubit>().signUp(userRegistrationInfo);
  }

  static Future<void> signIn(
    BuildContext context,
    UserLoginInfo userLoginInfo,
  ) async {
    await context.read<AuthCubit>().signIn(userLoginInfo);
  }

  static Future<void> signOut(BuildContext context) async {
    await context.read<AuthCubit>().signOut();
  }

  static AuthUserData? getCredentials(BuildContext context) {
    return context.read<AuthCubit>().getCredentials();
  }

  static bool isLoggedIn(BuildContext context) {
    return context.read<AuthCubit>().isLoggedIn();
  }
}
