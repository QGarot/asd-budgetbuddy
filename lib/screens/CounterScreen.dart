import 'package:budgetbuddy/bloc/CounterScreen/CounterCubit.dart';
import 'package:budgetbuddy/pojos/Counter.dart';
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
              onPressed: () => context.read<CounterCubit>().increment(),
              child: Text("Increment Counter"),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/second'),
              child: Text("Go to Second Page"),
            ),
          ],
        ),
      ),
    );
  }
}
