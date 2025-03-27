import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:offline_first_flutter/presentation/cubits/task_state.dart';

import '../../data/repositories/task_repository.dart';
import '../../domain/entities/task.dart';

class TaskCubit extends Cubit<TaskState> {
  final TaskRepository repository;

  TaskCubit(this.repository) : super(TaskInitial());

  Future<void> loadTasks() async {
    emit(TaskLoading());
    try {
      final tasks = await repository.getTasks();
      emit(TaskLoaded(tasks));
    } catch (e) {
      emit(TaskError('Failed to load tasks'));
    }
  }

  Future<void> addTask(String title) async {
    final currentState = state;
    if (currentState is TaskLoaded) {
      final newTask = Task(title: title);
      emit(TaskLoaded([...currentState.tasks, newTask]));
      await repository.saveTask(newTask);
    }
  }

  Future<void> syncTasks() async {
    emit(TaskSyncing());
    try {
      await repository.syncPendingTasks();
      await loadTasks();
    } catch (e) {
      emit(TaskError('Sync failed'));
    }
  }
}
