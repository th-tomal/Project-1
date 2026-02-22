import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AssignStudentsScreen extends StatefulWidget {
  final String courseId;
  final String courseName;

  const AssignStudentsScreen({
    super.key,
    required this.courseId,
    required this.courseName,
  });

  @override
  State<AssignStudentsScreen> createState() =>
      _AssignStudentsScreenState();
}

class _AssignStudentsScreenState
    extends State<AssignStudentsScreen> {

  final FirebaseFirestore _db =
      FirebaseFirestore.instance;

  List<String> enrolledStudents = [];

  @override
  void initState() {
    super.initState();
    _loadEnrolledStudents();
  }

  Future<void> _loadEnrolledStudents() async {
    final doc = await _db
        .collection("courses")
        .doc(widget.courseId)
        .get();

    if (doc.exists) {
      enrolledStudents =
          List<String>.from(doc["students"] ?? []);
      setState(() {});
    }
  }

  Future<void> _addStudent(String studentUid) async {
    await _db
        .collection("courses")
        .doc(widget.courseId)
        .update({
      "students": FieldValue.arrayUnion([studentUid])
    });

    await _loadEnrolledStudents();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Students"),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.indigo, Colors.blueAccent],
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: StreamBuilder<QuerySnapshot>(
          stream: _db
              .collection("users")
              .where("role", isEqualTo: "student")
              .snapshots(),
          builder: (context, snapshot) {

            if (!snapshot.hasData) {
              return const Center(
                  child: CircularProgressIndicator());
            }

            final students = snapshot.data!.docs
                .where((doc) =>
                    !enrolledStudents.contains(doc.id))
                .toList();

            if (students.isEmpty) {
              return const Center(
                child: Text(
                  "All students already enrolled 🎉",
                  style: TextStyle(fontSize: 16),
                ),
              );
            }

            return ListView.builder(
              itemCount: students.length,
              itemBuilder: (context, index) {

                final doc = students[index];
                final data =
                    doc.data() as Map<String, dynamic>;

                final name =
                    data["name"] ?? "No Name";

                final studentId =
                    data["studentId"] ?? "No ID";

                return Container(
                  margin:
                      const EdgeInsets.only(bottom: 15),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey
                            .withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ListTile(
                    contentPadding:
                        const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10),

                    /// Avatar
                    leading: CircleAvatar(
                      backgroundColor:
                          Colors.indigo.shade100,
                      child: Text(
                        name.isNotEmpty
                            ? name[0].toUpperCase()
                            : "S",
                        style: const TextStyle(
                            color: Colors.indigo,
                            fontWeight:
                                FontWeight.bold),
                      ),
                    ),

                    /// Name
                    title: Text(
                      name,
                      style: const TextStyle(
                          fontWeight:
                              FontWeight.bold),
                    ),

                    subtitle: Text(
                      "Student ID: $studentId",
                      style: const TextStyle(
                          color: Colors.black54),
                    ),

                    /// Add Button
                    trailing: ElevatedButton(
                      style:
                          ElevatedButton.styleFrom(
                        backgroundColor:
                            Colors.indigo,
                        foregroundColor:
                            Colors.white,
                        shape:
                            RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(
                                  20),
                        ),
                      ),
                      onPressed: () =>
                          _addStudent(doc.id),
                      child: const Text("Add"),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
