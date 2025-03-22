import 'package:budgetbuddy/bloc/TextScreen/text_cubit.dart';
import 'package:budgetbuddy/pojos/text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MessageDisplay extends StatelessWidget {
  const MessageDisplay({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TextCubit, Message>(
      builder: (context, message) {
        return Text(message.text, style: TextStyle(fontSize: 24));
      },
    );
  }
}

class TextScreen extends StatelessWidget {
  const TextScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Second Page")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            MessageDisplay(),
            ElevatedButton(
              onPressed:
                  () => context.read<TextCubit>().changeMessage("New Message"),
              child: Text("Change Message"),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Back to First Page"),
            ),
          ],
        ),
      ),
    );
  }
}
