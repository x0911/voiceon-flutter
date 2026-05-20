import 'dart:async';
import 'dart:io';

import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart' hide TextDirection;

import '../../core/models/call_record.dart';
import '../../core/models/call_utterance.dart';
import '../../core/repositories/calls_repository.dart';
import '../../core/services/call_vault_sync_service.dart';
import '../../core/utils/duration_utils.dart';
import 'call_vault_provider.dart';
import 'package:url_launcher/url_launcher.dart';

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
                      color: Theme.of(
                        context,
                      ).colorScheme.outlineVariant.withAlpha(128),
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
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                        if (!hasName && call.phoneNumber.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          OutlinedButton.icon(
                            icon: const Icon(Icons.person_add),
                            label: const Text('Add to Contacts'),
                            onPressed: () {
                              final uri = Uri(
                                scheme: 'tel',
                                path: call.phoneNumber,
                              );
                              launchUrl(uri);
                            },
                          ),
                        ],
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.schedule,
                              size: 16,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              DateFormat(
                                'MMMM d, yyyy · HH:mm',
                              ).format(call.startedAt),
                              style: TextStyle(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
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
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: (isIncoming ? Colors.teal : Colors.red)
                                    .withAlpha(40),
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
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Theme.of(
                                  context,
                                ).colorScheme.surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                call.formattedFileSize,
                                style: TextStyle(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Theme.of(
                                  context,
                                ).colorScheme.surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                call.fileExtension.toUpperCase(),
                                style: TextStyle(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
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
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // 3. Transcript Section
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(
                      color: Theme.of(
                        context,
                      ).colorScheme.outlineVariant.withAlpha(128),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: _buildTranscriptSection(call, call.utterances),
                  ),
                ),

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

  Widget _buildTranscriptSection(
    CallRecord call,
    List<CallUtterance> utterances,
  ) {
    if (call.transcriptionStatus == 'processing') {
      return const _TranscriptLoading();
    }

    if (call.transcriptionStatus == 'failed') {
      return _TranscriptFailed(
        onRetry: () => ref
            .read(callVaultSyncServiceProvider)
            .retranscribe(call.id, call.audioPath),
      );
    }

    if (call.transcriptionStatus == 'no_provider') {
      return const _NoProviderBanner();
    }

    if (utterances.isNotEmpty) {
      return _ChatBubbleTranscript(utterances: utterances);
    }

    if (call.rawTranscript.isNotEmpty) {
      return _PlainTextTranscript(text: call.rawTranscript);
    }

    return const _TranscriptEmpty();
  }
}

class _ChatBubbleTranscript extends StatelessWidget {
  final List<CallUtterance> utterances;
  const _ChatBubbleTranscript({required this.utterances});

  bool _hasArabic(String text) {
    return RegExp(r'[\u0600-\u06FF]').hasMatch(text);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            children: [
              Icon(
                Icons.chat_bubble_outline,
                size: 18,
                color: colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'Transcript',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Text(
                '${utterances.length} turns',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),

        // Bubbles
        ...utterances.map((utterance) {
          final isOwner = utterance.speaker == 'person_1';
          final hasArabic = _hasArabic(utterance.text);

          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Column(
              crossAxisAlignment: isOwner
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                // Speaker label
                Padding(
                  padding: EdgeInsets.only(
                    left: isOwner ? 0 : 4,
                    right: isOwner ? 4 : 0,
                    bottom: 2,
                  ),
                  child: Text(
                    isOwner ? 'You' : 'Caller',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),

                // Bubble
                Align(
                  alignment: isOwner
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.75,
                    ),
                    margin: EdgeInsets.only(
                      left: isOwner ? 56 : 0,
                      right: isOwner ? 0 : 56,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: isOwner
                          ? colorScheme.primary
                          : colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(18),
                        topRight: const Radius.circular(18),
                        bottomLeft: Radius.circular(isOwner ? 18 : 4),
                        bottomRight: Radius.circular(isOwner ? 4 : 18),
                      ),
                    ),
                    child: Text(
                      utterance.text,
                      // Let Flutter handle mixed RTL/LTR inline
                      textDirection: hasArabic
                          ? TextDirection.rtl
                          : TextDirection.ltr,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: isOwner
                            ? colorScheme.onPrimary
                            : colorScheme.onSurfaceVariant,
                        height: 1.4,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}

class _TranscriptLoading extends StatelessWidget {
  const _TranscriptLoading();
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
        const SizedBox(width: 12),
        Text(
          'Transcribing...',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _TranscriptFailed extends StatelessWidget {
  final VoidCallback onRetry;
  const _TranscriptFailed({required this.onRetry});
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          Icons.error_outline,
          color: Theme.of(context).colorScheme.error,
          size: 20,
        ),
        const SizedBox(width: 8),
        Text(
          'Transcription failed',
          style: TextStyle(color: Theme.of(context).colorScheme.error),
        ),
        const Spacer(),
        TextButton.icon(
          onPressed: onRetry,
          icon: const Icon(Icons.refresh, size: 16),
          label: const Text('Retry'),
        ),
      ],
    );
  }
}

class _NoProviderBanner extends StatelessWidget {
  const _NoProviderBanner();
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            size: 18,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Set up an AI provider in Settings to enable transcription.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}

class _PlainTextTranscript extends StatelessWidget {
  final String text;
  const _PlainTextTranscript({required this.text});
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.chat_bubble_outline,
              size: 18,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Text(
              'Transcript',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            text,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(height: 1.6),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Speaker separation unavailable for this recording.',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _TranscriptEmpty extends StatelessWidget {
  const _TranscriptEmpty();
  @override
  Widget build(BuildContext context) {
    return Text(
      'No transcript available.',
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );
  }
}
