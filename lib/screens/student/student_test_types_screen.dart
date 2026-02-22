import 'package:flutter/material.dart';
import 'student_tests_list_screen.dart';

class StudentTestTypesScreen extends StatelessWidget {
  const StudentTestTypesScreen({super.key});

  final List<Map<String, dynamic>> testTypes = const [
    {"type": "mock", "icon": Icons.school, "color": Colors.deepPurple},
    {"type": "reading", "icon": Icons.menu_book, "color": Colors.blue},
    {"type": "listening", "icon": Icons.headphones, "color": Colors.orange},
    {"type": "speaking", "icon": Icons.mic, "color": Colors.green},
    {"type": "writing", "icon": Icons.edit, "color": Colors.red},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      appBar: AppBar(
        title: const Text("Select Test Type"),
        backgroundColor: Colors.indigo,
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: testTypes.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 18,
          mainAxisSpacing: 18,
          childAspectRatio: 1,
        ),
        itemBuilder: (context, index) {
          final item = testTypes[index];
          final Color color = item["color"];

          return InkWell(
            borderRadius: BorderRadius.circular(22),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      StudentTestsListScreen(type: item["type"]),
                ),
              );
            },
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                gradient: LinearGradient(
                  colors: [
                    color.withOpacity(0.15),
                    color.withOpacity(0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                border: Border.all(color: color, width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.15),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  )
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [

                  CircleAvatar(
                    radius: 30,
                    backgroundColor: color.withOpacity(0.2),
                    child: Icon(
                      item["icon"],
                      size: 32,
                      color: color,
                    ),
                  ),

                  const SizedBox(height: 14),

                  Text(
                    item["type"].toString().toUpperCase(),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: color,
                      fontSize: 16,
                      letterSpacing: 0.8,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Icon(
                    Icons.arrow_forward_ios,
                    size: 14,
                    color: color.withOpacity(0.7),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
