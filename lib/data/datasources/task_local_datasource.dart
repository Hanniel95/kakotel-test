import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/task_model.dart';
import '../../domain/entities/task_entity.dart';

abstract class TaskLocalDataSource {
  Future<List<TaskEntity>> getTasks();
  Future<TaskEntity> getTaskById(String id);
  Future<TaskEntity> addTask(TaskEntity task);
  Future<TaskEntity> updateTask(TaskEntity task);
  Future<void> deleteTask(String id);
  Future<void> clearAllTasks();
}

class TaskLocalDataSourceImpl implements TaskLocalDataSource {
  static const String _tasksKey = 'tasks';
  final SharedPreferences _prefs;

  TaskLocalDataSourceImpl({required SharedPreferences prefs}) : _prefs = prefs;

  @override
  Future<List<TaskEntity>> getTasks() async {
    final tasksJson = _prefs.getStringList(_tasksKey) ?? [];
    if (tasksJson.isEmpty) return [];
    
    final tasksList = tasksJson
        .map((json) => jsonDecode(json) as Map<String, dynamic>)
        .toList();
    
    return TaskModel.fromJsonList(tasksList);
  }

  @override
  Future<TaskEntity> getTaskById(String id) async {
    final tasks = await getTasks();
    try {
      return tasks.firstWhere((task) => task.id == id);
    } catch (e) {
      throw Exception('Task $id not found');
    }
  }

  @override
  Future<TaskEntity> addTask(TaskEntity task) async {
    final tasks = await getTasks();
    final taskModel = TaskModel.fromEntity(task);
    final updatedTasks = [...tasks, taskModel];
    
    await _saveTasks(updatedTasks);
    return task;
  }

  @override
  Future<TaskEntity> updateTask(TaskEntity task) async {
    final tasks = await getTasks();
    final taskIndex = tasks.indexWhere((t) => t.id == task.id);
    
    if (taskIndex == -1) {
      throw Exception('Task ${task.id} not found');
    }
    
    final updatedTasks = List<TaskEntity>.from(tasks);
    updatedTasks[taskIndex] = task;
    
    await _saveTasks(updatedTasks);
    return task;
  }

  @override
  Future<void> deleteTask(String id) async {
    final tasks = await getTasks();
    final updatedTasks = tasks.where((task) => task.id != id).toList();
    
    await _saveTasks(updatedTasks);
  }

  @override
  Future<void> clearAllTasks() async {
    await _prefs.remove(_tasksKey);
  }

  Future<void> _saveTasks(List<TaskEntity> tasks) async {
    final tasksJson = tasks
        .map((task) => jsonEncode(TaskModel.fromEntity(task).toJson()))
        .toList();
    
    await _prefs.setStringList(_tasksKey, tasksJson);
  }
}
