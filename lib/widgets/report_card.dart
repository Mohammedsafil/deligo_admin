import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class ReportCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final double percentage;
  final bool isPositive;

  const ReportCard({
    Key? key,
    required this.icon,
    required this.title,
    required this.value,
    required this.percentage,
    required this.isPositive,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 🔹 Left Icon Section
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.orange, size: 26),
          ),
          const SizedBox(width: 15),

          // 🔹 Middle Data Section
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),

          // 🔹 Right Graph & Percentage Section
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // 🔹 Line Graph
              SizedBox(
                height: 40,
                width: 70,
                child: LineChart(
                  LineChartData(
                    borderData: FlBorderData(show: false),
                    gridData: FlGridData(show: false),
                    titlesData: FlTitlesData(show: false),
                    lineBarsData: [
                      LineChartBarData(
                        spots: isPositive
                            ? [
                          const FlSpot(0, 1),
                          const FlSpot(1, 2),
                          const FlSpot(2, 1.5),
                          const FlSpot(3, 2.8),
                          const FlSpot(4, 2),
                          const FlSpot(5, 3),
                          const FlSpot(6, 3.2),
                        ]
                            : [
                          const FlSpot(0, 3),
                          const FlSpot(1, 2.5),
                          const FlSpot(2, 3.1),
                          const FlSpot(3, 2.2),
                          const FlSpot(4, 2),
                          const FlSpot(5, 1.5),
                          const FlSpot(6, 1.2),
                        ],
                        isCurved: true,
                        color: isPositive ? Colors.green : Colors.red,
                        barWidth: 2.5,
                        belowBarData: BarAreaData(show: false),
                        dotData: FlDotData(show: false),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 5),

              // 🔹 Percentage Increase/Decrease
              Row(
                children: [
                  Icon(
                    isPositive ? Icons.arrow_upward : Icons.arrow_downward,
                    color: isPositive ? Colors.green : Colors.red,
                    size: 18,
                  ),
                  Text(
                    "${percentage.toStringAsFixed(1)}%",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isPositive ? Colors.green : Colors.red,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
