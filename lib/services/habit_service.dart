import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/habit.dart';

class HabitService {
  static const String _habitsKey = 'habits';
  static const String _progressKey = 'habit_progress';

  // Habits CRUD
  Future<List<Habit>> getHabits() async {
    final prefs = await SharedPreferences.getInstance();
    final habitsJson = prefs.getStringList(_habitsKey) ?? [];
    return habitsJson.map((json) => Habit.fromJson(json)).toList();
  }

  Future<void> saveHabit(Habit habit) async {
    final habits = await getHabits();
    final existingIndex = habits.indexWhere((h) => h.id == habit.id);

    if (existingIndex >= 0) {
      habits[existingIndex] = habit;
    } else {
      habits.add(habit);
    }

    await _saveHabits(habits);
  }

  Future<void> deleteHabit(String habitId) async {
    final habits = await getHabits();
    habits.removeWhere((h) => h.id == habitId);
    await _saveHabits(habits);

    // Also delete related progress
    final progress = await getProgress();
    progress.removeWhere((p) => p.habitId == habitId);
    await _saveProgress(progress);
  }

  Future<void> _saveHabits(List<Habit> habits) async {
    final prefs = await SharedPreferences.getInstance();
    final habitsJson = habits.map((h) => h.toJson()).toList();
    await prefs.setStringList(_habitsKey, habitsJson);
  }

  // Progress CRUD
  Future<List<HabitProgress>> getProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final progressJson = prefs.getStringList(_progressKey) ?? [];
    return progressJson.map((json) => HabitProgress.fromJson(json)).toList();
  }

  Future<void> toggleProgress(String habitId, DateTime date) async {
    final progress = await getProgress();
    final dateKey =
        HabitProgress(habitId: habitId, date: date, completed: false).dateKey;

    final existingIndex = progress
        .indexWhere((p) => p.habitId == habitId && p.dateKey == dateKey);

    if (existingIndex >= 0) {
      progress[existingIndex] = HabitProgress(
        habitId: habitId,
        date: date,
        completed: !progress[existingIndex].completed,
      );
    } else {
      progress.add(HabitProgress(
        habitId: habitId,
        date: date,
        completed: true,
      ));
    }

    await _saveProgress(progress);
  }

  Future<void> _saveProgress(List<HabitProgress> progress) async {
    final prefs = await SharedPreferences.getInstance();
    final progressJson = progress.map((p) => p.toJson()).toList();
    await prefs.setStringList(_progressKey, progressJson);
  }

  Future<bool> isHabitCompleted(String habitId, DateTime date) async {
    final progress = await getProgress();
    final dateKey =
        HabitProgress(habitId: habitId, date: date, completed: false).dateKey;

    final habitProgress = progress.firstWhere(
      (p) => p.habitId == habitId && p.dateKey == dateKey,
      orElse: () =>
          HabitProgress(habitId: habitId, date: date, completed: false),
    );

    return habitProgress.completed;
  }

  Future<List<HabitProgress>> getProgressForDate(DateTime date) async {
    final progress = await getProgress();
    final dateKey =
        HabitProgress(habitId: '', date: date, completed: false).dateKey;

    return progress.where((p) => p.dateKey == dateKey).toList();
  }

  Future<double> getCompletionPercentage(DateTime date) async {
    final habits = await getHabits();
    if (habits.isEmpty) return 0.0;

    final progress = await getProgressForDate(date);
    final completedCount = progress.where((p) => p.completed).length;

    return completedCount / habits.length;
  }

  Future<Map<String, int>> getHabitCompletionStats(
      DateTime startDate, DateTime endDate) async {
    final habits = await getHabits();
    final progress = await getProgress();
    final stats = <String, int>{};

    // Filter progress within date range
    final filteredProgress = progress.where((p) {
      return p.date.isAfter(startDate.subtract(const Duration(days: 1))) &&
          p.date.isBefore(endDate.add(const Duration(days: 1))) &&
          p.completed;
    }).toList();

    // Group by habit
    for (final habit in habits) {
      final habitCompletions =
          filteredProgress.where((p) => p.habitId == habit.id).length;
      stats[habit.name] = habitCompletions;
    }

    return stats;
  }

  // Import/Export
  Future<Map<String, dynamic>> exportData() async {
    final habits = await getHabits();
    final progress = await getProgress();

    return {
      'habits': habits.map((h) => h.toMap()).toList(),
      'progress': progress.map((p) => p.toMap()).toList(),
      'exportDate': DateTime.now().millisecondsSinceEpoch,
    };
  }

  Future<void> importData(Map<String, dynamic> data) async {
    final habits =
        (data['habits'] as List).map((map) => Habit.fromMap(map)).toList();

    final progress = (data['progress'] as List)
        .map((map) => HabitProgress.fromMap(map))
        .toList();

    await _saveHabits(habits);
    await _saveProgress(progress);
  }

  Future<void> clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_habitsKey);
    await prefs.remove(_progressKey);
  }
}
