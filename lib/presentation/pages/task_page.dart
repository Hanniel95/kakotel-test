import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/task_entity.dart';
import '../controllers/task_cubit.dart';

class TaskPage extends StatefulWidget {
  const TaskPage({super.key});

  @override
  State<TaskPage> createState() => _TaskPageState();
}

class _TaskPageState extends State<TaskPage> {
  TaskStatus? _statusFilter;
  TaskPriority? _priorityFilter;

  @override
  void initState() {
    super.initState();
    context.read<TaskCubit>().loadTasks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tasks'),
        actions: [
          IconButton(
            tooltip: 'Clear filters',
            icon: const Icon(Icons.filter_alt_off),
            onPressed: () {
              setState(() {
                _statusFilter = null;
                _priorityFilter = null;
              });
              context.read<TaskCubit>().clearFilters();
            },
          )
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButton<TaskStatus>(
                    isExpanded: true,
                    value: _statusFilter,
                    hint: const Text('Filter by status'),
                    items: [
                      const DropdownMenuItem<TaskStatus>(
                        value: null,
                        child: Text('All statuses'),
                      ),
                      ...TaskStatus.values.map(
                        (s) => DropdownMenuItem<TaskStatus>(
                          value: s,
                          child: Text(s.name),
                        ),
                      ),
                    ],
                    onChanged: (val) {
                      setState(() => _statusFilter = val);
                      context
                          .read<TaskCubit>()
                          .filterTasks(status: val, priority: _priorityFilter);
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: DropdownButton<TaskPriority>(
                    isExpanded: true,
                    value: _priorityFilter,
                    hint: const Text('Filter by priority'),
                    items: [
                      const DropdownMenuItem<TaskPriority>(
                        value: null,
                        child: Text('All priorities'),
                      ),
                      ...TaskPriority.values.map(
                        (p) => DropdownMenuItem<TaskPriority>(
                          value: p,
                          child: Text(p.name),
                        ),
                      ),
                    ],
                    onChanged: (val) {
                      setState(() => _priorityFilter = val);
                      context
                          .read<TaskCubit>()
                          .filterTasks(status: _statusFilter, priority: val);
                    },
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  tooltip: 'Sort by priority',
                  onPressed: () => context.read<TaskCubit>().sortByPriority(),
                  icon: const Icon(Icons.sort),
                ),
              ],
            ),
          ),
          Expanded(
            child: BlocBuilder<TaskCubit, TaskState>(
              builder: (context, state) {
                if (state is TaskLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state is TaskError) {
                  return Center(child: Text(state.message));
                }
                if (state is TaskLoaded) {
                  if (state.filteredTasks.isEmpty) {
                    return const Center(child: Text('No tasks'));
                  }
                  return ListView.separated(
                    itemCount: state.filteredTasks.length,
                    separatorBuilder: (_, __) => const Divider(height: 0),
                    itemBuilder: (context, index) {
                      final task = state.filteredTasks[index];
                      return ListTile(
                        title: Text(task.title),
                        subtitle: Text(
                          '${task.description}\n${task.status.name} • ${task.priority.name}',
                        ),
                        isThreeLine: true,
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () => context
                              .read<TaskCubit>()
                              .deleteTask(task.id),
                        ),
                      );
                    },
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTaskDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _showAddTaskDialog(BuildContext context) async {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    TaskPriority priority = TaskPriority.medium;
    final taskCubit = context.read<TaskCubit>();

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Add Task'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Title'),
              ),
              TextField(
                controller: descController,
                decoration: const InputDecoration(labelText: 'Description'),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<TaskPriority>(
                value: priority,
                items: TaskPriority.values
                    .map((p) => DropdownMenuItem(
                          value: p,
                          child: Text(p.name),
                        ))
                    .toList(),
                onChanged: (val) {
                  if (val != null) priority = val;
                },
                decoration: const InputDecoration(labelText: 'Priority'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                if (titleController.text.trim().isEmpty) return;
                await taskCubit.addTask(
                      title: titleController.text.trim(),
                      description: descController.text.trim(),
                      priority: priority,
                    );
                if (dialogContext.mounted) Navigator.of(dialogContext).pop();
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }
}
