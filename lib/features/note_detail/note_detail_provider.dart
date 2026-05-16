import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/note.dart';
import '../../core/models/person.dart';
import '../../core/repositories/note_repository.dart';
import '../../core/repositories/people_repository.dart';

final noteDetailProvider = FutureProvider.family<NoteModel?, String>((
  ref,
  noteId,
) {
  final repository = ref.watch(noteRepositoryProvider);
  return repository.getNoteById(noteId);
});

final noteDetailPeopleProvider = StreamProvider.autoDispose<List<PersonModel>>(
  (ref) => ref.watch(peopleRepositoryProvider).watchAllPeople(),
);
