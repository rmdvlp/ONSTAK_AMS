import 'package:flutter/material.dart';
import 'package:reedling/dashboard_screen.dart';
import 'package:reedling/detailed-view.dart';
import 'package:reedling/welcome_screen.dart';
import 'onboarding.dart';
Future<void> main() async {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final String initialRoute;
  MyApp({this.initialRoute});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        initialRoute: WelcomeScreen.id,

        routes: {
          OnBoardingPage.id: (context) => OnBoardingPage(),
          WelcomeScreen.id: (context) => WelcomeScreen(),
          DashboardScreen.id:(context) => DashboardScreen(),
          detail.id:(context) => detail(),
        }
    );
  }
}
