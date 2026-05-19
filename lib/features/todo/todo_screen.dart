import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/models/note.dart';
import '../../core/repositories/note_repository.dart';
import '../home/note_card.dart';
import 'todo_state.dart';

class TodoScreen extends ConsumerStatefulWidget {
  const TodoScreen({super.key});

  @override
  ConsumerState<TodoScreen> createState() => _TodoScreenState();
}

class _TodoScreenState extends ConsumerState<TodoScreen> {
  /// Opens the filter bottom sheet dialog.
  void _openFilters(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return _TodoFilterSheet();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final todosAsync = ref.watch(todoNotesProvider);
    final filters = ref.watch(todoFilterProvider);
    final filterNotifier = ref.read(todoFilterProvider.notifier);
    final noteRepository = ref.watch(noteRepositoryProvider);

    ref.listen<AsyncValue<List<NoteModel>>>(todoNotesProvider, (
      previous,
      next,
    ) {
      if (next.hasError && previous?.hasError == false) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Could not load todos.')));
      }
    });

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            floating: false,
            snap: false,
            title: const Text('Todo'),
            actions: [
              Stack(
                alignment: Alignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.tune),
                    tooltip: 'Filters',
                    onPressed: () => _openFilters(context),
                  ),
                  if (filters.hasFilters)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.error,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),

          // Search field
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    decoration: const InputDecoration(
                      hintText: 'Search todos...',
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
                ],
              ),
            ),
          ),

          // Todos list
          todosAsync.when(
            data: (todos) {
              if (todos.isEmpty) {
                return SliverFillRemaining(
                  hasScrollBody: false,
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.checklist_outlined,
                          size: 72,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 24),
                        Text(
                          filters.hasFilters
                              ? 'No todos match your filters'
                              : 'No pending todos',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          filters.hasFilters
                              ? 'Try clearing filters or adjusting your search.'
                              : filters.showCompleted
                              ? 'All done! No todos here.'
                              : 'You have no pending todos. Tap + to create one.',
                          textAlign: TextAlign.center,
                        ),
                        if (filters.hasFilters) ...[
                          const SizedBox(height: 16),
                          FilledButton.tonal(
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
                  final todo = todos[index];
                  return NoteCard(
                    note: todo,
                    onToggleCompleted: (value) =>
                        noteRepository.toggleNoteCompletion(todo.id, value),
                    onTap: () => context.push('/note/${todo.id}'),
                  );
                }, childCount: todos.length),
              );
            },
            loading: () => const SliverFillRemaining(
              hasScrollBody: false,
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (error, stack) => SliverFillRemaining(
              hasScrollBody: false,
              child: Center(child: Text('Unable to load todos: $error')),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 96)),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Filter bottom sheet for todos
// ---------------------------------------------------------------------------

class _TodoFilterSheet extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filters = ref.watch(todoFilterProvider);
    final filterNotifier = ref.read(todoFilterProvider.notifier);
    final peopleAsync = ref.watch(todoPeopleProvider);

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.92,
      expand: false,
      builder: (_, scrollController) {
        return Column(
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 4),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Header row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Text(
                    'Filters',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  if (filters.hasFilters)
                    TextButton.icon(
                      onPressed: () {
                        filterNotifier.clearFilters();
                        Navigator.of(context).pop();
                      },
                      icon: const Icon(Icons.filter_alt_off, size: 18),
                      label: const Text('Clear all'),
                    ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),

            const Divider(height: 1),

            // Scrollable filter content
            Expanded(
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                children: [
                  // ── Show Completed toggle ──────────────────────────
                  _SheetSection(
                    title: 'Completed Items',
                    child: SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Show completed todos'),
                      value: filters.showCompleted,
                      onChanged: (_) => filterNotifier.toggleShowCompleted(),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ── Priority ────────────────────────────────────────
                  _SheetSection(
                    title: 'Priority',
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: NotePriority.values.map((priority) {
                        final selected = filters.priorities.contains(priority);
                        return FilterChip(
                          label: Text(
                            priority.name[0].toUpperCase() +
                                priority.name.substring(1),
                          ),
                          selected: selected,
                          showCheckmark: false,
                          selectedColor: Theme.of(context).colorScheme.primary,
                          labelStyle: TextStyle(
                            color: selected
                                ? Colors.white
                                : Theme.of(context).colorScheme.onSurface,
                            fontWeight: selected
                                ? FontWeight.w600
                                : FontWeight.w400,
                          ),
                          selectedShadowColor: Colors.transparent,
                          onSelected: (_) =>
                              filterNotifier.togglePriority(priority),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ── People ──────────────────────────────────────────
                  peopleAsync.when(
                    data: (people) {
                      if (people.isEmpty) return const SizedBox.shrink();
                      return _SheetSection(
                        title: 'People',
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
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
                        ),
                      );
                    },
                    loading: () => const SizedBox.shrink(),
                    error: (error, stackTrace) => const SizedBox.shrink(),
                  ),
                ],
              ),
            ),

            // Apply / Done button
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Apply Filters'),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Small helper widget for a labelled section inside the filter sheet.
// ---------------------------------------------------------------------------

class _SheetSection extends StatelessWidget {
  final String title;
  final Widget child;

  const _SheetSection({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(height: 10),
        child,
      ],
    );
  }
}
