import 'package:flutter/material.dart';
import '../models/habit.dart';
import '../services/habit_service.dart';

class HabitCircle extends StatefulWidget {
  final DateTime date;
  final List<Habit> habits;
  final bool isCurrentMonth;

  const HabitCircle({
    super.key,
    required this.date,
    required this.habits,
    required this.isCurrentMonth,
  });

  @override
  State<HabitCircle> createState() => _HabitCircleState();
}

class _HabitCircleState extends State<HabitCircle> {
  final HabitService _habitService = HabitService();
  List<String> _completedHabitIds = [];

  @override
  void initState() {
    super.initState();
    _loadCompletedHabits();
  }

  @override
  void didUpdateWidget(HabitCircle oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.date != widget.date || oldWidget.habits != widget.habits) {
      _loadCompletedHabits();
    }
  }

  Future<void> _loadCompletedHabits() async {
    final completedIds = <String>[];

    for (final habit in widget.habits) {
      final isCompleted =
          await _habitService.isHabitCompleted(habit.id, widget.date);
      if (isCompleted) {
        completedIds.add(habit.id);
      }
    }

    if (mounted) {
      setState(() {
        _completedHabitIds = completedIds;
      });
    }
  }

  Color _mixColors(List<Color> colors) {
    if (colors.isEmpty) return Colors.transparent;
    if (colors.length == 1) return colors.first;

    double red = 0, green = 0, blue = 0;

    for (final color in colors) {
      red += color.red;
      green += color.green;
      blue += color.blue;
    }

    final count = colors.length;
    return Color.fromRGBO(
      (red / count).round(),
      (green / count).round(),
      (blue / count).round(),
      1.0,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    final isToday = widget.date.day == DateTime.now().day &&
        widget.date.month == DateTime.now().month &&
        widget.date.year == DateTime.now().year;

    final completedHabits = widget.habits
        .where((habit) => _completedHabitIds.contains(habit.id))
        .toList();

    final hasCompletedHabits = completedHabits.isNotEmpty;

    Color fillColor = Colors.transparent;
    if (hasCompletedHabits) {
      final colors = completedHabits.map((h) => Color(h.color)).toList();
      fillColor = _mixColors(colors);
    }

    // Colors for the circle border
    final borderColor = isToday
        ? (isDarkTheme ? Colors.white : Colors.black)
        : (isDarkTheme ? Colors.grey.shade600 : Colors.grey.shade400);

    // Colors for the text
    final textColor = widget.isCurrentMonth
        ? (hasCompletedHabits
            ? Colors.white
            : (isDarkTheme ? Colors.white : Colors.black))
        : (isDarkTheme ? Colors.grey.shade600 : Colors.grey.shade400);

    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: hasCompletedHabits ? fillColor : Colors.transparent,
        border: Border.all(
          color: borderColor,
          width: isToday ? 2 : 1,
        ),
      ),
      child: Center(
        child: Text(
          widget.date.day.toString(),
          style: TextStyle(
            color: textColor,
            fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}
