import 'package:flutter/material.dart';
import '../models/habit.dart';
import '../services/habit_service.dart';
import '../screens/add_habit_screen.dart';

class HabitList extends StatelessWidget {
  final List<Habit> habits;
  final Function onHabitUpdated;

  const HabitList({
    super.key,
    required this.habits,
    required this.onHabitUpdated,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;

    if (habits.isEmpty) {
      return const Center(
        child: Text(
          'No habits yet. Add one to get started!',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const BouncingScrollPhysics(),
      itemCount: habits.length,
      itemBuilder: (context, index) {
        final habit = habits[index];

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 4),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(
              color: isDarkTheme ? Colors.grey.shade800 : Colors.grey.shade300,
            ),
          ),
          child: ListTile(
            leading: Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: Color(habit.color),
                shape: BoxShape.circle,
              ),
            ),
            title: Text(
              habit.name,
              style: const TextStyle(fontSize: 16),
            ),
            subtitle: Text(
              habit.frequency.displayName,
              style: TextStyle(
                fontSize: 12,
                color:
                    isDarkTheme ? Colors.grey.shade400 : Colors.grey.shade600,
              ),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, size: 20),
                  onPressed: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddHabitScreen(habit: habit),
                      ),
                    );
                    onHabitUpdated();
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete, size: 20, color: Colors.red),
                  onPressed: () => _confirmDelete(context, habit),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _confirmDelete(BuildContext context, Habit habit) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Habit'),
        content: Text('Are you sure you want to delete "${habit.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final habitService = HabitService();
      await habitService.deleteHabit(habit.id);
      onHabitUpdated();
    }
  }
}
