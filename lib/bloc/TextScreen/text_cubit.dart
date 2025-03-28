import 'package:budgetbuddy/pojos/text.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TextCubit extends Cubit<Message> {
  TextCubit() : super(Message("Hello from Second Page"));
  void changeMessage(String message) => emit(Message(message));
}
