import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:voiceon/core/database/app_database.dart';
import 'package:voiceon/core/repositories/note_repository.dart';
import 'package:voiceon/core/repositories/people_repository.dart';
import 'package:voiceon/core/services/audio_service.dart';
import 'package:voiceon/features/metadata/metadata_screen.dart';

void main() {
  late AppDatabase db;
  late NoteRepository noteRepository;
  late PeopleRepository peopleRepository;

  setUp(() {
    db = AppDatabase.test(NativeDatabase.memory());
    noteRepository = NoteRepository(db.notesDao, db.notePeopleDao);
    peopleRepository = PeopleRepository(db.peopleDao);
  });

  tearDown(() async {
    await db.close();
  });

  Widget buildTestApp() {
    return ProviderScope(
      overrides: [
        noteRepositoryProvider.overrideWithValue(noteRepository),
        peopleRepositoryProvider.overrideWithValue(peopleRepository),
        audioServiceProvider.overrideWithValue(AudioService()),
      ],
      child: MaterialApp(
        home: MetadataScreen(
          recordingResult: RecordingResult(
            path: 'recordings/test.m4a',
            durationSeconds: 15,
          ),
        ),
      ),
    );
  }

  testWidgets('shows due date error when todo enabled and save pressed', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(buildTestApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Is Todo?'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Save Note'));
    await tester.pumpAndSettle();

    expect(
      find.text('Please choose a due date for this todo item.'),
      findsOneWidget,
    );
  });

  testWidgets('shows label length validation error', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(buildTestApp());
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).first, 'A' * 101);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Save Note'));
    await tester.pumpAndSettle();

    expect(find.text('Label must be 100 characters or less.'), findsOneWidget);
  });
}
