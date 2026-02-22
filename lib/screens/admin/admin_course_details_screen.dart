import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class AdminCourseDetailsScreen extends StatelessWidget {
  final String courseId;
  final String courseName;

  const AdminCourseDetailsScreen({
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

          final List students =
              data["students"] ?? [];

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(16),
              ),
              elevation: 5,
              child: Padding(
                padding:
                    const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [

                    _buildRow("Start Date",
                        DateFormat('dd MMM yyyy')
                            .format(startDate)),

                    _buildRow("End Date",
                        DateFormat('dd MMM yyyy')
                            .format(endDate)),

                    _buildRow("Total Classes",
                        totalClasses.toString()),

                    _buildRow("Class Days",
                        classDays.join(", ")),

                    _buildRow("Class Time",
                        classTime),

                    const SizedBox(height: 20),

                    Text(
                      "Students Enrolled: ${students.length}",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
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
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment:
            MainAxisAlignment.spaceBetween,
        children: [
          Text(title,
              style: const TextStyle(
                  fontWeight: FontWeight.bold)),
          Text(value),
        ],
      ),
    );
  }
}
