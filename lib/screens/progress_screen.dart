import 'package:flutter/material.dart';
import 'package:budgetbuddy/Elements/header_bar.dart';


class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          HeaderBar(title: "Progress"),
          Expanded(
            child: Center(
              child: Text(
                '📈 Progress Screen',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      );
    }
}