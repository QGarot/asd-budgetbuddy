import 'package:budgetbuddy/app.dart';
import 'package:budgetbuddy/bloc/Auth/auth_bloc.dart';
import 'package:budgetbuddy/bloc/CounterScreen/counter_cubit.dart';
import 'package:budgetbuddy/bloc/Data/data_bloc.dart';
import 'package:budgetbuddy/bloc/Navigation/sidebar_cubit.dart';
import 'package:budgetbuddy/bloc/TextScreen/text_cubit.dart';
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
        BlocProvider(create: (context) => DataCubit()),
        BlocProvider(create: (context) => SidebarCubit()),
      ],
      child: App(),
    ),
  );
}
