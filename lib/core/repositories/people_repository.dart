import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/app_database.dart';
import '../models/person.dart';

class PeopleRepository {
  final PeopleDao _peopleDao;

  PeopleRepository(this._peopleDao);

  Stream<List<PersonModel>> watchAllPeople() {
    return _peopleDao.watchAllPeople().map(
      (people) => people
          .map((person) => PersonModel(id: person.id, name: person.name))
          .toList(),
    );
  }

  Future<String> upsertPerson(String name) => _peopleDao.upsertPerson(name);

  Future<List<PersonModel>> getAllPeople() async {
    final people = await _peopleDao.getAllPeople();
    return people
        .map((person) => PersonModel(id: person.id, name: person.name))
        .toList();
  }
}

final peopleRepositoryProvider = Provider<PeopleRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return PeopleRepository(db.peopleDao);
});
