import 'package:flutter/material.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/dashboard/dashboard_screen.dart';
import '../screens/dashboard/student_dashboard.dart';
import '../screens/dashboard/teacher_dashboard.dart';

class AppRoutes {
  static Map<String, WidgetBuilder> routes = {
    '/login': (context) => const LoginScreen(),
    '/register': (context) => const RegisterScreen(),
    '/dashboard': (context) => const DashboardScreen(),
    '/adminDashboard': (context) => const DashboardScreen(),
    '/studentDashboard': (context) => const StudentDashboard(),
    '/teacherDashboard': (context) => const TeacherDashboard(),
  };
}
