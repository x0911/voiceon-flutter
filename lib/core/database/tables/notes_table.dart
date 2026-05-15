import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

class Notes extends Table {
  TextColumn get id => text().clientDefault(() => const Uuid().v4())();

  TextColumn get label => text().withDefault(const Constant(''))();
  TextColumn get description => text().withDefault(const Constant(''))();
  TextColumn get content => text().withDefault(const Constant(''))();
  TextColumn get priority => text().withDefault(const Constant('low'))();

  BoolColumn get isTodo => boolean().withDefault(const Constant(false))();
  BoolColumn get isCompleted => boolean().withDefault(const Constant(false))();

  DateTimeColumn get dueDate => dateTime().nullable()();

  TextColumn get audioPath => text()();
  IntColumn get audioDurationSeconds =>
      integer().withDefault(const Constant(0))();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}
