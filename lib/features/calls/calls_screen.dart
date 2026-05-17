import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'call_card.dart';
import 'calls_provider.dart';

class CallsScreen extends ConsumerStatefulWidget {
  const CallsScreen({super.key});

  @override
  ConsumerState<CallsScreen> createState() => _CallsScreenState();
}

class _CallsScreenState extends ConsumerState<CallsScreen> {
  void _openFilters(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return _FilterSheet();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final callsAsync = ref.watch(filteredCallsProvider);
    final filters = ref.watch(callFilterProvider);
    final filterNotifier = ref.read(callFilterProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Calls'),
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
      body: CustomScrollView(
        slivers: [
          // Search field
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    decoration: const InputDecoration(
                      hintText: 'Search calls...',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                    onChanged: filterNotifier.updateSearchText,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 4, left: 12),
                    child: Text(
                      'Searches transcript, contact name and phone number',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withAlpha((0.5 * 255).round()),
                          ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),

          // Calls list
          callsAsync.when(
            data: (calls) {
              if (calls.isEmpty) {
                return SliverFillRemaining(
                  hasScrollBody: false,
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.phone_in_talk_outlined,
                          size: 72,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 24),
                        Text(
                          filters.hasFilters
                              ? 'No calls match your filters'
                              : 'No calls recorded yet',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
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
                  final call = calls[index];
                  return CallCard(
                    callRecord: call,
                    onTap: () => context.push('/calls/${call.id}'),
                  );
                }, childCount: calls.length),
              );
            },
            loading: () => const SliverFillRemaining(
              hasScrollBody: false,
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (error, stack) => SliverFillRemaining(
              hasScrollBody: false,
              child: Center(child: Text('Unable to load calls: $error')),
            ),
          ),
          
          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    );
  }
}

class _FilterSheet extends ConsumerStatefulWidget {
  @override
  ConsumerState<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends ConsumerState<_FilterSheet> {
  late TextEditingController _calleeNameController;
  late TextEditingController _calleeNumberController;

  @override
  void initState() {
    super.initState();
    final filters = ref.read(callFilterProvider);
    _calleeNameController = TextEditingController(text: filters.calleeName);
    _calleeNumberController = TextEditingController(text: filters.calleeNumber);
  }

  @override
  void dispose() {
    _calleeNameController.dispose();
    _calleeNumberController.dispose();
    super.dispose();
  }

  Future<void> _pickDate(BuildContext context, bool isStart) async {
    final filters = ref.read(callFilterProvider);
    final initialDate = isStart
        ? (filters.startDate ?? DateTime.now())
        : (filters.endDate ?? DateTime.now());

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      final notifier = ref.read(callFilterProvider.notifier);
      if (isStart) {
        notifier.setStartDate(picked);
      } else {
        notifier.setEndDate(picked);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final filters = ref.watch(callFilterProvider);
    final filterNotifier = ref.read(callFilterProvider.notifier);

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
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
                        _calleeNameController.clear();
                        _calleeNumberController.clear();
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
                  _SheetSection(
                    title: 'Callee Name',
                    child: TextField(
                      controller: _calleeNameController,
                      decoration: const InputDecoration(
                        hintText: 'Filter by contact name',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: filterNotifier.updateCalleeName,
                    ),
                  ),
                  const SizedBox(height: 24),
                  _SheetSection(
                    title: 'Callee Number',
                    child: TextField(
                      controller: _calleeNumberController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        hintText: 'Filter by phone number',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: filterNotifier.updateCalleeNumber,
                    ),
                  ),
                  const SizedBox(height: 24),
                  _SheetSection(
                    title: 'Date Range',
                    child: Row(
                      children: [
                        Expanded(
                          child: _DateTile(
                            label: 'From',
                            date: filters.startDate,
                            onTap: () => _pickDate(context, true),
                            onClear: () => filterNotifier.setStartDate(null),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _DateTile(
                            label: 'To',
                            date: filters.endDate,
                            onTap: () => _pickDate(context, false),
                            onClear: () => filterNotifier.setEndDate(null),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Apply button
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

class _DateTile extends StatelessWidget {
  final String label;
  final DateTime? date;
  final VoidCallback onTap;
  final VoidCallback onClear;

  const _DateTile({
    required this.label,
    required this.date,
    required this.onTap,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 4),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Theme.of(context).colorScheme.outline),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    date != null ? DateFormat('MMM d, yyyy').format(date!) : 'Tap to set',
                    style: TextStyle(
                      color: date != null
                          ? Theme.of(context).colorScheme.onSurface
                          : Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (date != null)
                  GestureDetector(
                    onTap: onClear,
                    child: const Icon(Icons.close, size: 16),
                  )
                else
                  const Icon(Icons.calendar_today, size: 16),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

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
