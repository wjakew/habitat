import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class DashboardCharts {
  static Widget buildCompletionRateIndicator(
      double completionRate, String label) {
    return Builder(builder: (context) {
      final isDarkMode = Theme.of(context).brightness == Brightness.dark;
      final textColor = isDarkMode ? Colors.white : Colors.black;
      final secondaryTextColor =
          isDarkMode ? Colors.grey.shade300 : Colors.grey.shade600;
      final emptyColor =
          isDarkMode ? Colors.grey.shade700 : Colors.grey.shade300;

      return SizedBox(
        height: 180,
        child: Stack(
          alignment: Alignment.center,
          children: [
            PieChart(
              PieChartData(
                sectionsSpace: 0,
                centerSpaceRadius: 60,
                sections: [
                  PieChartSectionData(
                    value: completionRate * 100,
                    color: Colors.green,
                    radius: 20,
                    showTitle: false,
                  ),
                  PieChartSectionData(
                    value: (1 - completionRate) * 100,
                    color: emptyColor,
                    radius: 20,
                    showTitle: false,
                  ),
                ],
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${(completionRate * 100).round()}%',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                Text(
                  label,
                  style: TextStyle(
                    color: secondaryTextColor,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }

  static Widget buildWeeklyTrendChart(Map<String, double> weeklyRates,
      {bool isDarkMode = false}) {
    final entries = weeklyRates.entries.toList();
    final textColor = isDarkMode ? Colors.grey.shade300 : Colors.grey.shade600;

    return LineChart(
      LineChartData(
        gridData: FlGridData(show: false),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              getTitlesWidget: (value, meta) {
                return Text(
                  '${(value * 100).round()}%',
                  style: TextStyle(
                    color: textColor,
                    fontSize: 12,
                  ),
                );
              },
            ),
          ),
          rightTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value < 0 || value >= entries.length) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    entries[value.toInt()].key,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 12,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        minX: 0,
        maxX: entries.length - 1,
        minY: 0,
        maxY: 1,
        lineBarsData: [
          LineChartBarData(
            spots: entries
                .asMap()
                .entries
                .map((entry) => FlSpot(entry.key.toDouble(), entry.value.value))
                .toList(),
            isCurved: true,
            color: Colors.blue,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(show: true),
            belowBarData: BarAreaData(
              show: true,
              color: Colors.blue.withOpacity(0.2),
            ),
          ),
        ],
      ),
    );
  }

  static Widget buildHabitDistributionChart(Map<String, int> habitCounts,
      {bool isDarkMode = false}) {
    final entries = habitCounts.entries.toList();
    final total = entries.fold(0, (sum, entry) => sum + entry.value);
    final textColor = isDarkMode ? Colors.white : Colors.black;

    if (total == 0) {
      return Center(
        child: Text(
          'No habits to display',
          style: TextStyle(color: textColor),
        ),
      );
    }

    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
    ];

    return PieChart(
      PieChartData(
        sectionsSpace: 2,
        centerSpaceRadius: 40,
        sections: entries.asMap().entries.map((entry) {
          final index = entry.key;
          final data = entry.value;
          final percentage = data.value / total;

          return PieChartSectionData(
            value: data.value.toDouble(),
            title: '${(percentage * 100).round()}%',
            color: colors[index % colors.length],
            radius: 80,
            titleStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          );
        }).toList(),
      ),
    );
  }
}
