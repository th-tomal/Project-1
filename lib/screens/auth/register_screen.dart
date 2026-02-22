import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/auth_service.dart';
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

  final AuthService _authService = AuthService();
  bool isLoading = false;

  String? nameError;
  String? emailError;
  String? passwordError;
  String? confirmPasswordError;

  bool _isValidEmail(String email) {
    final emailRegex =
        RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blueAccent, Colors.indigo],
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
                    children: [
                      const Text("Create Account",
                          style: TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 20),

                      CustomTextField(
                        hint: "Full Name",
                        icon: Icons.person,
                        controller: nameController,
                        errorText: nameError,
                      ),
                      const SizedBox(height: 16),

                      CustomTextField(
                        hint: "Email",
                        icon: Icons.email,
                        controller: emailController,
                        errorText: emailError,
                      ),
                      const SizedBox(height: 16),

                      CustomTextField(
                        hint: "Password",
                        icon: Icons.lock,
                        isPassword: true,
                        controller: passwordController,
                        errorText: passwordError,
                      ),
                      const SizedBox(height: 16),

                      CustomTextField(
                        hint: "Confirm Password",
                        icon: Icons.lock_outline,
                        isPassword: true,
                        controller: confirmPasswordController,
                        errorText: confirmPasswordError,
                      ),
                      const SizedBox(height: 24),

                      CustomButton(
                        text: isLoading ? "Registering..." : "Register",
                        onPressed: isLoading ? null : _handleRegister,
                      ),

                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: () => Navigator.pop(context),
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

  Future<void> _handleRegister() async {
    final name = nameController.text.trim();
    final email = emailController.text.trim().toLowerCase();
    final password = passwordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();

    setState(() {
      nameError = null;
      emailError = null;
      passwordError = null;
      confirmPasswordError = null;
    });

    if (name.isEmpty) {
      setState(() => nameError = "Full name required");
      return;
    }

    if (!_isValidEmail(email)) {
      setState(() => emailError = "Enter valid email address");
      return;
    }

    if (password.length < 6) {
      setState(() => passwordError = "Minimum 6 characters required");
      return;
    }

    if (password != confirmPassword) {
      setState(() => confirmPasswordError = "Passwords do not match");
      return;
    }

    setState(() => isLoading = true);

    try {
      await _authService.register(
        name: name,
        email: email,
        password: password,
      );

      if (!mounted) return;
      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      setState(() {
        if (e.code == 'email-already-in-use') {
          emailError = "Email already registered";
        } else {
          emailError = "Registration failed";
        }
      });
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }
}
