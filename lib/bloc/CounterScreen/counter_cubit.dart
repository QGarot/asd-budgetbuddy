import 'package:budgetbuddy/pojos/Counter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CounterCubit extends Cubit<Counter> {
  CounterCubit() : super(Counter(0));
  void increment() => emit(Counter(state.value + 1));
}