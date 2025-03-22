import 'package:budgetbuddy/AppData/app_data.dart';
import 'package:budgetbuddy/bloc/CounterScreen/counter_cubit.dart';
import 'package:budgetbuddy/bloc/CounterScreen/counter_event.dart';
import 'package:budgetbuddy/pojos/counter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CounterDisplay extends StatelessWidget {
  const CounterDisplay({super.key});
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CounterCubit, Counter>(
      builder: (context, counter) {
        return Text(
          "Counter: ${counter.value}",
          style: TextStyle(fontSize: 24),
        );
      },
    );
  }
}

class CounterScreen extends StatelessWidget {
  const CounterScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("First Page")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CounterDisplay(),
            ElevatedButton(
              onPressed: () => CounterEvent.increment(context),
              child: Text("Increment Counter"),
            ),
            Text(UserData.firestoreUserData!.email),
            Text(UserData.firestoreUserData!.username),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/text'),
              child: Text("Go to Second Page"),
            ),
          ],
        ),
      ),
    );
  }
}
