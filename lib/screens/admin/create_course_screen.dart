import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'assign_students_screen.dart';
import 'view_enrolled_students_screen.dart';

class CreateCourseScreen extends StatefulWidget {
  const CreateCourseScreen({super.key});

  @override
  State<CreateCourseScreen> createState() =>
      _CreateCourseScreenState();
}

class _CreateCourseScreenState extends State<CreateCourseScreen> {

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final List<String> weekDays = [
    "Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"
  ];

  final TextEditingController courseNameController =
      TextEditingController();

  String? selectedTeacherId;

  DateTime? startDate;
  DateTime? endDate;

  final totalClassesController = TextEditingController();
  final classTimeController = TextEditingController();

  List<String> selectedDays = [];

  bool isLoading = false;

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text("Create Course"),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.indigo, Colors.blueAccent],
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            _buildStyledBox(
              TextField(
                controller: courseNameController,
                decoration: const InputDecoration(
                  labelText: "Course Name",
                  border: InputBorder.none,
                ),
              ),
            ),

            const SizedBox(height: 15),

            _buildStyledBox(
              StreamBuilder<QuerySnapshot>(
                stream: _firestore
                    .collection('users')
                    .where('role', isEqualTo: 'teacher')
                    .snapshots(),
                builder: (context, snapshot) {

                  if (!snapshot.hasData) {
                    return const CircularProgressIndicator();
                  }

                  final teachers = snapshot.data!.docs;

                  return DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: "Assign Teacher",
                      border: InputBorder.none,
                    ),
                    value: selectedTeacherId,
                    items: teachers.map((doc) {
                      final data =
                          doc.data() as Map<String, dynamic>;
                      return DropdownMenuItem(
                        value: doc.id,
                        child: Text(
                            data['name'] ?? "No Name"),
                      );
                    }).toList(),
                    onChanged: (value) =>
                        setState(() =>
                            selectedTeacherId = value),
                  );
                },
              ),
            ),

            const SizedBox(height: 15),

            _buildStyledBox(
              TextField(
                controller: totalClassesController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Total Number of Classes",
                  border: InputBorder.none,
                ),
              ),
            ),

            const SizedBox(height: 15),

            _buildStyledBox(
              TextField(
                controller: classTimeController,
                decoration: const InputDecoration(
                  labelText:
                      "Class Time (e.g. 5:00 PM - 7:00 PM)",
                  border: InputBorder.none,
                ),
              ),
            ),

            const SizedBox(height: 15),

            ListTile(
              title: Text(
                startDate == null
                    ? "Select Start Date"
                    : "Start: ${DateFormat('dd MMM yyyy').format(startDate!)}",
              ),
              trailing: const Icon(Icons.calendar_today),
              onTap: _pickStartDate,
            ),

            ListTile(
              title: Text(
                endDate == null
                    ? "Select End Date"
                    : "End: ${DateFormat('dd MMM yyyy').format(endDate!)}",
              ),
              trailing: const Icon(Icons.calendar_today),
              onTap: _pickEndDate,
            ),

            const SizedBox(height: 10),

            const Text(
              "Select Class Days",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),

            Wrap(
              spacing: 8,
              children: weekDays.map((day) {
                final isSelected =
                    selectedDays.contains(day);

                return FilterChip(
                  label: Text(day),
                  selected: isSelected,
                  onSelected: (value) {
                    setState(() {
                      if (value) {
                        selectedDays.add(day);
                      } else {
                        selectedDays.remove(day);
                      }
                    });
                  },
                );
              }).toList(),
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(30),
                  ),
                ),
                onPressed:
                    isLoading ? null : _createCourse,
                child: Text(isLoading
                    ? "Creating..."
                    : "Create Course"),
              ),
            ),

            const SizedBox(height: 30),

            StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection("courses")
                  .orderBy("createdAt", descending: true)
                  .snapshots(),
              builder: (context, snapshot) {

                if (!snapshot.hasData) {
                  return const Center(
                      child: CircularProgressIndicator());
                }

                final courses = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: courses.length,
                  shrinkWrap: true,
                  physics:
                      const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {

                    final doc = courses[index];
                    final data =
                        doc.data() as Map<String, dynamic>;

                    final name = data["name"] ?? "";
                    final count =
                        (data["students"] ?? []).length;

                    return Container(
                      margin:
                          const EdgeInsets.only(bottom: 15),
                      decoration: BoxDecoration(
                        gradient:
                            const LinearGradient(
                          colors: [
                            Colors.indigo,
                            Colors.blueAccent
                          ],
                        ),
                        borderRadius:
                            BorderRadius.circular(15),
                      ),
                      child: ListTile(
                        contentPadding:
                            const EdgeInsets.all(16),
                        title: Text(
                          name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(
                          "Students: $count",
                          style: const TextStyle(
                              color: Colors.white70),
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  ViewEnrolledStudentsScreen(
                                courseId: doc.id,
                                courseName: name,
                              ),
                            ),
                          );
                        },
                        trailing:
                            PopupMenuButton<String>(
                          icon: const Icon(
                              Icons.more_vert,
                              color: Colors.white),
                          onSelected: (value) {
                            if (value == "assign") {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      AssignStudentsScreen(
                                    courseId: doc.id,
                                    courseName: name,
                                  ),
                                ),
                              );
                            }

                            if (value == "delete") {
                              _deleteCourse(doc.id);
                            }
                          },
                          itemBuilder: (context) => const [
                            PopupMenuItem(
                              value: "assign",
                              child:
                                  Text("Assign Students"),
                            ),
                            PopupMenuItem(
                              value: "delete",
                              child: Text("Delete"),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStyledBox(Widget child) {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color:
                Colors.grey.withOpacity(0.2),
            blurRadius: 8,
          ),
        ],
      ),
      child: child,
    );
  }

  Future<void> _deleteCourse(String id) async {
    await _firestore.collection("courses").doc(id).delete();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Course Deleted")),
    );
  }

  Future<void> _pickStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2024),
      lastDate: DateTime(2035),
    );
    if (picked != null) {
      setState(() => startDate = picked);
    }
  }

  Future<void> _pickEndDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2024),
      lastDate: DateTime(2035),
    );
    if (picked != null) {
      setState(() => endDate = picked);
    }
  }

  Future<void> _createCourse() async {

    if (courseNameController.text.isEmpty ||
        selectedTeacherId == null ||
        startDate == null ||
        endDate == null ||
        totalClassesController.text.isEmpty ||
        classTimeController.text.isEmpty ||
        selectedDays.isEmpty) {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all fields")),
      );
      return;
    }

    setState(() => isLoading = true);

    await _firestore.collection("courses").add({
      "name": courseNameController.text.trim(),
      "teacherId": selectedTeacherId,
      "students": [],
      "startDate": Timestamp.fromDate(startDate!),
      "endDate": Timestamp.fromDate(endDate!),
      "totalClasses": int.parse(totalClassesController.text),
      "classDays": selectedDays,
      "classTime": classTimeController.text.trim(),
      "createdAt": FieldValue.serverTimestamp(),
    });

    setState(() {
      courseNameController.clear();
      selectedTeacherId = null;
      startDate = null;
      endDate = null;
      selectedDays.clear();
      totalClassesController.clear();
      classTimeController.clear();
      isLoading = false;
    });
  }
}
