import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/database/app_database.dart';
import '../../core/models/note.dart';
import '../../core/models/person.dart';
import '../../core/repositories/note_repository.dart';
import '../../core/repositories/people_repository.dart';

class TodoFilterState {
  final Set<NotePriority> priorities;
  final bool showCompleted;
  final Set<String> selectedPersonIds;
  final String searchText;

  const TodoFilterState({
    this.priorities = const {},
    this.showCompleted = false,
    this.selectedPersonIds = const {},
    this.searchText = '',
  });

  TodoFilterState copyWith({
    Set<NotePriority>? priorities,
    bool? showCompleted,
    Set<String>? selectedPersonIds,
    String? searchText,
  }) {
    return TodoFilterState(
      priorities: priorities ?? this.priorities,
      showCompleted: showCompleted ?? this.showCompleted,
      selectedPersonIds: selectedPersonIds ?? this.selectedPersonIds,
      searchText: searchText ?? this.searchText,
    );
  }

  bool get hasFilters {
    return priorities.isNotEmpty ||
        showCompleted ||
        selectedPersonIds.isNotEmpty ||
        searchText.trim().isNotEmpty;
  }
}

class TodoFilterNotifier extends StateNotifier<TodoFilterState> {
  TodoFilterNotifier() : super(const TodoFilterState());

  void togglePriority(NotePriority priority) {
    final priorities = Set<NotePriority>.from(state.priorities);
    if (priorities.contains(priority)) {
      priorities.remove(priority);
    } else {
      priorities.add(priority);
    }
    state = state.copyWith(priorities: priorities);
  }

  void toggleShowCompleted() {
    state = state.copyWith(showCompleted: !state.showCompleted);
  }

  void togglePersonFilter(String personId) {
    final selectedPersonIds = Set<String>.from(state.selectedPersonIds);
    if (selectedPersonIds.contains(personId)) {
      selectedPersonIds.remove(personId);
    } else {
      selectedPersonIds.add(personId);
    }
    state = state.copyWith(selectedPersonIds: selectedPersonIds);
  }

  void updateSearchText(String searchText) {
    state = state.copyWith(searchText: searchText);
  }

  void clearFilters() {
    state = const TodoFilterState();
  }
}

final todoFilterProvider =
    StateNotifierProvider<TodoFilterNotifier, TodoFilterState>(
      (ref) => TodoFilterNotifier(),
    );

final todoPeopleProvider = StreamProvider.autoDispose<List<PersonModel>>(
  (ref) => ref.watch(peopleRepositoryProvider).watchAllPeople(),
);

final todoNotesProvider = StreamProvider.autoDispose<List<NoteModel>>((ref) {
  final filters = ref.watch(todoFilterProvider);
  final repository = ref.watch(noteRepositoryProvider);

  final priorityStrings = filters.priorities
      .map((priority) => priority.value)
      .toList();

  // Always filter to todos only; hide completed unless toggled on
  final isCompleted = filters.showCompleted ? null : false;

  final params = FilterParams(
    priorities: priorityStrings,
    isTodo: true,
    isCompleted: isCompleted,
    taggedPeopleIds: filters.selectedPersonIds.toList(),
    searchText: filters.searchText.trim(),
  );

  return repository.watchFilteredNotes(params);
});
