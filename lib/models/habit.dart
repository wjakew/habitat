import 'dart:convert';

class Habit {
  final String id;
  final String name;
  final int color; // Color value as int
  final HabitFrequency frequency;
  final DateTime createdAt;

  Habit({
    required this.id,
    required this.name,
    required this.color,
    required this.frequency,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'color': color,
      'frequency': frequency.index,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }

  factory Habit.fromMap(Map<String, dynamic> map) {
    return Habit(
      id: map['id'],
      name: map['name'],
      color: map['color'],
      frequency: HabitFrequency.values[map['frequency']],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
    );
  }

  String toJson() => json.encode(toMap());
  factory Habit.fromJson(String source) => Habit.fromMap(json.decode(source));

  Habit copyWith({
    String? id,
    String? name,
    int? color,
    HabitFrequency? frequency,
    DateTime? createdAt,
  }) {
    return Habit(
      id: id ?? this.id,
      name: name ?? this.name,
      color: color ?? this.color,
      frequency: frequency ?? this.frequency,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class HabitProgress {
  final String habitId;
  final DateTime date;
  final bool completed;

  HabitProgress({
    required this.habitId,
    required this.date,
    required this.completed,
  });

  Map<String, dynamic> toMap() {
    return {
      'habitId': habitId,
      'date': date.millisecondsSinceEpoch,
      'completed': completed,
    };
  }

  factory HabitProgress.fromMap(Map<String, dynamic> map) {
    return HabitProgress(
      habitId: map['habitId'],
      date: DateTime.fromMillisecondsSinceEpoch(map['date']),
      completed: map['completed'],
    );
  }

  String toJson() => json.encode(toMap());
  factory HabitProgress.fromJson(String source) =>
      HabitProgress.fromMap(json.decode(source));

  String get dateKey =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
}

enum HabitFrequency {
  daily,
  weekly,
  monthly,
}

extension HabitFrequencyExtension on HabitFrequency {
  String get displayName {
    switch (this) {
      case HabitFrequency.daily:
        return 'Daily';
      case HabitFrequency.weekly:
        return 'Weekly';
      case HabitFrequency.monthly:
        return 'Monthly';
    }
  }
}
