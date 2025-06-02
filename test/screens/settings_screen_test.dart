import 'package:budgetbuddy/Elements/header_bar.dart';
import 'package:budgetbuddy/bloc/Locale/locale_cubit.dart';
import 'package:budgetbuddy/screens/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeLocaleCubit extends Cubit<Locale> implements LocaleCubit {
  _FakeLocaleCubit() : super(const Locale('en'));

  @override
  Future<void> setLocale(Locale locale) async {
    emit(locale);
  }
}

void main() {
  group('SettingsScreen Widget Tests', () {
    testWidgets('displays HeaderBar and localized Settings text', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        BlocProvider<LocaleCubit>(
          create: (_) => _FakeLocaleCubit(),
          child: const MaterialApp(
            localizationsDelegates: [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: [Locale('en'), Locale('de'), Locale('ar')],
            locale: Locale('en'),
            home: Scaffold(body: SettingsScreen()),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(HeaderBar), findsOneWidget);

      expect(find.text('Settings'), findsNWidgets(2));
    });
  });
}
