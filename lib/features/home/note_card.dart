import 'dart:ui';

import 'package:flutter/material.dart';
import '../../core/models/note.dart';
import '../../core/models/person.dart';

class NoteCard extends StatelessWidget {
  final NoteModel note;
  final Future<bool> Function(bool)? onToggleCompleted;
  final VoidCallback? onTap;

  const NoteCard({
    super.key,
    required this.note,
    this.onToggleCompleted,
    this.onTap,
  });

  Color _priorityColor(NotePriority priority) {
    switch (priority) {
      case NotePriority.high:
        return Colors.redAccent;
      case NotePriority.medium:
        return Colors.orangeAccent;
      case NotePriority.low:
        return Colors.lightGreen;
    }
  }

  @override
  Widget build(BuildContext context) {
    final dueText = _formatDueText(note.dueDate);
    final backgroundColor = Theme.of(context).brightness == Brightness.dark
        ? Colors.white.withAlpha(15)
        : Colors.white.withAlpha(219);
    final borderColor = Theme.of(context).colorScheme.onSurface.withAlpha(20);
    final accentColor = _priorityColor(note.priority);

    final cardContent = InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 6,
                  decoration: BoxDecoration(
                    color: accentColor,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      bottomLeft: Radius.circular(16),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                note.label.isNotEmpty
                                    ? note.label
                                    : 'Untitled note',
                                style: Theme.of(context).textTheme.titleLarge,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            _PriorityBadge(priority: note.priority),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          note.description.isNotEmpty
                              ? note.description
                              : note.content,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            if (note.isTodo) ...[
                              note.isCompleted
                                  ? const Icon(
                                      Icons.check_box_outlined,
                                      size: 20,
                                    )
                                  : const Icon(
                                      Icons.check_box_outline_blank,
                                      size: 20,
                                    ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  note.isCompleted ? 'Completed' : 'Todo',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ),
                            ] else ...[
                              const Icon(Icons.article_outlined, size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Note',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ),
                            ],
                            if (note.dueDate != null) ...[
                              const Icon(
                                Icons.calendar_today_outlined,
                                size: 18,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                dueText,
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(
                                      color:
                                          note.dueDate!.isBefore(DateTime.now())
                                          ? Colors.redAccent
                                          : null,
                                    ),
                              ),
                            ],
                          ],
                        ),
                        if (note.taggedPeople.isNotEmpty) ...[
                          const SizedBox(height: 14),
                          _TaggedPeopleRow(people: note.taggedPeople),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    if (!note.isTodo || onToggleCompleted == null) {
      return cardContent;
    }

    final direction = note.isCompleted
        ? DismissDirection.endToStart
        : DismissDirection.startToEnd;

    return Dismissible(
      key: ValueKey('${note.id}_${note.isCompleted}'),
      direction: direction,
      confirmDismiss: (dir) async {
        await onToggleCompleted!(!note.isCompleted);
        return false;
      },
      background: _SwipeBackground(
        alignment: Alignment.centerLeft,
        color: Colors.green.shade400,
        icon: Icons.check_rounded,
        label: 'Complete',
      ),
      secondaryBackground: _SwipeBackground(
        alignment: Alignment.centerRight,
        color: Colors.amber.shade600,
        icon: Icons.undo_rounded,
        label: 'Undo',
      ),
      child: cardContent,
    );
  }

  String _formatDueText(DateTime? dueDate) {
    if (dueDate == null) {
      return 'No due date';
    }

    final now = DateTime.now();
    final difference = dueDate.difference(now);

    if (difference.inDays.abs() >= 1) {
      if (difference.isNegative) {
        return 'Overdue by ${difference.inDays.abs()} day${difference.inDays.abs() == 1 ? '' : 's'}';
      }
      return 'Due in ${difference.inDays} day${difference.inDays == 1 ? '' : 's'}';
    }

    if (difference.inHours.abs() >= 1) {
      return difference.isNegative
          ? 'Overdue by ${difference.inHours.abs()} hour${difference.inHours.abs() == 1 ? '' : 's'}'
          : 'Due in ${difference.inHours} hour${difference.inHours == 1 ? '' : 's'}';
    }

    if (difference.isNegative) {
      return 'Due today';
    }

    return 'Due soon';
  }
}

class _PriorityBadge extends StatelessWidget {
  final NotePriority priority;

  const _PriorityBadge({required this.priority});

  @override
  Widget build(BuildContext context) {
    final color = _priorityColor(priority);
    return Container(
      decoration: BoxDecoration(
        color: color.withAlpha((0.12 * 255).round()),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      child: Text(
        priority.name[0].toUpperCase() + priority.name.substring(1),
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }

  Color _priorityColor(NotePriority priority) {
    switch (priority) {
      case NotePriority.high:
        return Colors.red;
      case NotePriority.medium:
        return Colors.orange;
      case NotePriority.low:
        return Colors.green;
    }
  }
}

class _TaggedPeopleRow extends StatelessWidget {
  final List<PersonModel> people;

  const _TaggedPeopleRow({required this.people});

  @override
  Widget build(BuildContext context) {
    final visiblePeople = people.take(3).toList();
    final overflow = people.length - visiblePeople.length;

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        ...visiblePeople.map(
          (person) => CircleAvatar(
            radius: 16,
            child: Text(
              person.name.isNotEmpty ? person.name[0].toUpperCase() : '?',
            ),
          ),
        ),
        if (overflow > 0)
          CircleAvatar(
            radius: 16,
            backgroundColor: Theme.of(context).colorScheme.primary,
            child: Text(
              '+$overflow',
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
      ],
    );
  }
}

class _SwipeBackground extends StatelessWidget {
  final AlignmentGeometry alignment;
  final Color color;
  final IconData icon;
  final String label;

  const _SwipeBackground({
    required this.alignment,
    required this.color,
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final isLeft = alignment == Alignment.centerLeft;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      alignment: alignment,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: isLeft
            ? [
                Icon(icon, color: Colors.white, size: 22),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ]
            : [
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(icon, color: Colors.white, size: 22),
              ],
      ),
    );
  }
}
