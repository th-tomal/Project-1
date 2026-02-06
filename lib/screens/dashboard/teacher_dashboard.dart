import 'package:flutter/material.dart';

class TeacherDashboard extends StatelessWidget {
  const TeacherDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Teacher Dashboard"),
        backgroundColor: Colors.green,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/login');
            },
          )
        ],
      ),
      body: GridView.count(
        padding: const EdgeInsets.all(16),
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        children: [
          _TeacherCard("My Classes", Icons.class_, Colors.blue),
          _TeacherCard("Attendance", Icons.check_circle, Colors.green),
          _TeacherCard("Marks Entry", Icons.edit, Colors.orange),
          _TeacherCard("Notices", Icons.notifications, Colors.purple),
        ],
      ),
    );
  }
}

class _TeacherCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;

  const _TeacherCard(this.title, this.icon, this.color);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        // navigate later
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color, width: 1.2),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
