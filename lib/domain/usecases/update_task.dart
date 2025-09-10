import '../entities/task_entity.dart';
import '../repositories/task_repository.dart';

class UpdateTask {
  final TaskRepository repository;

  UpdateTask({required this.repository});

  Future<TaskEntity> call(TaskEntity task) async {
    return await repository.updateTask(task);
  }
}
