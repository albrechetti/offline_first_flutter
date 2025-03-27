import 'package:supabase_flutter/supabase_flutter.dart';

class RemoteDatasource {
  final SupabaseClient supabase;

  RemoteDatasource(this.supabase);

  Future<List<Map<String, dynamic>>> getTasks() async {
    return await supabase.from('tasks').select();
  }

  Future<void> saveTask(Map<String, dynamic> task) async {
    await supabase.from('tasks').upsert(task);
  }

  Future<void> deleteTask(int id) async {
    await supabase.from('tasks').delete().eq('id', id);
  }
}
