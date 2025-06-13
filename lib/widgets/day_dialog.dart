import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/habit.dart';
import '../services/habit_service.dart';

class DayDialog extends StatefulWidget {
  final DateTime date;
  final List<Habit> habits;
  final Function(String habitId) onHabitToggled;

  const DayDialog({
    super.key,
    required this.date,
    required this.habits,
    required this.onHabitToggled,
  });

  @override
  State<DayDialog> createState() => _DayDialogState();
}

class _DayDialogState extends State<DayDialog> {
  final HabitService _habitService = HabitService();
  Map<String, bool> _habitStates = {};

  @override
  void initState() {
    super.initState();
    _loadHabitStates();
  }

  Future<void> _loadHabitStates() async {
    final states = <String, bool>{};

    for (final habit in widget.habits) {
      final isCompleted =
          await _habitService.isHabitCompleted(habit.id, widget.date);
      states[habit.id] = isCompleted;
    }

    if (mounted) {
      setState(() {
        _habitStates = states;
      });
    }
  }

  void _toggleHabit(String habitId) {
    setState(() {
      _habitStates[habitId] = !(_habitStates[habitId] ?? false);
    });
    widget.onHabitToggled(habitId);
  }

  @override
  Widget build(BuildContext context) {
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    final dateString = DateFormat('EEEE, MMMM d, y').format(widget.date);
    final completedCount =
        _habitStates.values.where((completed) => completed).length;
    final totalCount = widget.habits.length;

    final textColor = isDarkTheme ? Colors.white : Colors.black;
    final secondaryTextColor =
        isDarkTheme ? Colors.grey.shade300 : Colors.grey.shade600;
    final completedTextColor =
        isDarkTheme ? Colors.grey.shade400 : Colors.grey.shade600;

    return Dialog(
      backgroundColor: isDarkTheme ? const Color(0xFF1E1E1E) : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date header
            Text(
              dateString,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: textColor,
              ),
            ),

            if (totalCount > 0) ...[
              const SizedBox(height: 8),
              Text(
                '$completedCount / $totalCount habits completed',
                style: TextStyle(
                  fontSize: 14,
                  color: secondaryTextColor,
                ),
              ),
            ],

            const SizedBox(height: 16),

            // Habits list
            if (widget.habits.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Center(
                  child: Text(
                    'No habits yet.\nTap + to add your first habit!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: secondaryTextColor,
                      fontSize: 16,
                    ),
                  ),
                ),
              )
            else
              ...widget.habits.map((habit) {
                final isCompleted = _habitStates[habit.id] ?? false;

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: GestureDetector(
                    onTap: () => _toggleHabit(habit.id),
                    child: Row(
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: isCompleted
                                ? Color(habit.color)
                                : Colors.transparent,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Color(habit.color),
                              width: 2,
                            ),
                          ),
                          child: isCompleted
                              ? const Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 16,
                                )
                              : null,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            habit.name,
                            style: TextStyle(
                              fontSize: 16,
                              decoration: isCompleted
                                  ? TextDecoration.lineThrough
                                  : TextDecoration.none,
                              color:
                                  isCompleted ? completedTextColor : textColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),

            const SizedBox(height: 16),

            // Close button
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Close',
                  style: TextStyle(
                      color: isDarkTheme ? Colors.white70 : Colors.black87),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
