import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/models/note.dart';
import '../../core/repositories/note_repository.dart';
import 'home_state.dart';
import 'note_card.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
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
        // Use a ConsumerWidget inside the sheet so it can watch Riverpod state.
        return _FilterSheet();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final notesAsync = ref.watch(homeNotesProvider);
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

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            floating: false,
            snap: false,
            title: const Text('Voiceon'),
            actions: [
              // Filter icon — badge shows when any filter is active
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
              IconButton(
                icon: const Icon(Icons.settings_outlined),
                tooltip: 'Settings',
                onPressed: () => context.push('/settings'),
              ),
            ],
          ),

          // Search field — stays on the main screen, not in the dialog
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
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
                ],
              ),
            ),
          ),

          // Notes list
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

// ---------------------------------------------------------------------------
// Filter bottom sheet — lives in its own ConsumerWidget so it rebuilds
// independently from the main screen when filter state changes.
// ---------------------------------------------------------------------------

class _FilterSheet extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filters = ref.watch(homeFilterProvider);
    final filterNotifier = ref.read(homeFilterProvider.notifier);
    final peopleAsync = ref.watch(homePeopleProvider);

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

                  // ── Type ────────────────────────────────────────────
                  _SheetSection(
                    title: 'Type',
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _typeChip(
                          context: context,
                          label: 'Todo',
                          selected: filters.todoFilter == HomeTodoFilter.todo,
                          onTap: () => filterNotifier.setTodoFilter(
                            filters.todoFilter == HomeTodoFilter.todo
                                ? HomeTodoFilter.all
                                : HomeTodoFilter.todo,
                          ),
                        ),
                        _typeChip(
                          context: context,
                          label: 'Non-Todo',
                          selected:
                              filters.todoFilter == HomeTodoFilter.nonTodo,
                          onTap: () => filterNotifier.setTodoFilter(
                            filters.todoFilter == HomeTodoFilter.nonTodo
                                ? HomeTodoFilter.all
                                : HomeTodoFilter.nonTodo,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ── Status ──────────────────────────────────────────
                  _SheetSection(
                    title: 'Status',
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _typeChip(
                          context: context,
                          label: 'Pending',
                          selected:
                              filters.statusFilter == HomeStatusFilter.pending,
                          onTap: () => filterNotifier.setStatusFilter(
                            filters.statusFilter == HomeStatusFilter.pending
                                ? HomeStatusFilter.all
                                : HomeStatusFilter.pending,
                          ),
                        ),
                        _typeChip(
                          context: context,
                          label: 'Completed',
                          selected:
                              filters.statusFilter ==
                              HomeStatusFilter.completed,
                          onTap: () => filterNotifier.setStatusFilter(
                            filters.statusFilter == HomeStatusFilter.completed
                                ? HomeStatusFilter.all
                                : HomeStatusFilter.completed,
                          ),
                        ),
                      ],
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

  Widget _typeChip({
    required BuildContext context,
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      showCheckmark: false,
      selectedColor: Theme.of(context).colorScheme.primary,
      labelStyle: TextStyle(
        color: selected
            ? Colors.white
            : Theme.of(context).colorScheme.onSurface,
      ),
      selectedShadowColor: Colors.transparent,
      onSelected: (_) => onTap(),
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
