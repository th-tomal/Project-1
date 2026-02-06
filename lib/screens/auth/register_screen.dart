import 'package:flutter/material.dart';
import '../../utils/constants.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_textfield.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blueAccent, Colors.indigo],
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
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
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        "Create Account",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),

                      CustomTextField(
                        hint: "Full Name",
                        icon: Icons.person,
                        controller: nameController,
                      ),
                      const SizedBox(height: 16),

                      CustomTextField(
                        hint: "Email",
                        icon: Icons.email,
                        controller: emailController,
                      ),
                      const SizedBox(height: 16),

                      CustomTextField(
                        hint: "Password",
                        icon: Icons.lock,
                        isPassword: true,
                        controller: passwordController,
                      ),
                      const SizedBox(height: 16),

                      CustomTextField(
                        hint: "Confirm Password",
                        icon: Icons.lock_outline,
                        isPassword: true,
                        controller: confirmPasswordController,
                      ),
                      const SizedBox(height: 24),

                      CustomButton(
                        text: "Register",
                        onPressed: () {
                          final String email =
                              emailController.text.trim().toLowerCase();

                          // 🔒 Basic validation
                          if (passwordController.text !=
                              confirmPasswordController.text) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text("Passwords do not match")),
                            );
                            return;
                          }

                          // 🧠 ROLE DECISION
                          String role;
                          if (email == adminEmail) {
                            role = "admin";
                          } else {
                            role = "student";
                          }

                          // TEMP: show role result
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("Registered as: $role"),
                            ),
                          );

                          // 🔀 Navigate based on role
                          if (role == "admin") {
                            Navigator.pushReplacementNamed(
                                context, '/adminDashboard');
                          } else {
                            Navigator.pushReplacementNamed(
                                context, '/studentDashboard');
                          }
                        },
                      ),

                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text("Already have an account? Login"),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
