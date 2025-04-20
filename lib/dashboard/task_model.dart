class SubTask {
  final String id;
  final String title;
  final bool isCompleted;

  SubTask({
    required this.id,
    required this.title,
    this.isCompleted = false,
  });

  factory SubTask.fromJson(Map<String, dynamic> json) {
    return SubTask(
      id: json['id'],
      title: json['title'],
      isCompleted: json['is_completed'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'is_completed': isCompleted,
    };
  }

  SubTask copyWith({
    String? id,
    String? title,
    bool? isCompleted,
  }) {
    return SubTask(
      id: id ?? this.id,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}

class Task {
  final String id;
  final String title;
  final String? details;
  final DateTime? dueDate;
  final DateTime createdAt;
  final List<String>? teamMembers;
  final double progress;
  final bool isCompleted;
  final List<SubTask>? subTasks;

  Task({
    required this.id,
    required this.title,
    this.details,
    this.dueDate,
    required this.createdAt,
    this.teamMembers,
    required this.progress,
    required this.isCompleted,
    this.subTasks,
  });

  // Create a Task from JSON data
  factory Task.fromJson(Map<String, dynamic> json) {
    List<SubTask>? subTasks;
    if (json['sub_tasks'] != null) {
      subTasks = (json['sub_tasks'] as List)
          .map((item) => SubTask.fromJson(item))
          .toList();
    }

    List<String>? teamMembers;
    if (json['team_members'] != null) {
      teamMembers = List<String>.from(json['team_members']);
    }

    return Task(
      id: json['id'],
      title: json['title'],
      details: json['details'],
      dueDate: json['due_date'] != null 
          ? DateTime.parse(json['due_date']) 
          : null,
      createdAt: DateTime.parse(json['created_at']),
      teamMembers: teamMembers,
      progress: (json['progress'] ?? 0).toDouble(),
      isCompleted: json['is_completed'] ?? false,
      subTasks: subTasks,
    );
  }

  // Convert Task to JSON
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'title': title,
      'is_completed': isCompleted,
      'progress': progress,
      'created_at': createdAt.toIso8601String(),
    };

    if (details != null) data['details'] = details;
    if (dueDate != null) data['due_date'] = dueDate!.toIso8601String();
    if (teamMembers != null) data['team_members'] = teamMembers;
    if (subTasks != null) {
      data['sub_tasks'] = subTasks!.map((task) => task.toJson()).toList();
    }

    return data;
  }

  // Create a copy of this Task with modifications
  Task copyWith({
    String? id,
    String? title,
    String? details,
    DateTime? dueDate,
    DateTime? createdAt,
    List<String>? teamMembers,
    double? progress,
    bool? isCompleted,
    List<SubTask>? subTasks,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      details: details ?? this.details,
      dueDate: dueDate ?? this.dueDate,
      createdAt: createdAt ?? this.createdAt,
      teamMembers: teamMembers ?? this.teamMembers,
      progress: progress ?? this.progress,
      isCompleted: isCompleted ?? this.isCompleted,
      subTasks: subTasks ?? this.subTasks,
    );
  }
}