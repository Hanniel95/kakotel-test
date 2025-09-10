import '../entities/task_entity.dart';
import '../repositories/task_repository.dart';

class GetTasks {
  final TaskRepository repository;

  GetTasks({required this.repository});

  Future<List<TaskEntity>> call() async {
    return await repository.getTasks();
  }
}
