import 'package:isar/isar.dart';
part 'task.g.dart';

@Collection()
class Task {
  Id id = Isar.autoIncrement;
  String title;
  bool isCompleted;
  DateTime createdAt = DateTime.now();

  Task({required this.title, this.isCompleted = false});

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'is_completed': isCompleted,
    'created_at': createdAt.toIso8601String(),
  };

  factory Task.fromJson(Map<String, dynamic> json) =>
      Task(title: json['title'], isCompleted: json['is_completed']);
}
