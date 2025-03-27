import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:isar/isar.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'data/datasources/local_datasource.dart';
import 'data/datasources/remote_datasource.dart';
import 'data/repositories/task_repository.dart';
import 'presentation/cubits/task_cubit.dart';
import 'presentation/pages/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final isar = await Isar.open([TaskSchema]);
  await Supabase.initialize(
    url: 'SUPABASE_URL',
    anonKey: 'SUPABASE_KEY',
  );

  runApp(MyApp(
    isar: isar,
    supabase: Supabase.instance.client,
  ));
}

class MyApp extends StatelessWidget {
  final Isar isar;
  final SupabaseClient supabase;

  const MyApp({super.key, required this.isar, required this.supabase});

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider(
      create: (context) => TaskRepository(
        local: LocalDatasource(isar),
        remote: RemoteDatasource(supabase),
        connectivity: Connectivity(),
      ),
      child: BlocProvider(
        create: (context) => TaskCubit(
          RepositoryProvider.of<TaskRepository>(context),
        )..loadTasks(),
        child: MaterialApp(
          home: HomePage(),
        ),
      ),
    );
  }
}