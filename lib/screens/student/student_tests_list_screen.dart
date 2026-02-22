import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'student_test_registration_screen.dart';

class StudentTestsListScreen extends StatelessWidget {
  final String type;

  const StudentTestsListScreen({
    super.key,
    required this.type,
  });

  String _formatDate(BuildContext context, Timestamp? timestamp) {
    if (timestamp == null) return "No Date";

    final date = timestamp.toDate();
    String formatted = "${date.day}-${date.month}-${date.year}";

    if (type.toLowerCase() == "mock") {
      final time = TimeOfDay.fromDateTime(date).format(context);
      formatted += "  |  $time";
    }

    return formatted;
  }

  Color _getColor() {
    switch (type.toLowerCase()) {
      case "mock":
        return Colors.deepPurple;
      case "reading":
        return Colors.blue;
      case "listening":
        return Colors.orange;
      case "speaking":
        return Colors.green;
      case "writing":
        return Colors.red;
      default:
        return Colors.indigo;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getColor();

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      appBar: AppBar(
        title: Text("${type.toUpperCase()} Tests"),
        backgroundColor: Colors.indigo,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('tests')
            .where('type', isEqualTo: type)
            .snapshots(),
        builder: (context, snapshot) {

          if (snapshot.hasError) {
            return Center(
              child: Text(
                "Error: ${snapshot.error}",
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final tests = snapshot.data?.docs ?? [];

          if (tests.isEmpty) {
            return const Center(
              child: Text(
                "No tests available",
                style: TextStyle(fontSize: 16),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: tests.length,
            itemBuilder: (context, index) {
              final test = tests[index];
              final data = test.data() as Map<String, dynamic>;

              final testName = data['name'] ?? 'No Name';
              final Timestamp? timestamp = data['date'];

              final formattedDate =
                  _formatDate(context, timestamp);

              return InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => StudentTestRegistrationScreen(
                        testId: test.id,
                        testName: testName,
                      ),
                    ),
                  );
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 18),
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      )
                    ],
                  ),
                  child: Row(
                    children: [

                      Container(
                        width: 6,
                        height: 60,
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),

                      const SizedBox(width: 16),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              testName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(Icons.calendar_today,
                                    size: 14, color: color),
                                const SizedBox(width: 6),
                                Text(
                                  formattedDate,
                                  style: TextStyle(
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      Icon(Icons.arrow_forward_ios,
                          size: 16, color: color),
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
