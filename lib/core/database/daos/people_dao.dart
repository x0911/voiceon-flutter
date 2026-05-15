part of '../app_database.dart';

@DriftAccessor(tables: [People])
class PeopleDao extends DatabaseAccessor<AppDatabase> with _$PeopleDaoMixin {
  PeopleDao(super.db);

  Stream<List<PeopleData>> watchAllPeople() {
    return select(people).watch();
  }

  Future<String> upsertPerson(String name) async {
    final existing = await (select(
      people,
    )..where((tbl) => tbl.name.equals(name))).getSingleOrNull();
    if (existing != null) {
      return existing.id;
    }

    final id = const Uuid().v4();
    await into(
      people,
    ).insert(PeopleCompanion(id: Value(id), name: Value(name)));

    return id;
  }

  Future<List<PeopleData>> getAllPeople() {
    return select(people).get();
  }
}
