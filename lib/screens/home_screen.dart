import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/habit.dart';
import '../services/habit_service.dart';
import '../widgets/habit_circle.dart';
import '../widgets/day_dialog.dart';
import '../widgets/habit_list.dart';
import 'add_habit_screen.dart';
import 'settings_screen.dart';
import 'dashboard_screen.dart';

class HomeScreen extends StatefulWidget {
  final Function? onThemeChanged;

  const HomeScreen({
    super.key,
    this.onThemeChanged,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final HabitService _habitService = HabitService();
  List<Habit> _habits = [];
  DateTime _currentMonth = DateTime.now();
  double _completionPercentage = 0.0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final habits = await _habitService.getHabits();
    final percentage =
        await _habitService.getCompletionPercentage(DateTime.now());

    setState(() {
      _habits = habits;
      _completionPercentage = percentage;
    });
  }

  List<DateTime> _getDaysInMonth(DateTime month) {
    final firstDay = DateTime(month.year, month.month, 1);
    final lastDay = DateTime(month.year, month.month + 1, 0);

    List<DateTime> days = [];
    for (int i = 0; i < lastDay.day; i++) {
      days.add(firstDay.add(Duration(days: i)));
    }

    // Add empty days at the beginning to align with weekdays
    final startWeekday = firstDay.weekday;
    final emptyDays = (startWeekday - 1) % 7;
    for (int i = 0; i < emptyDays; i++) {
      days.insert(0, firstDay.subtract(Duration(days: emptyDays - i)));
    }

    return days;
  }

  void _previousMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1);
    });
  }

  void _showDayDialog(DateTime date) {
    showDialog(
      context: context,
      builder: (context) => DayDialog(
        date: date,
        habits: _habits,
        onHabitToggled: (habitId) async {
          await _habitService.toggleProgress(habitId, date);
          _loadData();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final days = _getDaysInMonth(_currentMonth);
    final monthName = DateFormat('MMMM yyyy').format(_currentMonth);
    final iconColor = Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Text(
              'habitat',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.normal,
                color: iconColor,
              ),
            ),
            Container(
              margin: const EdgeInsets.only(left: 8, top: 20),
              height: 2,
              width: 60,
              decoration: const BoxDecoration(
                color: Colors.red,
              ),
            ),
          ],
        ),
        actions: [
          Text(
            '${(_completionPercentage * 100).round()}%',
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const DashboardScreen()),
              );
              _loadData();
            },
            icon: Icon(Icons.dashboard, color: iconColor),
            tooltip: 'Dashboard',
          ),
          IconButton(
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AddHabitScreen()),
              );
              _loadData();
            },
            icon: Icon(Icons.add, color: iconColor),
          ),
          IconButton(
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SettingsScreen(
                    onThemeChanged: () {
                      if (widget.onThemeChanged != null) {
                        widget.onThemeChanged!();
                      }
                    },
                  ),
                ),
              );
              _loadData();
            },
            icon: Icon(Icons.settings, color: iconColor),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Month navigation
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  monthName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      onPressed: _previousMonth,
                      icon: const Icon(Icons.chevron_left),
                    ),
                    IconButton(
                      onPressed: _nextMonth,
                      icon: const Icon(Icons.chevron_right),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Calendar grid
            SizedBox(
              height: MediaQuery.of(context).size.width *
                  0.7, // Fixed height for calendar
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                  childAspectRatio: 1,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: days.length,
                itemBuilder: (context, index) {
                  final date = days[index];
                  final isCurrentMonth = date.month == _currentMonth.month;

                  return GestureDetector(
                    onTap: isCurrentMonth ? () => _showDayDialog(date) : null,
                    child: HabitCircle(
                      date: date,
                      habits: _habits,
                      isCurrentMonth: isCurrentMonth,
                    ),
                  );
                },
              ),
            ),

            // Section title for habits list
            if (_habits.isNotEmpty) ...[
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'My Habits',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    '${_habits.length} habits',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],

            // Habits list
            Expanded(
              child: HabitList(
                habits: _habits,
                onHabitUpdated: _loadData,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
