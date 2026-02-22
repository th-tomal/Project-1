import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TestDetailsScreen extends StatelessWidget {
  final String testId;
  final String testName;

  const TestDetailsScreen({
    super.key,
    required this.testId,
    required this.testName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      appBar: AppBar(
        title: Text(testName),
        backgroundColor: const Color(0xFF3F51B5),
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
            return const Center(
              child: Text("No students registered"),
            );
          }

          final registrations = snapshot.data!.docs;

          return Column(
            children: [

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                color: const Color(0xFFE8EAF6),
                child: Text(
                  "Total Registered: ${registrations.length}",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF3F51B5),
                  ),
                ),
              ),

              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: registrations.length,
                  itemBuilder: (context, index) {

                    final data = registrations[index].data()
                        as Map<String, dynamic>;

                    final studentName =
                        data["studentName"] ?? "No Name";

                    final studentId =
                        data["studentId"] ?? "N/A";

                    final phone =
                        data["phone"] ?? "N/A";

                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 6),
                          )
                        ],
                      ),
                      child: Row(
                        children: [

                          CircleAvatar(
                            radius: 26,
                            backgroundColor:
                                const Color(0xFF5C6BC0),
                            child: Text(
                              studentName.isNotEmpty
                                  ? studentName[0].toUpperCase()
                                  : "S",
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),

                          const SizedBox(width: 16),

                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [

                                Text(
                                  studentName,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),

                                const SizedBox(height: 6),

                                Text("Student ID: $studentId"),
                                Text("Phone: $phone"),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
