import 'package:flutter/material.dart';
import '../widgets/report_card.dart';
import '../widgets/revenue_expenses_chart.dart';
import '../widgets/bottom_nav_bar.dart';
import '../widgets/app_header.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      // ✅ Use reusable AppHeader
      appBar: AppHeader(
        title: "DeliGo",
        onNotificationPressed: () {
          // Handle notification press
        },
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),

              // 🔹 Revenue & Expenses Summary
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFA726), Color(0xFFFFCC80)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      "Revenue",
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                    SizedBox(height: 5),
                    Text(
                      "Rs. 2,32,640",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      "Expenses",
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                    SizedBox(height: 5),
                    Text(
                      "Rs. 52,040",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // 🔹 Revenue & Expenses Chart
              const Text(
                "Revenue & Expenses Overview",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 15),

              const RevenueExpensesChart(),

              const SizedBox(height: 30),

              // 📊 🔹 Statistics Section (Using ReportCard)
              Column(
                children: const [
                  ReportCard(
                    icon: Icons.shopping_bag,
                    title: "Total Orders Received",
                    value: "1,521",
                    percentage: 25.0,
                    isPositive: true,
                  ),
                  SizedBox(height: 15),
                  ReportCard(
                    icon: Icons.thumb_up,
                    title: "Total Orders Delivered",
                    value: "1,382",
                    percentage: 30.0,
                    isPositive: true,
                  ),
                  SizedBox(height: 15),
                  ReportCard(
                    icon: Icons.person,
                    title: "Total Customers",
                    value: "892",
                    percentage: 12.0,
                    isPositive: false,
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // 🔥 New Section: Reviews & Customer Data in Separate Boxes
              Row(
                children: [
                  Expanded(
                    child: _buildBox(Icons.thumb_up, "Reviews"),
                  ),
                  const SizedBox(width: 15), // Space between boxes
                  Expanded(
                    child: _buildBox(Icons.people, "Customer Data"),
                  ),
                ],
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),

      // ✅ Bottom Navigation Bar
      bottomNavigationBar: const BottomNavBar(selectedIndex: 1),
    );
  }

  // 🔹 Helper function to create separate gradient boxes
  Widget _buildBox(IconData icon, String title) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFF4B3A), Color(0xFFFF8329)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 30, color: Colors.white),
          const SizedBox(height: 5),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
