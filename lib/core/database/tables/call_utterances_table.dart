import 'package:drift/drift.dart';

import 'calls_table.dart';

class CallUtterancesTable extends Table {
  TextColumn get id => text()();
  TextColumn get callId =>
      text().references(CallsTable, #id, onDelete: KeyAction.cascade)();
  TextColumn get speaker => text()(); // "person_1" or "person_2"
  // Named 'utteranceText' to avoid shadowing drift's built-in text() builder
  TextColumn get utteranceText => text()();
  IntColumn get startMs => integer().nullable()();
  IntColumn get sequence => integer()();

  @override
  Set<Column> get primaryKey => {id};
}
