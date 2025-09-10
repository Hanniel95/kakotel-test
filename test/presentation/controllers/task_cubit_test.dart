import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:kakotel_test/presentation/controllers/task_cubit.dart';
import 'package:kakotel_test/domain/entities/task_entity.dart';
import 'package:kakotel_test/domain/usecases/add_task.dart';
import 'package:kakotel_test/domain/usecases/delete_task.dart';
import 'package:kakotel_test/domain/usecases/get_tasks.dart';
import 'package:kakotel_test/domain/usecases/update_task.dart';

class MockAddTask extends Mock implements AddTask {}

class MockUpdateTask extends Mock implements UpdateTask {}

class MockDeleteTask extends Mock implements DeleteTask {}

class MockGetTasks extends Mock implements GetTasks {}

void main() {
  late MockAddTask mockAddTask;
  late MockUpdateTask mockUpdateTask;
  late MockDeleteTask mockDeleteTask;
  late MockGetTasks mockGetTasks;
  late TaskCubit cubit;

  setUp(() {
    mockAddTask = MockAddTask();
    mockUpdateTask = MockUpdateTask();
    mockDeleteTask = MockDeleteTask();
    mockGetTasks = MockGetTasks();

    cubit = TaskCubit(
      addTask: mockAddTask,
      updateTask: mockUpdateTask,
      deleteTask: mockDeleteTask,
      getTasks: mockGetTasks,
    );
  });

  tearDown(() {
    cubit.close();
  });

  final sampleTask = TaskEntity(
    id: '1',
    title: 'Title',
    description: 'Desc',
    status: TaskStatus.todo,
    priority: TaskPriority.medium,
    createdAt: DateTime(2024, 1, 1),
  );

  test('initial state is TaskInitial', () {
    expect(cubit.state, isA<TaskInitial>());
  });

  blocTest<TaskCubit, TaskState>(
    'emits [TaskLoading, TaskLoaded] on successful loadTasks',
    build: () {
      when(() => mockGetTasks()).thenAnswer((_) async => [sampleTask]);
      return cubit;
    },
    act: (c) => c.loadTasks(),
    expect: () => [
      isA<TaskLoading>(),
      isA<TaskLoaded>().having(
        (s) => (s as TaskLoaded).tasks.length,
        'tasks length',
        1,
      ),
    ],
  );

  blocTest<TaskCubit, TaskState>(
    'emits TaskError when loadTasks throws',
    build: () {
      when(() => mockGetTasks()).thenThrow(Exception('boom'));
      return cubit;
    },
    act: (c) => c.loadTasks(),
    expect: () => [isA<TaskLoading>(), isA<TaskError>()],
  );

  blocTest<TaskCubit, TaskState>(
    'addTask calls usecase and reloads',
    build: () {
      when(
        () => mockAddTask(
          title: any(named: 'title'),
          description: any(named: 'description'),
          status: any(named: 'status'),
          priority: any(named: 'priority'),
        ),
      ).thenAnswer((_) async => sampleTask);
      when(() => mockGetTasks()).thenAnswer((_) async => [sampleTask]);
      return cubit;
    },
    act: (c) async {
      await c.addTask(title: 'Title', description: 'Desc');
    },
    expect: () => [isA<TaskLoading>(), isA<TaskLoaded>()],
    verify: (_) {
      verify(
        () => mockAddTask(
          title: any(named: 'title'),
          description: any(named: 'description'),
          status: any(named: 'status'),
          priority: any(named: 'priority'),
        ),
      ).called(1);
      verify(() => mockGetTasks()).called(1);
    },
  );

  blocTest<TaskCubit, TaskState>(
    'filterTasks by status and priority',
    build: () {
      when(() => mockGetTasks()).thenAnswer(
        (_) async => [
          sampleTask,
          sampleTask.copyWith(id: '2', priority: TaskPriority.high),
          sampleTask.copyWith(id: '3', status: TaskStatus.done),
        ],
      );
      return cubit;
    },
    act: (c) async {
      await c.loadTasks();
      c.filterTasks(status: TaskStatus.todo);
      c.filterTasks(priority: TaskPriority.high);
    },
    expect: () => [
      isA<TaskLoading>(),
      isA<TaskLoaded>(),
      isA<TaskLoaded>().having(
        (s) => (s as TaskLoaded).filteredTasks.every(
          (t) => t.status == TaskStatus.todo,
        ),
        'status filter applied',
        true,
      ),
      isA<TaskLoaded>().having(
        (s) => (s as TaskLoaded).filteredTasks.every(
          (t) => t.priority == TaskPriority.high,
        ),
        'priority filter applied',
        true,
      ),
    ],
  );

  blocTest<TaskCubit, TaskState>(
    'sortByPriority orders high->low',
    build: () {
      when(() => mockGetTasks()).thenAnswer(
        (_) async => [
          sampleTask.copyWith(id: '1', priority: TaskPriority.low),
          sampleTask.copyWith(id: '2', priority: TaskPriority.high),
          sampleTask.copyWith(id: '3', priority: TaskPriority.medium),
        ],
      );
      return cubit;
    },
    act: (c) async {
      await c.loadTasks();
      c.sortByPriority();
    },
    expect: () => [
      isA<TaskLoading>(),
      isA<TaskLoaded>(),
      isA<TaskLoaded>().having(
        (s) => (s as TaskLoaded).filteredTasks.map((t) => t.priority).toList(),
        'sorted priorities',
        [TaskPriority.high, TaskPriority.medium, TaskPriority.low],
      ),
    ],
  );
}
