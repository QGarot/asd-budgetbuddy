import 'package:flutter/material.dart';
import 'package:budgetbuddy/Elements/header_bar.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        HeaderBar(title: "Help"),
        Expanded(
          child: Center(
            child: Text(
              '❓ Help Screen',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }
}