import 'package:budgetbuddy/Elements/header_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        HeaderBar(title: AppLocalizations.of(context)!.helpScreen_title),
        Expanded(
          child: Center(
            child: Text(
              AppLocalizations.of(context)!.helpScreen_label,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }
}
