import 'person.dart';

enum NotePriority { low, medium, high }

extension NotePriorityX on NotePriority {
  String get value {
    switch (this) {
      case NotePriority.low:
        return 'low';
      case NotePriority.medium:
        return 'medium';
      case NotePriority.high:
        return 'high';
    }
  }

  static NotePriority fromString(String value) {
    switch (value) {
      case 'medium':
        return NotePriority.medium;
      case 'high':
        return NotePriority.high;
      default:
        return NotePriority.low;
    }
  }
}

class NoteModel {
  final String id;
  final String label;
  final String description;
  final String content;
  final NotePriority priority;
  final bool isTodo;
  final bool isCompleted;
  final DateTime? dueDate;
  final String audioPath;
  final int audioDurationSeconds;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<PersonModel> taggedPeople;

  const NoteModel({
    required this.id,
    this.label = '',
    this.description = '',
    this.content = '',
    this.priority = NotePriority.low,
    this.isTodo = false,
    this.isCompleted = false,
    this.dueDate,
    required this.audioPath,
    this.audioDurationSeconds = 0,
    required this.createdAt,
    required this.updatedAt,
    this.taggedPeople = const [],
  });

  NoteModel copyWith({
    String? id,
    String? label,
    String? description,
    String? content,
    NotePriority? priority,
    bool? isTodo,
    bool? isCompleted,
    DateTime? dueDate,
    String? audioPath,
    int? audioDurationSeconds,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<PersonModel>? taggedPeople,
  }) {
    return NoteModel(
      id: id ?? this.id,
      label: label ?? this.label,
      description: description ?? this.description,
      content: content ?? this.content,
      priority: priority ?? this.priority,
      isTodo: isTodo ?? this.isTodo,
      isCompleted: isCompleted ?? this.isCompleted,
      dueDate: dueDate ?? this.dueDate,
      audioPath: audioPath ?? this.audioPath,
      audioDurationSeconds: audioDurationSeconds ?? this.audioDurationSeconds,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      taggedPeople: taggedPeople ?? this.taggedPeople,
    );
  }
}
