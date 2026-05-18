import 'package:drift/drift.dart';

class CallsTable extends Table {
  TextColumn get id => text()();
  TextColumn get phoneNumber => text()();
  TextColumn get contactName => text().withDefault(const Constant(''))();
  TextColumn get direction => text()(); // "incoming" or "outgoing"
  IntColumn get startedAt => integer()(); // Unix ms
  IntColumn get endedAt => integer()(); // Unix ms
  IntColumn get durationSeconds => integer()();
  TextColumn get audioPath => text()();
  IntColumn get fileSizeBytes => integer().withDefault(const Constant(0))();
  TextColumn get fileExtension => text().withDefault(const Constant('m4a'))();
  TextColumn get transcriptionStatus =>
      text().withDefault(const Constant('pending'))();
  TextColumn get rawTranscript => text().withDefault(const Constant(''))();
  TextColumn get sourceFileUri => text().withDefault(const Constant(''))();
  IntColumn get createdAt => integer()(); // Unix ms

  @override
  Set<Column> get primaryKey => {id};
}
