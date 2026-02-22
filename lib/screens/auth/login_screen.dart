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

  String? emailError;
  String? passwordError;

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
      resizeToAvoidBottomInset: true,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.indigo, Colors.blueAccent],
            ),
          ),
          child: Center(
            child: SingleChildScrollView(
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
                      const Icon(Icons.school,
                          size: 60, color: Colors.indigo),
                      const SizedBox(height: 10),
                      const Text("SmartCoach",
                          style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold)),
                      const SizedBox(height: 6),
                      const Text("Login to continue",
                          style: TextStyle(color: Colors.grey)),
                      const SizedBox(height: 24),

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
                      const SizedBox(height: 10),

                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: _handleForgotPassword,
                          child: const Text("Forgot Password?"),
                        ),
                      ),

                      const SizedBox(height: 10),

                      CustomButton(
                        text: isLoading
                            ? "Logging in..."
                            : "Login",
                        onPressed:
                            isLoading ? null : _handleLogin,
                      ),

                      const SizedBox(height: 10),

                      TextButton(
                        onPressed: () {
                          Navigator.pushNamed(
                              context, '/register');
                        },
                        child:
                            const Text("Create new account"),
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

  // ================= LOGIN =================
  Future<void> _handleLogin() async {
    FocusScope.of(context).unfocus();

    final email =
        emailController.text.trim().toLowerCase();
    final password =
        passwordController.text.trim();

    setState(() {
      emailError = null;
      passwordError = null;
    });

    if (!_isValidEmail(email)) {
      setState(
          () => emailError = "Enter valid email address");
      return;
    }

    if (password.isEmpty) {
      setState(() => passwordError = "Password required");
      return;
    }

    setState(() => isLoading = true);

    try {
      await _authService.login(
          email: email, password: password);

      final user =
          FirebaseAuth.instance.currentUser;

      if (email != adminEmail) {
        if (user != null && !user.emailVerified) {
          await FirebaseAuth.instance.signOut();
          throw FirebaseAuthException(
              code: 'email-not-verified');
        }
      }

      final role =
          await _authService.getUserRole();

      if (!mounted) return;

      switch (role) {
        case "admin":
          Navigator.pushReplacementNamed(
              context, '/adminDashboard');
          break;
        case "teacher":
          Navigator.pushReplacementNamed(
              context, '/teacherDashboard');
          break;
        default:
          Navigator.pushReplacementNamed(
              context, '/studentDashboard');
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        if (e.code == 'user-not-found') {
          emailError = "Email not found";
        } else if (e.code == 'wrong-password') {
          passwordError = "Incorrect password";
        } else if (e.code == 'invalid-email') {
          emailError = "Invalid email format";
        } else if (e.code == 'email-not-verified') {
          emailError =
              "Please verify your email first";
        } else {
          passwordError =
              "Email or password is incorrect";
        }
      });
    } finally {
      if (mounted)
        setState(() => isLoading = false);
    }
  }

  // ================= FORGOT PASSWORD =================
  Future<void> _handleForgotPassword() async {
    FocusScope.of(context).unfocus();

    final email =
        emailController.text.trim().toLowerCase();

    if (!_isValidEmail(email)) {
      setState(
          () => emailError = "Enter valid email first");
      return;
    }

    try {
      await _authService
          .sendPasswordResetEmail(email);
      setState(() =>
          emailError = "Password reset email sent");
    } catch (_) {
      setState(() =>
          emailError = "Failed to send reset email");
    }
  }
}
