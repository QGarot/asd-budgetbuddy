import 'package:budgetbuddy/bloc/CounterScreen/CounterCubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CounterEvent {
  static void increment(BuildContext context) {
    context.read<CounterCubit>().increment();
  }
}
