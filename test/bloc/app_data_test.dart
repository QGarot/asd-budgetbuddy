import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:budgetbuddy/AppData/app_colors.dart';
import 'package:budgetbuddy/AppData/layout_constants.dart';
import 'package:budgetbuddy/AppData/category_icons.dart';

void main() {
  test('AppColors constants should match expected values', () {
    expect(AppColors.primaryColor, Colors.deepPurpleAccent);
    expect(AppColors.dangerColor, Colors.redAccent);
    expect(AppColors.yellowColor, const Color(0xFFFFAB00));
  });

  testWidgets('AppColors.primaryFaint gets used in a widget', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Container(color: AppColors.primaryFaint),
        ),
      ),
    );

    final container = tester.widget<Container>(find.byType(Container));
    expect(container.color, AppColors.primaryFaint);
  });

  testWidgets('LayoutConstants covers all sidebar and card width logic', (tester) async {
    Future<void> pumpAndTestWidth(double screenWidth) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: MediaQueryData(size: Size(screenWidth, 600)),
            child: Builder(
              builder: (context) {
                final sidebarWidth = LayoutConstants.getSidebarWidth(context);
                final cardWidth = LayoutConstants.getCardWidth(context);

                if (screenWidth * LayoutConstants.sidebarWidthProcent < LayoutConstants.minSidebarWidth) {
                  expect(sidebarWidth, LayoutConstants.minSidebarWidth);
                } else if (screenWidth * LayoutConstants.sidebarWidthProcent > LayoutConstants.maxSidebarWidth) {
                  expect(sidebarWidth, LayoutConstants.maxSidebarWidth);
                } else {
                  expect(sidebarWidth, screenWidth * LayoutConstants.sidebarWidthProcent);
                }

                if (screenWidth * LayoutConstants.cardWidthProcent < LayoutConstants.minCardWidth) {
                  expect(cardWidth, LayoutConstants.minCardWidth);
                } else {
                  expect(cardWidth, screenWidth * LayoutConstants.cardWidthProcent);
                }

                return const Placeholder();
              },
            ),
          ),
        ),
      );
    }

    await pumpAndTestWidth(400);  // Triggers min width logic
    await pumpAndTestWidth(1200); // Triggers max width logic
    await pumpAndTestWidth(1050);
    await pumpAndTestWidth(800);  // Triggers normal proportional logic
  });

  test('CategoryIcons returns correct icons', () {
    expect(CategoryIcons.getIcon('Groceries'), Icons.shopping_cart);
    expect(CategoryIcons.getIcon('Rent'), Icons.home);
    expect(CategoryIcons.getIcon('entertainment'), Icons.movie);
    expect(CategoryIcons.getIcon('Dining'), Icons.restaurant);
    expect(CategoryIcons.getIcon('Utilities'), Icons.electrical_services);
    expect(CategoryIcons.getIcon('Travel'), Icons.flight);
    expect(CategoryIcons.getIcon('Shopping'), Icons.shopping_bag);
    expect(CategoryIcons.getIcon('Unknown'), Icons.category); // fallback
  });
}
