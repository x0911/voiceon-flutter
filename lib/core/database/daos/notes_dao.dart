part of '../app_database.dart';

class FilterParams {
  final List<String> priorities;
  final bool? isTodo;
  final bool? isCompleted;
  final List<String> taggedPeopleIds;
  final String? searchText;

  const FilterParams({
    this.priorities = const [],
    this.isTodo,
    this.isCompleted,
    this.taggedPeopleIds = const [],
    this.searchText,
  });
}

@DriftAccessor(tables: [Notes, NotePeople])
class NotesDao extends DatabaseAccessor<AppDatabase> with _$NotesDaoMixin {
  NotesDao(super.db);

  Stream<List<Note>> watchAllNotes() {
    final nowMs = DateTime.now().millisecondsSinceEpoch;
    return customSelect(
      '''
SELECT notes.*
FROM notes
ORDER BY
  CASE
    WHEN due_date IS NULL THEN 2
    WHEN due_date >= ? THEN 0
    ELSE 1
  END,
  due_date ASC,
  created_at DESC
''',
      variables: [Variable.withInt(nowMs)],
      readsFrom: {notes},
    ).watch().map((rows) => rows.map((row) => notes.map(row.data)).toList());
  }

  Stream<List<Note>> watchFilteredNotes(FilterParams params) {
    final nowMs = DateTime.now().millisecondsSinceEpoch;
    final whereClauses = <String>[];
    final variables = <Variable>[];
    var joinClause = '';

    if (params.taggedPeopleIds.isNotEmpty) {
      joinClause = 'JOIN note_people ON note_people.note_id = notes.id';
      whereClauses.add(
        'note_people.person_id IN (${List.filled(params.taggedPeopleIds.length, '?').join(', ')})',
      );
      variables.addAll(params.taggedPeopleIds.map(Variable.withString));
    }

    if (params.priorities.isNotEmpty) {
      whereClauses.add(
        'priority IN (${List.filled(params.priorities.length, '?').join(', ')})',
      );
      variables.addAll(params.priorities.map(Variable.withString));
    }

    if (params.isTodo != null) {
      whereClauses.add('is_todo = ?');
      variables.add(Variable.withBool(params.isTodo!));
    }

    if (params.isCompleted != null) {
      whereClauses.add('is_completed = ?');
      variables.add(Variable.withBool(params.isCompleted!));
    }

    if (params.searchText?.trim().isNotEmpty ?? false) {
      final pattern = '%${params.searchText!.trim()}%';
      whereClauses.add(
        '(label LIKE ? OR description LIKE ? OR content LIKE ?)',
      );
      variables.addAll([
        Variable.withString(pattern),
        Variable.withString(pattern),
        Variable.withString(pattern),
      ]);
    }

    final whereClause = whereClauses.isEmpty
        ? ''
        : 'WHERE ${whereClauses.join(' AND ')}';
    final groupBy = joinClause.isNotEmpty ? 'GROUP BY notes.id' : '';

    final sql =
        '''
SELECT notes.*
FROM notes
$joinClause
$whereClause
$groupBy
ORDER BY
  CASE
    WHEN due_date IS NULL THEN 2
    WHEN due_date >= ? THEN 0
    ELSE 1
  END,
  due_date ASC,
  created_at DESC
''';

    variables.add(Variable.withInt(nowMs));

    return customSelect(
      sql,
      variables: variables,
      readsFrom: {notes, notePeople},
    ).watch().map((rows) => rows.map((row) => notes.map(row.data)).toList());
  }

  Future<String> insertNote(NotesCompanion entry) async {
    final noteId = entry.id.present ? entry.id.value : const Uuid().v4();
    await into(notes).insert(entry.copyWith(id: Value(noteId)));
    return noteId;
  }

  Future<bool> updateNote(NotesCompanion entry) async {
    return update(notes).replace(entry);
  }

  Future<bool> toggleNoteCompletion(String id, bool isCompleted) async {
    final updatedRows = await (update(notes)..where((tbl) => tbl.id.equals(id)))
        .write(NotesCompanion(isCompleted: Value(isCompleted)));
    return updatedRows > 0;
  }

  Future<int> deleteNote(String id) {
    return (delete(notes)..where((tbl) => tbl.id.equals(id))).go();
  }

  Future<Note?> getNoteById(String id) {
    return (select(notes)..where((tbl) => tbl.id.equals(id))).getSingleOrNull();
  }
}
