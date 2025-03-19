import 'package:budgetbuddy/app.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  //await Firebase.initializeApp(
  //  options: DefaultFirebaseOptions.currentPlatform,
  //);

  //EMULATOR for firebase
  // FirebaseFunctions.instance.useFunctionsEmulator('localhost', 5001);

  runApp(const App());
}
