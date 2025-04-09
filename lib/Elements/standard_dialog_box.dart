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

            // Body
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 30, 20, 0),
              child: content,
            ),

            // Actions
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

  static Widget buildDropdownField<T>({
    required T? selectedValue,
    required List<T> items,
    required ValueChanged<T?> onChanged,
    required String Function(T) itemLabel,
    IconData? Function(T)? itemIcon,
    double itemHeight = 48,
    double menuWidth = 200,
    String? label,
  }) {
    return Builder(
      builder: (ctx) {
        final GlobalKey fieldKey = GlobalKey();

        return GestureDetector(
          onTap: () async {
            final RenderBox renderBox =
                fieldKey.currentContext!.findRenderObject() as RenderBox;
            final Offset offset = renderBox.localToGlobal(Offset.zero);
            final Rect position = offset & renderBox.size;

            final selected = await showMenu<T>(
              context: ctx, // <- fix is here
              position: RelativeRect.fromLTRB(
                position.left,
                position.bottom + 4,
                position.left + menuWidth,
                0,
              ),
              items:
                  items.map((item) {
                    return PopupMenuItem<T>(
                      value: item,
                      height: itemHeight,
                      child: Row(
                        children: [
                          if (itemIcon != null && itemIcon(item) != null)
                            Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: Icon(itemIcon(item), size: 18),
                            ),
                          Text(itemLabel(item)),
                        ],
                      ),
                    );
                  }).toList(),
              color: Colors.white,
              elevation: 10,
              shape: RoundedRectangleBorder(
                borderRadius: UIConstants.borderRadius,
              ),
            );

            if (selected != null) {
              onChanged(selected);
            }
          },
          child: InputDecorator(
            key: fieldKey,
            decoration: InputDecoration(
              labelText: label,
              border: const OutlineInputBorder(),
              suffixIcon: const Icon(Icons.arrow_drop_down),
              isDense: true,
            ),
            child: Text(
              selectedValue != null ? itemLabel(selectedValue as T) : '',
              style: const TextStyle(fontSize: 16),
            ),
          ),
        );
      },
    );
  }

  static Widget buildStandardDropdown<T>({
    required BuildContext context,
    required String label,
    required T? selectedValue,
    required List<T> items,
    required ValueChanged<T?> onChanged,
    required String Function(T) itemLabel,
    IconData? Function(T)? itemIcon,
    double itemHeight = 48,
    double menuWidth = 200,
  }) {
    final GlobalKey fieldKey = GlobalKey();

    return Builder(
      builder:
          (ctx) => GestureDetector(
            onTap: () async {
              final RenderBox renderBox =
                  fieldKey.currentContext!.findRenderObject() as RenderBox;
              final Offset offset = renderBox.localToGlobal(Offset.zero);
              final Rect position = offset & renderBox.size;

              final selected = await showMenu<T>(
                context: context,
                position: RelativeRect.fromLTRB(
                  position.left,
                  position.bottom + 4,
                  position.left + menuWidth,
                  0,
                ),
                items:
                    items.map((item) {
                      return PopupMenuItem<T>(
                        value: item,
                        height: itemHeight,
                        child: Row(
                          children: [
                            if (itemIcon != null && itemIcon(item) != null)
                              Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: Icon(itemIcon(item), size: 18),
                              ),
                            Text(itemLabel(item)),
                          ],
                        ),
                      );
                    }).toList(),
                color: Colors.white,
                elevation: 10,
                shape: RoundedRectangleBorder(
                  borderRadius: UIConstants.borderRadius,
                ),
              );

              if (selected != null) {
                onChanged(selected);
              }
            },
            child: InputDecorator(
              key: fieldKey,
              decoration: InputDecoration(
                labelText: label,
                border: const OutlineInputBorder(),
                suffixIcon: const Icon(Icons.arrow_drop_down),
                isDense: true,
              ),
              child: Text(
                selectedValue != null ? itemLabel(selectedValue) : '',
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ),
    );
  }
}
