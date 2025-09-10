import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/task_entity.dart';
import '../../domain/usecases/add_task.dart';
import '../../domain/usecases/update_task.dart';
import '../../domain/usecases/delete_task.dart';
import '../../domain/usecases/get_tasks.dart';

// States
abstract class TaskState {}

class TaskInitial extends TaskState {}

class TaskLoading extends TaskState {}

class TaskLoaded extends TaskState {
  final List<TaskEntity> tasks;
  final List<TaskEntity> filteredTasks;
  final TaskStatus? statusFilter;
  final TaskPriority? priorityFilter;

  TaskLoaded({
    required this.tasks,
    required this.filteredTasks,
    this.statusFilter,
    this.priorityFilter,
  });

  TaskLoaded copyWith({
    List<TaskEntity>? tasks,
    List<TaskEntity>? filteredTasks,
    TaskStatus? statusFilter,
    TaskPriority? priorityFilter,
  }) {
    return TaskLoaded(
      tasks: tasks ?? this.tasks,
      filteredTasks: filteredTasks ?? this.filteredTasks,
      statusFilter: statusFilter ?? this.statusFilter,
      priorityFilter: priorityFilter ?? this.priorityFilter,
    );
  }
}

class TaskError extends TaskState {
  final String message;

  TaskError({required this.message});
}

// Cubit
class TaskCubit extends Cubit<TaskState> {
  final AddTask _addTask;
  final UpdateTask _updateTask;
  final DeleteTask _deleteTask;
  final GetTasks _getTasks;

  TaskCubit({
    required AddTask addTask,
    required UpdateTask updateTask,
    required DeleteTask deleteTask,
    required GetTasks getTasks,
  }) : _addTask = addTask,
       _updateTask = updateTask,
       _deleteTask = deleteTask,
       _getTasks = getTasks,
       super(TaskInitial());

  Future<void> loadTasks() async {
    emit(TaskLoading());
    try {
      final tasks = await _getTasks();
      emit(TaskLoaded(tasks: tasks, filteredTasks: tasks));
    } catch (e) {
      emit(TaskError(message: 'Failed to load tasks: $e'));
    }
  }

  Future<void> addTask({
    required String title,
    required String description,
    TaskStatus status = TaskStatus.todo,
    TaskPriority priority = TaskPriority.medium,
  }) async {
    try {
      await _addTask(
        title: title,
        description: description,
        status: status,
        priority: priority,
      );
      await loadTasks();
    } catch (e) {
      emit(TaskError(message: 'Failed to add task: $e'));
    }
  }

  Future<void> updateTask(TaskEntity task) async {
    try {
      await _updateTask(task);
      await loadTasks();
    } catch (e) {
      emit(TaskError(message: 'Failed to update task: $e'));
    }
  }

  Future<void> deleteTask(String taskId) async {
    try {
      await _deleteTask(taskId);
      await loadTasks();
    } catch (e) {
      emit(TaskError(message: 'Failed to delete task: $e'));
    }
  }

  void filterTasks({TaskStatus? status, TaskPriority? priority}) {
    final currentState = state;
    if (currentState is! TaskLoaded) return;

    List<TaskEntity> filtered = currentState.tasks;

    if (status != null) {
      filtered = filtered.where((task) => task.status == status).toList();
    }

    if (priority != null) {
      filtered = filtered.where((task) => task.priority == priority).toList();
    }

    emit(
      currentState.copyWith(
        filteredTasks: filtered,
        statusFilter: status,
        priorityFilter: priority,
      ),
    );
  }

  void clearFilters() {
    final currentState = state;
    if (currentState is! TaskLoaded) return;

    emit(
      currentState.copyWith(
        filteredTasks: currentState.tasks,
        statusFilter: null,
        priorityFilter: null,
      ),
    );
  }

  void sortByPriority() {
    final currentState = state;
    if (currentState is! TaskLoaded) return;

    final priorityOrder = {
      TaskPriority.high: 0,
      TaskPriority.medium: 1,
      TaskPriority.low: 2,
    };

    final sortedTasks = List<TaskEntity>.from(currentState.filteredTasks)
      ..sort(
        (a, b) =>
            priorityOrder[a.priority]!.compareTo(priorityOrder[b.priority]!),
      );

    emit(currentState.copyWith(filteredTasks: sortedTasks));
  }

  void sortByCreatedDate({bool ascending = true}) {
    final currentState = state;
    if (currentState is! TaskLoaded) return;

    final sortedTasks = List<TaskEntity>.from(currentState.filteredTasks)
      ..sort(
        (a, b) => ascending
            ? a.createdAt.compareTo(b.createdAt)
            : b.createdAt.compareTo(a.createdAt),
      );

    emit(currentState.copyWith(filteredTasks: sortedTasks));
  }
}
