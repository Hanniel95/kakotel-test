import '../entities/task_entity.dart';
import '../repositories/task_repository.dart';

class AddTask {
  final TaskRepository repository;

  AddTask({required this.repository});

  Future<TaskEntity> call({
    required String title,
    required String description,
    TaskStatus status = TaskStatus.todo,
    TaskPriority priority = TaskPriority.medium,
  }) async {
    final task = TaskEntity(
      id: 'K-${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      description: description,
      status: status,
      priority: priority,
      createdAt: DateTime.now(),
    );

    return await repository.addTask(task);
  }
}
