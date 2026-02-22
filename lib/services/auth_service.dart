import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/constants.dart';
import '../utils/user_roles.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ================= REGISTER =================
  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user!;
      final uid = user.uid;

      final role = email.toLowerCase() == adminEmail
          ? UserRole.admin.value
          : UserRole.student.value;

      // 🔥 Send email verification only for NON-admin
      if (email.toLowerCase() != adminEmail) {
        await user.sendEmailVerification();
      }

      await _db.collection("users").doc(uid).set({
        "name": name,
        "email": email,
        "role": role,
        "createdAt": FieldValue.serverTimestamp(),
      });

    } on FirebaseAuthException catch (e) {
      throw Exception(e.message ?? "Registration failed");
    }
  }

  // ================= LOGIN =================
  Future<void> login({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message ?? "Login failed");
    }
  }

  // ================= FORGOT PASSWORD =================
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message ?? "Failed to send reset email");
    }
  }

  // ================= RESEND VERIFICATION =================
  Future<void> resendVerificationEmail() async {
    final user = _auth.currentUser;
    if (user != null && !user.emailVerified) {
      await user.sendEmailVerification();
    }
  }

  // ================= GET ROLE =================
  Future<String> getUserRole() async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception("User not logged in");
    }

    final doc =
        await _db.collection("users").doc(user.uid).get();

    if (!doc.exists) {
      throw Exception("User profile not found");
    }

    final data = doc.data();

    if (data == null || !data.containsKey("role")) {
      throw Exception("User role missing");
    }

    return data["role"] as String;
  }

  // ================= LOGOUT =================
  Future<void> logout() async {
    await _auth.signOut();
  }
}
