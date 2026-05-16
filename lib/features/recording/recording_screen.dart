import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../metadata/metadata_screen.dart';
import 'recording_state.dart';

class RecordingScreen extends ConsumerWidget {
  final Object? extra;

  const RecordingScreen({super.key, this.extra});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(recordingStateProvider);
    final notifier = ref.read(recordingStateProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Recording'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () async {
            await notifier.cancelRecording();
            if (!context.mounted) return;
            if (extra is RecordingEditContext) {
              context.go('/note/${(extra as RecordingEditContext).noteId}');
            } else {
              context.go('/');
            }
          },
        ),
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
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 16),
            _buildWaveform(context, state),
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
    final transcript = state.liveTranscript.isEmpty
        ? 'Live transcription will appear here while you record.'
        : state.liveTranscript;

    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color.fromRGBO(0, 0, 0, 0.04),
          borderRadius: BorderRadius.circular(20),
        ),
        child: SingleChildScrollView(
          child: Text(
            transcript,
            style: TextStyle(
              color: state.liveTranscript.isEmpty
                  ? Colors.grey[600]
                  : Colors.black,
            ),
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
    final mainButtonLabel = state.isRecording
        ? 'Pause'
        : state.isPaused
        ? 'Resume'
        : 'Record';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FilledButton(
          onPressed: () async {
            if (state.isRecording) {
              await notifier.pauseRecording();
            } else if (state.isPaused) {
              await notifier.resumeRecording();
            } else {
              await notifier.startRecording();
            }
          },
          child: Text(mainButtonLabel),
        ),
        const SizedBox(height: 12),
        if (isActive)
          FilledButton.tonal(
            onPressed: () async {
              final result = await notifier.stopRecording();
              if (!context.mounted) return;
              if (extra is RecordingEditContext) {
                final editContext = extra as RecordingEditContext;
                context.go(
                  '/metadata',
                  extra: RecordingEditContext(
                    noteId: editContext.noteId,
                    recordingResult: result,
                  ),
                );
                return;
              }
              context.go('/metadata', extra: result);
            },
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
