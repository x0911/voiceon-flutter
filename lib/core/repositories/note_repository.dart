import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/app_database.dart';
import '../models/note.dart';
import '../models/person.dart';

class NoteRepository {
  final NotesDao _notesDao;
  final NotePeopleDao _notePeopleDao;

  NoteRepository(this._notesDao, this._notePeopleDao);

  Stream<List<NoteModel>> watchAllNotes() {
    return _notesDao.watchAllNotes().asyncMap(_attachPeople);
  }

  Stream<List<NoteModel>> watchFilteredNotes(FilterParams params) {
    return _notesDao.watchFilteredNotes(params).asyncMap(_attachPeople);
  }

  Future<List<NoteModel>> _attachPeople(List<Note> notes) async {
    final enrichedNotes = await Future.wait(
      notes.map((note) async {
        final people = await _notePeopleDao.getPeopleForNote(note.id);
        return NoteModel(
          id: note.id,
          label: note.label,
          description: note.description,
          content: note.content,
          priority: NotePriorityX.fromString(note.priority),
          isTodo: note.isTodo,
          isCompleted: note.isCompleted,
          dueDate: note.dueDate,
          audioPath: note.audioPath,
          audioDurationSeconds: note.audioDurationSeconds,
          createdAt: note.createdAt,
          updatedAt: note.updatedAt,
          taggedPeople: people
              .map((person) => PersonModel(id: person.id, name: person.name))
              .toList(),
        );
      }),
    );
    return enrichedNotes;
  }

  Future<NoteModel?> getNoteById(String id) async {
    final note = await _notesDao.getNoteById(id);
    if (note == null) {
      return null;
    }

    final people = await _notePeopleDao.getPeopleForNote(id);
    return NoteModel(
      id: note.id,
      label: note.label,
      description: note.description,
      content: note.content,
      priority: NotePriorityX.fromString(note.priority),
      isTodo: note.isTodo,
      isCompleted: note.isCompleted,
      dueDate: note.dueDate,
      audioPath: note.audioPath,
      audioDurationSeconds: note.audioDurationSeconds,
      createdAt: note.createdAt,
      updatedAt: note.updatedAt,
      taggedPeople: people
          .map((person) => PersonModel(id: person.id, name: person.name))
          .toList(),
    );
  }

  Future<String> insertNote(NotesCompanion note) => _notesDao.insertNote(note);

  Future<String> saveNoteWithPeople(
    NotesCompanion note,
    List<String> personIds,
  ) async {
    final noteId = await insertNote(note);
    await _notePeopleDao.setNotePeople(noteId, personIds);
    return noteId;
  }

  Future<bool> updateNote(NotesCompanion note) => _notesDao.updateNote(note);

  Future<bool> updateNoteWithPeople(
    NotesCompanion note,
    List<String> personIds,
  ) async {
    final noteId = note.id.present
        ? note.id.value
        : (throw ArgumentError('Note id is required for an update.'));
    final updated = await _notesDao.updateNote(note);
    await _notePeopleDao.setNotePeople(noteId, personIds);
    return updated;
  }

  Future<int> deleteNote(String id) => _notesDao.deleteNote(id);

  Future<bool> toggleNoteCompletion(String noteId, bool isCompleted) {
    return _notesDao.toggleNoteCompletion(noteId, isCompleted);
  }
}

final noteRepositoryProvider = Provider<NoteRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return NoteRepository(db.notesDao, db.notePeopleDao);
});
