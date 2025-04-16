import 'package:flutter/material.dart';
import 'package:budgetbuddy/Elements/header_bar.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        HeaderBar(title: "Settings"),
        Expanded(
          child: Center(
            child: Text(
              '⚙️ Settings Screen',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }
}