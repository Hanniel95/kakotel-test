import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'presentation/pages/task_page.dart';
import 'presentation/controllers/task_cubit.dart';
import 'domain/usecases/add_task.dart';
import 'domain/usecases/update_task.dart';
import 'domain/usecases/delete_task.dart';
import 'domain/usecases/get_tasks.dart';
import 'data/datasources/task_local_datasource.dart';
import 'data/repositories/task_repository_impl.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  final dataSource = TaskLocalDataSourceImpl(prefs: prefs);
  final repository = TaskRepositoryImpl(localDataSource: dataSource);

  final addTask = AddTask(repository: repository);
  final updateTask = UpdateTask(repository: repository);
  final deleteTask = DeleteTask(repository: repository);
  final getTasks = GetTasks(repository: repository);

  runApp(MyApp(
    addTask: addTask,
    updateTask: updateTask,
    deleteTask: deleteTask,
    getTasks: getTasks,
  ));
}

class MyApp extends StatelessWidget {
  final AddTask addTask;
  final UpdateTask updateTask;
  final DeleteTask deleteTask;
  final GetTasks getTasks;

  const MyApp({super.key, required this.addTask, required this.updateTask, required this.deleteTask, required this.getTasks});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kakotel Test',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: BlocProvider(
        create: (_) => TaskCubit(
          addTask: addTask,
          updateTask: updateTask,
          deleteTask: deleteTask,
          getTasks: getTasks,
        ),
        child: const TaskPage(),
      ),
    );
  }
}
 
