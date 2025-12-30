import 'package:flutter/material.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_textfield.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

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

                      const CustomTextField(
                        hint: "Full Name",
                        icon: Icons.person,
                      ),
                      const SizedBox(height: 16),

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
                      const SizedBox(height: 16),

                      const CustomTextField(
                        hint: "Confirm Password",
                        icon: Icons.lock_outline,
                        isPassword: true,
                      ),
                      const SizedBox(height: 24),

                      CustomButton(
                        text: "Register",
                        onPressed: () {},
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
