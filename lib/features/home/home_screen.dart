import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/models/note.dart';
import '../../core/models/person.dart';
import '../../core/repositories/note_repository.dart';
import 'home_state.dart';
import 'note_card.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final notesAsync = ref.watch(homeNotesProvider);
    final peopleAsync = ref.watch(homePeopleProvider);
    final filters = ref.watch(homeFilterProvider);
    final filterNotifier = ref.read(homeFilterProvider.notifier);
    final noteRepository = ref.watch(noteRepositoryProvider);

    ref.listen<AsyncValue<List<NoteModel>>>(homeNotesProvider, (
      previous,
      next,
    ) {
      if (next.hasError && previous?.hasError == false) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Could not load notes.')));
      }
    });

    ref.listen<AsyncValue<List<PersonModel>>>(homePeopleProvider, (
      previous,
      next,
    ) {
      if (next.hasError && previous?.hasError == false) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Could not load people.')));
      }
    });

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            floating: false,
            snap: false,
            title: const Text('Voiceon'),
            actions: [
              IconButton(
                icon: const Icon(Icons.settings_outlined),
                tooltip: 'Settings',
                onPressed: () => context.push('/settings'),
              ),
              if (filters.hasFilters)
                IconButton(
                  icon: const Icon(Icons.filter_alt_off),
                  tooltip: 'Clear filters',
                  onPressed: filterNotifier.clearFilters,
                ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    decoration: const InputDecoration(
                      hintText: 'Search notes...',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                    onChanged: filterNotifier.updateSearchText,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 4, left: 12),
                    child: Text(
                      'Searches label, description and transcript',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withAlpha((0.5 * 255).round()),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _FilterSection(
                    title: 'Priority',
                    children: NotePriority.values.map((priority) {
                      return FilterChip(
                        label: Text(priority.name.toUpperCase()),
                        selected: filters.priorities.contains(priority),
                        showCheckmark: false,
                        selectedColor: Theme.of(context).colorScheme.primary,
                        labelStyle: TextStyle(
                          color: filters.priorities.contains(priority)
                              ? Colors.white
                              : Theme.of(context).colorScheme.onSurface,
                          fontWeight: filters.priorities.contains(priority)
                              ? FontWeight.w600
                              : FontWeight.w400,
                        ),
                        selectedShadowColor: Colors.transparent,
                        onSelected: (_) =>
                            filterNotifier.togglePriority(priority),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  _FilterSection(
                    title: 'Type',
                    children: [
                      ChoiceChip(
                        label: const Text('Todo'),
                        selected: filters.todoFilter == HomeTodoFilter.todo,
                        selectedColor: Theme.of(context).colorScheme.primary,
                        labelStyle: TextStyle(
                          color: filters.todoFilter == HomeTodoFilter.todo
                              ? Colors.white
                              : Theme.of(context).colorScheme.onSurface,
                        ),
                        selectedShadowColor: Colors.transparent,
                        onSelected: (_) => filterNotifier.setTodoFilter(
                          filters.todoFilter == HomeTodoFilter.todo
                              ? HomeTodoFilter.all
                              : HomeTodoFilter.todo,
                        ),
                      ),
                      ChoiceChip(
                        label: const Text('Non-Todo'),
                        selected: filters.todoFilter == HomeTodoFilter.nonTodo,
                        selectedColor: Theme.of(context).colorScheme.primary,
                        labelStyle: TextStyle(
                          color: filters.todoFilter == HomeTodoFilter.nonTodo
                              ? Colors.white
                              : Theme.of(context).colorScheme.onSurface,
                        ),
                        selectedShadowColor: Colors.transparent,
                        onSelected: (_) => filterNotifier.setTodoFilter(
                          filters.todoFilter == HomeTodoFilter.nonTodo
                              ? HomeTodoFilter.all
                              : HomeTodoFilter.nonTodo,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _FilterSection(
                    title: 'Status',
                    children: [
                      ChoiceChip(
                        label: const Text('Pending'),
                        selected:
                            filters.statusFilter == HomeStatusFilter.pending,
                        selectedColor: Theme.of(context).colorScheme.primary,
                        labelStyle: TextStyle(
                          color:
                              filters.statusFilter == HomeStatusFilter.pending
                              ? Colors.white
                              : Theme.of(context).colorScheme.onSurface,
                        ),
                        selectedShadowColor: Colors.transparent,
                        onSelected: (_) => filterNotifier.setStatusFilter(
                          filters.statusFilter == HomeStatusFilter.pending
                              ? HomeStatusFilter.all
                              : HomeStatusFilter.pending,
                        ),
                      ),
                      ChoiceChip(
                        label: const Text('Completed'),
                        selected:
                            filters.statusFilter == HomeStatusFilter.completed,
                        selectedColor: Theme.of(context).colorScheme.primary,
                        labelStyle: TextStyle(
                          color:
                              filters.statusFilter == HomeStatusFilter.completed
                              ? Colors.white
                              : Theme.of(context).colorScheme.onSurface,
                        ),
                        selectedShadowColor: Colors.transparent,
                        onSelected: (_) => filterNotifier.setStatusFilter(
                          filters.statusFilter == HomeStatusFilter.completed
                              ? HomeStatusFilter.all
                              : HomeStatusFilter.completed,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  peopleAsync.when(
                    data: (people) {
                      if (people.isEmpty) {
                        return const SizedBox.shrink();
                      }
                      return _FilterSection(
                        title: 'People',
                        children: people.map((person) {
                          final selected = filters.selectedPersonIds.contains(
                            person.id,
                          );
                          return FilterChip(
                            label: Text(person.name),
                            selected: selected,
                            showCheckmark: false,
                            selectedColor: Theme.of(
                              context,
                            ).colorScheme.primary,
                            labelStyle: TextStyle(
                              color: selected
                                  ? Colors.white
                                  : Theme.of(context).colorScheme.onSurface,
                            ),
                            selectedShadowColor: Colors.transparent,
                            onSelected: (_) =>
                                filterNotifier.togglePersonFilter(person.id),
                          );
                        }).toList(),
                      );
                    },
                    loading: () => const SizedBox.shrink(),
                    error: (error, stack) => const SizedBox.shrink(),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
          notesAsync.when(
            data: (notes) {
              if (notes.isEmpty) {
                return SliverFillRemaining(
                  hasScrollBody: false,
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.note_alt_outlined,
                          size: 72,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 24),
                        Text(
                          filters.hasFilters
                              ? 'No notes match your filters'
                              : 'No notes yet',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          filters.hasFilters
                              ? 'Try clearing filters or add a new note.'
                              : 'Tap + to capture your first voice note.',
                          textAlign: TextAlign.center,
                        ),
                        if (filters.hasFilters) ...[
                          const SizedBox(height: 16),
                          FilledButton(
                            onPressed: filterNotifier.clearFilters,
                            child: const Text('Clear filters'),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              }

              return SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final note = notes[index];
                  return NoteCard(
                    note: note,
                    onToggleCompleted: note.isTodo
                        ? (value) => noteRepository.toggleNoteCompletion(
                            note.id,
                            value,
                          )
                        : null,
                    onTap: () => context.push('/note/${note.id}'),
                  );
                }, childCount: notes.length),
              );
            },
            loading: () => const SliverFillRemaining(
              hasScrollBody: false,
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (error, stack) => SliverFillRemaining(
              hasScrollBody: false,
              child: Center(child: Text('Unable to load notes: $error')),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 96)),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.mic),
        label: const Text('New note'),
        onPressed: () => context.push('/record'),
      ),
    );
  }
}

class _FilterSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _FilterSection({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 8),
        Wrap(spacing: 8, runSpacing: 8, children: children),
      ],
    );
  }
}
