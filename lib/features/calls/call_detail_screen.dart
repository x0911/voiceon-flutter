import 'dart:async';
import 'dart:io';

import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/models/call_record.dart';
import '../../core/models/call_utterance.dart';
import '../../core/repositories/calls_repository.dart';
import '../../core/services/call_transcription_service.dart';
import '../../core/utils/duration_utils.dart';
import 'calls_provider.dart';

class CallDetailScreen extends ConsumerStatefulWidget {
  final String callId;

  const CallDetailScreen({super.key, required this.callId});

  @override
  ConsumerState<CallDetailScreen> createState() => _CallDetailScreenState();
}

class _CallDetailScreenState extends ConsumerState<CallDetailScreen> {
  late final PlayerController _playerController;
  late final StreamSubscription<int> _durationSubscription;
  late final StreamSubscription<PlayerState> _playerStateSubscription;

  bool _isPreparingAudio = false;
  bool _audioMissing = false;
  int _currentMs = 0;
  int _maxMs = 0;
  PlayerState _playerState = PlayerState.stopped;
  bool _audioInitialized = false;

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
    super.dispose();
  }

  Future<void> _prepareAudio(String path, int initialDurationSeconds) async {
    if (_isPreparingAudio || _audioInitialized) return;
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
        _audioInitialized = true;
      });
      return;
    }

    try {
      await _playerController.preparePlayer(path: path);
      final durationMs = await _playerController.getDuration();
      if (!mounted) return;
      setState(() {
        _maxMs = durationMs > 0 ? durationMs : initialDurationSeconds * 1000;
        _audioMissing = false;
        _audioInitialized = true;
      });
    } catch (_) {
      if (mounted) {
        setState(() {
          _audioMissing = true;
          _audioInitialized = true;
        });
      }
    } finally {
      if (mounted) setState(() => _isPreparingAudio = false);
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

  Future<void> _confirmDelete(CallRecord call) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete call record?'),
        content: const Text(
          'This will permanently delete the call metadata, transcription, and the audio recording.',
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

    final repo = ref.read(callsRepositoryProvider);

    try {
      await repo.deleteCall(call.id);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to delete call record.')),
      );
      return;
    }

    if (!mounted) return;
    context.pop();
  }

  Future<void> _retryTranscription(CallRecord call) async {
    final transcriptionServiceFuture = ref.read(callTranscriptionServiceProvider);
    
    if (transcriptionServiceFuture is! AsyncData<CallTranscriptionService>) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Transcription service unavailable.')),
      );
      return;
    }
    
    final repo = ref.read(callsRepositoryProvider);
    await repo.updateTranscription(call.id, 'processing', '', const []);
    
    final service = transcriptionServiceFuture.value;
    try {
      final result = await service.transcribeCall(call.audioPath);
      final utterances = result.utterances
          .map((u) => u.copyWith(callId: call.id))
          .toList();
          
      await repo.updateTranscription(
        call.id,
        result.success ? 'done' : 'failed',
        result.rawText,
        utterances,
      );
    } catch (e) {
      await repo.updateTranscription(call.id, 'failed', '', const []);
    }
  }

  Widget _buildSectionTitle(String text) {
    return Text(
      text,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
    );
  }

  @override
  Widget build(BuildContext context) {
    final callAsync = ref.watch(callDetailProvider(widget.callId));

    return callAsync.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, stack) =>
          Scaffold(body: Center(child: Text('Could not load call: $error'))),
      data: (call) {
        if (call == null) {
          return const Scaffold(body: Center(child: Text('Call not found.')));
        }

        if (!_audioInitialized && !_isPreparingAudio) {
          _prepareAudio(call.audioPath, call.durationSeconds);
        }

        final totalSeconds = call.durationSeconds;
        final maxDuration = Duration(
          milliseconds: _maxMs > 0 ? _maxMs : totalSeconds * 1000,
        );
        final currentDuration = Duration(
          milliseconds: _currentMs.clamp(
            0,
            _maxMs > 0 ? _maxMs : totalSeconds * 1000,
          ),
        );

        final isIncoming = call.direction == 'incoming';
        final hasName = call.contactName.isNotEmpty;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Call Details'),
            actions: [
              IconButton(
                icon: const Icon(Icons.delete_outline),
                tooltip: 'Delete call',
                onPressed: () => _confirmDelete(call),
              ),
            ],
          ),
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.all(20),
              physics: const BouncingScrollPhysics(),
              children: [
                // 1. Header Card
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(
                      color: Theme.of(context).colorScheme.outlineVariant.withAlpha(128),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: (isIncoming ? Colors.teal : Colors.red)
                                .withAlpha(25),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isIncoming ? Icons.call_received : Icons.call_made,
                            color: isIncoming ? Colors.teal : Colors.red,
                            size: 32,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          hasName ? call.contactName : call.phoneNumber,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        if (hasName) ...[
                          const SizedBox(height: 4),
                          Text(
                            call.phoneNumber,
                            style: TextStyle(
                              fontSize: 16,
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.schedule,
                              size: 16,
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              DateFormat('MMMM d, yyyy · HH:mm').format(call.startedAt),
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Duration: ${formatCallDuration(call.durationSeconds)}',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: (isIncoming ? Colors.teal : Colors.red).withAlpha(40),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                isIncoming ? 'Incoming' : 'Outgoing',
                                style: TextStyle(
                                  color: isIncoming ? Colors.teal : Colors.red,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                
                // 2. Audio Player
                _buildSectionTitle('Audio Recording'),
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
                          const Text('Audio file not found.')
                        else ...[
                          SizedBox(
                            width: double.infinity,
                            child: AudioFileWaveforms(
                              size: Size(
                                MediaQuery.of(context).size.width - 64,
                                100,
                              ),
                              playerController: _playerController,
                              playerWaveStyle: PlayerWaveStyle(
                                showSeekLine: true,
                                fixedWaveColor: Theme.of(context)
                                    .colorScheme
                                    .primary
                                    .withAlpha(64),
                                liveWaveColor: Theme.of(context).colorScheme.primary,
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
                                        '${formatCallDuration(currentDuration.inSeconds)} / ${formatCallDuration(maxDuration.inSeconds)}',
                                    ),
                                    Slider(
                                      value: (_currentMs.clamp(
                                        0,
                                        _maxMs > 0
                                            ? _maxMs
                                            : totalSeconds * 1000,
                                      )).toDouble(),
                                      min: 0,
                                      max: (_maxMs > 0
                                              ? _maxMs
                                              : totalSeconds * 1000)
                                          .toDouble()
                                          .clamp(1, double.infinity),
                                      onChanged: (value) => _seekTo(value.toInt()),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                
                // 3. Transcript Section
                _buildSectionTitle('Transcript'),
                const SizedBox(height: 12),
                _buildTranscriptSection(call),
                
                const SizedBox(height: 32),
                
                // 5. Danger Zone
                _buildSectionTitle('Danger zone'),
                const SizedBox(height: 12),
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.redAccent,
                    side: const BorderSide(color: Colors.redAccent),
                  ),
                  onPressed: () => _confirmDelete(call),
                  child: const Text('Delete call record'),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildTranscriptSection(CallRecord call) {
    if (call.transcriptionStatus == 'processing') {
      return Container(
        padding: const EdgeInsets.all(24),
        alignment: Alignment.center,
        child: const Column(
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Transcribing...'),
          ],
        ),
      );
    }
    
    if (call.transcriptionStatus == 'failed') {
      return Container(
        padding: const EdgeInsets.all(24),
        alignment: Alignment.center,
        child: Column(
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.redAccent),
            const SizedBox(height: 16),
            const Text('Transcription failed.'),
            const SizedBox(height: 16),
            FilledButton.tonal(
              onPressed: () => _retryTranscription(call),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }
    
    if (call.transcriptionStatus == 'no_provider') {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.errorContainer,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(
              Icons.warning_amber_rounded, 
              color: Theme.of(context).colorScheme.onErrorContainer
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Set up AI transcription in Settings to view transcripts.',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onErrorContainer,
                ),
              ),
            ),
          ],
        ),
      );
    }
    
    if (call.hasUtterances) {
      return Column(
        children: call.utterances.map((u) => _buildConversationBubble(u)).toList(),
      );
    }
    
    if (call.rawTranscript.isNotEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(call.rawTranscript),
      );
    }
    
    return const Padding(
      padding: EdgeInsets.all(24),
      child: Text('No transcript available.'),
    );
  }
  
  Widget _buildConversationBubble(CallUtterance utterance) {
    final isOwner = utterance.speaker == 'person_1';
    return Align(
      alignment: isOwner ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(
          left: isOwner ? 48 : 0,
          right: isOwner ? 0 : 48,
          bottom: 12,
        ),
        child: Column(
          crossAxisAlignment: isOwner ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              child: Text(
                isOwner ? 'You' : 'Caller',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isOwner
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.surfaceContainerHigh,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isOwner ? 16 : 4),
                  bottomRight: Radius.circular(isOwner ? 4 : 16),
                ),
              ),
              child: Text(
                utterance.text,
                style: TextStyle(
                  color: isOwner 
                      ? Theme.of(context).colorScheme.onPrimary 
                      : Theme.of(context).colorScheme.onSurface,
                  fontSize: 15,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
