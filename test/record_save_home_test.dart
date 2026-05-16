import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import 'package:voiceon/core/database/app_database.dart';
import 'package:voiceon/core/models/note.dart';
import 'package:voiceon/core/models/person.dart';
import 'package:voiceon/core/repositories/note_repository.dart';
import 'package:voiceon/core/repositories/people_repository.dart';
import 'package:voiceon/core/services/audio_service.dart';
import 'package:voiceon/features/home/home_screen.dart';
import 'package:voiceon/features/metadata/metadata_screen.dart';

class InMemoryNoteRepository implements NoteRepository {
  final List<NoteModel> _notes = [];
  final StreamController<List<NoteModel>> _controller =
      StreamController<List<NoteModel>>.broadcast();

  InMemoryNoteRepository() {
    _controller.add(_notes);
  }

  @override
  Stream<List<NoteModel>> watchAllNotes() => _controller.stream;

  @override
  Stream<List<NoteModel>> watchFilteredNotes(FilterParams params) {
    return _controller.stream;
  }

  @override
  Future<NoteModel?> getNoteById(String id) async {
    for (final note in _notes) {
      if (note.id == id) {
        return note;
      }
    }
    return null;
  }

  @override
  Future<String> insertNote(NotesCompanion note) async {
    final id = note.id.present ? note.id.value : const Uuid().v4();
    final newNote = NoteModel(
      id: id,
      label: note.label.present ? note.label.value : '',
      description: note.description.present ? note.description.value : '',
      content: note.content.present ? note.content.value : '',
      priority: note.priority.present
          ? NotePriorityX.fromString(note.priority.value)
          : NotePriority.low,
      isTodo: note.isTodo.present ? note.isTodo.value : false,
      isCompleted: note.isCompleted.present ? note.isCompleted.value : false,
      dueDate: note.dueDate.present ? note.dueDate.value : null,
      audioPath: note.audioPath.present ? note.audioPath.value : '',
      audioDurationSeconds: note.audioDurationSeconds.present
          ? note.audioDurationSeconds.value
          : 0,
      createdAt: note.createdAt.present ? note.createdAt.value : DateTime.now(),
      updatedAt: note.updatedAt.present ? note.updatedAt.value : DateTime.now(),
      taggedPeople: const [],
    );
    _notes.add(newNote);
    _controller.add(List.of(_notes));
    return id;
  }

  @override
  Future<String> saveNoteWithPeople(
    NotesCompanion note,
    List<String> personIds,
  ) {
    return insertNote(note);
  }

  @override
  Future<bool> updateNote(NotesCompanion note) async {
    if (!note.id.present) {
      return false;
    }
    final index = _notes.indexWhere((item) => item.id == note.id.value);
    if (index < 0) {
      return false;
    }
    _notes[index] = _notes[index].copyWith(
      label: note.label.present ? note.label.value : null,
      description: note.description.present ? note.description.value : null,
      content: note.content.present ? note.content.value : null,
      priority: note.priority.present
          ? NotePriorityX.fromString(note.priority.value)
          : null,
      isTodo: note.isTodo.present ? note.isTodo.value : null,
      isCompleted: note.isCompleted.present ? note.isCompleted.value : null,
      dueDate: note.dueDate.present ? note.dueDate.value : null,
      audioPath: note.audioPath.present ? note.audioPath.value : null,
      audioDurationSeconds: note.audioDurationSeconds.present
          ? note.audioDurationSeconds.value
          : null,
      updatedAt: note.updatedAt.present ? note.updatedAt.value : null,
    );
    _controller.add(List.of(_notes));
    return true;
  }

  @override
  Future<bool> updateNoteWithPeople(
    NotesCompanion note,
    List<String> personIds,
  ) async {
    return updateNote(note);
  }

  @override
  Future<int> deleteNote(String id) async {
    _notes.removeWhere((note) => note.id == id);
    _controller.add(List.of(_notes));
    return 1;
  }

  @override
  Future<bool> toggleNoteCompletion(String noteId, bool isCompleted) async {
    final index = _notes.indexWhere((note) => note.id == noteId);
    if (index < 0) {
      return false;
    }
    _notes[index] = _notes[index].copyWith(isCompleted: isCompleted);
    _controller.add(List.of(_notes));
    return true;
  }
}

class InMemoryPeopleRepository implements PeopleRepository {
  @override
  Stream<List<PersonModel>> watchAllPeople() => Stream.value(const []);

  @override
  Future<List<PersonModel>> getAllPeople() async => const [];

  @override
  Future<String> upsertPerson(String name) async => const Uuid().v4();
}

void main() {
  testWidgets('recording save path navigates home and shows new note', (
    WidgetTester tester,
  ) async {
    final noteRepository = InMemoryNoteRepository();
    final peopleRepository = InMemoryPeopleRepository();
    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
        GoRoute(
          path: '/metadata',
          builder: (context, state) =>
              MetadataScreen(recordingResult: state.extra as RecordingResult),
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          noteRepositoryProvider.overrideWithValue(noteRepository),
          peopleRepositoryProvider.overrideWithValue(peopleRepository),
          audioServiceProvider.overrideWithValue(AudioService()),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );

    await tester.pumpAndSettle();
    router.go(
      '/metadata',
      extra: RecordingResult(path: 'recordings/test.m4a', durationSeconds: 12),
    );
    await tester.pumpAndSettle();

    expect(find.byType(MetadataScreen), findsOneWidget);

    await tester.enterText(find.byType(TextFormField).first, 'Saved note');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save Note'));
    await tester.pumpAndSettle();

    expect(find.text('Saved note'), findsOneWidget);
  });
}
