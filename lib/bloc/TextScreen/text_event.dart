import 'package:budgetbuddy/bloc/TextScreen/text_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TextEvent {
  static void changeMessage(BuildContext context, String message) {
    context.read<TextCubit>().changeMessage(message);
  }
}
