import 'package:flutter/material.dart';
import 'package:budgetbuddy/AppData/app_colors.dart';
import 'package:budgetbuddy/AppData/ui_constants.dart';



class DashboardHeader extends StatelessWidget {
  const DashboardHeader({
    super.key,
    required this.title,
    required this.subtitle,
    required this.buttonText,
    required this.onPressed,
    this.showButton = true,
  });

  final String title;
  final String subtitle;
  final String buttonText;
  //onpressed of button
  final VoidCallback onPressed;
  // Whether to show the action button
  final bool showButton;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        color: Colors.black87,
                        letterSpacing: -0.5,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFF9E9E9E),
                        fontWeight: FontWeight.w400,
                        height: 1.1,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (showButton)
          Positioned(
            right: 24,
            top: 28,
            child: Container(
              decoration: BoxDecoration(
                boxShadow: UIConstants.standardShadow,
                borderRadius: BorderRadius.circular(24),
              ),
              child: ElevatedButton.icon(
                onPressed: onPressed,
                icon: const Icon(Icons.add, size: 18),
                label: Text(buttonText),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 14,
                  ),
                  textStyle: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
