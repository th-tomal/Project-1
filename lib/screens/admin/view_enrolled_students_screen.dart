import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ViewEnrolledStudentsScreen extends StatelessWidget {
  final String courseId;
  final String courseName;

  const ViewEnrolledStudentsScreen({
    super.key,
    required this.courseId,
    required this.courseName,
  });

  @override
  Widget build(BuildContext context) {
    final FirebaseFirestore db = FirebaseFirestore.instance;

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: Text("Students - $courseName"),
        backgroundColor: Colors.indigo,
        elevation: 0,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: db.collection("courses").doc(courseId).snapshots(),
        builder: (context, snapshot) {

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final courseData =
              snapshot.data!.data() as Map<String, dynamic>?;

          if (courseData == null) {
            return const Center(child: Text("Course not found"));
          }

          final List students = courseData["students"] ?? [];

          if (students.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.group_off,
                      size: 70, color: Colors.grey),
                  SizedBox(height: 10),
                  Text(
                    "No students enrolled yet",
                    style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: students.length,
            itemBuilder: (context, index) {

              final studentUid = students[index];

              return FutureBuilder<DocumentSnapshot>(
                future: db.collection("users").doc(studentUid).get(),
                builder: (context, studentSnap) {

                  if (!studentSnap.hasData) {
                    return const SizedBox();
                  }

                  final studentData =
                      studentSnap.data!.data()
                          as Map<String, dynamic>?;

                  if (studentData == null) {
                    return const SizedBox();
                  }

                  final name =
                      studentData["name"] ?? "No Name";

                  final studentId =
                      studentData["studentId"] ?? "No ID";

                  return Container(
                    margin: const EdgeInsets.only(bottom: 14),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFF6366F1),
                          Color(0xFF4F46E5)
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        )
                      ],
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),

                      /// Avatar
                      leading: CircleAvatar(
                        radius: 26,
                        backgroundColor: Colors.white,
                        child: Text(
                          name.isNotEmpty
                              ? name[0].toUpperCase()
                              : "?",
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.indigo,
                          ),
                        ),
                      ),

                      title: Text(
                        name,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),

                      subtitle: Text(
                        "Student ID: $studentId",
                        style: const TextStyle(
                          color: Colors.white70,
                        ),
                      ),

                      /// Remove Button
                      trailing: IconButton(
                        icon: const Icon(
                          Icons.remove_circle,
                          color: Colors.redAccent,
                          size: 28,
                        ),
                        onPressed: () async {

                          final confirm = await showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              title: const Text("Remove Student"),
                              content: const Text(
                                "Are you sure you want to remove this student from the course?",
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context, false),
                                  child: const Text("Cancel"),
                                ),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                  ),
                                  onPressed: () =>
                                      Navigator.pop(context, true),
                                  child: const Text("Remove"),
                                ),
                              ],
                            ),
                          );

                          if (confirm == true) {
                            await db
                                .collection("courses")
                                .doc(courseId)
                                .update({
                              "students":
                                  FieldValue.arrayRemove([studentUid])
                            });
                          }
                        },
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
