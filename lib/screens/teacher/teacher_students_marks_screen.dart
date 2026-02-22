import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'marks_entry_screen.dart';

class TeacherStudentsMarksScreen extends StatelessWidget {
  final String testId;
  final String testName;
  final String testType;

  const TeacherStudentsMarksScreen({
    super.key,
    required this.testId,
    required this.testName,
    required this.testType,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(testName),
        backgroundColor: Colors.indigo,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("tests")
            .doc(testId)
            .collection("registrations")
            .orderBy("registeredAt", descending: true)
            .snapshots(),
        builder: (context, snapshot) {

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No students registered"));
          }

          final students = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: students.length,
            itemBuilder: (context, index) {
              final studentDoc = students[index];
              final data = studentDoc.data() as Map<String, dynamic>;

              final studentName = data["studentName"] ?? "No Name";
              final studentId = data["studentId"] ?? "No ID";
              final isMarked = data["marked"] ?? false;

              return Card(
                child: ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Colors.indigo,
                    child: Icon(Icons.person, color: Colors.white),
                  ),
                  title: Text(studentName),
                  subtitle: Text("Student ID: $studentId"),
                  trailing: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          isMarked ? Colors.orange : Colors.indigo,
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => MarksEntryScreen(
                            testId: testId,
                            registrationId: studentDoc.id,
                            studentName: studentName,
                            testType: testType,
                          ),
                        ),
                      );
                    },
                    child: Text(
                      isMarked ? "Edit Marks" : "Enter Marks",
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
