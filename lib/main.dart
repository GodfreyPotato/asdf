import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:take_home_quiz/firebase_options.dart';
import 'package:take_home_quiz/screens/homeScreen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(TakeHomeQuiz());
}

class TakeHomeQuiz extends StatelessWidget {
  const TakeHomeQuiz({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false, home: HomeScreen());
  }
}
