import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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

      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          // 🔄 Checking authentication state
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }

          // ❌ User NOT logged in
          if (!snapshot.hasData) {
            return const LoginScreen();
          }

          // ✅ User logged in → check role from Firestore
          return FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance
                .collection("users")
                .doc(snapshot.data!.uid)
                .get(),
            builder: (context, roleSnapshot) {
              if (roleSnapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              if (!roleSnapshot.hasData ||
                  !roleSnapshot.data!.exists) {
                return const LoginScreen();
              }

              final userData =
                  roleSnapshot.data!.data() as Map<String, dynamic>;

              final role = userData["role"];

              if (role == "admin") {
                return const DashboardScreen();
              } else if (role == "teacher") {
                return const TeacherDashboard();
              } else {
                return const StudentDashboard();
              }
            },
          );
        },
      ),

      routes: {
        '/register': (context) => const RegisterScreen(),
        '/adminDashboard': (context) => const DashboardScreen(),
        '/studentDashboard': (context) => const StudentDashboard(),
        '/teacherDashboard': (context) => const TeacherDashboard(),
      },
    );
  }
}
