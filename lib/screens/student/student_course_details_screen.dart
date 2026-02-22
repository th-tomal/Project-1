import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class StudentCourseDetailsScreen extends StatelessWidget {
  final String courseId;
  final String courseName;

  const StudentCourseDetailsScreen({
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

          if (snapshot.hasError) {
            return Center(
              child: Text(
                "Error: ${snapshot.error}",
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          /// ⏳ SHOW LOADING
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(
              child: Text("Course not found"),
            );
          }

          final data =
              snapshot.data!.data() as Map<String, dynamic>;

          final startDate =
              (data["startDate"] as Timestamp).toDate();

          final endDate =
              (data["endDate"] as Timestamp).toDate();

          final totalClasses =
              data["totalClasses"] ?? 0;

          final classDays =
              List<String>.from(data["classDays"] ?? []);

          final classTime =
              data["classTime"] ?? "";

          /// Calculate classes left
          final now = DateTime.now();
          final totalDays =
              endDate.difference(startDate).inDays;
          final passedDays =
              now.difference(startDate).inDays;

          int classesLeft = totalClasses;

          if (passedDays > 0 && totalDays > 0) {
            double progress = passedDays / totalDays;
            classesLeft =
                (totalClasses -
                        (totalClasses * progress).round())
                    .clamp(0, totalClasses);
          }

          return Padding(
            padding: const EdgeInsets.all(20),
            child: Card(
              elevation: 6,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    _buildRow(
                      "Start Date",
                      DateFormat('dd MMM yyyy').format(startDate),
                    ),

                    _buildRow(
                      "End Date",
                      DateFormat('dd MMM yyyy').format(endDate),
                    ),

                    _buildRow(
                      "Total Classes",
                      totalClasses.toString(),
                    ),

                    _buildRow(
                      "Classes Left",
                      classesLeft.toString(),
                    ),

                    _buildRow(
                      "Class Days",
                      classDays.join(", "),
                    ),

                    _buildRow(
                      "Class Time",
                      classTime,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(value),
        ],
      ),
    );
  }
}
