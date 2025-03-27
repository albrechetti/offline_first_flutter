import 'package:connectivity_plus/connectivity_plus.dart';

import '../../domain/entities/task.dart';
import '../datasources/local_datasource.dart';
import '../datasources/remote_datasource.dart';

class TaskRepository {
  final LocalDatasource local;
  final RemoteDatasource remote;
  final Connectivity connectivity;

  TaskRepository({
    required this.local,
    required this.remote,
    required this.connectivity,
  });

  Future<List<Task>> getTasks() async {
    final hasConnection =
        await connectivity.checkConnectivity() != ConnectivityResult.none;

    if (hasConnection) {
      try {
        final remoteTasks = await remote.getTasks();
        await local.isar.writeTxn(() async {
          await local.isar.tasks.clear();
          for (final task in remoteTasks) {
            await local.saveTask(Task.fromJson(task));
          }
        });
      } catch (_) {
        // Load from local if remote fails
        return await local.getTasks();
      }
    }

    return await local.getTasks();
  }

  Future<void> saveTask(Task task) async {
    await local.saveTask(task);

    final hasConnection =
        await connectivity.checkConnectivity() != ConnectivityResult.none;
    if (hasConnection) {
      try {
        await remote.saveTask(task.toJson());
        await local.deleteTask(task.id); // Remove from pending sync
        await local.saveTask(task); // Save with updated data from server
        return;
      } catch (_) {
        // Save to pending sync if remote fails
        await local.isar.writeTxn(() async {
          await local.saveTask(task.copyWith(id: 0));
        });
      }
    }
  }

  Future<void> syncPendingTasks() async {
    final pendingTasks = await local.getPendingTasks();
    for (final task in pendingTasks) {
      await saveTask(task);
    }
  }
}
