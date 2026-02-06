import 'package:flutter/material.dart';
import 'routes/app_routes.dart';
import 'screens/auth/login_screen.dart';

class SmartCoachApp extends StatelessWidget {
  const SmartCoachApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SmartCoach',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        fontFamily: 'Roboto',
      ),
      routes: AppRoutes.routes,
      home: const LoginScreen(),
    );
  }
}
