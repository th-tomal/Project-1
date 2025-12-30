import 'package:flutter/material.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_textfield.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

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
                    const SizedBox(height: 24),

                    CustomButton(
                      text: "Login",
                      onPressed: () {},
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
}
