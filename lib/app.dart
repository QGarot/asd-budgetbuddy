import 'package:budgetbuddy/bloc/Locale/locale_cubit.dart';
import 'package:budgetbuddy/screens/loading_screen.dart';
import 'package:budgetbuddy/screens/login_screen.dart';
import 'package:budgetbuddy/screens/main_screen.dart';
import 'package:budgetbuddy/screens/signup_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LocaleCubit, Locale>(
      builder: (context, locale) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Budget Buddy',
          locale: locale,

          supportedLocales: const [
            Locale('en'),
            Locale('de'),
            Locale('ar'),
            Locale('he'),
            Locale('sty'),
          ],

          localizationsDelegates: const [
            AppLocalizations.delegate,
            _StyAwareMaterialDelegate(),
            GlobalWidgetsLocalizations.delegate,
            _StyAwareCupertinoDelegate(),
          ],

          routes: {
            '/': (context) {
              final user = FirebaseAuth.instance.currentUser;
              return user == null ? const LoginScreen() : const LoadingScreen();
            },
            '/loading': (context) => const LoadingScreen(),
            '/login': (context) => const LoginScreen(),
            '/signup': (context) => const SignupScreen(),
            '/home': (context) => const MainScreen(),
          },
        );
      },
    );
  }
}

class _StyAwareMaterialDelegate
    extends LocalizationsDelegate<MaterialLocalizations> {
  const _StyAwareMaterialDelegate();

  @override
  bool isSupported(Locale locale) {
    return locale.languageCode == 'sty' ||
        GlobalMaterialLocalizations.delegate.isSupported(locale);
  }

  @override
  Future<MaterialLocalizations> load(Locale locale) {
    if (locale.languageCode == 'sty') {
      return GlobalMaterialLocalizations.delegate.load(const Locale('de'));
    }
    return GlobalMaterialLocalizations.delegate.load(locale);
  }

  @override
  bool shouldReload(LocalizationsDelegate<MaterialLocalizations> old) => false;
}

class _StyAwareCupertinoDelegate
    extends LocalizationsDelegate<CupertinoLocalizations> {
  const _StyAwareCupertinoDelegate();

  @override
  bool isSupported(Locale locale) {
    return locale.languageCode == 'sty' ||
        GlobalCupertinoLocalizations.delegate.isSupported(locale);
  }

  @override
  Future<CupertinoLocalizations> load(Locale locale) {
    if (locale.languageCode == 'sty') {
      return GlobalCupertinoLocalizations.delegate.load(const Locale('de'));
    }
    return GlobalCupertinoLocalizations.delegate.load(locale);
  }

  @override
  bool shouldReload(LocalizationsDelegate<CupertinoLocalizations> old) => false;
}
