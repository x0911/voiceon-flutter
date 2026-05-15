import 'package:drift/drift.dart';

import 'notes_table.dart';
import 'people_table.dart';

class NotePeople extends Table {
  TextColumn get noteId =>
      text().references(Notes, #id, onDelete: KeyAction.cascade)();
  TextColumn get personId =>
      text().references(People, #id, onDelete: KeyAction.cascade)();

  @override
  Set<Column> get primaryKey => {noteId, personId};
}
