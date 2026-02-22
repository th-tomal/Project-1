import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class StudentTestRegistrationScreen extends StatefulWidget {
  final String testId;
  final String testName;

  const StudentTestRegistrationScreen({
    super.key,
    required this.testId,
    required this.testName,
  });

  @override
  State<StudentTestRegistrationScreen> createState() =>
      _StudentTestRegistrationScreenState();
}

class _StudentTestRegistrationScreenState
    extends State<StudentTestRegistrationScreen> {

  final _formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final studentIdController = TextEditingController();
  final phoneController = TextEditingController();

  bool loading = false;
  bool alreadyRegistered = false;
  bool registrationClosed = false;

  @override
  void initState() {
    super.initState();
    checkIfRegistered();
    checkIfClosed();
  }

  Future<void> checkIfClosed() async {
    final testDoc = await FirebaseFirestore.instance
        .collection('tests')
        .doc(widget.testId)
        .get();

    if (!testDoc.exists) return;

    final data = testDoc.data()!;
    final Timestamp testDate = data["date"];

    if (DateTime.now().isAfter(testDate.toDate())) {
      setState(() {
        registrationClosed = true;
      });
    }
  }

  Future<void> checkIfRegistered() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    final doc = await FirebaseFirestore.instance
        .collection('tests')
        .doc(widget.testId)
        .collection('registrations')
        .doc(uid)
        .get();

    if (doc.exists) {
      final data = doc.data()!;

      setState(() {
        alreadyRegistered = true;

        nameController.text = data["studentName"] ?? "";
        studentIdController.text = data["studentId"] ?? "";
        phoneController.text = data["phone"] ?? "";
      });
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    studentIdController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  Future<void> register() async {
    if (!_formKey.currentState!.validate()) return;

    if (registrationClosed) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Registration Closed.")),
      );
      return;
    }

    setState(() => loading = true);

    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;

      final registrationRef = FirebaseFirestore.instance
          .collection('tests')
          .doc(widget.testId)
          .collection('registrations')
          .doc(uid);

      final existingDoc = await registrationRef.get();

      if (existingDoc.exists) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Already registered.")),
        );
        setState(() {
          alreadyRegistered = true;
          loading = false;
        });
        return;
      }

      await registrationRef.set({
        "studentName": nameController.text.trim(),
        "studentId": studentIdController.text.trim(),
        "phone": phoneController.text.trim(),
        "registeredAt": FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Successfully Registered")),
      );

      setState(() {
        alreadyRegistered = true;
      });

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }

    if (mounted) setState(() => loading = false);
  }

  Widget buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: TextFormField(
        controller: controller,
        enabled: !alreadyRegistered && !registrationClosed,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.indigo),
          filled: true,
          fillColor: alreadyRegistered || registrationClosed
              ? Colors.grey.shade200
              : Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        validator: (value) =>
            value == null || value.isEmpty
                ? "Required field"
                : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      appBar: AppBar(
        title: Text("Register: ${widget.testName}"),
        backgroundColor: Colors.indigo,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Card(
          elevation: 6,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                children: [

                  if (registrationClosed)
                    const Text(
                      "Registration Closed ❌",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),

                  if (alreadyRegistered)
                    const Text(
                      "Registered ✔",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),

                  const SizedBox(height: 20),

                  buildTextField(
                    controller: nameController,
                    label: "Full Name",
                    icon: Icons.person_outline,
                  ),

                  buildTextField(
                    controller: studentIdController,
                    label: "Student ID",
                    icon: Icons.badge_outlined,
                  ),

                  buildTextField(
                    controller: phoneController,
                    label: "Phone Number",
                    icon: Icons.phone_outlined,
                  ),

                  const SizedBox(height: 20),

                  if (!alreadyRegistered && !registrationClosed)
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.indigo,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        onPressed: loading ? null : register,
                        child: loading
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : const Text(
                                "CONFIRM REGISTRATION",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
