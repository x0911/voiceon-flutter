import 'dart:async';
import 'dart:io';

import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/database/app_database.dart';
import '../../core/models/note.dart';
import '../../core/models/person.dart';
import '../../core/repositories/note_repository.dart';
import '../../core/repositories/people_repository.dart';
import '../../core/services/audio_service.dart';
import '../../core/services/transcription_service.dart';
import '../../core/transcription/transcription_result.dart';
import '../metadata/metadata_screen.dart';
import 'note_detail_provider.dart';

class NoteDetailScreen extends ConsumerStatefulWidget {
  final String noteId;

  const NoteDetailScreen({super.key, required this.noteId});

  @override
  ConsumerState<NoteDetailScreen> createState() => _NoteDetailScreenState();
}

class _NoteDetailScreenState extends ConsumerState<NoteDetailScreen> {
  late final PlayerController _playerController;
  late final StreamSubscription<int> _durationSubscription;
  late final StreamSubscription<PlayerState> _playerStateSubscription;

  final _labelController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _contentController = TextEditingController();
  final _newPersonController = TextEditingController();

  bool _isEditing = false;
  bool _showTranscript = false;
  bool _isPreparingAudio = false;
  bool _audioMissing = false;
  bool _isTranscribing = false;
  int _currentMs = 0;
  int _maxMs = 0;
  PlayerState _playerState = PlayerState.stopped;

  // FIX: track whether we have loaded the note into local state at least once.
  // _noteLoaded prevents _syncNoteValues from overwriting user edits on every
  // stream rebuild, while still allowing the initial load to populate fields.
  bool _noteLoaded = false;
  String? _loadedNoteId;

  NoteModel? _note;
  Set<String> _selectedPersonIds = {};
  NotePriority _editedPriority = NotePriority.low;
  bool _editedIsTodo = false;
  bool _editedIsCompleted = false;
  DateTime? _editedDueDate;

  @override
  void initState() {
    super.initState();
    _playerController = PlayerController();
    _durationSubscription = _playerController.onCurrentDurationChanged.listen((
      milliseconds,
    ) {
      if (!mounted) return;
      setState(() => _currentMs = milliseconds);
    });
    _playerStateSubscription = _playerController.onPlayerStateChanged.listen((
      state,
    ) {
      if (!mounted) return;
      setState(() => _playerState = state);
    });
  }

  @override
  void dispose() {
    _durationSubscription.cancel();
    _playerStateSubscription.cancel();
    _playerController.dispose();
    _labelController.dispose();
    _descriptionController.dispose();
    _contentController.dispose();
    _newPersonController.dispose();
    super.dispose();
  }

  Future<void> _prepareAudio(String path) async {
    if (_isPreparingAudio) return;
    setState(() {
      _isPreparingAudio = true;
      _audioMissing = false;
    });

    final file = File(path);
    if (!await file.exists()) {
      if (!mounted) return;
      setState(() {
        _audioMissing = true;
        _isPreparingAudio = false;
      });
      return;
    }

    try {
      await _playerController.preparePlayer(path: path);
      final durationMs = await _playerController.getDuration();
      if (!mounted) return;
      setState(() {
        _maxMs = durationMs > 0
            ? durationMs
            : (_note?.audioDurationSeconds ?? 0) * 1000;
        _audioMissing = false;
      });
    } catch (_) {
      if (mounted) setState(() => _audioMissing = true);
    } finally {
      if (mounted) setState(() => _isPreparingAudio = false);
    }
  }

  // FIX: Only sync from the stream when we haven't loaded yet OR when the
  // note ID changes (different note). Never overwrite while user is editing.
  void _syncNoteValues(NoteModel note) {
    final isNewNote = _loadedNoteId != note.id;

    // Always update the stored reference so _saveNote has the latest
    // immutable fields (audioPath, audioDurationSeconds, createdAt).
    _note = note;

    if (_noteLoaded && !isNewNote) {
      // Already initialised for this note — don't overwrite the user's edits.
      return;
    }

    // First load (or a different note): populate all editable fields.
    _loadedNoteId = note.id;
    _noteLoaded = true;

    _labelController.text = note.label;
    _descriptionController.text = note.description;
    _contentController.text = note.content;
    _selectedPersonIds = note.taggedPeople.map((p) => p.id).toSet();
    _editedPriority = note.priority;
    _editedIsTodo = note.isTodo;
    _editedIsCompleted = note.isCompleted;
    _editedDueDate = note.dueDate;

    if (!_isPreparingAudio) {
      _prepareAudio(note.audioPath);
    }
  }

  // FIX: Enter edit mode explicitly populates all fields from the current note
  // so the user always starts editing from the latest saved values.
  void _enterEditMode(NoteModel note) {
    _labelController.text = note.label;
    _descriptionController.text = note.description;
    _contentController.text = note.content;
    _selectedPersonIds = note.taggedPeople.map((p) => p.id).toSet();
    _editedPriority = note.priority;
    _editedIsTodo = note.isTodo;
    _editedIsCompleted = note.isCompleted;
    _editedDueDate = note.dueDate;
    setState(() {
      _isEditing = true;
    });
  }

  Future<void> _togglePlayback() async {
    if (_audioMissing || _isPreparingAudio) return;
    if (_playerState == PlayerState.playing) {
      await _playerController.pausePlayer();
      return;
    }
    await _playerController.startPlayer();
  }

  Future<void> _seekTo(int milliseconds) async {
    if (_playerState == PlayerState.stopped) return;
    await _playerController.seekTo(milliseconds);
  }

  Future<void> _confirmDelete(NoteModel note) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete note?'),
        content: const Text(
          'This will permanently delete the note and its recording.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (shouldDelete != true) return;

    final noteRepository = ref.read(noteRepositoryProvider);
    final audioService = ref.read(audioServiceProvider);

    try {
      await noteRepository.deleteNote(note.id);
      await audioService.deleteAudio(note.audioPath);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Unable to delete note.')));
      return;
    }

    if (!mounted) return;
    context.go('/');
  }

  Future<void> _retranscribe(NoteModel note) async {
    setState(() => _isTranscribing = true);

    final transcriptionServiceFuture = ref.read(transcriptionServiceProvider);

    if (transcriptionServiceFuture is! AsyncData<TranscriptionService>) {
      if (!mounted) return;
      setState(() => _isTranscribing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Transcription service unavailable.')),
      );
      return;
    }

    final transcriptionService = transcriptionServiceFuture.value;
    final result = await transcriptionService.transcribe(note.audioPath);

    if (!mounted) return;
    setState(() => _isTranscribing = false);

    if (result.status == TranscriptionStatus.success) {
      if (result.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not transcribe audio.')),
        );
        return;
      }
      // FIX: update the controller directly — this is the editable state.
      setState(() {
        _contentController.text = result.text;
        _showTranscript = true;
        _isEditing = true;
      });
    } else if (result.status == TranscriptionStatus.noApiKey) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Set up AI transcription in Settings to re-transcribe.',
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Transcription failed: ${result.errorMessage}')),
      );
    }
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  Widget _buildFieldValue(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: '$title\n',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  TextSpan(text: value),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final noteAsync = ref.watch(noteDetailProvider(widget.noteId));
    final peopleAsync = ref.watch(noteDetailPeopleProvider);

    return noteAsync.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, stack) =>
          Scaffold(body: Center(child: Text('Could not load note: $error'))),
      data: (note) {
        if (note == null) {
          return const Scaffold(body: Center(child: Text('Note not found.')));
        }

        _syncNoteValues(note);

        final totalSeconds = note.audioDurationSeconds;
        final maxDuration = Duration(
          milliseconds: _maxMs > 0 ? _maxMs : totalSeconds * 1000,
        );
        final currentDuration = Duration(
          milliseconds: _currentMs.clamp(
            0,
            _maxMs > 0 ? _maxMs : totalSeconds * 1000,
          ),
        );

        return Scaffold(
          appBar: AppBar(
            title: Text(note.label.isNotEmpty ? note.label : 'Untitled'),
            actions: [
              IconButton(
                icon: Icon(_isEditing ? Icons.check : Icons.edit),
                tooltip: _isEditing ? 'Save note' : 'Edit note',
                // FIX: use _enterEditMode so fields are always fresh when
                // the pencil icon is tapped.
                onPressed: _isEditing
                    ? () => _saveNote(note)
                    : () => _enterEditMode(note),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline),
                tooltip: 'Delete note',
                onPressed: () => _confirmDelete(note),
              ),
            ],
          ),
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.all(20),
              physics: const BouncingScrollPhysics(),
              children: [
                _buildSectionTitle('Audio player'),
                const SizedBox(height: 12),
                Card(
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  clipBehavior: Clip.hardEdge,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (_audioMissing)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const Text('Audio file not found.'),
                              const SizedBox(height: 12),
                              FilledButton(
                                onPressed: () {
                                  context.go(
                                    '/record',
                                    extra: RecordingEditContext(
                                      noteId: note.id,
                                      recordingResult: RecordingResult(
                                        path: note.audioPath,
                                        durationSeconds:
                                            note.audioDurationSeconds,
                                      ),
                                    ),
                                  );
                                },
                                child: const Text('Record replacement'),
                              ),
                            ],
                          )
                        else ...[
                          SizedBox(
                            width: double.infinity,
                            child: AudioFileWaveforms(
                              size: Size(
                                MediaQuery.of(context).size.width - 64,
                                120,
                              ),
                              playerController: _playerController,
                              playerWaveStyle: PlayerWaveStyle(
                                showSeekLine: true,
                                fixedWaveColor: Theme.of(
                                  context,
                                ).colorScheme.primary.withAlpha(64),
                                liveWaveColor: Theme.of(
                                  context,
                                ).colorScheme.primary,
                                seekLineColor: Colors.white70,
                                spacing: 4,
                                waveThickness: 3,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              FilledButton(
                                onPressed: _togglePlayback,
                                child: Icon(
                                  _playerState == PlayerState.playing
                                      ? Icons.pause
                                      : Icons.play_arrow,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${_formatDuration(currentDuration)} / ${_formatDuration(maxDuration)}',
                                    ),
                                    Slider(
                                      value: (_currentMs.clamp(
                                        0,
                                        _maxMs > 0
                                            ? _maxMs
                                            : totalSeconds * 1000,
                                      )).toDouble(),
                                      min: 0,
                                      max:
                                          (_maxMs > 0
                                                  ? _maxMs
                                                  : totalSeconds * 1000)
                                              .toDouble()
                                              .clamp(1, double.infinity),
                                      onChanged: (value) =>
                                          _seekTo(value.toInt()),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          FilledButton.tonal(
                            onPressed: () => _confirmReRecord(note),
                            child: const Text('Re-record'),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                _buildSectionTitle('Metadata'),
                const SizedBox(height: 12),
                if (_isEditing) ...[
                  _buildLabelField(),
                  const SizedBox(height: 16),
                  _buildDescriptionField(),
                  const SizedBox(height: 16),
                  _buildPrioritySelector(),
                  const SizedBox(height: 16),
                  _buildTodoSwitch(),
                  if (_editedIsTodo) ...[
                    const SizedBox(height: 12),
                    _buildCompletedSwitch(),
                    const SizedBox(height: 12),
                    _buildDueDatePicker(context),
                  ],
                  const SizedBox(height: 24),
                  _buildPeopleSection(peopleAsync),
                  const SizedBox(height: 16),
                  _buildAddPersonField(),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: () => _saveNote(note),
                    child: const Text('Save Changes'),
                  ),
                ] else ...[
                  _buildFieldValue(
                    'Label',
                    note.label.isNotEmpty ? note.label : 'Untitled',
                  ),
                  _buildFieldValue(
                    'Description',
                    note.description.isNotEmpty ? note.description : '—',
                  ),
                  _buildFieldValue(
                    'Priority',
                    note.priority.name.toUpperCase(),
                  ),
                  _buildFieldValue('Type', note.isTodo ? 'Todo' : 'Note'),
                  if (note.isTodo)
                    _buildFieldValue(
                      'Status',
                      note.isCompleted ? 'Completed' : 'Pending',
                    ),
                  if (note.isTodo)
                    _buildFieldValue(
                      'Due date',
                      note.dueDate != null
                          ? '${note.dueDate!.month}/${note.dueDate!.day}/${note.dueDate!.year}'
                          : 'Not set',
                    ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: note.taggedPeople
                        .map((p) => Chip(label: Text(p.name)))
                        .toList(),
                  ),
                ],
                const SizedBox(height: 24),
                _buildSectionTitle('Transcript'),
                const SizedBox(height: 12),
                FilledButton.tonal(
                  onPressed: () =>
                      setState(() => _showTranscript = !_showTranscript),
                  child: Text(
                    _showTranscript ? 'Hide Transcript' : 'View Transcript',
                  ),
                ),
                if (_showTranscript) ...[
                  const SizedBox(height: 16),
                  _isEditing
                      ? TextFormField(
                          controller: _contentController,
                          minLines: 4,
                          maxLines: 6,
                          textAlignVertical: TextAlignVertical.top,
                          decoration: const InputDecoration(
                            labelText: 'Transcript',
                            alignLabelWithHint: true,
                            border: OutlineInputBorder(),
                          ),
                        )
                      : Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Theme.of(
                              context,
                            ).colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            note.content.isNotEmpty
                                ? note.content
                                : 'No transcript available.',
                          ),
                        ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      FilledButton.tonal(
                        onPressed: _isTranscribing
                            ? null
                            : () => _retranscribe(note),
                        child: _isTranscribing
                            ? const SizedBox(
                                height: 18,
                                width: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text('Re-transcribe'),
                      ),
                      const SizedBox(width: 12),
                      if (!_isEditing)
                        FilledButton.tonal(
                          onPressed: () => setState(() => _isEditing = true),
                          child: const Text('Edit transcript'),
                        ),
                    ],
                  ),
                ],
                const SizedBox(height: 24),
                _buildSectionTitle('Details'),
                const SizedBox(height: 12),
                _buildFieldValue('Created', _formatDate(note.createdAt)),
                _buildFieldValue('Last updated', _formatDate(note.updatedAt)),
                _buildFieldValue(
                  'Audio duration',
                  _formatDuration(Duration(seconds: note.audioDurationSeconds)),
                ),
                const SizedBox(height: 24),
                _buildSectionTitle('Danger zone'),
                const SizedBox(height: 12),
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.redAccent,
                    side: const BorderSide(color: Colors.redAccent),
                  ),
                  onPressed: () => _confirmDelete(note),
                  child: const Text('Delete note'),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionTitle(String text) {
    return Text(
      text,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
    );
  }

  Widget _buildLabelField() {
    return TextFormField(
      controller: _labelController,
      decoration: const InputDecoration(
        labelText: 'Label',
        hintText: 'Give it a name...',
        border: OutlineInputBorder(),
      ),
      textInputAction: TextInputAction.next,
    );
  }

  Widget _buildDescriptionField() {
    return TextFormField(
      controller: _descriptionController,
      decoration: const InputDecoration(
        labelText: 'Description',
        hintText: 'Add context...',
        alignLabelWithHint: true,
        border: OutlineInputBorder(),
      ),
      minLines: 3,
      maxLines: 4,
      textAlignVertical: TextAlignVertical.top,
      textInputAction: TextInputAction.newline,
    );
  }

  Widget _buildPrioritySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Priority', style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        SegmentedButton<NotePriority>(
          segments: const [
            ButtonSegment(value: NotePriority.low, label: Text('Low')),
            ButtonSegment(value: NotePriority.medium, label: Text('Medium')),
            ButtonSegment(value: NotePriority.high, label: Text('High')),
          ],
          showSelectedIcon: false,
          selected: {_editedPriority},
          onSelectionChanged: (newSelection) {
            if (!mounted) return;
            setState(() => _editedPriority = newSelection.first);
          },
        ),
      ],
    );
  }

  Widget _buildTodoSwitch() {
    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      title: const Text('Is Todo?'),
      value: _editedIsTodo,
      // FIX: was guarded by _isEditing but this widget only renders when
      // _isEditing is already true, so the guard was always satisfied.
      // Kept the onChanged unconditional for clarity.
      onChanged: (value) {
        setState(() {
          _editedIsTodo = value;
          if (!value) {
            _editedIsCompleted = false;
            _editedDueDate = null;
          }
        });
      },
    );
  }

  Widget _buildCompletedSwitch() {
    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      title: const Text('Is Completed?'),
      value: _editedIsCompleted,
      onChanged: (value) => setState(() => _editedIsCompleted = value),
    );
  }

  Widget _buildDueDatePicker(BuildContext context) {
    final dueDate = _editedDueDate;
    final label = dueDate == null
        ? 'Set due date'
        : 'Due ${dueDate.month}/${dueDate.day}/${dueDate.year}';
    return Row(
      children: [
        Expanded(
          child: FilledButton(
            onPressed: () => _pickDueDate(context),
            child: Text(label),
          ),
        ),
        if (dueDate != null)
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => setState(() => _editedDueDate = null),
          ),
      ],
    );
  }

  Widget _buildPeopleSection(AsyncValue<List<PersonModel>> peopleAsync) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tagged people',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        peopleAsync.when(
          data: (people) {
            if (people.isEmpty) {
              return const Text('No people saved yet. Add a name below.');
            }
            return Wrap(
              spacing: 8,
              runSpacing: 8,
              children: people.map((person) {
                final selected = _selectedPersonIds.contains(person.id);
                return FilterChip(
                  label: Text(person.name),
                  selected: selected,
                  selectedColor: Theme.of(context).colorScheme.primary,
                  labelStyle: TextStyle(
                    color: selected
                        ? Colors.white
                        : Theme.of(context).colorScheme.onSurface,
                  ),
                  selectedShadowColor: Colors.transparent,
                  showCheckmark: false,
                  onSelected: (_) {
                    setState(() {
                      if (selected) {
                        _selectedPersonIds.remove(person.id);
                      } else {
                        _selectedPersonIds.add(person.id);
                      }
                    });
                  },
                );
              }).toList(),
            );
          },
          loading: () => const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (error, _) => Text('Failed to load people: $error'),
        ),
      ],
    );
  }

  Widget _buildAddPersonField() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _newPersonController,
            textInputAction: TextInputAction.done,
            decoration: const InputDecoration(
              labelText: 'Add person',
              hintText: 'Type a name and press add',
              border: OutlineInputBorder(),
            ),
            onSubmitted: (_) => _addPerson(),
          ),
        ),
        const SizedBox(width: 12),
        FilledButton(onPressed: _addPerson, child: const Text('Add')),
      ],
    );
  }

  Future<void> _addPerson() async {
    final name = _newPersonController.text.trim();
    if (name.isEmpty) return;

    try {
      final peopleRepository = ref.read(peopleRepositoryProvider);
      final id = await peopleRepository.upsertPerson(name);
      if (!mounted) return;
      setState(() {
        _selectedPersonIds.add(id);
        _newPersonController.clear();
      });
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Unable to add person.')));
    }
  }

  Future<void> _pickDueDate(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _editedDueDate ?? now.add(const Duration(days: 1)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );
    if (picked == null || !mounted) return;
    // FIX: was updating _note via copyWith but never setting _editedDueDate,
    // so the picked date was invisible to _saveNote.
    setState(() => _editedDueDate = picked);
  }

  Future<void> _saveNote(NoteModel note) async {
    final noteRepository = ref.read(noteRepositoryProvider);
    final now = DateTime.now();

    // FIX: build the companion entirely from local edit-state variables,
    // NOT from `note` (the stream value). Using `note.copyWith(...)` would
    // silently fall back to the stream's values for any field not mentioned,
    // which meant label/description/priority were never actually persisted.
    final companion = NotesCompanion(
      id: drift.Value(note.id),
      label: drift.Value(_labelController.text.trim()),
      description: drift.Value(_descriptionController.text.trim()),
      content: drift.Value(_contentController.text.trim()),
      priority: drift.Value(_editedPriority.value),
      isTodo: drift.Value(_editedIsTodo),
      isCompleted: drift.Value(_editedIsCompleted),
      dueDate: drift.Value(_editedDueDate),
      // Always preserve the original audio fields — never allow them to change
      // through the metadata edit path.
      audioPath: drift.Value(note.audioPath),
      audioDurationSeconds: drift.Value(note.audioDurationSeconds),
      createdAt: drift.Value(note.createdAt),
      updatedAt: drift.Value(now),
    );

    try {
      await noteRepository.updateNoteWithPeople(
        companion,
        _selectedPersonIds.toList(),
      );
      if (!mounted) return;
      setState(() => _isEditing = false);
      ref.invalidate(noteDetailProvider(widget.noteId));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Note updated successfully.')),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Unable to save changes.')));
    }
  }

  Future<void> _confirmReRecord(NoteModel note) async {
    final shouldReplace = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Replace recording?'),
        content: const Text(
          'This will replace your current recording and update the note audio.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Continue'),
          ),
        ],
      ),
    );

    if (shouldReplace != true || !mounted) return;

    context.push(
      '/record',
      extra: RecordingEditContext(
        noteId: note.id,
        recordingResult: RecordingResult(
          path: note.audioPath,
          durationSeconds: note.audioDurationSeconds,
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year}';
  }
}
