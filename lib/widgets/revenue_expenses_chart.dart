import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class RevenueExpensesChart extends StatelessWidget {
  const RevenueExpensesChart({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 250,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: 60000,
          barGroups: [
            makeGroupData(0, 48000, 32000), // Jan
            makeGroupData(1, 50000, 42000), // Feb
            makeGroupData(2, 52000, 38000), // Mar
            makeGroupData(3, 49000, 48000), // Apr
            makeGroupData(4, 53000, 46000), // May
          ],
          borderData: FlBorderData(
            show: true,
            border: Border.all(color: Colors.grey.shade300),
          ),
          gridData: FlGridData(
            show: true,
            drawHorizontalLine: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: Colors.grey.shade300,
                strokeWidth: 1,
              );
            },
          ),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 50, // Space for labels
                getTitlesWidget: (value, _) {
                  if (value % 10000 == 0) {
                    return Text('${(value ~/ 1000)}K', style: const TextStyle(fontSize: 12));
                  }
                  return const SizedBox();
                },
              ),
            ),
            rightTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, _) {
                  switch (value.toInt()) {
                    case 0: return const Text("Jan");
                    case 1: return const Text("Feb");
                    case 2: return const Text("Mar");
                    case 3: return const Text("Apr");
                    case 4: return const Text("May");
                    default: return const Text("");
                  }
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  // 🔹 Function to create grouped bars
  BarChartGroupData makeGroupData(int x, double revenue, double expenses) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: revenue,
          color: Colors.green,
          width: 12,
          borderRadius: BorderRadius.circular(4),
        ),
        BarChartRodData(
          toY: expenses,
          color: Colors.red,
          width: 12,
          borderRadius: BorderRadius.circular(4),
        ),
      ],
    );
  }
}
