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
import '../../core/services/stt_service.dart';
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

  NoteModel? _note;
  Set<String> _selectedPersonIds = {};

  @override
  void initState() {
    super.initState();
    _playerController = PlayerController();
    _durationSubscription = _playerController.onCurrentDurationChanged.listen((
      milliseconds,
    ) {
      if (!mounted) return;
      setState(() {
        _currentMs = milliseconds;
      });
    });
    _playerStateSubscription = _playerController.onPlayerStateChanged.listen((
      state,
    ) {
      if (!mounted) return;
      setState(() {
        _playerState = state;
      });
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
      if (mounted) {
        setState(() {
          _audioMissing = true;
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isPreparingAudio = false;
        });
      }
    }
  }

  void _syncNoteValues(NoteModel note) {
    if (_note?.id == note.id && !_isEditing) return;
    _note = note;
    _labelController.text = note.label;
    _descriptionController.text = note.description;
    _contentController.text = note.content;
    _selectedPersonIds = note.taggedPeople.map((person) => person.id).toSet();
    if (!_isPreparingAudio) {
      _prepareAudio(note.audioPath);
    }
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
      builder: (context) {
        return AlertDialog(
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
        );
      },
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
    setState(() {
      _isTranscribing = true;
    });

    final sttService = ref.read(sttServiceProvider);
    final result = await sttService.transcribeFile(note.audioPath);

    if (!mounted) return;
    setState(() {
      _isTranscribing = false;
    });

    if (result.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not transcribe audio.')),
      );
      return;
    }

    setState(() {
      _contentController.text = result;
      _showTranscript = true;
      _isEditing = true;
    });
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
                onPressed: _isEditing
                    ? () => _saveNote(note)
                    : () {
                        setState(() {
                          _isEditing = true;
                          _showTranscript = true;
                        });
                      },
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
                                fixedWaveColor: Colors.teal.withAlpha(64),
                                liveWaveColor: Colors.teal,
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
                  if (_isTodo) const SizedBox(height: 12),
                  if (_isTodo) _buildCompletedSwitch(),
                  if (_isTodo) const SizedBox(height: 12),
                  if (_isTodo) _buildDueDatePicker(context),
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
                    note.description.isNotEmpty
                        ? note.description
                        : note.content,
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
                        .map((person) => Chip(label: Text(person.name)))
                        .toList(),
                  ),
                ],
                const SizedBox(height: 24),
                _buildSectionTitle('Transcript'),
                const SizedBox(height: 12),
                FilledButton.tonal(
                  onPressed: () {
                    setState(() {
                      _showTranscript = !_showTranscript;
                    });
                  },
                  child: Text(
                    _showTranscript ? 'Hide Transcript' : 'View Transcript',
                  ),
                ),
                if (_showTranscript) ...[
                  const SizedBox(height: 16),
                  _isEditing
                      ? TextFormField(
                          controller: _contentController,
                          maxLines: 6,
                          decoration: const InputDecoration(
                            labelText: 'Transcript',
                            border: OutlineInputBorder(),
                          ),
                        )
                      : Container(
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
                        OutlinedButton(
                          onPressed: () {
                            setState(() {
                              _isEditing = true;
                            });
                          },
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
        border: OutlineInputBorder(),
      ),
      maxLines: 4,
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
          selected: {_note?.priority ?? NotePriority.low},
          onSelectionChanged: (newSelection) {
            if (!mounted) return;
            setState(() {
              _note = _note?.copyWith(priority: newSelection.first) ?? _note;
            });
          },
        ),
      ],
    );
  }

  Widget _buildTodoSwitch() {
    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      title: const Text('Is Todo?'),
      value: _note?.isTodo ?? false,
      onChanged: _isEditing
          ? (value) {
              setState(() {
                _note = _note?.copyWith(isTodo: value);
                if (!value) {
                  _note = _note?.copyWith(isCompleted: false, dueDate: null);
                }
              });
            }
          : null,
    );
  }

  Widget _buildCompletedSwitch() {
    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      title: const Text('Is Completed?'),
      value: _note?.isCompleted ?? false,
      onChanged: _isEditing
          ? (value) {
              setState(() {
                _note = _note?.copyWith(isCompleted: value);
              });
            }
          : null,
    );
  }

  Widget _buildDueDatePicker(BuildContext context) {
    final dueDate = _note?.dueDate;
    final label = dueDate == null
        ? 'Set due date'
        : 'Due ${dueDate.month}/${dueDate.day}/${dueDate.year}';
    return Row(
      children: [
        Expanded(
          child: FilledButton(
            onPressed: _isEditing ? () => _pickDueDate(context) : null,
            child: Text(label),
          ),
        ),
        if (dueDate != null)
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: _isEditing
                ? () {
                    setState(() {
                      _note = _note?.copyWith(dueDate: null);
                    });
                  }
                : null,
          ),
      ],
    );
  }

  bool get _isTodo => _note?.isTodo ?? false;

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
                return ChoiceChip(
                  label: Text(person.name),
                  selected: selected,
                  onSelected: _isEditing
                      ? (_) {
                          setState(() {
                            if (selected) {
                              _selectedPersonIds.remove(person.id);
                            } else {
                              _selectedPersonIds.add(person.id);
                            }
                          });
                        }
                      : null,
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
    if (name.isEmpty) {
      return;
    }

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
      initialDate: _note?.dueDate ?? now.add(const Duration(days: 1)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );
    if (picked == null || !mounted) {
      return;
    }

    setState(() {
      _note = _note?.copyWith(dueDate: picked);
    });
  }

  Future<void> _saveNote(NoteModel note) async {
    final noteRepository = ref.read(noteRepositoryProvider);
    final now = DateTime.now();
    final updatedNote = note.copyWith(
      label: _labelController.text.trim(),
      description: _descriptionController.text.trim(),
      content: _contentController.text.trim(),
      priority: _note?.priority ?? note.priority,
      isTodo: _note?.isTodo ?? note.isTodo,
      isCompleted: _note?.isCompleted ?? note.isCompleted,
      dueDate: _note?.dueDate,
      updatedAt: now,
      taggedPeople: note.taggedPeople,
    );

    final companion = NotesCompanion(
      id: drift.Value(updatedNote.id),
      label: drift.Value(updatedNote.label),
      description: drift.Value(updatedNote.description),
      content: drift.Value(updatedNote.content),
      priority: drift.Value(updatedNote.priority.value),
      isTodo: drift.Value(updatedNote.isTodo),
      isCompleted: drift.Value(updatedNote.isCompleted),
      dueDate: drift.Value(updatedNote.dueDate),
      audioPath: drift.Value(updatedNote.audioPath),
      audioDurationSeconds: drift.Value(updatedNote.audioDurationSeconds),
      createdAt: drift.Value(updatedNote.createdAt),
      updatedAt: drift.Value(updatedNote.updatedAt),
    );

    try {
      await noteRepository.updateNoteWithPeople(
        companion,
        _selectedPersonIds.toList(),
      );
      if (!mounted) return;
      setState(() {
        _isEditing = false;
      });
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
      builder: (context) {
        return AlertDialog(
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
        );
      },
    );

    if (shouldReplace != true || !mounted) return;

    context.go(
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
