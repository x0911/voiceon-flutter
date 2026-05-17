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

final peopleStreamProvider = StreamProvider.autoDispose<List<PersonModel>>((
  ref,
) {
  final peopleRepository = ref.watch(peopleRepositoryProvider);
  return peopleRepository.watchAllPeople();
});

class RecordingEditContext {
  final String noteId;
  final RecordingResult recordingResult;

  RecordingEditContext({required this.noteId, required this.recordingResult});
}

class MetadataScreen extends ConsumerStatefulWidget {
  final RecordingResult recordingResult;
  final String? editingNoteId;

  const MetadataScreen({
    super.key,
    required this.recordingResult,
    this.editingNoteId,
  });

  @override
  ConsumerState<MetadataScreen> createState() => _MetadataScreenState();
}

class _MetadataScreenState extends ConsumerState<MetadataScreen> {
  final _formKey = GlobalKey<FormState>();
  final _labelController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _contentController = TextEditingController();
  final _newPersonController = TextEditingController();

  bool _showContentEditor = false;
  bool _isTodo = false;
  bool _isCompleted = false;
  DateTime? _dueDate;
  NotePriority _priority = NotePriority.low;
  final Set<String> _selectedPersonIds = {};
  bool _isSaving = false;
  bool _isLoadingExistingNote = false;
  String? _errorMessage;
  NoteModel? _existingNote;
  String? _originalAudioPath;

  @override
  void initState() {
    super.initState();
    if (widget.editingNoteId != null) {
      _loadExistingNote();
    } else if (widget.recordingResult.transcript.isNotEmpty) {
      _contentController.text = widget.recordingResult.transcript;
      _showContentEditor = true;
      debugPrint(
        'MetadataScreen.initState: content initialized with transcript="${widget.recordingResult.transcript}"',
      );
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Transcription unavailable — you can type it manually.',
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
      });
      debugPrint('MetadataScreen.initState: no transcript available');
    }

    // Handle transcription errors
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      // Future note: RecordingResult will include transcriptionError and showApiKeyBanner fields
      // which can be handled here to show appropriate error messages and banners
    });
  }

  Future<void> _loadExistingNote() async {
    setState(() {
      _isLoadingExistingNote = true;
    });

    final notesRepository = ref.read(noteRepositoryProvider);
    final existingNote = await notesRepository.getNoteById(
      widget.editingNoteId!,
    );

    if (existingNote != null) {
      _existingNote = existingNote;
      _originalAudioPath = existingNote.audioPath;
      _labelController.text = existingNote.label;
      _descriptionController.text = existingNote.description;
      _contentController.text = existingNote.content;
      _isTodo = existingNote.isTodo;
      _isCompleted = existingNote.isCompleted;
      _dueDate = existingNote.dueDate;
      _priority = existingNote.priority;
      _selectedPersonIds.addAll(
        existingNote.taggedPeople.map((person) => person.id),
      );
    }

    if (mounted) {
      setState(() {
        _isLoadingExistingNote = false;
      });
    }
  }

  @override
  void dispose() {
    _labelController.dispose();
    _descriptionController.dispose();
    _contentController.dispose();
    _newPersonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final peopleAsync = ref.watch(peopleStreamProvider);
    final notesRepository = ref.watch(noteRepositoryProvider);
    final audioService = ref.watch(audioServiceProvider);

    if (widget.editingNoteId != null && _isLoadingExistingNote) {
      return Scaffold(
        appBar: AppBar(title: const Text('Metadata')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (widget.editingNoteId != null && _existingNote == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Metadata')),
        body: const Center(child: Text('Original note not found.')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Metadata')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: ListView(
                    physics: const BouncingScrollPhysics(),
                    children: [
                      _buildSectionTitle('Recording details'),
                      const SizedBox(height: 12),
                      _buildSummaryTile(),
                      const SizedBox(height: 24),
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
                      const SizedBox(height: 24),
                      _buildContentToggle(),
                      if (_showContentEditor) const SizedBox(height: 12),
                      if (_showContentEditor) _buildContentEditor(),
                      if (_errorMessage != null) ...[
                        const SizedBox(height: 16),
                        Text(
                          _errorMessage!,
                          style: const TextStyle(color: Colors.redAccent),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                _buildActions(context, notesRepository, audioService),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String text) {
    return Text(
      text,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
    );
  }

  Widget _buildSummaryTile() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Duration: ${_formatDuration(Duration(seconds: widget.recordingResult.durationSeconds))}',
            ),
            const SizedBox(height: 8),
            Text('File: ${widget.recordingResult.path.split('/').last}'),
          ],
        ),
      ),
    );
  }

  Widget _buildLabelField() {
    return TextFormField(
      controller: _labelController,
      maxLength: 100,
      decoration: const InputDecoration(
        labelText: 'Label',
        hintText: 'Give it a name...',
        border: OutlineInputBorder(),
      ),
      textInputAction: TextInputAction.next,
      validator: (value) {
        final trimmed = value?.trim() ?? '';
        if (trimmed.length > 100) {
          return 'Label must be 100 characters or less.';
        }
        return null;
      },
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
          selected: {_priority},
          onSelectionChanged: (newSelection) {
            setState(() {
              _priority = newSelection.first;
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
      value: _isTodo,
      onChanged: (value) {
        setState(() {
          _isTodo = value;
          if (!value) {
            _isCompleted = false;
            _dueDate = null;
          }
        });
      },
    );
  }

  Widget _buildCompletedSwitch() {
    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      title: const Text('Is Completed?'),
      value: _isCompleted,
      onChanged: (value) {
        setState(() {
          _isCompleted = value;
        });
      },
    );
  }

  Widget _buildDueDatePicker(BuildContext context) {
    final label = _dueDate == null
        ? 'Set due date'
        : 'Due ${_dueDate!.month}/${_dueDate!.day}/${_dueDate!.year}';
    return Row(
      children: [
        Expanded(
          child: FilledButton(
            onPressed: () => _pickDueDate(context),
            child: Text(label),
          ),
        ),
        if (_dueDate != null)
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              setState(() {
                _dueDate = null;
              });
            },
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
                return ChoiceChip(
                  label: Text(person.name),
                  selected: selected,
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

  Widget _buildContentToggle() {
    return FilledButton.tonal(
      onPressed: () {
        setState(() {
          _showContentEditor = !_showContentEditor;
        });
      },
      child: Text(
        _showContentEditor ? 'Hide transcript' : 'View/Edit transcript',
      ),
    );
  }

  Widget _buildContentEditor() {
    return TextFormField(
      controller: _contentController,
      decoration: const InputDecoration(
        labelText: 'Content',
        hintText: 'Edit transcript here...',
        alignLabelWithHint: true,
        border: OutlineInputBorder(),
      ),
      minLines: 4,
      maxLines: 6,
      textAlignVertical: TextAlignVertical.top,
      textInputAction: TextInputAction.newline,
    );
  }

  Widget _buildActions(
    BuildContext context,
    NoteRepository notesRepository,
    AudioService audioService,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FilledButton(
          onPressed: _isSaving
              ? null
              : () => _saveNote(context, notesRepository, audioService),
          child: _isSaving
              ? const SizedBox(
                  height: 20,
                  child: Center(child: CircularProgressIndicator()),
                )
              : Text(
                  widget.editingNoteId != null ? 'Save Changes' : 'Save Note',
                ),
        ),
        const SizedBox(height: 12),
        TextButton(
          onPressed: _isSaving
              ? null
              : () async {
                  await audioService.deleteAudio(widget.recordingResult.path);
                  if (!context.mounted) return;
                  if (widget.editingNoteId != null) {
                    context.go('/note/${widget.editingNoteId}');
                  } else {
                    context.go('/');
                  }
                },
          child: const Text('Discard'),
        ),
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
      setState(() {
        _selectedPersonIds.add(id);
        _newPersonController.clear();
        _errorMessage = null;
      });
    } catch (error) {
      setState(() {
        _errorMessage = 'Unable to add person.';
      });
    }
  }

  Future<void> _pickDueDate(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? now.add(const Duration(days: 1)),
      firstDate: now.add(const Duration(days: 1)),
      lastDate: now.add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _dueDate = picked;
        _errorMessage = null;
      });
    }
  }

  Future<void> _saveNote(
    BuildContext context,
    NoteRepository notesRepository,
    AudioService audioService,
  ) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_isTodo && _dueDate == null) {
      setState(() {
        _errorMessage = 'Please choose a due date for this todo item.';
      });
      return;
    }

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    final now = DateTime.now();
    final content = _contentController.text.trim();
    final note = NotesCompanion(
      id: widget.editingNoteId != null
          ? drift.Value(widget.editingNoteId!)
          : const drift.Value.absent(),
      label: drift.Value(_labelController.text.trim()),
      description: drift.Value(_descriptionController.text.trim()),
      content: drift.Value(content),
      priority: drift.Value(_priority.value),
      isTodo: drift.Value(_isTodo),
      isCompleted: drift.Value(_isTodo ? _isCompleted : false),
      dueDate: drift.Value(_dueDate),
      audioPath: drift.Value(widget.recordingResult.path),
      audioDurationSeconds: drift.Value(widget.recordingResult.durationSeconds),
      createdAt: drift.Value(_existingNote?.createdAt ?? now),
      updatedAt: drift.Value(now),
    );

    try {
      if (widget.editingNoteId != null) {
        await notesRepository.updateNoteWithPeople(
          note,
          _selectedPersonIds.toList(),
        );
        if (_originalAudioPath != null &&
            _originalAudioPath != widget.recordingResult.path) {
          await audioService.deleteAudio(_originalAudioPath!);
        }
      } else {
        await notesRepository.saveNoteWithPeople(
          note,
          _selectedPersonIds.toList(),
        );
      }

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.editingNoteId != null
                ? 'Note updated successfully.'
                : 'Note saved successfully.',
          ),
        ),
      );
      if (widget.editingNoteId != null) {
        context.go('/note/${widget.editingNoteId}');
      } else {
        context.go('/');
      }
    } catch (_) {
      setState(() {
        _errorMessage = 'Unable to save note. Please try again.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}
