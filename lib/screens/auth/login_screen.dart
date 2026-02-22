import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/auth_service.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_textfield.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthService _authService = AuthService();

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool isLoading = false;

  static const String adminEmail = "admin@smartcoach.com";

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  bool _isValidEmail(String email) {
    final emailRegex =
        RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }

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
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 24),

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
                    const SizedBox(height: 10),

                    // 🔥 FORGOT PASSWORD BUTTON
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: _handleForgotPassword,
                        child: const Text("Forgot Password?"),
                      ),
                    ),

                    const SizedBox(height: 10),

                    CustomButton(
                      text: isLoading ? "Logging in..." : "Login",
                      onPressed: isLoading ? null : _handleLogin,
                    ),

                    const SizedBox(height: 10),

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

  // ================= LOGIN FUNCTION =================
  Future<void> _handleLogin() async {
    final email = emailController.text.trim().toLowerCase();
    final password = passwordController.text.trim();

    if (!_isValidEmail(email)) {
      _showMessage("Enter valid email address");
      return;
    }

    if (password.isEmpty) {
      _showMessage("Password required");
      return;
    }

    setState(() => isLoading = true);

    try {
      await _authService.login(
        email: email,
        password: password,
      );

      final user = FirebaseAuth.instance.currentUser;

      // 🔥 Skip verification only for admin
      if (email != adminEmail) {
        if (user != null && !user.emailVerified) {
          await FirebaseAuth.instance.signOut();
          throw "Please verify your email before logging in.";
        }
      }

      final role = await _authService.getUserRole();

      if (!mounted) return;

      switch (role) {
        case "admin":
          Navigator.pushReplacementNamed(context, '/adminDashboard');
          break;
        case "teacher":
          Navigator.pushReplacementNamed(context, '/teacherDashboard');
          break;
        default:
          Navigator.pushReplacementNamed(context, '/studentDashboard');
      }
    } catch (e) {
      _showMessage(e.toString().replaceAll("Exception:", ""));
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  // ================= FORGOT PASSWORD =================
  Future<void> _handleForgotPassword() async {
    final email = emailController.text.trim().toLowerCase();

    if (!_isValidEmail(email)) {
      _showMessage("Enter your registered email first");
      return;
    }

    try {
      await _authService.sendPasswordResetEmail(email);
      _showMessage("Password reset email sent!");
    } catch (e) {
      _showMessage(e.toString().replaceAll("Exception:", ""));
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
