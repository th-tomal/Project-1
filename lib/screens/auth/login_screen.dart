import 'package:flutter/material.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_textfield.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String selectedRole = 'admin'; // admin / teacher / student

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.indigo, Colors.blueAccent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              elevation: 8,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.school,
                      size: 60,
                      color: Colors.indigo,
                    ),
                    const SizedBox(height: 10),

                    const Text(
                      "SmartCoach",
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),

                    Text(
                      "Login to continue",
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                    const SizedBox(height: 24),

                    const CustomTextField(
                      hint: "Email",
                      icon: Icons.email,
                    ),
                    const SizedBox(height: 16),

                    const CustomTextField(
                      hint: "Password",
                      icon: Icons.lock,
                      isPassword: true,
                    ),

                    const SizedBox(height: 20),

                    // 🔽 LOGIN AS SECTION
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Login as",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 8),

                    Row(
                      children: [
                        roleButton("Admin"),
                        roleButton("Teacher"),
                        roleButton("Student"),
                      ],
                    ),

                    const SizedBox(height: 24),

                    CustomButton(
                      text: "Login",
                      onPressed: () {
                        if (selectedRole == 'admin') {
                          Navigator.pushReplacementNamed(
                              context, '/adminDashboard');
                        } else if (selectedRole == 'teacher') {
                          Navigator.pushReplacementNamed(
                              context, '/teacherDashboard');
                        } else {
                          Navigator.pushReplacementNamed(
                              context, '/studentDashboard');
                        }
                      },
                    ),

                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/register');
                      },
                      child: const Text("Create new account"),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // 🔹 ROLE BUTTON WIDGET
  Widget roleButton(String role) {
    final bool isSelected = selectedRole == role.toLowerCase();

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedRole = role.toLowerCase();
          });
        },
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? Colors.indigo : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.indigo),
          ),
          child: Text(
            role,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.indigo,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
