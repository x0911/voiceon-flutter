import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/database/app_database.dart';
import '../../core/models/note.dart';
import '../../core/models/person.dart';
import '../../core/repositories/note_repository.dart';
import '../../core/repositories/people_repository.dart';

enum HomeTodoFilter { all, todo, nonTodo }

enum HomeStatusFilter { all, completed, pending }

class HomeFilterState {
  final Set<NotePriority> priorities;
  final HomeTodoFilter todoFilter;
  final HomeStatusFilter statusFilter;
  final Set<String> selectedPersonIds;
  final String searchText;

  const HomeFilterState({
    this.priorities = const {},
    this.todoFilter = HomeTodoFilter.all,
    this.statusFilter = HomeStatusFilter.all,
    this.selectedPersonIds = const {},
    this.searchText = '',
  });

  HomeFilterState copyWith({
    Set<NotePriority>? priorities,
    HomeTodoFilter? todoFilter,
    HomeStatusFilter? statusFilter,
    Set<String>? selectedPersonIds,
    String? searchText,
  }) {
    return HomeFilterState(
      priorities: priorities ?? this.priorities,
      todoFilter: todoFilter ?? this.todoFilter,
      statusFilter: statusFilter ?? this.statusFilter,
      selectedPersonIds: selectedPersonIds ?? this.selectedPersonIds,
      searchText: searchText ?? this.searchText,
    );
  }

  bool get hasFilters {
    return priorities.isNotEmpty ||
        todoFilter != HomeTodoFilter.all ||
        statusFilter != HomeStatusFilter.all ||
        selectedPersonIds.isNotEmpty ||
        searchText.trim().isNotEmpty;
  }
}

class HomeFilterNotifier extends StateNotifier<HomeFilterState> {
  HomeFilterNotifier() : super(const HomeFilterState());

  void togglePriority(NotePriority priority) {
    final priorities = Set<NotePriority>.from(state.priorities);
    if (priorities.contains(priority)) {
      priorities.remove(priority);
    } else {
      priorities.add(priority);
    }
    state = state.copyWith(priorities: priorities);
  }

  void setTodoFilter(HomeTodoFilter filter) {
    state = state.copyWith(todoFilter: filter);
  }

  void setStatusFilter(HomeStatusFilter filter) {
    state = state.copyWith(statusFilter: filter);
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
    state = const HomeFilterState();
  }
}

final homeFilterProvider =
    StateNotifierProvider<HomeFilterNotifier, HomeFilterState>(
      (ref) => HomeFilterNotifier(),
    );

final homePeopleProvider = StreamProvider.autoDispose<List<PersonModel>>(
  (ref) => ref.watch(peopleRepositoryProvider).watchAllPeople(),
);

final homeNotesProvider = StreamProvider.autoDispose<List<NoteModel>>((ref) {
  final filters = ref.watch(homeFilterProvider);
  final repository = ref.watch(noteRepositoryProvider);

  final priorityStrings = filters.priorities
      .map((priority) => priority.value)
      .toList();
  final isTodo = filters.todoFilter == HomeTodoFilter.all
      ? null
      : filters.todoFilter == HomeTodoFilter.todo;
  final isCompleted = filters.statusFilter == HomeStatusFilter.all
      ? null
      : filters.statusFilter == HomeStatusFilter.completed;

  final params = FilterParams(
    priorities: priorityStrings,
    isTodo: isTodo,
    isCompleted: isCompleted,
    taggedPeopleIds: filters.selectedPersonIds.toList(),
    searchText: filters.searchText.trim(),
  );

  return repository.watchFilteredNotes(params);
});
