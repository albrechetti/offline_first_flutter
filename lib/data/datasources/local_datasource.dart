import 'package:isar/isar.dart';

import '../../domain/entities/task.dart';

class LocalDatasource {
  final Isar isar;

  LocalDatasource(this.isar);

  Future<List<Task>> getTasks() async {
    return await isar.tasks.where().findAll();
  }

  Future<void> saveTask(Task task) async {
    await isar.writeTxn(() async {
      await isar.tasks.put(task);
    });
  }

  Future<void> deleteTask(int id) async {
    await isar.writeTxn(() async {
      await isar.tasks.delete(id);
    });
  }

  Future<List<Task>> getPendingTasks() async {
    return await isar.tasks.filter().idEqualTo(0).findAll();
  }
}
