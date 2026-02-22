import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'teacher_students_marks_screen.dart';

class TeacherAssignedTestsScreen extends StatefulWidget {
  const TeacherAssignedTestsScreen({super.key});

  @override
  State<TeacherAssignedTestsScreen> createState() =>
      _TeacherAssignedTestsScreenState();
}

class _TeacherAssignedTestsScreenState
    extends State<TeacherAssignedTestsScreen> {

  late final String teacherId;

  @override
  void initState() {
    super.initState();
    teacherId = FirebaseAuth.instance.currentUser!.uid;
    print("Teacher UID: $teacherId");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Assigned Tests"),
        backgroundColor: Colors.indigo,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("tests")
            .where("assignedTeacherId", isEqualTo: teacherId)
            .snapshots(),
        builder: (context, snapshot) {

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData) {
            return const Center(child: Text("No data found"));
          }

          final tests = snapshot.data!.docs;

          if (tests.isEmpty) {
            return const Center(
              child: Text(
                "No tests assigned to you",
                style: TextStyle(fontSize: 16),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: tests.length,
            itemBuilder: (context, index) {
              final test = tests[index];
              final data = test.data() as Map<String, dynamic>;

              return Card(
                elevation: 6,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ListTile(
                  title: Text(
                    data["name"] ?? "Test",
                    style: const TextStyle(
                        fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    (data["type"] ?? "").toString().toUpperCase(),
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => TeacherStudentsMarksScreen(
                          testId: test.id,
                          testName: data["name"],
                          testType: data["type"],
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
