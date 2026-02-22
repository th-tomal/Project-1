import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class StudentResultsScreen extends StatelessWidget {
  const StudentResultsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final uid = user!.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Results"),
        backgroundColor: Colors.indigo,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('tests').snapshots(),
        builder: (context, testSnapshot) {

          if (!testSnapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final tests = testSnapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: tests.length,
            itemBuilder: (context, index) {

              final testDoc = tests[index];
              final testId = testDoc.id;
              final testName = testDoc['name'];
              final testType = testDoc['type'];

              final Timestamp? timestamp = testDoc['date'];
              DateTime? testDate = timestamp?.toDate();

              String formattedDate = '';
              if (testDate != null) {
                formattedDate =
                    "${testDate.day}/${testDate.month}/${testDate.year}";
              }

              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('tests')
                    .doc(testId)
                    .collection('registrations')
                    .doc(uid)
                    .get(),
                builder: (context, registrationSnapshot) {

                  if (!registrationSnapshot.hasData) {
                    return const SizedBox();
                  }

                  final registrationDoc = registrationSnapshot.data!;

                  if (!registrationDoc.exists) {
                    return const SizedBox();
                  }

                  final data =
                      registrationDoc.data() as Map<String, dynamic>?;

                  final marked = data?['marked'] ?? false;
                  final marks = data?['marks'] ?? {};

                  return Card(
                    elevation: 6,
                    margin: const EdgeInsets.only(bottom: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [

                          /// ✅ Test Name
                          Text(
                            testName,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 6),

                          /// ✅ Date
                          Text(
                            formattedDate,
                            style: const TextStyle(
                              fontSize: 15,
                              color: Colors.grey,
                            ),
                          ),

                          const Divider(height: 28),

                          /// ✅ MARKS SECTION
                          if (marked && marks.isNotEmpty) ...[

                            if (testType == "mock") ...[
                              _resultRow("Speaking", marks['speaking']),
                              _resultRow("Reading", marks['reading']),
                              _resultRow("Writing", marks['writing']),
                              _resultRow("Listening", marks['listening']),
                              const SizedBox(height: 10),
                              _resultRow("Overall", marks['overall'], isBold: true),
                            ]

                            else
                              Text(
                                "${testType.toUpperCase()}: ${marks[testType] ?? '-'}",
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                          ]

                          else
                            const Text(
                              "Registered ✔\nNot graded yet",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.orange,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                        ],
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

  static Widget _resultRow(String label, dynamic value,
      {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 17,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            ),
          ),
          Text(
            value?.toString() ?? '-',
            style: TextStyle(
              fontSize: 18,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
