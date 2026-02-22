import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MarksEntryScreen extends StatefulWidget {
  final String testId;
  final String registrationId;
  final String studentName;
  final String testType;

  const MarksEntryScreen({
    super.key,
    required this.testId,
    required this.registrationId,
    required this.studentName,
    required this.testType,
  });

  @override
  State<MarksEntryScreen> createState() => _MarksEntryScreenState();
}

class _MarksEntryScreenState extends State<MarksEntryScreen> {

  final TextEditingController speaking = TextEditingController();
  final TextEditingController reading = TextEditingController();
  final TextEditingController writing = TextEditingController();
  final TextEditingController listening = TextEditingController();
  final TextEditingController overall = TextEditingController();
  final TextEditingController singleMark = TextEditingController();

  bool isLoading = true;
  bool alreadyMarked = false;
  bool isEditing = false;

  @override
  void initState() {
    super.initState();
    _loadExistingMarks();
  }

  Future<void> _loadExistingMarks() async {
    final doc = await FirebaseFirestore.instance
        .collection("tests")
        .doc(widget.testId)
        .collection("registrations")
        .doc(widget.registrationId)
        .get();

    if (doc.exists) {
      final data = doc.data()!;
      alreadyMarked = data["marked"] ?? false;

      if (alreadyMarked && data["marks"] != null) {
        final marks = Map<String, dynamic>.from(data["marks"]);

        if (widget.testType.toLowerCase() == "mock") {
          speaking.text = marks["speaking"]?.toString() ?? "";
          reading.text = marks["reading"]?.toString() ?? "";
          writing.text = marks["writing"]?.toString() ?? "";
          listening.text = marks["listening"]?.toString() ?? "";
          overall.text = marks["overall"]?.toString() ?? "";
        } else {
          singleMark.text =
              marks[widget.testType]?.toString() ?? "";
        }
      }
    }

    setState(() => isLoading = false);
  }

  Future<void> _saveMarks() async {

    Map<String, dynamic> marksData = {};

    /// MOCK TEST
    if (widget.testType.toLowerCase() == "mock") {
      marksData = {
        "speaking": double.tryParse(speaking.text) ?? 0,
        "reading": double.tryParse(reading.text) ?? 0,
        "writing": double.tryParse(writing.text) ?? 0,
        "listening": double.tryParse(listening.text) ?? 0,
        "overall": double.tryParse(overall.text) ?? 0,
      };
    }

    /// SINGLE MODULE TEST
    else {
      marksData = {
        widget.testType:
            double.tryParse(singleMark.text) ?? 0,
      };
    }

    await FirebaseFirestore.instance
        .collection("tests")
        .doc(widget.testId)
        .collection("registrations")
        .doc(widget.registrationId)
        .update({
      "marks": marksData,
      "marked": true,
    });

    setState(() {
      alreadyMarked = true;
      isEditing = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Marks saved successfully")),
    );
  }

  Widget _buildTextField(
      String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextField(
        controller: controller,
        readOnly: alreadyMarked && !isEditing,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    final isMock = widget.testType.toLowerCase() == "mock";

    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Marks - ${widget.studentName}"),
        backgroundColor: Colors.indigo,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            /// MOCK TEST
            if (isMock) ...[
              _buildTextField("Speaking", speaking),
              _buildTextField("Reading", reading),
              _buildTextField("Writing", writing),
              _buildTextField("Listening", listening),
              _buildTextField("Overall", overall),
            ]

            else
              _buildTextField(
                widget.testType.toUpperCase(),
                singleMark,
              ),

            const SizedBox(height: 25),

            /// BUTTON LOGIC
            if (!alreadyMarked)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveMarks,
                  style: ElevatedButton.styleFrom(
                    padding:
                        const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.indigo,
                  ),
                  child: const Text(
                    "Submit Marks",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              )

            else if (!isEditing)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    setState(() => isEditing = true);
                  },
                  style: ElevatedButton.styleFrom(
                    padding:
                        const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: const Color.fromARGB(255, 17, 49, 163),
                  ),
                  child: const Text(
                    "Edit Marks",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              )

            else
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveMarks,
                  style: ElevatedButton.styleFrom(
                    padding:
                        const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.green,
                  ),
                  child: const Text(
                    "Update Marks",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
