class Task {
  final int? id;
  final int userId;
  final String title;
  final String description;
  final bool isCompleted;

  const Task({
    this.id,
    required this.userId,
    required this.title,
    required this.description,
    this.isCompleted = false,
  });

  Task copyWith({
    int? id,
    int? userId,
    String? title,
    String? description,
    bool? isCompleted,
  }) {
    return Task(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  Map<String, Object?> toMap() {
    return {
      'user_id': userId,
      'title': title,
      'description': description,
      'is_completed': isCompleted ? 1 : 0,
    };
  }

  factory Task.fromMap(Map<String, Object?> map) {
    return Task(
      id: map['id'] as int,
      userId: map['user_id'] as int,
      title: map['title'] as String,
      description: map['description'] as String,
      isCompleted: (map['is_completed'] as int) == 1,
    );
  }
}
