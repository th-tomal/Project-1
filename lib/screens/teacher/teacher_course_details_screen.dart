import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

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
        backgroundColor: Colors.indigo,
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
          final students = List<String>.from(data["students"] ?? []);

          /// Calculate classes left
          final now = DateTime.now();
          final totalDays = endDate.difference(startDate).inDays;
          final passedDays = now.difference(startDate).inDays;

          int classesLeft = totalClasses;

          if (passedDays > 0 && totalDays > 0) {
            double progress = passedDays / totalDays;
            classesLeft = (totalClasses -
                    (totalClasses * progress).round())
                .clamp(0, totalClasses);
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                /// COURSE DETAILS CARD
                Card(
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
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

                /// STUDENTS SECTION TITLE
                const Text(
                  "Enrolled Students",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 12),

                /// STUDENTS LIST
                ListView.builder(
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

                        if (!studentSnapshot.hasData ||
                            !studentSnapshot.data!.exists) {
                          return const SizedBox();
                        }

                        final studentData =
                            studentSnapshot.data!.data()
                                as Map<String, dynamic>;

                        final studentName =
                            studentData["name"] ?? "No Name";

                        final studentId =
                            studentData["studentId"] ?? "No ID";

                        return Card(
                          child: ListTile(
                            leading: const Icon(
                              Icons.person,
                              color: Colors.indigo,
                            ),
                            title: Text(studentName),
                            subtitle: Text("Student ID: $studentId"),
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title,
              style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(value),
        ],
      ),
    );
  }
}
