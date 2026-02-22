import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class TeacherCoursesScreen extends StatelessWidget {
  const TeacherCoursesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final teacherId = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Courses"),
        backgroundColor: Colors.blue,
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("courses")
            .where("teacherId", isEqualTo: teacherId)
            .snapshots(),
        builder: (context, snapshot) {

          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final courses = snapshot.data!.docs;

          if (courses.isEmpty) {
            return const Center(
              child: Text(
                "No courses assigned yet",
                style: TextStyle(fontSize: 16),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: courses.length,
            itemBuilder: (context, index) {

              final course = courses[index];
              final data = course.data() as Map<String, dynamic>;
              final List students = data["students"] ?? [];

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => TeacherCourseDetailsScreen(
                        courseId: course.id,
                        courseName: data["name"] ?? "",
                      ),
                    ),
                  );
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF2196F3), Color(0xFF64B5F6)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.menu_book_rounded,
                        size: 40,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              data["name"] ?? "No Name",
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              "${students.length} Students Enrolled",
                              style: const TextStyle(
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.white,
                        size: 18,
                      )
                    ],
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

class TeacherCourseDetailsScreen extends StatelessWidget {
  final String courseId;
  final String courseName;

  const TeacherCourseDetailsScreen({
    super.key,
    required this.courseId,
    required this.courseName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(courseName),
        backgroundColor: Colors.blue,
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection("courses")
            .doc(courseId)
            .get(),
        builder: (context, snapshot) {

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;

          final startDate = (data["startDate"] as Timestamp).toDate();
          final endDate = (data["endDate"] as Timestamp).toDate();
          final totalClasses = data["totalClasses"] ?? 0;
          final classDays = List<String>.from(data["classDays"] ?? []);
          final classTime = data["classTime"] ?? "";
          final List students = data["students"] ?? [];

          /// Calculate classes left
          final now = DateTime.now();
          final totalDays = endDate.difference(startDate).inDays;
          final passedDays = now.difference(startDate).inDays;

          int classesLeft = totalClasses;

          if (passedDays > 0 && totalDays > 0) {
            double progress = passedDays / totalDays;
            classesLeft =
                (totalClasses - (totalClasses * progress).round())
                    .clamp(0, totalClasses);
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                /// COURSE DETAILS CARD
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 5,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        _buildRow("Start Date",
                            DateFormat('dd MMM yyyy').format(startDate)),
                        _buildRow("End Date",
                            DateFormat('dd MMM yyyy').format(endDate)),
                        _buildRow("Total Classes", totalClasses.toString()),
                        _buildRow("Classes Left", classesLeft.toString()),
                        _buildRow("Class Days", classDays.join(", ")),
                        _buildRow("Class Time", classTime),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                const Text(
                  "Enrolled Students",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 12),

                students.isEmpty
                    ? const Text("No students enrolled")
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: students.length,
                        itemBuilder: (context, index) {

                          return FutureBuilder<DocumentSnapshot>(
                            future: FirebaseFirestore.instance
                                .collection("users")
                                .doc(students[index])
                                .get(),
                            builder: (context, studentSnapshot) {

                              if (!studentSnapshot.hasData) {
                                return const SizedBox();
                              }

                              final studentData =
                                  studentSnapshot.data!.data()
                                      as Map<String, dynamic>;

                              return Container(
                                margin:
                                    const EdgeInsets.only(bottom: 12),
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  borderRadius:
                                      BorderRadius.circular(14),
                                ),
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      backgroundColor:
                                          Colors.blue.shade100,
                                      child: Text(
                                        (studentData["name"] ?? "S")[0]
                                            .toUpperCase(),
                                        style: const TextStyle(
                                            color: Colors.blue),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            studentData["name"] ??
                                                "No Name",
                                            style: const TextStyle(
                                                fontWeight:
                                                    FontWeight.bold),
                                          ),
                                          Text(
                                            studentData["email"] ??
                                                "",
                                            style: TextStyle(
                                                color: Colors
                                                    .grey.shade600),
                                          ),
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              );
                            },
                          );
                        },
                      ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment:
            MainAxisAlignment.spaceBetween,
        children: [
          Text(title,
              style:
                  const TextStyle(fontWeight: FontWeight.bold)),
          Text(value),
        ],
      ),
    );
  }
}
