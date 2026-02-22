import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';

import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/dashboard/dashboard_screen.dart';
import 'screens/dashboard/student_dashboard.dart';
import 'screens/dashboard/teacher_dashboard.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const SmartCoachApp());
}

class SmartCoachApp extends StatelessWidget {
  const SmartCoachApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SmartCoach',
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/adminDashboard': (context) => const DashboardScreen(),
        '/studentDashboard': (context) => const StudentDashboard(),
        '/teacherDashboard': (context) => const TeacherDashboard(),
      },
    );
  }
}
