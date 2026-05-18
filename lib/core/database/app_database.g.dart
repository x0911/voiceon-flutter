// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $NotesTable extends Notes with TableInfo<$NotesTable, Note> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $NotesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: () => const Uuid().v4(),
  );
  static const VerificationMeta _labelMeta = const VerificationMeta('label');
  @override
  late final GeneratedColumn<String> label = GeneratedColumn<String>(
    'label',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _contentMeta = const VerificationMeta(
    'content',
  );
  @override
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
    'content',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _priorityMeta = const VerificationMeta(
    'priority',
  );
  @override
  late final GeneratedColumn<String> priority = GeneratedColumn<String>(
    'priority',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('low'),
  );
  static const VerificationMeta _isTodoMeta = const VerificationMeta('isTodo');
  @override
  late final GeneratedColumn<bool> isTodo = GeneratedColumn<bool>(
    'is_todo',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_todo" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isCompletedMeta = const VerificationMeta(
    'isCompleted',
  );
  @override
  late final GeneratedColumn<bool> isCompleted = GeneratedColumn<bool>(
    'is_completed',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_completed" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _dueDateMeta = const VerificationMeta(
    'dueDate',
  );
  @override
  late final GeneratedColumn<DateTime> dueDate = GeneratedColumn<DateTime>(
    'due_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _audioPathMeta = const VerificationMeta(
    'audioPath',
  );
  @override
  late final GeneratedColumn<String> audioPath = GeneratedColumn<String>(
    'audio_path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _audioDurationSecondsMeta =
      const VerificationMeta('audioDurationSeconds');
  @override
  late final GeneratedColumn<int> audioDurationSeconds = GeneratedColumn<int>(
    'audio_duration_seconds',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    label,
    description,
    content,
    priority,
    isTodo,
    isCompleted,
    dueDate,
    audioPath,
    audioDurationSeconds,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'notes';
  @override
  VerificationContext validateIntegrity(
    Insertable<Note> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('label')) {
      context.handle(
        _labelMeta,
        label.isAcceptableOrUnknown(data['label']!, _labelMeta),
      );
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('content')) {
      context.handle(
        _contentMeta,
        content.isAcceptableOrUnknown(data['content']!, _contentMeta),
      );
    }
    if (data.containsKey('priority')) {
      context.handle(
        _priorityMeta,
        priority.isAcceptableOrUnknown(data['priority']!, _priorityMeta),
      );
    }
    if (data.containsKey('is_todo')) {
      context.handle(
        _isTodoMeta,
        isTodo.isAcceptableOrUnknown(data['is_todo']!, _isTodoMeta),
      );
    }
    if (data.containsKey('is_completed')) {
      context.handle(
        _isCompletedMeta,
        isCompleted.isAcceptableOrUnknown(
          data['is_completed']!,
          _isCompletedMeta,
        ),
      );
    }
    if (data.containsKey('due_date')) {
      context.handle(
        _dueDateMeta,
        dueDate.isAcceptableOrUnknown(data['due_date']!, _dueDateMeta),
      );
    }
    if (data.containsKey('audio_path')) {
      context.handle(
        _audioPathMeta,
        audioPath.isAcceptableOrUnknown(data['audio_path']!, _audioPathMeta),
      );
    } else if (isInserting) {
      context.missing(_audioPathMeta);
    }
    if (data.containsKey('audio_duration_seconds')) {
      context.handle(
        _audioDurationSecondsMeta,
        audioDurationSeconds.isAcceptableOrUnknown(
          data['audio_duration_seconds']!,
          _audioDurationSecondsMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Note map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Note(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      label: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}label'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      )!,
      content: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content'],
      )!,
      priority: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}priority'],
      )!,
      isTodo: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_todo'],
      )!,
      isCompleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_completed'],
      )!,
      dueDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}due_date'],
      ),
      audioPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}audio_path'],
      )!,
      audioDurationSeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}audio_duration_seconds'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $NotesTable createAlias(String alias) {
    return $NotesTable(attachedDatabase, alias);
  }
}

class Note extends DataClass implements Insertable<Note> {
  final String id;
  final String label;
  final String description;
  final String content;
  final String priority;
  final bool isTodo;
  final bool isCompleted;
  final DateTime? dueDate;
  final String audioPath;
  final int audioDurationSeconds;
  final DateTime createdAt;
  final DateTime updatedAt;
  const Note({
    required this.id,
    required this.label,
    required this.description,
    required this.content,
    required this.priority,
    required this.isTodo,
    required this.isCompleted,
    this.dueDate,
    required this.audioPath,
    required this.audioDurationSeconds,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['label'] = Variable<String>(label);
    map['description'] = Variable<String>(description);
    map['content'] = Variable<String>(content);
    map['priority'] = Variable<String>(priority);
    map['is_todo'] = Variable<bool>(isTodo);
    map['is_completed'] = Variable<bool>(isCompleted);
    if (!nullToAbsent || dueDate != null) {
      map['due_date'] = Variable<DateTime>(dueDate);
    }
    map['audio_path'] = Variable<String>(audioPath);
    map['audio_duration_seconds'] = Variable<int>(audioDurationSeconds);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  NotesCompanion toCompanion(bool nullToAbsent) {
    return NotesCompanion(
      id: Value(id),
      label: Value(label),
      description: Value(description),
      content: Value(content),
      priority: Value(priority),
      isTodo: Value(isTodo),
      isCompleted: Value(isCompleted),
      dueDate: dueDate == null && nullToAbsent
          ? const Value.absent()
          : Value(dueDate),
      audioPath: Value(audioPath),
      audioDurationSeconds: Value(audioDurationSeconds),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Note.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Note(
      id: serializer.fromJson<String>(json['id']),
      label: serializer.fromJson<String>(json['label']),
      description: serializer.fromJson<String>(json['description']),
      content: serializer.fromJson<String>(json['content']),
      priority: serializer.fromJson<String>(json['priority']),
      isTodo: serializer.fromJson<bool>(json['isTodo']),
      isCompleted: serializer.fromJson<bool>(json['isCompleted']),
      dueDate: serializer.fromJson<DateTime?>(json['dueDate']),
      audioPath: serializer.fromJson<String>(json['audioPath']),
      audioDurationSeconds: serializer.fromJson<int>(
        json['audioDurationSeconds'],
      ),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'label': serializer.toJson<String>(label),
      'description': serializer.toJson<String>(description),
      'content': serializer.toJson<String>(content),
      'priority': serializer.toJson<String>(priority),
      'isTodo': serializer.toJson<bool>(isTodo),
      'isCompleted': serializer.toJson<bool>(isCompleted),
      'dueDate': serializer.toJson<DateTime?>(dueDate),
      'audioPath': serializer.toJson<String>(audioPath),
      'audioDurationSeconds': serializer.toJson<int>(audioDurationSeconds),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Note copyWith({
    String? id,
    String? label,
    String? description,
    String? content,
    String? priority,
    bool? isTodo,
    bool? isCompleted,
    Value<DateTime?> dueDate = const Value.absent(),
    String? audioPath,
    int? audioDurationSeconds,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => Note(
    id: id ?? this.id,
    label: label ?? this.label,
    description: description ?? this.description,
    content: content ?? this.content,
    priority: priority ?? this.priority,
    isTodo: isTodo ?? this.isTodo,
    isCompleted: isCompleted ?? this.isCompleted,
    dueDate: dueDate.present ? dueDate.value : this.dueDate,
    audioPath: audioPath ?? this.audioPath,
    audioDurationSeconds: audioDurationSeconds ?? this.audioDurationSeconds,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  Note copyWithCompanion(NotesCompanion data) {
    return Note(
      id: data.id.present ? data.id.value : this.id,
      label: data.label.present ? data.label.value : this.label,
      description: data.description.present
          ? data.description.value
          : this.description,
      content: data.content.present ? data.content.value : this.content,
      priority: data.priority.present ? data.priority.value : this.priority,
      isTodo: data.isTodo.present ? data.isTodo.value : this.isTodo,
      isCompleted: data.isCompleted.present
          ? data.isCompleted.value
          : this.isCompleted,
      dueDate: data.dueDate.present ? data.dueDate.value : this.dueDate,
      audioPath: data.audioPath.present ? data.audioPath.value : this.audioPath,
      audioDurationSeconds: data.audioDurationSeconds.present
          ? data.audioDurationSeconds.value
          : this.audioDurationSeconds,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Note(')
          ..write('id: $id, ')
          ..write('label: $label, ')
          ..write('description: $description, ')
          ..write('content: $content, ')
          ..write('priority: $priority, ')
          ..write('isTodo: $isTodo, ')
          ..write('isCompleted: $isCompleted, ')
          ..write('dueDate: $dueDate, ')
          ..write('audioPath: $audioPath, ')
          ..write('audioDurationSeconds: $audioDurationSeconds, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    label,
    description,
    content,
    priority,
    isTodo,
    isCompleted,
    dueDate,
    audioPath,
    audioDurationSeconds,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Note &&
          other.id == this.id &&
          other.label == this.label &&
          other.description == this.description &&
          other.content == this.content &&
          other.priority == this.priority &&
          other.isTodo == this.isTodo &&
          other.isCompleted == this.isCompleted &&
          other.dueDate == this.dueDate &&
          other.audioPath == this.audioPath &&
          other.audioDurationSeconds == this.audioDurationSeconds &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class NotesCompanion extends UpdateCompanion<Note> {
  final Value<String> id;
  final Value<String> label;
  final Value<String> description;
  final Value<String> content;
  final Value<String> priority;
  final Value<bool> isTodo;
  final Value<bool> isCompleted;
  final Value<DateTime?> dueDate;
  final Value<String> audioPath;
  final Value<int> audioDurationSeconds;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const NotesCompanion({
    this.id = const Value.absent(),
    this.label = const Value.absent(),
    this.description = const Value.absent(),
    this.content = const Value.absent(),
    this.priority = const Value.absent(),
    this.isTodo = const Value.absent(),
    this.isCompleted = const Value.absent(),
    this.dueDate = const Value.absent(),
    this.audioPath = const Value.absent(),
    this.audioDurationSeconds = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  NotesCompanion.insert({
    this.id = const Value.absent(),
    this.label = const Value.absent(),
    this.description = const Value.absent(),
    this.content = const Value.absent(),
    this.priority = const Value.absent(),
    this.isTodo = const Value.absent(),
    this.isCompleted = const Value.absent(),
    this.dueDate = const Value.absent(),
    required String audioPath,
    this.audioDurationSeconds = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : audioPath = Value(audioPath);
  static Insertable<Note> custom({
    Expression<String>? id,
    Expression<String>? label,
    Expression<String>? description,
    Expression<String>? content,
    Expression<String>? priority,
    Expression<bool>? isTodo,
    Expression<bool>? isCompleted,
    Expression<DateTime>? dueDate,
    Expression<String>? audioPath,
    Expression<int>? audioDurationSeconds,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (label != null) 'label': label,
      if (description != null) 'description': description,
      if (content != null) 'content': content,
      if (priority != null) 'priority': priority,
      if (isTodo != null) 'is_todo': isTodo,
      if (isCompleted != null) 'is_completed': isCompleted,
      if (dueDate != null) 'due_date': dueDate,
      if (audioPath != null) 'audio_path': audioPath,
      if (audioDurationSeconds != null)
        'audio_duration_seconds': audioDurationSeconds,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  NotesCompanion copyWith({
    Value<String>? id,
    Value<String>? label,
    Value<String>? description,
    Value<String>? content,
    Value<String>? priority,
    Value<bool>? isTodo,
    Value<bool>? isCompleted,
    Value<DateTime?>? dueDate,
    Value<String>? audioPath,
    Value<int>? audioDurationSeconds,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return NotesCompanion(
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
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (label.present) {
      map['label'] = Variable<String>(label.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    if (priority.present) {
      map['priority'] = Variable<String>(priority.value);
    }
    if (isTodo.present) {
      map['is_todo'] = Variable<bool>(isTodo.value);
    }
    if (isCompleted.present) {
      map['is_completed'] = Variable<bool>(isCompleted.value);
    }
    if (dueDate.present) {
      map['due_date'] = Variable<DateTime>(dueDate.value);
    }
    if (audioPath.present) {
      map['audio_path'] = Variable<String>(audioPath.value);
    }
    if (audioDurationSeconds.present) {
      map['audio_duration_seconds'] = Variable<int>(audioDurationSeconds.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('NotesCompanion(')
          ..write('id: $id, ')
          ..write('label: $label, ')
          ..write('description: $description, ')
          ..write('content: $content, ')
          ..write('priority: $priority, ')
          ..write('isTodo: $isTodo, ')
          ..write('isCompleted: $isCompleted, ')
          ..write('dueDate: $dueDate, ')
          ..write('audioPath: $audioPath, ')
          ..write('audioDurationSeconds: $audioDurationSeconds, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PeopleTable extends People with TableInfo<$PeopleTable, PeopleData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PeopleTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: () => const Uuid().v4(),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 255,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'UNIQUE',
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'people';
  @override
  VerificationContext validateIntegrity(
    Insertable<PeopleData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PeopleData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PeopleData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $PeopleTable createAlias(String alias) {
    return $PeopleTable(attachedDatabase, alias);
  }
}

class PeopleData extends DataClass implements Insertable<PeopleData> {
  final String id;
  final String name;
  final DateTime createdAt;
  const PeopleData({
    required this.id,
    required this.name,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  PeopleCompanion toCompanion(bool nullToAbsent) {
    return PeopleCompanion(
      id: Value(id),
      name: Value(name),
      createdAt: Value(createdAt),
    );
  }

  factory PeopleData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PeopleData(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  PeopleData copyWith({String? id, String? name, DateTime? createdAt}) =>
      PeopleData(
        id: id ?? this.id,
        name: name ?? this.name,
        createdAt: createdAt ?? this.createdAt,
      );
  PeopleData copyWithCompanion(PeopleCompanion data) {
    return PeopleData(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PeopleData(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PeopleData &&
          other.id == this.id &&
          other.name == this.name &&
          other.createdAt == this.createdAt);
}

class PeopleCompanion extends UpdateCompanion<PeopleData> {
  final Value<String> id;
  final Value<String> name;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const PeopleCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PeopleCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : name = Value(name);
  static Insertable<PeopleData> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PeopleCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return PeopleCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PeopleCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $NotePeopleTable extends NotePeople
    with TableInfo<$NotePeopleTable, NotePeopleData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $NotePeopleTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _noteIdMeta = const VerificationMeta('noteId');
  @override
  late final GeneratedColumn<String> noteId = GeneratedColumn<String>(
    'note_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES notes (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _personIdMeta = const VerificationMeta(
    'personId',
  );
  @override
  late final GeneratedColumn<String> personId = GeneratedColumn<String>(
    'person_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES people (id) ON DELETE CASCADE',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [noteId, personId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'note_people';
  @override
  VerificationContext validateIntegrity(
    Insertable<NotePeopleData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('note_id')) {
      context.handle(
        _noteIdMeta,
        noteId.isAcceptableOrUnknown(data['note_id']!, _noteIdMeta),
      );
    } else if (isInserting) {
      context.missing(_noteIdMeta);
    }
    if (data.containsKey('person_id')) {
      context.handle(
        _personIdMeta,
        personId.isAcceptableOrUnknown(data['person_id']!, _personIdMeta),
      );
    } else if (isInserting) {
      context.missing(_personIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {noteId, personId};
  @override
  NotePeopleData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return NotePeopleData(
      noteId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note_id'],
      )!,
      personId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}person_id'],
      )!,
    );
  }

  @override
  $NotePeopleTable createAlias(String alias) {
    return $NotePeopleTable(attachedDatabase, alias);
  }
}

class NotePeopleData extends DataClass implements Insertable<NotePeopleData> {
  final String noteId;
  final String personId;
  const NotePeopleData({required this.noteId, required this.personId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['note_id'] = Variable<String>(noteId);
    map['person_id'] = Variable<String>(personId);
    return map;
  }

  NotePeopleCompanion toCompanion(bool nullToAbsent) {
    return NotePeopleCompanion(
      noteId: Value(noteId),
      personId: Value(personId),
    );
  }

  factory NotePeopleData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return NotePeopleData(
      noteId: serializer.fromJson<String>(json['noteId']),
      personId: serializer.fromJson<String>(json['personId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'noteId': serializer.toJson<String>(noteId),
      'personId': serializer.toJson<String>(personId),
    };
  }

  NotePeopleData copyWith({String? noteId, String? personId}) => NotePeopleData(
    noteId: noteId ?? this.noteId,
    personId: personId ?? this.personId,
  );
  NotePeopleData copyWithCompanion(NotePeopleCompanion data) {
    return NotePeopleData(
      noteId: data.noteId.present ? data.noteId.value : this.noteId,
      personId: data.personId.present ? data.personId.value : this.personId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('NotePeopleData(')
          ..write('noteId: $noteId, ')
          ..write('personId: $personId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(noteId, personId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is NotePeopleData &&
          other.noteId == this.noteId &&
          other.personId == this.personId);
}

class NotePeopleCompanion extends UpdateCompanion<NotePeopleData> {
  final Value<String> noteId;
  final Value<String> personId;
  final Value<int> rowid;
  const NotePeopleCompanion({
    this.noteId = const Value.absent(),
    this.personId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  NotePeopleCompanion.insert({
    required String noteId,
    required String personId,
    this.rowid = const Value.absent(),
  }) : noteId = Value(noteId),
       personId = Value(personId);
  static Insertable<NotePeopleData> custom({
    Expression<String>? noteId,
    Expression<String>? personId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (noteId != null) 'note_id': noteId,
      if (personId != null) 'person_id': personId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  NotePeopleCompanion copyWith({
    Value<String>? noteId,
    Value<String>? personId,
    Value<int>? rowid,
  }) {
    return NotePeopleCompanion(
      noteId: noteId ?? this.noteId,
      personId: personId ?? this.personId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (noteId.present) {
      map['note_id'] = Variable<String>(noteId.value);
    }
    if (personId.present) {
      map['person_id'] = Variable<String>(personId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('NotePeopleCompanion(')
          ..write('noteId: $noteId, ')
          ..write('personId: $personId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CallsTableTable extends CallsTable
    with TableInfo<$CallsTableTable, CallsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CallsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _phoneNumberMeta = const VerificationMeta(
    'phoneNumber',
  );
  @override
  late final GeneratedColumn<String> phoneNumber = GeneratedColumn<String>(
    'phone_number',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _contactNameMeta = const VerificationMeta(
    'contactName',
  );
  @override
  late final GeneratedColumn<String> contactName = GeneratedColumn<String>(
    'contact_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _directionMeta = const VerificationMeta(
    'direction',
  );
  @override
  late final GeneratedColumn<String> direction = GeneratedColumn<String>(
    'direction',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startedAtMeta = const VerificationMeta(
    'startedAt',
  );
  @override
  late final GeneratedColumn<int> startedAt = GeneratedColumn<int>(
    'started_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endedAtMeta = const VerificationMeta(
    'endedAt',
  );
  @override
  late final GeneratedColumn<int> endedAt = GeneratedColumn<int>(
    'ended_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _durationSecondsMeta = const VerificationMeta(
    'durationSeconds',
  );
  @override
  late final GeneratedColumn<int> durationSeconds = GeneratedColumn<int>(
    'duration_seconds',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _audioPathMeta = const VerificationMeta(
    'audioPath',
  );
  @override
  late final GeneratedColumn<String> audioPath = GeneratedColumn<String>(
    'audio_path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fileSizeBytesMeta = const VerificationMeta(
    'fileSizeBytes',
  );
  @override
  late final GeneratedColumn<int> fileSizeBytes = GeneratedColumn<int>(
    'file_size_bytes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _fileExtensionMeta = const VerificationMeta(
    'fileExtension',
  );
  @override
  late final GeneratedColumn<String> fileExtension = GeneratedColumn<String>(
    'file_extension',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('m4a'),
  );
  static const VerificationMeta _transcriptionStatusMeta =
      const VerificationMeta('transcriptionStatus');
  @override
  late final GeneratedColumn<String> transcriptionStatus =
      GeneratedColumn<String>(
        'transcription_status',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('pending'),
      );
  static const VerificationMeta _rawTranscriptMeta = const VerificationMeta(
    'rawTranscript',
  );
  @override
  late final GeneratedColumn<String> rawTranscript = GeneratedColumn<String>(
    'raw_transcript',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _sourceFileUriMeta = const VerificationMeta(
    'sourceFileUri',
  );
  @override
  late final GeneratedColumn<String> sourceFileUri = GeneratedColumn<String>(
    'source_file_uri',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    phoneNumber,
    contactName,
    direction,
    startedAt,
    endedAt,
    durationSeconds,
    audioPath,
    fileSizeBytes,
    fileExtension,
    transcriptionStatus,
    rawTranscript,
    sourceFileUri,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'calls_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<CallsTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('phone_number')) {
      context.handle(
        _phoneNumberMeta,
        phoneNumber.isAcceptableOrUnknown(
          data['phone_number']!,
          _phoneNumberMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_phoneNumberMeta);
    }
    if (data.containsKey('contact_name')) {
      context.handle(
        _contactNameMeta,
        contactName.isAcceptableOrUnknown(
          data['contact_name']!,
          _contactNameMeta,
        ),
      );
    }
    if (data.containsKey('direction')) {
      context.handle(
        _directionMeta,
        direction.isAcceptableOrUnknown(data['direction']!, _directionMeta),
      );
    } else if (isInserting) {
      context.missing(_directionMeta);
    }
    if (data.containsKey('started_at')) {
      context.handle(
        _startedAtMeta,
        startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_startedAtMeta);
    }
    if (data.containsKey('ended_at')) {
      context.handle(
        _endedAtMeta,
        endedAt.isAcceptableOrUnknown(data['ended_at']!, _endedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_endedAtMeta);
    }
    if (data.containsKey('duration_seconds')) {
      context.handle(
        _durationSecondsMeta,
        durationSeconds.isAcceptableOrUnknown(
          data['duration_seconds']!,
          _durationSecondsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_durationSecondsMeta);
    }
    if (data.containsKey('audio_path')) {
      context.handle(
        _audioPathMeta,
        audioPath.isAcceptableOrUnknown(data['audio_path']!, _audioPathMeta),
      );
    } else if (isInserting) {
      context.missing(_audioPathMeta);
    }
    if (data.containsKey('file_size_bytes')) {
      context.handle(
        _fileSizeBytesMeta,
        fileSizeBytes.isAcceptableOrUnknown(
          data['file_size_bytes']!,
          _fileSizeBytesMeta,
        ),
      );
    }
    if (data.containsKey('file_extension')) {
      context.handle(
        _fileExtensionMeta,
        fileExtension.isAcceptableOrUnknown(
          data['file_extension']!,
          _fileExtensionMeta,
        ),
      );
    }
    if (data.containsKey('transcription_status')) {
      context.handle(
        _transcriptionStatusMeta,
        transcriptionStatus.isAcceptableOrUnknown(
          data['transcription_status']!,
          _transcriptionStatusMeta,
        ),
      );
    }
    if (data.containsKey('raw_transcript')) {
      context.handle(
        _rawTranscriptMeta,
        rawTranscript.isAcceptableOrUnknown(
          data['raw_transcript']!,
          _rawTranscriptMeta,
        ),
      );
    }
    if (data.containsKey('source_file_uri')) {
      context.handle(
        _sourceFileUriMeta,
        sourceFileUri.isAcceptableOrUnknown(
          data['source_file_uri']!,
          _sourceFileUriMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CallsTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CallsTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      phoneNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}phone_number'],
      )!,
      contactName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}contact_name'],
      )!,
      direction: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}direction'],
      )!,
      startedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}started_at'],
      )!,
      endedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ended_at'],
      )!,
      durationSeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_seconds'],
      )!,
      audioPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}audio_path'],
      )!,
      fileSizeBytes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}file_size_bytes'],
      )!,
      fileExtension: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}file_extension'],
      )!,
      transcriptionStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}transcription_status'],
      )!,
      rawTranscript: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}raw_transcript'],
      )!,
      sourceFileUri: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_file_uri'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $CallsTableTable createAlias(String alias) {
    return $CallsTableTable(attachedDatabase, alias);
  }
}

class CallsTableData extends DataClass implements Insertable<CallsTableData> {
  final String id;
  final String phoneNumber;
  final String contactName;
  final String direction;
  final int startedAt;
  final int endedAt;
  final int durationSeconds;
  final String audioPath;
  final int fileSizeBytes;
  final String fileExtension;
  final String transcriptionStatus;
  final String rawTranscript;
  final String sourceFileUri;
  final int createdAt;
  const CallsTableData({
    required this.id,
    required this.phoneNumber,
    required this.contactName,
    required this.direction,
    required this.startedAt,
    required this.endedAt,
    required this.durationSeconds,
    required this.audioPath,
    required this.fileSizeBytes,
    required this.fileExtension,
    required this.transcriptionStatus,
    required this.rawTranscript,
    required this.sourceFileUri,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['phone_number'] = Variable<String>(phoneNumber);
    map['contact_name'] = Variable<String>(contactName);
    map['direction'] = Variable<String>(direction);
    map['started_at'] = Variable<int>(startedAt);
    map['ended_at'] = Variable<int>(endedAt);
    map['duration_seconds'] = Variable<int>(durationSeconds);
    map['audio_path'] = Variable<String>(audioPath);
    map['file_size_bytes'] = Variable<int>(fileSizeBytes);
    map['file_extension'] = Variable<String>(fileExtension);
    map['transcription_status'] = Variable<String>(transcriptionStatus);
    map['raw_transcript'] = Variable<String>(rawTranscript);
    map['source_file_uri'] = Variable<String>(sourceFileUri);
    map['created_at'] = Variable<int>(createdAt);
    return map;
  }

  CallsTableCompanion toCompanion(bool nullToAbsent) {
    return CallsTableCompanion(
      id: Value(id),
      phoneNumber: Value(phoneNumber),
      contactName: Value(contactName),
      direction: Value(direction),
      startedAt: Value(startedAt),
      endedAt: Value(endedAt),
      durationSeconds: Value(durationSeconds),
      audioPath: Value(audioPath),
      fileSizeBytes: Value(fileSizeBytes),
      fileExtension: Value(fileExtension),
      transcriptionStatus: Value(transcriptionStatus),
      rawTranscript: Value(rawTranscript),
      sourceFileUri: Value(sourceFileUri),
      createdAt: Value(createdAt),
    );
  }

  factory CallsTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CallsTableData(
      id: serializer.fromJson<String>(json['id']),
      phoneNumber: serializer.fromJson<String>(json['phoneNumber']),
      contactName: serializer.fromJson<String>(json['contactName']),
      direction: serializer.fromJson<String>(json['direction']),
      startedAt: serializer.fromJson<int>(json['startedAt']),
      endedAt: serializer.fromJson<int>(json['endedAt']),
      durationSeconds: serializer.fromJson<int>(json['durationSeconds']),
      audioPath: serializer.fromJson<String>(json['audioPath']),
      fileSizeBytes: serializer.fromJson<int>(json['fileSizeBytes']),
      fileExtension: serializer.fromJson<String>(json['fileExtension']),
      transcriptionStatus: serializer.fromJson<String>(
        json['transcriptionStatus'],
      ),
      rawTranscript: serializer.fromJson<String>(json['rawTranscript']),
      sourceFileUri: serializer.fromJson<String>(json['sourceFileUri']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'phoneNumber': serializer.toJson<String>(phoneNumber),
      'contactName': serializer.toJson<String>(contactName),
      'direction': serializer.toJson<String>(direction),
      'startedAt': serializer.toJson<int>(startedAt),
      'endedAt': serializer.toJson<int>(endedAt),
      'durationSeconds': serializer.toJson<int>(durationSeconds),
      'audioPath': serializer.toJson<String>(audioPath),
      'fileSizeBytes': serializer.toJson<int>(fileSizeBytes),
      'fileExtension': serializer.toJson<String>(fileExtension),
      'transcriptionStatus': serializer.toJson<String>(transcriptionStatus),
      'rawTranscript': serializer.toJson<String>(rawTranscript),
      'sourceFileUri': serializer.toJson<String>(sourceFileUri),
      'createdAt': serializer.toJson<int>(createdAt),
    };
  }

  CallsTableData copyWith({
    String? id,
    String? phoneNumber,
    String? contactName,
    String? direction,
    int? startedAt,
    int? endedAt,
    int? durationSeconds,
    String? audioPath,
    int? fileSizeBytes,
    String? fileExtension,
    String? transcriptionStatus,
    String? rawTranscript,
    String? sourceFileUri,
    int? createdAt,
  }) => CallsTableData(
    id: id ?? this.id,
    phoneNumber: phoneNumber ?? this.phoneNumber,
    contactName: contactName ?? this.contactName,
    direction: direction ?? this.direction,
    startedAt: startedAt ?? this.startedAt,
    endedAt: endedAt ?? this.endedAt,
    durationSeconds: durationSeconds ?? this.durationSeconds,
    audioPath: audioPath ?? this.audioPath,
    fileSizeBytes: fileSizeBytes ?? this.fileSizeBytes,
    fileExtension: fileExtension ?? this.fileExtension,
    transcriptionStatus: transcriptionStatus ?? this.transcriptionStatus,
    rawTranscript: rawTranscript ?? this.rawTranscript,
    sourceFileUri: sourceFileUri ?? this.sourceFileUri,
    createdAt: createdAt ?? this.createdAt,
  );
  CallsTableData copyWithCompanion(CallsTableCompanion data) {
    return CallsTableData(
      id: data.id.present ? data.id.value : this.id,
      phoneNumber: data.phoneNumber.present
          ? data.phoneNumber.value
          : this.phoneNumber,
      contactName: data.contactName.present
          ? data.contactName.value
          : this.contactName,
      direction: data.direction.present ? data.direction.value : this.direction,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      endedAt: data.endedAt.present ? data.endedAt.value : this.endedAt,
      durationSeconds: data.durationSeconds.present
          ? data.durationSeconds.value
          : this.durationSeconds,
      audioPath: data.audioPath.present ? data.audioPath.value : this.audioPath,
      fileSizeBytes: data.fileSizeBytes.present
          ? data.fileSizeBytes.value
          : this.fileSizeBytes,
      fileExtension: data.fileExtension.present
          ? data.fileExtension.value
          : this.fileExtension,
      transcriptionStatus: data.transcriptionStatus.present
          ? data.transcriptionStatus.value
          : this.transcriptionStatus,
      rawTranscript: data.rawTranscript.present
          ? data.rawTranscript.value
          : this.rawTranscript,
      sourceFileUri: data.sourceFileUri.present
          ? data.sourceFileUri.value
          : this.sourceFileUri,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CallsTableData(')
          ..write('id: $id, ')
          ..write('phoneNumber: $phoneNumber, ')
          ..write('contactName: $contactName, ')
          ..write('direction: $direction, ')
          ..write('startedAt: $startedAt, ')
          ..write('endedAt: $endedAt, ')
          ..write('durationSeconds: $durationSeconds, ')
          ..write('audioPath: $audioPath, ')
          ..write('fileSizeBytes: $fileSizeBytes, ')
          ..write('fileExtension: $fileExtension, ')
          ..write('transcriptionStatus: $transcriptionStatus, ')
          ..write('rawTranscript: $rawTranscript, ')
          ..write('sourceFileUri: $sourceFileUri, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    phoneNumber,
    contactName,
    direction,
    startedAt,
    endedAt,
    durationSeconds,
    audioPath,
    fileSizeBytes,
    fileExtension,
    transcriptionStatus,
    rawTranscript,
    sourceFileUri,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CallsTableData &&
          other.id == this.id &&
          other.phoneNumber == this.phoneNumber &&
          other.contactName == this.contactName &&
          other.direction == this.direction &&
          other.startedAt == this.startedAt &&
          other.endedAt == this.endedAt &&
          other.durationSeconds == this.durationSeconds &&
          other.audioPath == this.audioPath &&
          other.fileSizeBytes == this.fileSizeBytes &&
          other.fileExtension == this.fileExtension &&
          other.transcriptionStatus == this.transcriptionStatus &&
          other.rawTranscript == this.rawTranscript &&
          other.sourceFileUri == this.sourceFileUri &&
          other.createdAt == this.createdAt);
}

class CallsTableCompanion extends UpdateCompanion<CallsTableData> {
  final Value<String> id;
  final Value<String> phoneNumber;
  final Value<String> contactName;
  final Value<String> direction;
  final Value<int> startedAt;
  final Value<int> endedAt;
  final Value<int> durationSeconds;
  final Value<String> audioPath;
  final Value<int> fileSizeBytes;
  final Value<String> fileExtension;
  final Value<String> transcriptionStatus;
  final Value<String> rawTranscript;
  final Value<String> sourceFileUri;
  final Value<int> createdAt;
  final Value<int> rowid;
  const CallsTableCompanion({
    this.id = const Value.absent(),
    this.phoneNumber = const Value.absent(),
    this.contactName = const Value.absent(),
    this.direction = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.endedAt = const Value.absent(),
    this.durationSeconds = const Value.absent(),
    this.audioPath = const Value.absent(),
    this.fileSizeBytes = const Value.absent(),
    this.fileExtension = const Value.absent(),
    this.transcriptionStatus = const Value.absent(),
    this.rawTranscript = const Value.absent(),
    this.sourceFileUri = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CallsTableCompanion.insert({
    required String id,
    required String phoneNumber,
    this.contactName = const Value.absent(),
    required String direction,
    required int startedAt,
    required int endedAt,
    required int durationSeconds,
    required String audioPath,
    this.fileSizeBytes = const Value.absent(),
    this.fileExtension = const Value.absent(),
    this.transcriptionStatus = const Value.absent(),
    this.rawTranscript = const Value.absent(),
    this.sourceFileUri = const Value.absent(),
    required int createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       phoneNumber = Value(phoneNumber),
       direction = Value(direction),
       startedAt = Value(startedAt),
       endedAt = Value(endedAt),
       durationSeconds = Value(durationSeconds),
       audioPath = Value(audioPath),
       createdAt = Value(createdAt);
  static Insertable<CallsTableData> custom({
    Expression<String>? id,
    Expression<String>? phoneNumber,
    Expression<String>? contactName,
    Expression<String>? direction,
    Expression<int>? startedAt,
    Expression<int>? endedAt,
    Expression<int>? durationSeconds,
    Expression<String>? audioPath,
    Expression<int>? fileSizeBytes,
    Expression<String>? fileExtension,
    Expression<String>? transcriptionStatus,
    Expression<String>? rawTranscript,
    Expression<String>? sourceFileUri,
    Expression<int>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (phoneNumber != null) 'phone_number': phoneNumber,
      if (contactName != null) 'contact_name': contactName,
      if (direction != null) 'direction': direction,
      if (startedAt != null) 'started_at': startedAt,
      if (endedAt != null) 'ended_at': endedAt,
      if (durationSeconds != null) 'duration_seconds': durationSeconds,
      if (audioPath != null) 'audio_path': audioPath,
      if (fileSizeBytes != null) 'file_size_bytes': fileSizeBytes,
      if (fileExtension != null) 'file_extension': fileExtension,
      if (transcriptionStatus != null)
        'transcription_status': transcriptionStatus,
      if (rawTranscript != null) 'raw_transcript': rawTranscript,
      if (sourceFileUri != null) 'source_file_uri': sourceFileUri,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CallsTableCompanion copyWith({
    Value<String>? id,
    Value<String>? phoneNumber,
    Value<String>? contactName,
    Value<String>? direction,
    Value<int>? startedAt,
    Value<int>? endedAt,
    Value<int>? durationSeconds,
    Value<String>? audioPath,
    Value<int>? fileSizeBytes,
    Value<String>? fileExtension,
    Value<String>? transcriptionStatus,
    Value<String>? rawTranscript,
    Value<String>? sourceFileUri,
    Value<int>? createdAt,
    Value<int>? rowid,
  }) {
    return CallsTableCompanion(
      id: id ?? this.id,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      contactName: contactName ?? this.contactName,
      direction: direction ?? this.direction,
      startedAt: startedAt ?? this.startedAt,
      endedAt: endedAt ?? this.endedAt,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      audioPath: audioPath ?? this.audioPath,
      fileSizeBytes: fileSizeBytes ?? this.fileSizeBytes,
      fileExtension: fileExtension ?? this.fileExtension,
      transcriptionStatus: transcriptionStatus ?? this.transcriptionStatus,
      rawTranscript: rawTranscript ?? this.rawTranscript,
      sourceFileUri: sourceFileUri ?? this.sourceFileUri,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (phoneNumber.present) {
      map['phone_number'] = Variable<String>(phoneNumber.value);
    }
    if (contactName.present) {
      map['contact_name'] = Variable<String>(contactName.value);
    }
    if (direction.present) {
      map['direction'] = Variable<String>(direction.value);
    }
    if (startedAt.present) {
      map['started_at'] = Variable<int>(startedAt.value);
    }
    if (endedAt.present) {
      map['ended_at'] = Variable<int>(endedAt.value);
    }
    if (durationSeconds.present) {
      map['duration_seconds'] = Variable<int>(durationSeconds.value);
    }
    if (audioPath.present) {
      map['audio_path'] = Variable<String>(audioPath.value);
    }
    if (fileSizeBytes.present) {
      map['file_size_bytes'] = Variable<int>(fileSizeBytes.value);
    }
    if (fileExtension.present) {
      map['file_extension'] = Variable<String>(fileExtension.value);
    }
    if (transcriptionStatus.present) {
      map['transcription_status'] = Variable<String>(transcriptionStatus.value);
    }
    if (rawTranscript.present) {
      map['raw_transcript'] = Variable<String>(rawTranscript.value);
    }
    if (sourceFileUri.present) {
      map['source_file_uri'] = Variable<String>(sourceFileUri.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CallsTableCompanion(')
          ..write('id: $id, ')
          ..write('phoneNumber: $phoneNumber, ')
          ..write('contactName: $contactName, ')
          ..write('direction: $direction, ')
          ..write('startedAt: $startedAt, ')
          ..write('endedAt: $endedAt, ')
          ..write('durationSeconds: $durationSeconds, ')
          ..write('audioPath: $audioPath, ')
          ..write('fileSizeBytes: $fileSizeBytes, ')
          ..write('fileExtension: $fileExtension, ')
          ..write('transcriptionStatus: $transcriptionStatus, ')
          ..write('rawTranscript: $rawTranscript, ')
          ..write('sourceFileUri: $sourceFileUri, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CallUtterancesTableTable extends CallUtterancesTable
    with TableInfo<$CallUtterancesTableTable, CallUtterancesTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CallUtterancesTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _callIdMeta = const VerificationMeta('callId');
  @override
  late final GeneratedColumn<String> callId = GeneratedColumn<String>(
    'call_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES calls_table (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _speakerMeta = const VerificationMeta(
    'speaker',
  );
  @override
  late final GeneratedColumn<String> speaker = GeneratedColumn<String>(
    'speaker',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _utteranceTextMeta = const VerificationMeta(
    'utteranceText',
  );
  @override
  late final GeneratedColumn<String> utteranceText = GeneratedColumn<String>(
    'utterance_text',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startMsMeta = const VerificationMeta(
    'startMs',
  );
  @override
  late final GeneratedColumn<int> startMs = GeneratedColumn<int>(
    'start_ms',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sequenceMeta = const VerificationMeta(
    'sequence',
  );
  @override
  late final GeneratedColumn<int> sequence = GeneratedColumn<int>(
    'sequence',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    callId,
    speaker,
    utteranceText,
    startMs,
    sequence,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'call_utterances_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<CallUtterancesTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('call_id')) {
      context.handle(
        _callIdMeta,
        callId.isAcceptableOrUnknown(data['call_id']!, _callIdMeta),
      );
    } else if (isInserting) {
      context.missing(_callIdMeta);
    }
    if (data.containsKey('speaker')) {
      context.handle(
        _speakerMeta,
        speaker.isAcceptableOrUnknown(data['speaker']!, _speakerMeta),
      );
    } else if (isInserting) {
      context.missing(_speakerMeta);
    }
    if (data.containsKey('utterance_text')) {
      context.handle(
        _utteranceTextMeta,
        utteranceText.isAcceptableOrUnknown(
          data['utterance_text']!,
          _utteranceTextMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_utteranceTextMeta);
    }
    if (data.containsKey('start_ms')) {
      context.handle(
        _startMsMeta,
        startMs.isAcceptableOrUnknown(data['start_ms']!, _startMsMeta),
      );
    }
    if (data.containsKey('sequence')) {
      context.handle(
        _sequenceMeta,
        sequence.isAcceptableOrUnknown(data['sequence']!, _sequenceMeta),
      );
    } else if (isInserting) {
      context.missing(_sequenceMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CallUtterancesTableData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CallUtterancesTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      callId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}call_id'],
      )!,
      speaker: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}speaker'],
      )!,
      utteranceText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}utterance_text'],
      )!,
      startMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}start_ms'],
      ),
      sequence: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sequence'],
      )!,
    );
  }

  @override
  $CallUtterancesTableTable createAlias(String alias) {
    return $CallUtterancesTableTable(attachedDatabase, alias);
  }
}

class CallUtterancesTableData extends DataClass
    implements Insertable<CallUtterancesTableData> {
  final String id;
  final String callId;
  final String speaker;
  final String utteranceText;
  final int? startMs;
  final int sequence;
  const CallUtterancesTableData({
    required this.id,
    required this.callId,
    required this.speaker,
    required this.utteranceText,
    this.startMs,
    required this.sequence,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['call_id'] = Variable<String>(callId);
    map['speaker'] = Variable<String>(speaker);
    map['utterance_text'] = Variable<String>(utteranceText);
    if (!nullToAbsent || startMs != null) {
      map['start_ms'] = Variable<int>(startMs);
    }
    map['sequence'] = Variable<int>(sequence);
    return map;
  }

  CallUtterancesTableCompanion toCompanion(bool nullToAbsent) {
    return CallUtterancesTableCompanion(
      id: Value(id),
      callId: Value(callId),
      speaker: Value(speaker),
      utteranceText: Value(utteranceText),
      startMs: startMs == null && nullToAbsent
          ? const Value.absent()
          : Value(startMs),
      sequence: Value(sequence),
    );
  }

  factory CallUtterancesTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CallUtterancesTableData(
      id: serializer.fromJson<String>(json['id']),
      callId: serializer.fromJson<String>(json['callId']),
      speaker: serializer.fromJson<String>(json['speaker']),
      utteranceText: serializer.fromJson<String>(json['utteranceText']),
      startMs: serializer.fromJson<int?>(json['startMs']),
      sequence: serializer.fromJson<int>(json['sequence']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'callId': serializer.toJson<String>(callId),
      'speaker': serializer.toJson<String>(speaker),
      'utteranceText': serializer.toJson<String>(utteranceText),
      'startMs': serializer.toJson<int?>(startMs),
      'sequence': serializer.toJson<int>(sequence),
    };
  }

  CallUtterancesTableData copyWith({
    String? id,
    String? callId,
    String? speaker,
    String? utteranceText,
    Value<int?> startMs = const Value.absent(),
    int? sequence,
  }) => CallUtterancesTableData(
    id: id ?? this.id,
    callId: callId ?? this.callId,
    speaker: speaker ?? this.speaker,
    utteranceText: utteranceText ?? this.utteranceText,
    startMs: startMs.present ? startMs.value : this.startMs,
    sequence: sequence ?? this.sequence,
  );
  CallUtterancesTableData copyWithCompanion(CallUtterancesTableCompanion data) {
    return CallUtterancesTableData(
      id: data.id.present ? data.id.value : this.id,
      callId: data.callId.present ? data.callId.value : this.callId,
      speaker: data.speaker.present ? data.speaker.value : this.speaker,
      utteranceText: data.utteranceText.present
          ? data.utteranceText.value
          : this.utteranceText,
      startMs: data.startMs.present ? data.startMs.value : this.startMs,
      sequence: data.sequence.present ? data.sequence.value : this.sequence,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CallUtterancesTableData(')
          ..write('id: $id, ')
          ..write('callId: $callId, ')
          ..write('speaker: $speaker, ')
          ..write('utteranceText: $utteranceText, ')
          ..write('startMs: $startMs, ')
          ..write('sequence: $sequence')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, callId, speaker, utteranceText, startMs, sequence);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CallUtterancesTableData &&
          other.id == this.id &&
          other.callId == this.callId &&
          other.speaker == this.speaker &&
          other.utteranceText == this.utteranceText &&
          other.startMs == this.startMs &&
          other.sequence == this.sequence);
}

class CallUtterancesTableCompanion
    extends UpdateCompanion<CallUtterancesTableData> {
  final Value<String> id;
  final Value<String> callId;
  final Value<String> speaker;
  final Value<String> utteranceText;
  final Value<int?> startMs;
  final Value<int> sequence;
  final Value<int> rowid;
  const CallUtterancesTableCompanion({
    this.id = const Value.absent(),
    this.callId = const Value.absent(),
    this.speaker = const Value.absent(),
    this.utteranceText = const Value.absent(),
    this.startMs = const Value.absent(),
    this.sequence = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CallUtterancesTableCompanion.insert({
    required String id,
    required String callId,
    required String speaker,
    required String utteranceText,
    this.startMs = const Value.absent(),
    required int sequence,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       callId = Value(callId),
       speaker = Value(speaker),
       utteranceText = Value(utteranceText),
       sequence = Value(sequence);
  static Insertable<CallUtterancesTableData> custom({
    Expression<String>? id,
    Expression<String>? callId,
    Expression<String>? speaker,
    Expression<String>? utteranceText,
    Expression<int>? startMs,
    Expression<int>? sequence,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (callId != null) 'call_id': callId,
      if (speaker != null) 'speaker': speaker,
      if (utteranceText != null) 'utterance_text': utteranceText,
      if (startMs != null) 'start_ms': startMs,
      if (sequence != null) 'sequence': sequence,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CallUtterancesTableCompanion copyWith({
    Value<String>? id,
    Value<String>? callId,
    Value<String>? speaker,
    Value<String>? utteranceText,
    Value<int?>? startMs,
    Value<int>? sequence,
    Value<int>? rowid,
  }) {
    return CallUtterancesTableCompanion(
      id: id ?? this.id,
      callId: callId ?? this.callId,
      speaker: speaker ?? this.speaker,
      utteranceText: utteranceText ?? this.utteranceText,
      startMs: startMs ?? this.startMs,
      sequence: sequence ?? this.sequence,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (callId.present) {
      map['call_id'] = Variable<String>(callId.value);
    }
    if (speaker.present) {
      map['speaker'] = Variable<String>(speaker.value);
    }
    if (utteranceText.present) {
      map['utterance_text'] = Variable<String>(utteranceText.value);
    }
    if (startMs.present) {
      map['start_ms'] = Variable<int>(startMs.value);
    }
    if (sequence.present) {
      map['sequence'] = Variable<int>(sequence.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CallUtterancesTableCompanion(')
          ..write('id: $id, ')
          ..write('callId: $callId, ')
          ..write('speaker: $speaker, ')
          ..write('utteranceText: $utteranceText, ')
          ..write('startMs: $startMs, ')
          ..write('sequence: $sequence, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $NotesTable notes = $NotesTable(this);
  late final $PeopleTable people = $PeopleTable(this);
  late final $NotePeopleTable notePeople = $NotePeopleTable(this);
  late final $CallsTableTable callsTable = $CallsTableTable(this);
  late final $CallUtterancesTableTable callUtterancesTable =
      $CallUtterancesTableTable(this);
  late final NotesDao notesDao = NotesDao(this as AppDatabase);
  late final PeopleDao peopleDao = PeopleDao(this as AppDatabase);
  late final NotePeopleDao notePeopleDao = NotePeopleDao(this as AppDatabase);
  late final CallsDao callsDao = CallsDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    notes,
    people,
    notePeople,
    callsTable,
    callUtterancesTable,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'notes',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('note_people', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'people',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('note_people', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'calls_table',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('call_utterances_table', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$NotesTableCreateCompanionBuilder =
    NotesCompanion Function({
      Value<String> id,
      Value<String> label,
      Value<String> description,
      Value<String> content,
      Value<String> priority,
      Value<bool> isTodo,
      Value<bool> isCompleted,
      Value<DateTime?> dueDate,
      required String audioPath,
      Value<int> audioDurationSeconds,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });
typedef $$NotesTableUpdateCompanionBuilder =
    NotesCompanion Function({
      Value<String> id,
      Value<String> label,
      Value<String> description,
      Value<String> content,
      Value<String> priority,
      Value<bool> isTodo,
      Value<bool> isCompleted,
      Value<DateTime?> dueDate,
      Value<String> audioPath,
      Value<int> audioDurationSeconds,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

final class $$NotesTableReferences
    extends BaseReferences<_$AppDatabase, $NotesTable, Note> {
  $$NotesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$NotePeopleTable, List<NotePeopleData>>
  _notePeopleRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.notePeople,
    aliasName: $_aliasNameGenerator(db.notes.id, db.notePeople.noteId),
  );

  $$NotePeopleTableProcessedTableManager get notePeopleRefs {
    final manager = $$NotePeopleTableTableManager(
      $_db,
      $_db.notePeople,
    ).filter((f) => f.noteId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_notePeopleRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$NotesTableFilterComposer extends Composer<_$AppDatabase, $NotesTable> {
  $$NotesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get priority => $composableBuilder(
    column: $table.priority,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isTodo => $composableBuilder(
    column: $table.isTodo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isCompleted => $composableBuilder(
    column: $table.isCompleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dueDate => $composableBuilder(
    column: $table.dueDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get audioPath => $composableBuilder(
    column: $table.audioPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get audioDurationSeconds => $composableBuilder(
    column: $table.audioDurationSeconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> notePeopleRefs(
    Expression<bool> Function($$NotePeopleTableFilterComposer f) f,
  ) {
    final $$NotePeopleTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.notePeople,
      getReferencedColumn: (t) => t.noteId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$NotePeopleTableFilterComposer(
            $db: $db,
            $table: $db.notePeople,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$NotesTableOrderingComposer
    extends Composer<_$AppDatabase, $NotesTable> {
  $$NotesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get priority => $composableBuilder(
    column: $table.priority,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isTodo => $composableBuilder(
    column: $table.isTodo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isCompleted => $composableBuilder(
    column: $table.isCompleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dueDate => $composableBuilder(
    column: $table.dueDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get audioPath => $composableBuilder(
    column: $table.audioPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get audioDurationSeconds => $composableBuilder(
    column: $table.audioDurationSeconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$NotesTableAnnotationComposer
    extends Composer<_$AppDatabase, $NotesTable> {
  $$NotesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get label =>
      $composableBuilder(column: $table.label, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get content =>
      $composableBuilder(column: $table.content, builder: (column) => column);

  GeneratedColumn<String> get priority =>
      $composableBuilder(column: $table.priority, builder: (column) => column);

  GeneratedColumn<bool> get isTodo =>
      $composableBuilder(column: $table.isTodo, builder: (column) => column);

  GeneratedColumn<bool> get isCompleted => $composableBuilder(
    column: $table.isCompleted,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get dueDate =>
      $composableBuilder(column: $table.dueDate, builder: (column) => column);

  GeneratedColumn<String> get audioPath =>
      $composableBuilder(column: $table.audioPath, builder: (column) => column);

  GeneratedColumn<int> get audioDurationSeconds => $composableBuilder(
    column: $table.audioDurationSeconds,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  Expression<T> notePeopleRefs<T extends Object>(
    Expression<T> Function($$NotePeopleTableAnnotationComposer a) f,
  ) {
    final $$NotePeopleTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.notePeople,
      getReferencedColumn: (t) => t.noteId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$NotePeopleTableAnnotationComposer(
            $db: $db,
            $table: $db.notePeople,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$NotesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $NotesTable,
          Note,
          $$NotesTableFilterComposer,
          $$NotesTableOrderingComposer,
          $$NotesTableAnnotationComposer,
          $$NotesTableCreateCompanionBuilder,
          $$NotesTableUpdateCompanionBuilder,
          (Note, $$NotesTableReferences),
          Note,
          PrefetchHooks Function({bool notePeopleRefs})
        > {
  $$NotesTableTableManager(_$AppDatabase db, $NotesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$NotesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$NotesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$NotesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> label = const Value.absent(),
                Value<String> description = const Value.absent(),
                Value<String> content = const Value.absent(),
                Value<String> priority = const Value.absent(),
                Value<bool> isTodo = const Value.absent(),
                Value<bool> isCompleted = const Value.absent(),
                Value<DateTime?> dueDate = const Value.absent(),
                Value<String> audioPath = const Value.absent(),
                Value<int> audioDurationSeconds = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => NotesCompanion(
                id: id,
                label: label,
                description: description,
                content: content,
                priority: priority,
                isTodo: isTodo,
                isCompleted: isCompleted,
                dueDate: dueDate,
                audioPath: audioPath,
                audioDurationSeconds: audioDurationSeconds,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> label = const Value.absent(),
                Value<String> description = const Value.absent(),
                Value<String> content = const Value.absent(),
                Value<String> priority = const Value.absent(),
                Value<bool> isTodo = const Value.absent(),
                Value<bool> isCompleted = const Value.absent(),
                Value<DateTime?> dueDate = const Value.absent(),
                required String audioPath,
                Value<int> audioDurationSeconds = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => NotesCompanion.insert(
                id: id,
                label: label,
                description: description,
                content: content,
                priority: priority,
                isTodo: isTodo,
                isCompleted: isCompleted,
                dueDate: dueDate,
                audioPath: audioPath,
                audioDurationSeconds: audioDurationSeconds,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$NotesTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback: ({notePeopleRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (notePeopleRefs) db.notePeople],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (notePeopleRefs)
                    await $_getPrefetchedData<
                      Note,
                      $NotesTable,
                      NotePeopleData
                    >(
                      currentTable: table,
                      referencedTable: $$NotesTableReferences
                          ._notePeopleRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$NotesTableReferences(db, table, p0).notePeopleRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.noteId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$NotesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $NotesTable,
      Note,
      $$NotesTableFilterComposer,
      $$NotesTableOrderingComposer,
      $$NotesTableAnnotationComposer,
      $$NotesTableCreateCompanionBuilder,
      $$NotesTableUpdateCompanionBuilder,
      (Note, $$NotesTableReferences),
      Note,
      PrefetchHooks Function({bool notePeopleRefs})
    >;
typedef $$PeopleTableCreateCompanionBuilder =
    PeopleCompanion Function({
      Value<String> id,
      required String name,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });
typedef $$PeopleTableUpdateCompanionBuilder =
    PeopleCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

final class $$PeopleTableReferences
    extends BaseReferences<_$AppDatabase, $PeopleTable, PeopleData> {
  $$PeopleTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$NotePeopleTable, List<NotePeopleData>>
  _notePeopleRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.notePeople,
    aliasName: $_aliasNameGenerator(db.people.id, db.notePeople.personId),
  );

  $$NotePeopleTableProcessedTableManager get notePeopleRefs {
    final manager = $$NotePeopleTableTableManager(
      $_db,
      $_db.notePeople,
    ).filter((f) => f.personId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_notePeopleRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$PeopleTableFilterComposer
    extends Composer<_$AppDatabase, $PeopleTable> {
  $$PeopleTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> notePeopleRefs(
    Expression<bool> Function($$NotePeopleTableFilterComposer f) f,
  ) {
    final $$NotePeopleTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.notePeople,
      getReferencedColumn: (t) => t.personId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$NotePeopleTableFilterComposer(
            $db: $db,
            $table: $db.notePeople,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PeopleTableOrderingComposer
    extends Composer<_$AppDatabase, $PeopleTable> {
  $$PeopleTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PeopleTableAnnotationComposer
    extends Composer<_$AppDatabase, $PeopleTable> {
  $$PeopleTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  Expression<T> notePeopleRefs<T extends Object>(
    Expression<T> Function($$NotePeopleTableAnnotationComposer a) f,
  ) {
    final $$NotePeopleTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.notePeople,
      getReferencedColumn: (t) => t.personId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$NotePeopleTableAnnotationComposer(
            $db: $db,
            $table: $db.notePeople,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PeopleTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PeopleTable,
          PeopleData,
          $$PeopleTableFilterComposer,
          $$PeopleTableOrderingComposer,
          $$PeopleTableAnnotationComposer,
          $$PeopleTableCreateCompanionBuilder,
          $$PeopleTableUpdateCompanionBuilder,
          (PeopleData, $$PeopleTableReferences),
          PeopleData,
          PrefetchHooks Function({bool notePeopleRefs})
        > {
  $$PeopleTableTableManager(_$AppDatabase db, $PeopleTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PeopleTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PeopleTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PeopleTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PeopleCompanion(
                id: id,
                name: name,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                required String name,
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PeopleCompanion.insert(
                id: id,
                name: name,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$PeopleTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback: ({notePeopleRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (notePeopleRefs) db.notePeople],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (notePeopleRefs)
                    await $_getPrefetchedData<
                      PeopleData,
                      $PeopleTable,
                      NotePeopleData
                    >(
                      currentTable: table,
                      referencedTable: $$PeopleTableReferences
                          ._notePeopleRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$PeopleTableReferences(db, table, p0).notePeopleRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.personId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$PeopleTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PeopleTable,
      PeopleData,
      $$PeopleTableFilterComposer,
      $$PeopleTableOrderingComposer,
      $$PeopleTableAnnotationComposer,
      $$PeopleTableCreateCompanionBuilder,
      $$PeopleTableUpdateCompanionBuilder,
      (PeopleData, $$PeopleTableReferences),
      PeopleData,
      PrefetchHooks Function({bool notePeopleRefs})
    >;
typedef $$NotePeopleTableCreateCompanionBuilder =
    NotePeopleCompanion Function({
      required String noteId,
      required String personId,
      Value<int> rowid,
    });
typedef $$NotePeopleTableUpdateCompanionBuilder =
    NotePeopleCompanion Function({
      Value<String> noteId,
      Value<String> personId,
      Value<int> rowid,
    });

final class $$NotePeopleTableReferences
    extends BaseReferences<_$AppDatabase, $NotePeopleTable, NotePeopleData> {
  $$NotePeopleTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $NotesTable _noteIdTable(_$AppDatabase db) => db.notes.createAlias(
    $_aliasNameGenerator(db.notePeople.noteId, db.notes.id),
  );

  $$NotesTableProcessedTableManager get noteId {
    final $_column = $_itemColumn<String>('note_id')!;

    final manager = $$NotesTableTableManager(
      $_db,
      $_db.notes,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_noteIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $PeopleTable _personIdTable(_$AppDatabase db) => db.people.createAlias(
    $_aliasNameGenerator(db.notePeople.personId, db.people.id),
  );

  $$PeopleTableProcessedTableManager get personId {
    final $_column = $_itemColumn<String>('person_id')!;

    final manager = $$PeopleTableTableManager(
      $_db,
      $_db.people,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_personIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$NotePeopleTableFilterComposer
    extends Composer<_$AppDatabase, $NotePeopleTable> {
  $$NotePeopleTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$NotesTableFilterComposer get noteId {
    final $$NotesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.noteId,
      referencedTable: $db.notes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$NotesTableFilterComposer(
            $db: $db,
            $table: $db.notes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PeopleTableFilterComposer get personId {
    final $$PeopleTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.personId,
      referencedTable: $db.people,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PeopleTableFilterComposer(
            $db: $db,
            $table: $db.people,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$NotePeopleTableOrderingComposer
    extends Composer<_$AppDatabase, $NotePeopleTable> {
  $$NotePeopleTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$NotesTableOrderingComposer get noteId {
    final $$NotesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.noteId,
      referencedTable: $db.notes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$NotesTableOrderingComposer(
            $db: $db,
            $table: $db.notes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PeopleTableOrderingComposer get personId {
    final $$PeopleTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.personId,
      referencedTable: $db.people,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PeopleTableOrderingComposer(
            $db: $db,
            $table: $db.people,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$NotePeopleTableAnnotationComposer
    extends Composer<_$AppDatabase, $NotePeopleTable> {
  $$NotePeopleTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$NotesTableAnnotationComposer get noteId {
    final $$NotesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.noteId,
      referencedTable: $db.notes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$NotesTableAnnotationComposer(
            $db: $db,
            $table: $db.notes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PeopleTableAnnotationComposer get personId {
    final $$PeopleTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.personId,
      referencedTable: $db.people,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PeopleTableAnnotationComposer(
            $db: $db,
            $table: $db.people,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$NotePeopleTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $NotePeopleTable,
          NotePeopleData,
          $$NotePeopleTableFilterComposer,
          $$NotePeopleTableOrderingComposer,
          $$NotePeopleTableAnnotationComposer,
          $$NotePeopleTableCreateCompanionBuilder,
          $$NotePeopleTableUpdateCompanionBuilder,
          (NotePeopleData, $$NotePeopleTableReferences),
          NotePeopleData,
          PrefetchHooks Function({bool noteId, bool personId})
        > {
  $$NotePeopleTableTableManager(_$AppDatabase db, $NotePeopleTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$NotePeopleTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$NotePeopleTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$NotePeopleTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> noteId = const Value.absent(),
                Value<String> personId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => NotePeopleCompanion(
                noteId: noteId,
                personId: personId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String noteId,
                required String personId,
                Value<int> rowid = const Value.absent(),
              }) => NotePeopleCompanion.insert(
                noteId: noteId,
                personId: personId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$NotePeopleTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({noteId = false, personId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (noteId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.noteId,
                                referencedTable: $$NotePeopleTableReferences
                                    ._noteIdTable(db),
                                referencedColumn: $$NotePeopleTableReferences
                                    ._noteIdTable(db)
                                    .id,
                              )
                              as T;
                    }
                    if (personId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.personId,
                                referencedTable: $$NotePeopleTableReferences
                                    ._personIdTable(db),
                                referencedColumn: $$NotePeopleTableReferences
                                    ._personIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$NotePeopleTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $NotePeopleTable,
      NotePeopleData,
      $$NotePeopleTableFilterComposer,
      $$NotePeopleTableOrderingComposer,
      $$NotePeopleTableAnnotationComposer,
      $$NotePeopleTableCreateCompanionBuilder,
      $$NotePeopleTableUpdateCompanionBuilder,
      (NotePeopleData, $$NotePeopleTableReferences),
      NotePeopleData,
      PrefetchHooks Function({bool noteId, bool personId})
    >;
typedef $$CallsTableTableCreateCompanionBuilder =
    CallsTableCompanion Function({
      required String id,
      required String phoneNumber,
      Value<String> contactName,
      required String direction,
      required int startedAt,
      required int endedAt,
      required int durationSeconds,
      required String audioPath,
      Value<int> fileSizeBytes,
      Value<String> fileExtension,
      Value<String> transcriptionStatus,
      Value<String> rawTranscript,
      Value<String> sourceFileUri,
      required int createdAt,
      Value<int> rowid,
    });
typedef $$CallsTableTableUpdateCompanionBuilder =
    CallsTableCompanion Function({
      Value<String> id,
      Value<String> phoneNumber,
      Value<String> contactName,
      Value<String> direction,
      Value<int> startedAt,
      Value<int> endedAt,
      Value<int> durationSeconds,
      Value<String> audioPath,
      Value<int> fileSizeBytes,
      Value<String> fileExtension,
      Value<String> transcriptionStatus,
      Value<String> rawTranscript,
      Value<String> sourceFileUri,
      Value<int> createdAt,
      Value<int> rowid,
    });

final class $$CallsTableTableReferences
    extends BaseReferences<_$AppDatabase, $CallsTableTable, CallsTableData> {
  $$CallsTableTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<
    $CallUtterancesTableTable,
    List<CallUtterancesTableData>
  >
  _callUtterancesTableRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.callUtterancesTable,
        aliasName: $_aliasNameGenerator(
          db.callsTable.id,
          db.callUtterancesTable.callId,
        ),
      );

  $$CallUtterancesTableTableProcessedTableManager get callUtterancesTableRefs {
    final manager = $$CallUtterancesTableTableTableManager(
      $_db,
      $_db.callUtterancesTable,
    ).filter((f) => f.callId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _callUtterancesTableRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$CallsTableTableFilterComposer
    extends Composer<_$AppDatabase, $CallsTableTable> {
  $$CallsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get phoneNumber => $composableBuilder(
    column: $table.phoneNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get contactName => $composableBuilder(
    column: $table.contactName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get direction => $composableBuilder(
    column: $table.direction,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get endedAt => $composableBuilder(
    column: $table.endedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationSeconds => $composableBuilder(
    column: $table.durationSeconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get audioPath => $composableBuilder(
    column: $table.audioPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get fileSizeBytes => $composableBuilder(
    column: $table.fileSizeBytes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fileExtension => $composableBuilder(
    column: $table.fileExtension,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get transcriptionStatus => $composableBuilder(
    column: $table.transcriptionStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get rawTranscript => $composableBuilder(
    column: $table.rawTranscript,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceFileUri => $composableBuilder(
    column: $table.sourceFileUri,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> callUtterancesTableRefs(
    Expression<bool> Function($$CallUtterancesTableTableFilterComposer f) f,
  ) {
    final $$CallUtterancesTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.callUtterancesTable,
      getReferencedColumn: (t) => t.callId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CallUtterancesTableTableFilterComposer(
            $db: $db,
            $table: $db.callUtterancesTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CallsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $CallsTableTable> {
  $$CallsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get phoneNumber => $composableBuilder(
    column: $table.phoneNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get contactName => $composableBuilder(
    column: $table.contactName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get direction => $composableBuilder(
    column: $table.direction,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get endedAt => $composableBuilder(
    column: $table.endedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationSeconds => $composableBuilder(
    column: $table.durationSeconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get audioPath => $composableBuilder(
    column: $table.audioPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get fileSizeBytes => $composableBuilder(
    column: $table.fileSizeBytes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fileExtension => $composableBuilder(
    column: $table.fileExtension,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get transcriptionStatus => $composableBuilder(
    column: $table.transcriptionStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rawTranscript => $composableBuilder(
    column: $table.rawTranscript,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceFileUri => $composableBuilder(
    column: $table.sourceFileUri,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CallsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $CallsTableTable> {
  $$CallsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get phoneNumber => $composableBuilder(
    column: $table.phoneNumber,
    builder: (column) => column,
  );

  GeneratedColumn<String> get contactName => $composableBuilder(
    column: $table.contactName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get direction =>
      $composableBuilder(column: $table.direction, builder: (column) => column);

  GeneratedColumn<int> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<int> get endedAt =>
      $composableBuilder(column: $table.endedAt, builder: (column) => column);

  GeneratedColumn<int> get durationSeconds => $composableBuilder(
    column: $table.durationSeconds,
    builder: (column) => column,
  );

  GeneratedColumn<String> get audioPath =>
      $composableBuilder(column: $table.audioPath, builder: (column) => column);

  GeneratedColumn<int> get fileSizeBytes => $composableBuilder(
    column: $table.fileSizeBytes,
    builder: (column) => column,
  );

  GeneratedColumn<String> get fileExtension => $composableBuilder(
    column: $table.fileExtension,
    builder: (column) => column,
  );

  GeneratedColumn<String> get transcriptionStatus => $composableBuilder(
    column: $table.transcriptionStatus,
    builder: (column) => column,
  );

  GeneratedColumn<String> get rawTranscript => $composableBuilder(
    column: $table.rawTranscript,
    builder: (column) => column,
  );

  GeneratedColumn<String> get sourceFileUri => $composableBuilder(
    column: $table.sourceFileUri,
    builder: (column) => column,
  );

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  Expression<T> callUtterancesTableRefs<T extends Object>(
    Expression<T> Function($$CallUtterancesTableTableAnnotationComposer a) f,
  ) {
    final $$CallUtterancesTableTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.callUtterancesTable,
          getReferencedColumn: (t) => t.callId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$CallUtterancesTableTableAnnotationComposer(
                $db: $db,
                $table: $db.callUtterancesTable,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$CallsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CallsTableTable,
          CallsTableData,
          $$CallsTableTableFilterComposer,
          $$CallsTableTableOrderingComposer,
          $$CallsTableTableAnnotationComposer,
          $$CallsTableTableCreateCompanionBuilder,
          $$CallsTableTableUpdateCompanionBuilder,
          (CallsTableData, $$CallsTableTableReferences),
          CallsTableData,
          PrefetchHooks Function({bool callUtterancesTableRefs})
        > {
  $$CallsTableTableTableManager(_$AppDatabase db, $CallsTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CallsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CallsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CallsTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> phoneNumber = const Value.absent(),
                Value<String> contactName = const Value.absent(),
                Value<String> direction = const Value.absent(),
                Value<int> startedAt = const Value.absent(),
                Value<int> endedAt = const Value.absent(),
                Value<int> durationSeconds = const Value.absent(),
                Value<String> audioPath = const Value.absent(),
                Value<int> fileSizeBytes = const Value.absent(),
                Value<String> fileExtension = const Value.absent(),
                Value<String> transcriptionStatus = const Value.absent(),
                Value<String> rawTranscript = const Value.absent(),
                Value<String> sourceFileUri = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CallsTableCompanion(
                id: id,
                phoneNumber: phoneNumber,
                contactName: contactName,
                direction: direction,
                startedAt: startedAt,
                endedAt: endedAt,
                durationSeconds: durationSeconds,
                audioPath: audioPath,
                fileSizeBytes: fileSizeBytes,
                fileExtension: fileExtension,
                transcriptionStatus: transcriptionStatus,
                rawTranscript: rawTranscript,
                sourceFileUri: sourceFileUri,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String phoneNumber,
                Value<String> contactName = const Value.absent(),
                required String direction,
                required int startedAt,
                required int endedAt,
                required int durationSeconds,
                required String audioPath,
                Value<int> fileSizeBytes = const Value.absent(),
                Value<String> fileExtension = const Value.absent(),
                Value<String> transcriptionStatus = const Value.absent(),
                Value<String> rawTranscript = const Value.absent(),
                Value<String> sourceFileUri = const Value.absent(),
                required int createdAt,
                Value<int> rowid = const Value.absent(),
              }) => CallsTableCompanion.insert(
                id: id,
                phoneNumber: phoneNumber,
                contactName: contactName,
                direction: direction,
                startedAt: startedAt,
                endedAt: endedAt,
                durationSeconds: durationSeconds,
                audioPath: audioPath,
                fileSizeBytes: fileSizeBytes,
                fileExtension: fileExtension,
                transcriptionStatus: transcriptionStatus,
                rawTranscript: rawTranscript,
                sourceFileUri: sourceFileUri,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$CallsTableTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({callUtterancesTableRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (callUtterancesTableRefs) db.callUtterancesTable,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (callUtterancesTableRefs)
                    await $_getPrefetchedData<
                      CallsTableData,
                      $CallsTableTable,
                      CallUtterancesTableData
                    >(
                      currentTable: table,
                      referencedTable: $$CallsTableTableReferences
                          ._callUtterancesTableRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$CallsTableTableReferences(
                            db,
                            table,
                            p0,
                          ).callUtterancesTableRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.callId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$CallsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CallsTableTable,
      CallsTableData,
      $$CallsTableTableFilterComposer,
      $$CallsTableTableOrderingComposer,
      $$CallsTableTableAnnotationComposer,
      $$CallsTableTableCreateCompanionBuilder,
      $$CallsTableTableUpdateCompanionBuilder,
      (CallsTableData, $$CallsTableTableReferences),
      CallsTableData,
      PrefetchHooks Function({bool callUtterancesTableRefs})
    >;
typedef $$CallUtterancesTableTableCreateCompanionBuilder =
    CallUtterancesTableCompanion Function({
      required String id,
      required String callId,
      required String speaker,
      required String utteranceText,
      Value<int?> startMs,
      required int sequence,
      Value<int> rowid,
    });
typedef $$CallUtterancesTableTableUpdateCompanionBuilder =
    CallUtterancesTableCompanion Function({
      Value<String> id,
      Value<String> callId,
      Value<String> speaker,
      Value<String> utteranceText,
      Value<int?> startMs,
      Value<int> sequence,
      Value<int> rowid,
    });

final class $$CallUtterancesTableTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $CallUtterancesTableTable,
          CallUtterancesTableData
        > {
  $$CallUtterancesTableTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $CallsTableTable _callIdTable(_$AppDatabase db) =>
      db.callsTable.createAlias(
        $_aliasNameGenerator(db.callUtterancesTable.callId, db.callsTable.id),
      );

  $$CallsTableTableProcessedTableManager get callId {
    final $_column = $_itemColumn<String>('call_id')!;

    final manager = $$CallsTableTableTableManager(
      $_db,
      $_db.callsTable,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_callIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$CallUtterancesTableTableFilterComposer
    extends Composer<_$AppDatabase, $CallUtterancesTableTable> {
  $$CallUtterancesTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get speaker => $composableBuilder(
    column: $table.speaker,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get utteranceText => $composableBuilder(
    column: $table.utteranceText,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get startMs => $composableBuilder(
    column: $table.startMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sequence => $composableBuilder(
    column: $table.sequence,
    builder: (column) => ColumnFilters(column),
  );

  $$CallsTableTableFilterComposer get callId {
    final $$CallsTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.callId,
      referencedTable: $db.callsTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CallsTableTableFilterComposer(
            $db: $db,
            $table: $db.callsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CallUtterancesTableTableOrderingComposer
    extends Composer<_$AppDatabase, $CallUtterancesTableTable> {
  $$CallUtterancesTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get speaker => $composableBuilder(
    column: $table.speaker,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get utteranceText => $composableBuilder(
    column: $table.utteranceText,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get startMs => $composableBuilder(
    column: $table.startMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sequence => $composableBuilder(
    column: $table.sequence,
    builder: (column) => ColumnOrderings(column),
  );

  $$CallsTableTableOrderingComposer get callId {
    final $$CallsTableTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.callId,
      referencedTable: $db.callsTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CallsTableTableOrderingComposer(
            $db: $db,
            $table: $db.callsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CallUtterancesTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $CallUtterancesTableTable> {
  $$CallUtterancesTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get speaker =>
      $composableBuilder(column: $table.speaker, builder: (column) => column);

  GeneratedColumn<String> get utteranceText => $composableBuilder(
    column: $table.utteranceText,
    builder: (column) => column,
  );

  GeneratedColumn<int> get startMs =>
      $composableBuilder(column: $table.startMs, builder: (column) => column);

  GeneratedColumn<int> get sequence =>
      $composableBuilder(column: $table.sequence, builder: (column) => column);

  $$CallsTableTableAnnotationComposer get callId {
    final $$CallsTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.callId,
      referencedTable: $db.callsTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CallsTableTableAnnotationComposer(
            $db: $db,
            $table: $db.callsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CallUtterancesTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CallUtterancesTableTable,
          CallUtterancesTableData,
          $$CallUtterancesTableTableFilterComposer,
          $$CallUtterancesTableTableOrderingComposer,
          $$CallUtterancesTableTableAnnotationComposer,
          $$CallUtterancesTableTableCreateCompanionBuilder,
          $$CallUtterancesTableTableUpdateCompanionBuilder,
          (CallUtterancesTableData, $$CallUtterancesTableTableReferences),
          CallUtterancesTableData,
          PrefetchHooks Function({bool callId})
        > {
  $$CallUtterancesTableTableTableManager(
    _$AppDatabase db,
    $CallUtterancesTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CallUtterancesTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CallUtterancesTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$CallUtterancesTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> callId = const Value.absent(),
                Value<String> speaker = const Value.absent(),
                Value<String> utteranceText = const Value.absent(),
                Value<int?> startMs = const Value.absent(),
                Value<int> sequence = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CallUtterancesTableCompanion(
                id: id,
                callId: callId,
                speaker: speaker,
                utteranceText: utteranceText,
                startMs: startMs,
                sequence: sequence,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String callId,
                required String speaker,
                required String utteranceText,
                Value<int?> startMs = const Value.absent(),
                required int sequence,
                Value<int> rowid = const Value.absent(),
              }) => CallUtterancesTableCompanion.insert(
                id: id,
                callId: callId,
                speaker: speaker,
                utteranceText: utteranceText,
                startMs: startMs,
                sequence: sequence,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$CallUtterancesTableTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({callId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (callId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.callId,
                                referencedTable:
                                    $$CallUtterancesTableTableReferences
                                        ._callIdTable(db),
                                referencedColumn:
                                    $$CallUtterancesTableTableReferences
                                        ._callIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$CallUtterancesTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CallUtterancesTableTable,
      CallUtterancesTableData,
      $$CallUtterancesTableTableFilterComposer,
      $$CallUtterancesTableTableOrderingComposer,
      $$CallUtterancesTableTableAnnotationComposer,
      $$CallUtterancesTableTableCreateCompanionBuilder,
      $$CallUtterancesTableTableUpdateCompanionBuilder,
      (CallUtterancesTableData, $$CallUtterancesTableTableReferences),
      CallUtterancesTableData,
      PrefetchHooks Function({bool callId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$NotesTableTableManager get notes =>
      $$NotesTableTableManager(_db, _db.notes);
  $$PeopleTableTableManager get people =>
      $$PeopleTableTableManager(_db, _db.people);
  $$NotePeopleTableTableManager get notePeople =>
      $$NotePeopleTableTableManager(_db, _db.notePeople);
  $$CallsTableTableTableManager get callsTable =>
      $$CallsTableTableTableManager(_db, _db.callsTable);
  $$CallUtterancesTableTableTableManager get callUtterancesTable =>
      $$CallUtterancesTableTableTableManager(_db, _db.callUtterancesTable);
}

mixin _$NotesDaoMixin on DatabaseAccessor<AppDatabase> {
  $NotesTable get notes => attachedDatabase.notes;
  $PeopleTable get people => attachedDatabase.people;
  $NotePeopleTable get notePeople => attachedDatabase.notePeople;
}
mixin _$PeopleDaoMixin on DatabaseAccessor<AppDatabase> {
  $PeopleTable get people => attachedDatabase.people;
}
mixin _$NotePeopleDaoMixin on DatabaseAccessor<AppDatabase> {
  $NotesTable get notes => attachedDatabase.notes;
  $PeopleTable get people => attachedDatabase.people;
  $NotePeopleTable get notePeople => attachedDatabase.notePeople;
}
mixin _$CallsDaoMixin on DatabaseAccessor<AppDatabase> {
  $CallsTableTable get callsTable => attachedDatabase.callsTable;
  $CallUtterancesTableTable get callUtterancesTable =>
      attachedDatabase.callUtterancesTable;
}
