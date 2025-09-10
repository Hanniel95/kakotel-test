import '../../domain/entities/task_entity.dart';
import '../../domain/repositories/task_repository.dart';
import '../datasources/task_local_datasource.dart';

class TaskRepositoryImpl implements TaskRepository {
  final TaskLocalDataSource _localDataSource;

  TaskRepositoryImpl({required TaskLocalDataSource localDataSource})
    : _localDataSource = localDataSource;

  @override
  Future<List<TaskEntity>> getTasks() async {
    return await _localDataSource.getTasks();
  }

  @override
  Future<TaskEntity> getTaskById(String id) async {
    return await _localDataSource.getTaskById(id);
  }

  @override
  Future<TaskEntity> addTask(TaskEntity task) async {
    return await _localDataSource.addTask(task);
  }

  @override
  Future<TaskEntity> updateTask(TaskEntity task) async {
    return await _localDataSource.updateTask(task);
  }

  @override
  Future<void> deleteTask(String id) async {
    await _localDataSource.deleteTask(id);
  }

  @override
  Future<void> clearAllTasks() async {
    await _localDataSource.clearAllTasks();
  }
}
