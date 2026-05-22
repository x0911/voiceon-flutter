import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../core/repositories/settings_repository.dart';
import '../../core/transcription/transcription_provider_config.dart';
import '../metadata/metadata_screen.dart';
import 'recording_state.dart';

class RecordingScreen extends ConsumerStatefulWidget {
  final Object? extra;

  const RecordingScreen({super.key, this.extra});

  @override
  ConsumerState<RecordingScreen> createState() => _RecordingScreenState();
}

class _RecordingScreenState extends ConsumerState<RecordingScreen>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final recordingState = ref.read(recordingStateProvider);
    final notifier = ref.read(recordingStateProvider.notifier);

    if (state == AppLifecycleState.paused && recordingState.isRecording) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Recording will continue in the background.'),
          ),
        );
      }
      return;
    }

    if (state == AppLifecycleState.inactive && recordingState.isRecording) {
      notifier.pauseRecording();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Recording paused due to an interruption.'),
          ),
        );
      }
    }
  }

  Future<bool> _ensureMicrophonePermission() async {
    final status = await Permission.microphone.status;
    if (status.isGranted) {
      return true;
    }

    final requested = await Permission.microphone.request();
    if (requested.isGranted) {
      return true;
    }

    if (requested.isPermanentlyDenied) {
      await _showPermissionPermanentlyDeniedDialog();
      return false;
    }

    await _showPermissionRationaleDialog();
    return false;
  }

  Future<void> _showPermissionRationaleDialog() async {
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Microphone permission required'),
          content: const Text(
            'Voiceon needs microphone access to record audio and transcribe your note.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Dismiss'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showPermissionPermanentlyDeniedDialog() async {
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Microphone permission blocked'),
          content: const Text(
            'Microphone access is blocked. Open app settings and grant permission to continue recording.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                openAppSettings();
                Navigator.of(context).pop();
              },
              child: const Text('Open settings'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _handleMainAction(
    RecordingState state,
    RecordingNotifier notifier,
  ) async {
    if (state.isRecording) {
      await notifier.pauseRecording();
      return;
    }

    if (state.isPaused) {
      await notifier.resumeRecording();
      return;
    }

    final granted = await _ensureMicrophonePermission();
    if (!granted) {
      return;
    }

    await notifier.startRecording();
  }

  Future<void> _stopRecording(RecordingNotifier notifier) async {
    try {
      final result = await notifier.stopRecording();
      if (!mounted) return;
      if (widget.extra is RecordingEditContext) {
        final editContext = widget.extra as RecordingEditContext;
        context.push(
          '/metadata',
          extra: RecordingEditContext(
            noteId: editContext.noteId,
            recordingResult: result,
          ),
        );
        return;
      }
      context.push('/metadata', extra: result);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(recordingStateProvider);
    final notifier = ref.read(recordingStateProvider.notifier);

    final isTranscribing = state.status == RecordingStatus.transcribing;

    return Scaffold(
      appBar: AppBar(
        title: const Text('New Recording'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 14),
            child: Center(
              child: Text(
                '5:00 max',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 16),
                _buildWaveform(context, state),
                if (state.isRecording) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.surfaceContainerHighest.withAlpha(30),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(
                      'Recording will continue if the app goes to the background.',
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
                const SizedBox(height: 20),
                _buildTimer(context, state),
                const SizedBox(height: 20),
                _buildTranscriptCard(state),
                const SizedBox(height: 24),
                if (state.errorMessage != null)
                  Text(
                    state.errorMessage!,
                    style: const TextStyle(color: Colors.redAccent),
                  ),
                const Spacer(),
                _buildControls(context, state, notifier),
              ],
            ),
          ),
          if (isTranscribing)
            FutureBuilder(
              future: ref
                  .read(settingsRepositoryProvider.future)
                  .then((repo) => repo.getSelectedProvider()),
              builder: (context, snapshot) {
                final providerName =
                    snapshot.data?.displayName ?? 'AI Provider';
                return Container(
                  color: Theme.of(
                    context,
                  ).colorScheme.surface.withAlpha((0.85 * 255).round()),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.mic,
                          size: 68,
                          color: Color(0xFF009688),
                        ),
                        const SizedBox(height: 20),
                        const CircularProgressIndicator(
                          color: Color(0xFF009688),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Transcribing...',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                fontFamily: 'Open Sans',
                                fontWeight: FontWeight.w600,
                              ),
                          textAlign: TextAlign.center,
                        ),
                        if (snapshot.data == AiProvider.whisperx) ...[
                          const SizedBox(height: 4),
                          Text(
                            'This may take up to 2 minutes.',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: Colors.grey[600]),
                          ),
                        ],
                        const SizedBox(height: 8),
                        Text(
                          'Using $providerName',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildWaveform(BuildContext context, RecordingState state) {
    final normalized = (state.amplitude + 60) / 60;
    final bars = List.generate(20, (index) {
      final heightFactor = (index + 1) / 20;
      final barHeight = 20 + normalized * 100 * heightFactor;
      return AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 6,
        margin: const EdgeInsets.symmetric(horizontal: 2),
        height: barHeight.clamp(18.0, 120.0),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          borderRadius: BorderRadius.circular(4),
        ),
      );
    });

    return Container(
      height: 160,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(24),
      ),
      padding: const EdgeInsets.all(16),
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: bars,
        ),
      ),
    );
  }

  Widget _buildTimer(BuildContext context, RecordingState state) {
    final duration = state.elapsed;
    final warning = duration.inSeconds >= 270;
    final formatted = _formatDuration(duration);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          formatted,
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
            color: warning
                ? Colors.redAccent
                : Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.bold,
            fontFamily: 'DM Serif Display',
          ),
        ),
        const SizedBox(height: 8),
        Text(
          state.status == RecordingStatus.recording
              ? 'Recording…'
              : state.status == RecordingStatus.paused
              ? 'Paused'
              : 'Ready to record',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }

  Widget _buildTranscriptCard(RecordingState state) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          color: const Color.fromRGBO(0, 0, 0, 0.04),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Center(
          child: Text(
            'Transcription will appear after you stop recording.',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  Widget _buildControls(
    BuildContext context,
    RecordingState state,
    RecordingNotifier notifier,
  ) {
    final isActive = state.isRecording || state.isPaused;
    final isTranscribing = state.status == RecordingStatus.transcribing;
    final mainButtonLabel = state.isRecording
        ? 'Pause'
        : state.isPaused
        ? 'Resume'
        : 'Record';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FilledButton(
          onPressed: isTranscribing
              ? null
              : () async {
                  await _handleMainAction(state, notifier);
                },
          child: Text(mainButtonLabel),
        ),
        const SizedBox(height: 12),
        if (isActive)
          FilledButton.tonal(
            onPressed: isTranscribing
                ? null
                : () async => _stopRecording(notifier),
            child: const Text('Stop & continue'),
          ),
      ],
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}
