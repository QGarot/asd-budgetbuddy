import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:budgetbuddy/AppData/app_colors.dart';
import 'package:budgetbuddy/Elements//message_to_user.dart'; // adapte selon ton projet

void main() {
  testWidgets('MessageToUser.showMessage displays a SnackBar with correct text and color', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () {
                  MessageToUser.showMessage(context, 'Hello user!');
                },
                child: Text('Show'),
              );
            },
          ),
        ),
      ),
    );

    await tester.tap(find.text('Show'));
    await tester.pump();

    expect(find.text('Hello user!'), findsOneWidget);

    final snackBar = tester.widget<SnackBar>(find.byType(SnackBar));
    expect(snackBar.backgroundColor, equals(AppColors.primaryColor));
    expect(snackBar.duration, equals(Duration(seconds: 2)));
  });
}
