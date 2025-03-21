import 'package:budgetbuddy/app.dart';
import 'package:budgetbuddy/bloc/Auth/AuthBloc.dart';
import 'package:budgetbuddy/bloc/CounterScreen/CounterCubit.dart';
import 'package:budgetbuddy/bloc/TextScreen/TextCubit.dart';
import 'package:budgetbuddy/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => CounterCubit()),
        BlocProvider(create: (context) => TextCubit()),
        BlocProvider(create: (context) => AuthCubit()),
      ],
      child: App(),
    ),
  );
}
