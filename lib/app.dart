import 'package:budgetbuddy/IndexScreen.dart';
import 'package:flutter/material.dart';


class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    //final auth = FirebaseAuth.instance;
    //var user = auth.currentUser;

    return MaterialApp(
      // theme: ThemeData(fontFamily: "sfpro"),
      //initialRoute: "/test",
      routes: {
        '/': (context) => const MyHomePage(title: "Hello World"),
        //'/': (context) => user == null ? const LoginScreen() : const LoadingScreen(),
        //'/login': (context) => const LoginScreen(),
        //'/home': (context) => const HomeScreen(),
      },
    );
  }
}
