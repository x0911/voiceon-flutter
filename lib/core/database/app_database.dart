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
import 'tables/calls_table.dart';
import 'tables/call_utterances_table.dart';

part 'app_database.g.dart';
part 'daos/notes_dao.dart';
part 'daos/people_dao.dart';
part 'daos/note_people_dao.dart';
part 'daos/calls_dao.dart';

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'voiceon.sqlite'));
    return NativeDatabase(file);
  });
}

@DriftDatabase(
  tables: [Notes, People, NotePeople, CallsTable, CallUtterancesTable],
  daos: [NotesDao, PeopleDao, NotePeopleDao, CallsDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  AppDatabase.test(super.executor);

  @override
  int get schemaVersion => 4;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onUpgrade: (migrator, from, to) async {
          if (from < 2) {
            await migrator.createTable(callsTable);
            await migrator.createTable(callUtterancesTable);
          }
          if (from < 3) {
            try { await migrator.addColumn(callsTable, callsTable.sourceFileUri); } catch (_) {}
          }
          if (from < 4) {
            try { await migrator.addColumn(callsTable, callsTable.fileSizeBytes); } catch (_) {}
            try { await migrator.addColumn(callsTable, callsTable.fileExtension); } catch (_) {}
          }
        },
      );
}

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final database = AppDatabase();
  ref.onDispose(database.close);
  return database;
});
