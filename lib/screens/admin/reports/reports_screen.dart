import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'create_test_screen.dart';
import 'test_details_screen.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  Future<void> _deleteTest(BuildContext context, String testId) async {
    await FirebaseFirestore.instance.collection("tests").doc(testId).delete();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Test deleted successfully")),
    );
  }

  Future<void> _assignTeacher(BuildContext context, String testId) async {
    final teachersSnapshot = await FirebaseFirestore.instance
        .collection("users")
        .where("role", isEqualTo: "teacher")
        .get();

    if (teachersSnapshot.docs.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No teachers found")),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14)),
          title: const Text("Assign Teacher"),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: teachersSnapshot.docs.length,
              itemBuilder: (context, index) {
                final teacher = teachersSnapshot.docs[index];
                final data = teacher.data();

                return ListTile(
                  leading:
                      const Icon(Icons.person, color: Colors.indigo),
                  title: Text(
                    data["name"] ?? "Teacher",
                    style: const TextStyle(color: Colors.black),
                  ),
                  subtitle: Text(
                    data["email"] ?? "",
                    style: const TextStyle(color: Colors.black54),
                  ),
                  onTap: () async {
                    await FirebaseFirestore.instance
                        .collection("tests")
                        .doc(testId)
                        .update({
                      "assignedTeacherId": teacher.id,
                      "assignedTeacherName": data["name"],
                    });

                    Navigator.pop(context);

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content:
                              Text("Teacher assigned successfully")),
                    );
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }

  String _formatDate(Timestamp timestamp) {
    final date = timestamp.toDate();
    return "${date.day}-${date.month}-${date.year}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE9EEF6),
      appBar: AppBar(
        title: const Text("Test Reports"),
        backgroundColor: Colors.indigo,
        centerTitle: true,
        elevation: 0,
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.indigo,
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const CreateTestScreen(),
            ),
          );
        },
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("tests")
            .orderBy("date")
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child:
                  CircularProgressIndicator(color: Colors.indigo),
            );
          }

          if (!snapshot.hasData ||
              snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                "No tests created yet",
                style: TextStyle(fontSize: 16),
              ),
            );
          }

          final tests = snapshot.data!.docs;

          return ListView.builder(
            padding:
                const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
            itemCount: tests.length,
            itemBuilder: (context, index) {
              final test = tests[index];
              final data =
                  test.data() as Map<String, dynamic>;
              final Timestamp ts = data["date"];

              return Container(
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.black12,
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color:
                          Colors.black.withOpacity(0.15),
                      blurRadius: 20,
                      spreadRadius: 2,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        data["name"] ?? "Test",
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight:
                              FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 14),

                      Row(
                        children: [
                          const Icon(Icons.category,
                              size: 18,
                              color: Colors.indigo),
                          const SizedBox(width: 8),
                          Text(
                            (data["type"] ?? "")
                                .toString()
                                .toUpperCase(),
                            style: const TextStyle(
                                color:
                                    Colors.black87),
                          ),
                        ],
                      ),

                      const SizedBox(height: 10),

                      Row(
                        children: [
                          const Icon(
                              Icons.calendar_today,
                              size: 18,
                              color:
                                  Colors.indigo),
                          const SizedBox(width: 8),
                          Text(
                            _formatDate(ts),
                            style: const TextStyle(
                                color:
                                    Colors.black87),
                          ),
                        ],
                      ),

                      const SizedBox(height: 10),

                      Row(
                        children: [
                          const Icon(Icons.person,
                              size: 18,
                              color:
                                  Colors.indigo),
                          const SizedBox(width: 8),
                          Text(
                            data["assignedTeacherName"] ??
                                "No Teacher Assigned",
                            style: const TextStyle(
                                color:
                                    Colors.black87),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                        children: [
                          ElevatedButton.icon(
                            style:
                                ElevatedButton
                                    .styleFrom(
                              backgroundColor:
                                  Colors.indigo,
                              foregroundColor:
                                  Colors.white,
                              padding:
                                  const EdgeInsets
                                      .symmetric(
                                      horizontal:
                                          18,
                                      vertical:
                                          12),
                              shape:
                                  RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius
                                        .circular(
                                            12),
                              ),
                            ),
                            icon: const Icon(
                                Icons.visibility),
                            label: const Text(
                                "View Students"),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      TestDetailsScreen(
                                    testId:
                                        test.id,
                                    testName:
                                        data["name"],
                                  ),
                                ),
                              );
                            },
                          ),
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(
                                    Icons.person_add,
                                    color:
                                        Colors.indigo),
                                onPressed: () =>
                                    _assignTeacher(
                                        context,
                                        test.id),
                              ),
                              IconButton(
                                icon: const Icon(
                                    Icons.edit,
                                    color:
                                        Colors.indigo),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          CreateTestScreen(
                                        testId:
                                            test.id,
                                        existingData:
                                            data,
                                      ),
                                    ),
                                  );
                                },
                              ),
                              IconButton(
                                icon: const Icon(
                                    Icons.delete,
                                    color:
                                        Colors.red),
                                onPressed:
                                    () async {
                                  final confirm =
                                      await showDialog(
                                    context:
                                        context,
                                    builder:
                                        (_) =>
                                            AlertDialog(
                                      shape:
                                          RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(
                                                14),
                                      ),
                                      title:
                                          const Text(
                                              "Delete Test"),
                                      content:
                                          const Text(
                                              "Are you sure you want to delete this test?"),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(
                                                  context,
                                                  false),
                                          child:
                                              const Text(
                                                  "Cancel"),
                                        ),
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(
                                                  context,
                                                  true),
                                          child:
                                              const Text(
                                                  "Delete"),
                                        ),
                                      ],
                                    ),
                                  );

                                  if (confirm ==
                                      true) {
                                    await _deleteTest(
                                        context,
                                        test.id);
                                  }
                                },
                              ),
                            ],
                          )
                        ],
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
