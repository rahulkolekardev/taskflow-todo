import 'package:flutter/material.dart';

enum TaskPriority {
  low('Low', Colors.blue, Icons.arrow_downward_rounded),
  medium('Medium', Colors.amber, Icons.remove_rounded),
  high('High', Colors.orange, Icons.arrow_upward_rounded),
  urgent('Urgent', Colors.redAccent, Icons.priority_high_rounded);

  final String label;
  final MaterialColor color;
  final IconData icon;

  const TaskPriority(this.label, this.color, this.icon);
}

enum TaskCategory {
  work('Work', Icons.work_outline_rounded, Color(0xFF6366F1)),
  personal('Personal', Icons.person_outline_rounded, Color(0xFF06B6D4)),
  fitness('Fitness', Icons.fitness_center_rounded, Color(0xFF10B981)),
  study('Study', Icons.school_outlined, Color(0xFF8B5CF6)),
  shopping('Shopping', Icons.shopping_bag_outlined, Color(0xFFF59E0B)),
  finance('Finance', Icons.account_balance_wallet_outlined, Color(0xFFEC4899));

  final String label;
  final IconData icon;
  final Color color;

  const TaskCategory(this.label, this.icon, this.color);
}

class Task {
  final String id;
  String title;
  String description;
  bool isCompleted;
  TaskPriority priority;
  TaskCategory category;
  DateTime dueDate;
  final DateTime createdAt;

  Task({
    required this.id,
    required this.title,
    this.description = '',
    this.isCompleted = false,
    this.priority = TaskPriority.medium,
    this.category = TaskCategory.work,
    required this.dueDate,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Task copyWith({
    String? id,
    String? title,
    String? description,
    bool? isCompleted,
    TaskPriority? priority,
    TaskCategory? category,
    DateTime? dueDate,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
      priority: priority ?? this.priority,
      category: category ?? this.category,
      dueDate: dueDate ?? this.dueDate,
      createdAt: createdAt,
    );
  }
}
