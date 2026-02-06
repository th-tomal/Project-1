import 'package:flutter/material.dart';
import '../../widgets/dashboard_card.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("SmartCoach Dashboard"),
        backgroundColor: Colors.indigo,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              // logout later
              Navigator.pushReplacementNamed(context, '/login');
            },
          )
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // Welcome Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.indigo.shade50,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    "Welcome 👋",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    "Manage your coaching center efficiently",
                    style: TextStyle(color: Colors.black54),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Grid Dashboard
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [

                  DashboardCard(
                    title: "Students",
                    icon: Icons.people,
                    color: Colors.blue,
                  ),

                  DashboardCard(
                    title: "Teachers",
                    icon: Icons.person_outline,
                    color: Colors.green,
                  ),

                  DashboardCard(
                    title: "Attendance",
                    icon: Icons.check_circle_outline,
                    color: Colors.orange,
                  ),

                  DashboardCard(
                    title: "Fees",
                    icon: Icons.attach_money,
                    color: Colors.purple,
                  ),

                  DashboardCard(
                    title: "Classes",
                    icon: Icons.schedule,
                    color: Colors.teal,
                  ),

                  DashboardCard(
                    title: "Reports",
                    icon: Icons.bar_chart,
                    color: Colors.redAccent,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
