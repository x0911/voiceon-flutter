import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/app_database.dart';
import '../models/note.dart';
import '../models/person.dart';

class NoteRepository {
  final NotesDao _notesDao;
  final NotePeopleDao _notePeopleDao;

  NoteRepository(this._notesDao, this._notePeopleDao);

  Stream<List<NoteModel>> watchAllNotes() {
    return _notesDao.watchAllNotes().map(
      (notes) => notes
          .map(
            (note) => NoteModel(
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
            ),
          )
          .toList(),
    );
  }

  Stream<List<NoteModel>> watchFilteredNotes(FilterParams params) {
    return _notesDao
        .watchFilteredNotes(params)
        .map(
          (notes) => notes
              .map(
                (note) => NoteModel(
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
                ),
              )
              .toList(),
        );
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

  Future<int> deleteNote(String id) => _notesDao.deleteNote(id);
}

final noteRepositoryProvider = Provider<NoteRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return NoteRepository(db.notesDao, db.notePeopleDao);
});
