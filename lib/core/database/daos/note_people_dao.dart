part of '../app_database.dart';

@DriftAccessor(tables: [NotePeople, People])
class NotePeopleDao extends DatabaseAccessor<AppDatabase>
    with _$NotePeopleDaoMixin {
  NotePeopleDao(super.db);

  Future<void> setNotePeople(String noteId, List<String> personIds) async {
    await transaction(() async {
      await (delete(
        notePeople,
      )..where((tbl) => tbl.noteId.equals(noteId))).go();

      if (personIds.isEmpty) {
        return;
      }

      await batch((batch) {
        batch.insertAll(
          notePeople,
          personIds
              .map(
                (personId) => NotePeopleCompanion(
                  noteId: Value(noteId),
                  personId: Value(personId),
                ),
              )
              .toList(),
        );
      });
    });
  }

  Future<List<PeopleData>> getPeopleForNote(String noteId) async {
    final query = select(people).join([
      innerJoin(notePeople, notePeople.personId.equalsExp(people.id)),
    ])..where(notePeople.noteId.equals(noteId));

    final rows = await query.get();
    return rows.map((row) => row.readTable(people)).toList();
  }

  Stream<List<PeopleData>> watchPeopleForNote(String noteId) {
    final query = select(people).join([
      innerJoin(notePeople, notePeople.personId.equalsExp(people.id)),
    ])..where(notePeople.noteId.equals(noteId));

    return query.watch().map(
      (rows) => rows.map((row) => row.readTable(people)).toList(),
    );
  }
}
