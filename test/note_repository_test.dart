import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uuid/uuid.dart';
import 'package:voiceon/core/database/app_database.dart';
import 'package:voiceon/core/repositories/note_repository.dart';
import 'package:drift/drift.dart';

void main() {
  late AppDatabase db;
  late NoteRepository repository;

  setUp(() {
    db = AppDatabase.test(NativeDatabase.memory());
    repository = NoteRepository(db.notesDao, db.notePeopleDao);
  });

  tearDown(() async {
    await db.close();
  });

  test('watchFilteredNotes filters by tagged person', () async {
    final personId = const Uuid().v4();
    await db
        .into(db.people)
        .insert(
          PeopleCompanion(
            id: Value<String>(personId),
            name: Value<String>('Alice'),
          ),
        );

    final noteId = await repository.insertNote(
      NotesCompanion(
        label: Value<String>('Shopping'),
        description: Value<String>('Buy milk and eggs'),
        content: Value<String>('Shopping list'),
        priority: Value<String>('high'),
        isTodo: Value<bool>(true),
        isCompleted: Value<bool>(false),
        dueDate: Value<DateTime>(DateTime.now().add(const Duration(days: 1))),
        audioPath: Value<String>('recordings/test.m4a'),
        audioDurationSeconds: Value<int>(30),
        createdAt: Value<DateTime>(DateTime.now()),
        updatedAt: Value<DateTime>(DateTime.now()),
      ),
    );

    await db
        .into(db.notePeople)
        .insert(
          NotePeopleCompanion(
            noteId: Value<String>(noteId),
            personId: Value<String>(personId),
          ),
        );

    final results = await repository
        .watchFilteredNotes(FilterParams(taggedPeopleIds: [personId]))
        .first;

    expect(results, hasLength(1));
    expect(results.first.taggedPeople, hasLength(1));
    expect(results.first.taggedPeople.first.name, 'Alice');
  });

  test('watchFilteredNotes filters by search text', () async {
    await repository.insertNote(
      NotesCompanion(
        label: Value<String>('Workout'),
        description: Value<String>('Gym routine'),
        content: Value<String>('Leg day and cardio'),
        priority: Value<String>('low'),
        isTodo: Value<bool>(false),
        isCompleted: Value<bool>(false),
        audioPath: Value<String>('recordings/workout.m4a'),
        audioDurationSeconds: Value<int>(45),
        createdAt: Value<DateTime>(DateTime.now()),
        updatedAt: Value<DateTime>(DateTime.now()),
      ),
    );

    final filtered = await repository
        .watchFilteredNotes(FilterParams(searchText: 'leg day'))
        .first;

    expect(filtered, hasLength(1));
    expect(filtered.first.label, 'Workout');
  });
}
