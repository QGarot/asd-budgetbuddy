import 'package:budgetbuddy/AppData/app_colors.dart';
import 'package:budgetbuddy/AppData/ui_constants.dart';
import 'package:flutter/material.dart';

class StandardDialogBox extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget content;
  final List<Widget> actions;
  final IconData? icon;
  final double maxWidth;

  const StandardDialogBox({
    super.key,
    required this.title,
    required this.subtitle,
    required this.content,
    required this.actions,
    this.icon,
    this.maxWidth = 550,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      elevation: 0,
      insetPadding: const EdgeInsets.all(24),
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: BoxConstraints(maxWidth: maxWidth),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: UIConstants.standardShadow,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 20),
              decoration: const BoxDecoration(
                color: AppColors.primaryColor,
                borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
              ),
              child: Column(
                children: [
                  if (icon != null) Icon(icon, size: 48, color: Colors.white),
                  const SizedBox(height: 8),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    subtitle,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),

            // Body content with extra top margin
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 30, 20, 0),
              child: content,
            ),

            // Actions with tight bottom margin
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: actions,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Shared form field for all dialog boxes
  static Widget buildStandardFormField({
    required TextEditingController controller,
    required String label,
    String? hint,
    bool obscureText = false,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    Widget? prefixIcon,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: prefixIcon,
        border: const OutlineInputBorder(),
      ),
    );
  }

  static Widget buildStandardForm({
    required GlobalKey<FormState> formKey,
    required Widget child,
  }) {
    return Form(
      key: formKey,
      autovalidateMode: AutovalidateMode.disabled,
      child: child,
    );
  }
}
