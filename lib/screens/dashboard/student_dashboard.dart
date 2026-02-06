import 'package:flutter/material.dart';

class StudentDashboard extends StatelessWidget {
  const StudentDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Student Dashboard"),
        backgroundColor: Colors.blue,
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
          _StudentCard("My Schedule", Icons.schedule, Colors.blue),
          _StudentCard("Attendance", Icons.fact_check, Colors.green),
          _StudentCard("Results", Icons.bar_chart, Colors.orange),
          _StudentCard("Fee Status", Icons.payments, Colors.purple),
        ],
      ),
    );
  }
}

class _StudentCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;

  const _StudentCard(this.title, this.icon, this.color);

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
