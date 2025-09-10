enum TaskStatus { todo, inProgress, done }

enum TaskPriority { high, medium, low }

class TaskEntity {
  final String id;
  final String title;
  final String description;
  final TaskStatus status;
  final TaskPriority priority;
  final DateTime createdAt;

  const TaskEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.priority,
    required this.createdAt,
  });

  TaskEntity copyWith({
    String? id,
    String? title,
    String? description,
    TaskStatus? status,
    TaskPriority? priority,
    DateTime? createdAt,
  }) {
    return TaskEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TaskEntity &&
        other.id == id &&
        other.title == title &&
        other.description == description &&
        other.status == status &&
        other.priority == priority &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        title.hashCode ^
        description.hashCode ^
        status.hashCode ^
        priority.hashCode ^
        createdAt.hashCode;
  }

  @override
  String toString() {
    return 'TaskEntity(id: $id, title: $title, description: $description, status: $status, priority: $priority, createdAt: $createdAt)';
  }
}
