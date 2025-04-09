import 'package:flutter/material.dart';
import 'package:budgetbuddy/AppData/ui_constants.dart';

class StandardDropdownField<T> extends StatelessWidget {
  final String label;
  final T? selectedValue;
  final List<T> items;
  final ValueChanged<T?> onChanged;
  final String Function(T) itemLabel;
  final IconData? Function(T)? itemIcon;
  final double itemHeight;
  final double menuWidth;

  const StandardDropdownField({
    super.key,
    required this.label,
    required this.selectedValue,
    required this.items,
    required this.onChanged,
    required this.itemLabel,
    this.itemIcon,
    this.itemHeight = 48,
    this.menuWidth = 200,
  });

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (ctx) {
        final GlobalKey fieldKey = GlobalKey();

        return GestureDetector(
          onTap: () async {
            final RenderBox renderBox = fieldKey.currentContext!.findRenderObject() as RenderBox;
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
              items: items.map((item) {
                return PopupMenuItem<T>(
                  value: item,
                  height: itemHeight,
                  child: Row(
                    children: [
                      if (itemIcon != null && itemIcon!(item) != null)
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: Icon(itemIcon!(item), size: 18),
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
}