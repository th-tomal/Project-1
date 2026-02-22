import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CreateTestScreen extends StatefulWidget {
  final String? testId;
  final Map<String, dynamic>? existingData;

  const CreateTestScreen({
    super.key,
    this.testId,
    this.existingData,
  });

  @override
  State<CreateTestScreen> createState() => _CreateTestScreenState();
}

class _CreateTestScreenState extends State<CreateTestScreen> {

  final _nameController = TextEditingController();
  String _selectedType = "mock";
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  String? _selectedTeacherId;
  String? _selectedTeacherName;

  final List<String> testTypes = [
    "mock",
    "speaking",
    "reading",
    "writing",
    "listening"
  ];

  @override
  void initState() {
    super.initState();

    if (widget.existingData != null) {
      _nameController.text = widget.existingData!["name"];
      _selectedType = widget.existingData!["type"];

      final Timestamp ts = widget.existingData!["date"];
      final DateTime date = ts.toDate();
      _selectedDate = date;
      _selectedTime = TimeOfDay.fromDateTime(date);

      _selectedTeacherId =
          widget.existingData!["assignedTeacherId"];
      _selectedTeacherName =
          widget.existingData!["assignedTeacherName"];
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime(2024),
      lastDate: DateTime(2030),
      initialDate: _selectedDate ?? DateTime.now(),
    );

    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
    );

    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }

  Future<void> _saveTest() async {

    if (_selectedDate == null ||
        _nameController.text.trim().isEmpty ||
        _selectedTeacherId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("All fields required")),
      );
      return;
    }

    DateTime finalDate = _selectedDate!;

    if (_selectedType == "mock" && _selectedTime != null) {
      finalDate = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        _selectedTime!.hour,
        _selectedTime!.minute,
      );
    }

    final data = {
      "name": _nameController.text.trim(),
      "type": _selectedType,
      "date": Timestamp.fromDate(finalDate),
      "assignedTeacherId": _selectedTeacherId,
      "assignedTeacherName": _selectedTeacherName,
    };

    if (widget.testId == null) {
      await FirebaseFirestore.instance.collection("tests").add({
        ...data,
        "createdAt": Timestamp.now(),
        "createdBy": FirebaseAuth.instance.currentUser!.uid,
        "registeredStudents": []
      });
    } else {
      await FirebaseFirestore.instance
          .collection("tests")
          .doc(widget.testId)
          .update(data);
    }

    if (!mounted) return;
    Navigator.pop(context);
  }

  Widget _styledContainer(Widget child) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.black12,
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 18,
            spreadRadius: 2,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {

    final isEditing = widget.testId != null;

    return Scaffold(
      backgroundColor: const Color(0xFFE9EEF6),
      appBar: AppBar(
        title: Text(isEditing ? "Edit Test" : "Create Test"),
        backgroundColor: Colors.indigo,
        centerTitle: true,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
        child: SingleChildScrollView(
          child: Column(
            children: [

              _styledContainer(
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.edit_note, color: Colors.indigo),
                    labelText: "Test Name",
                    border: InputBorder.none,
                  ),
                ),
              ),

              const SizedBox(height: 22),

              _styledContainer(
                DropdownButtonFormField(
                  value: _selectedType,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.category, color: Colors.indigo),
                    border: InputBorder.none,
                  ),
                  items: testTypes.map((type) {
                    return DropdownMenuItem(
                      value: type,
                      child: Text(type.toUpperCase()),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedType = value!;
                    });
                  },
                ),
              ),

              const SizedBox(height: 22),

              _styledContainer(
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection("users")
                      .where("role", isEqualTo: "teacher")
                      .snapshots(),
                  builder: (context, snapshot) {

                    if (!snapshot.hasData) {
                      return const Center(
                          child: CircularProgressIndicator(color: Colors.indigo));
                    }

                    final teachers = snapshot.data!.docs;

                    return DropdownButtonFormField<String>(
                      value: _selectedTeacherId,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.person, color: Colors.indigo),
                        labelText: "Assign Teacher",
                        border: InputBorder.none,
                      ),
                      items: teachers.map((doc) {
                        final data =
                            doc.data() as Map<String, dynamic>;

                        return DropdownMenuItem<String>(
                          value: doc.id,
                          child: Text(data["name"] ?? "No Name"),
                        );
                      }).toList(),
                      onChanged: (value) {
                        final selectedDoc = teachers
                            .firstWhere((doc) => doc.id == value);

                        final data =
                            selectedDoc.data() as Map<String, dynamic>;

                        setState(() {
                          _selectedTeacherId = value;
                          _selectedTeacherName = data["name"];
                        });
                      },
                    );
                  },
                ),
              ),

              const SizedBox(height: 22),

              _styledContainer(
                ListTile(
                  leading: const Icon(Icons.calendar_today, color: Colors.indigo),
                  title: Text(
                    _selectedDate == null
                        ? "Select Date"
                        : "${_selectedDate!.day}-${_selectedDate!.month}-${_selectedDate!.year}",
                  ),
                  onTap: _pickDate,
                ),
              ),

              if (_selectedType == "mock")
                Padding(
                  padding: const EdgeInsets.only(top: 22),
                  child: _styledContainer(
                    ListTile(
                      leading: const Icon(Icons.access_time, color: Colors.indigo),
                      title: Text(
                        _selectedTime == null
                            ? "Select Time"
                            : _selectedTime!.format(context),
                      ),
                      onTap: _pickTime,
                    ),
                  ),
                ),

              const SizedBox(height: 40),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _saveTest,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    foregroundColor: Colors.white, // ✅ FIXED
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    isEditing ? "Update Test" : "Create Test",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }
}
