import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../models/habit.dart';
import '../services/habit_service.dart';
import '../widgets/dashboard_charts.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final HabitService _habitService = HabitService();
  List<Habit> _habits = [];
  double _currentCompletionRate = 0.0;
  Map<String, double> _weeklyCompletionRates = {};
  Map<String, int> _habitCategoryCounts = {};
  Map<String, int> _habitCompletionStats = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    final habits = await _habitService.getHabits();
    final currentPercentage =
        await _habitService.getCompletionPercentage(DateTime.now());

    // Calculate weekly completion rates
    final weeklyRates = <String, double>{};
    final today = DateTime.now();

    for (int i = 6; i >= 0; i--) {
      final date = today.subtract(Duration(days: i));
      final percentage = await _habitService.getCompletionPercentage(date);
      final dayName = DateFormat('E').format(date); // Mon, Tue, etc.
      weeklyRates[dayName] = percentage;
    }

    // Calculate habit frequency distribution
    final habitCounts = <String, int>{
      'Daily': 0,
      'Weekly': 0,
      'Monthly': 0,
    };

    for (final habit in habits) {
      habitCounts[habit.frequency.displayName] =
          (habitCounts[habit.frequency.displayName] ?? 0) + 1;
    }

    // Get habit completion stats for the last 7 days
    final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));
    final completionStats = await _habitService.getHabitCompletionStats(
        sevenDaysAgo, DateTime.now());

    setState(() {
      _habits = habits;
      _currentCompletionRate = currentPercentage;
      _weeklyCompletionRates = weeklyRates;
      _habitCategoryCounts = habitCounts;
      _habitCompletionStats = completionStats;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDarkTheme ? Colors.white : Colors.black;
    final borderColor =
        isDarkTheme ? Colors.grey.shade700 : Colors.grey.shade300;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Dashboard',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.normal,
            color: textColor,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Today's completion rate
                  _buildSectionTitle('Today\'s Progress'),
                  DashboardCharts.buildCompletionRateIndicator(
                    _currentCompletionRate,
                    'Completion Rate',
                  ),
                  const SizedBox(height: 32),

                  // Weekly trend chart
                  _buildSectionTitle('Weekly Trend'),
                  SizedBox(
                    height: 200,
                    child: DashboardCharts.buildWeeklyTrendChart(
                      _weeklyCompletionRates,
                      isDarkMode: isDarkTheme,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Habit distribution
                  _buildSectionTitle('Habit Distribution'),
                  SizedBox(
                    height: 200,
                    child: DashboardCharts.buildHabitDistributionChart(
                      _habitCategoryCounts,
                      isDarkMode: isDarkTheme,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Habit completion stats
                  _buildSectionTitle('Habit Completion (Last 7 Days)'),
                  _buildCompletionStatsTable(borderColor, textColor),
                  const SizedBox(height: 32),

                  // Habit count summary
                  _buildHabitSummary(borderColor, textColor),
                  const SizedBox(height: 16),
                ],
              ),
            ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w500,
          color: Theme.of(context).textTheme.titleLarge?.color,
        ),
      ),
    );
  }

  Widget _buildCompletionStatsTable(Color borderColor, Color textColor) {
    if (_habitCompletionStats.isEmpty) {
      return Center(
        child: Text(
          'No completion data available',
          style: TextStyle(color: textColor),
        ),
      );
    }

    // Sort habits by completion count (descending)
    final sortedStats = _habitCompletionStats.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: borderColor),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Table(
          columnWidths: const {
            0: FlexColumnWidth(3),
            1: FlexColumnWidth(1),
          },
          children: [
            TableRow(
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: borderColor),
                ),
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Habit',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Completed',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
            ...sortedStats
                .map((entry) => TableRow(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            entry.key,
                            style: TextStyle(color: textColor),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            '${entry.value}',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: textColor),
                          ),
                        ),
                      ],
                    ))
                .toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildHabitSummary(Color borderColor, Color textColor) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: borderColor),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Summary',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: textColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Total Habits: ${_habits.length}',
              style: TextStyle(color: textColor),
            ),
            const SizedBox(height: 4),
            Text(
              'Daily Habits: ${_habitCategoryCounts['Daily'] ?? 0}',
              style: TextStyle(color: textColor),
            ),
            const SizedBox(height: 4),
            Text(
              'Weekly Habits: ${_habitCategoryCounts['Weekly'] ?? 0}',
              style: TextStyle(color: textColor),
            ),
            const SizedBox(height: 4),
            Text(
              'Monthly Habits: ${_habitCategoryCounts['Monthly'] ?? 0}',
              style: TextStyle(color: textColor),
            ),
          ],
        ),
      ),
    );
  }
}
