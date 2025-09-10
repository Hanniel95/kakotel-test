import '../../domain/entities/task_entity.dart';
import '../../domain/repositories/task_repository.dart';
import '../datasources/task_local_datasource.dart';

class TaskRepositoryImpl implements TaskRepository {
  final TaskLocalDataSource _localDataSource;

  TaskRepositoryImpl({required TaskLocalDataSource localDataSource})
      : _localDataSource = localDataSource;

  @override
  Future<List<TaskEntity>> getTasks() async {
    try {
      return await _localDataSource.getTasks();
    } catch (e) {
      throw Exception('Failed to get tasks: $e');
    }
  }

  @override
  Future<TaskEntity> getTaskById(String id) async {
    try {
      return await _localDataSource.getTaskById(id);
    } catch (e) {
      throw Exception('Failed to get task by id: $e');
    }
  }

  @override
  Future<TaskEntity> addTask(TaskEntity task) async {
    try {
      return await _localDataSource.addTask(task);
    } catch (e) {
      throw Exception('Failed to add task: $e');
    }
  }

  @override
  Future<TaskEntity> updateTask(TaskEntity task) async {
    try {
      return await _localDataSource.updateTask(task);
    } catch (e) {
      throw Exception('Failed to update task: $e');
    }
  }

  @override
  Future<void> deleteTask(String id) async {
    try {
      await _localDataSource.deleteTask(id);
    } catch (e) {
      throw Exception('Failed to delete task: $e');
    }
  }

  @override
  Future<void> clearAllTasks() async {
    try {
      await _localDataSource.clearAllTasks();
    } catch (e) {
      throw Exception('Failed to clear all tasks: $e');
    }
  }
}
