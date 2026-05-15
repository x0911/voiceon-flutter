import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

class People extends Table {
  TextColumn get id => text().clientDefault(() => const Uuid().v4())();
  TextColumn get name =>
      text().withLength(min: 1, max: 255).customConstraint('UNIQUE')();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}
