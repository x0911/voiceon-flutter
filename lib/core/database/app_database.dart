import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import 'tables/notes_table.dart';
import 'tables/people_table.dart';
import 'tables/note_people_table.dart';

part 'app_database.g.dart';
part 'daos/notes_dao.dart';
part 'daos/people_dao.dart';
part 'daos/note_people_dao.dart';

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'voiceon.sqlite'));
    return NativeDatabase(file);
  });
}

@DriftDatabase(
  tables: [Notes, People, NotePeople],
  daos: [NotesDao, PeopleDao, NotePeopleDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  AppDatabase.test(QueryExecutor executor) : super(executor);

  @override
  int get schemaVersion => 1;
}

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final database = AppDatabase();
  ref.onDispose(database.close);
  return database;
});
