import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../utils/user_roles.dart';
import 'student_details_screen.dart';

class ManageStudentsScreen extends StatelessWidget {
  const ManageStudentsScreen({super.key});

  // ================= PROMOTE =================
  Future<void> _promoteToTeacher(String uid) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .update({
      'role': UserRole.teacher.value,
    });
  }

  // ================= DELETE =================
  Future<void> _deleteStudent(String uid) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .delete();
  }

  // ================= CONFIRM DELETE =================
  void _confirmDelete(BuildContext context, String uid) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Student"),
        content: const Text(
          "Are you sure you want to permanently delete this student?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _deleteStudent(uid);

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Student deleted successfully"),
                ),
              );
            },
            child: const Text(
              "Delete",
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  // ================= MENU HANDLER =================
  void _handleMenuAction(
      BuildContext context, String value, String uid) {
    if (value == "promote") {
      _promoteToTeacher(uid);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Student promoted to Teacher")),
      );
    } else if (value == "delete") {
      _confirmDelete(context, uid);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Students"),
        backgroundColor: Colors.indigo,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .where('role', isEqualTo: UserRole.student.value)
            .snapshots(),
        builder: (context, snapshot) {

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No students found"));
          }

          final students = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: students.length,
            itemBuilder: (context, index) {

              final doc = students[index];
              final data = doc.data() as Map<String, dynamic>;

              final name = data['name'] ?? 'No Name';
              final email = data['email'] ?? 'No Email';
              final studentId = data['studentId'] ?? 'Not Assigned';

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          StudentDetailsScreen(userId: doc.id),
                    ),
                  );
                },
                child: Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 28,
                          backgroundColor: Colors.indigo,
                          child: Text(
                            name.isNotEmpty
                                ? name[0].toUpperCase()
                                : "?",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
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
                                name,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 6),

                              Text(
                                "Student ID: $studentId",
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Colors.black54,
                                ),
                              ),

                              const SizedBox(height: 4),
                              Text(
                                email,
                                style: const TextStyle(
                                  color: Colors.black54,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // 🔥 THREE DOT MENU
                        PopupMenuButton<String>(
                          onSelected: (value) =>
                              _handleMenuAction(
                                  context, value, doc.id),
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: "promote",
                              child: Row(
                                children: [
                                  Icon(Icons.arrow_upward,
                                      color: Colors.indigo),
                                  SizedBox(width: 8),
                                  Text("Promote to Teacher"),
                                ],
                              ),
                            ),
                            const PopupMenuItem(
                              value: "delete",
                              child: Row(
                                children: [
                                  Icon(Icons.delete,
                                      color: Colors.red),
                                  SizedBox(width: 8),
                                  Text("Delete Student"),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
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
