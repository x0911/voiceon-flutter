import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/services/audio_service.dart';
import '../../core/services/stt_service.dart';

enum RecordingStatus { idle, recording, paused, stopped }

class RecordingState {
  final RecordingStatus status;
  final Duration elapsed;
  final String liveTranscript;
  final String? audioPath;
  final int? durationSeconds;
  final double amplitude;
  final String? errorMessage;

  const RecordingState({
    required this.status,
    required this.elapsed,
    required this.liveTranscript,
    required this.audioPath,
    required this.durationSeconds,
    required this.amplitude,
    required this.errorMessage,
  });

  factory RecordingState.initial() {
    return const RecordingState(
      status: RecordingStatus.idle,
      elapsed: Duration.zero,
      liveTranscript: '',
      audioPath: null,
      durationSeconds: null,
      amplitude: 0,
      errorMessage: null,
    );
  }

  RecordingState copyWith({
    RecordingStatus? status,
    Duration? elapsed,
    String? liveTranscript,
    String? audioPath,
    int? durationSeconds,
    double? amplitude,
    String? errorMessage,
  }) {
    return RecordingState(
      status: status ?? this.status,
      elapsed: elapsed ?? this.elapsed,
      liveTranscript: liveTranscript ?? this.liveTranscript,
      audioPath: audioPath ?? this.audioPath,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      amplitude: amplitude ?? this.amplitude,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  bool get isRecording => status == RecordingStatus.recording;
  bool get isPaused => status == RecordingStatus.paused;
  bool get isStopped => status == RecordingStatus.stopped;
}

final recordingStateProvider =
    StateNotifierProvider<RecordingNotifier, RecordingState>((ref) {
      final audioService = ref.watch(audioServiceProvider);
      final sttService = ref.watch(sttServiceProvider);
      return RecordingNotifier(audioService, sttService);
    });

class RecordingNotifier extends StateNotifier<RecordingState> {
  final AudioService _audioService;
  final SttService _sttService;
  Timer? _ticker;
  StreamSubscription<String>? _transcriptionSubscription;
  StreamSubscription<double>? _amplitudeSubscription;

  RecordingNotifier(this._audioService, this._sttService)
    : super(RecordingState.initial()) {
    _amplitudeSubscription = _audioService.amplitudeStream.listen((value) {
      state = state.copyWith(amplitude: value);
    });
  }

  Future<void> startRecording() async {
    try {
      final result = await _audioService.startRecording();
      await _sttService.startRealtimeTranscription();

      _transcriptionSubscription?.cancel();
      _transcriptionSubscription = _sttService.transcriptionStream.listen((
        text,
      ) {
        state = state.copyWith(liveTranscript: text);
      });

      _startTicker();
      state = state.copyWith(
        status: RecordingStatus.recording,
        elapsed: Duration.zero,
        liveTranscript: '',
        audioPath: result.path,
        durationSeconds: null,
        errorMessage: null,
      );
    } catch (error) {
      state = state.copyWith(errorMessage: error.toString());
    }
  }

  Future<void> pauseRecording() async {
    if (!state.isRecording) return;
    await _audioService.pauseRecording();
    await _sttService.cancelRealtimeTranscription();
    _ticker?.cancel();
    state = state.copyWith(status: RecordingStatus.paused);
  }

  Future<void> resumeRecording() async {
    if (!state.isPaused) return;
    await _audioService.resumeRecording();
    await _sttService.startRealtimeTranscription();
    _startTicker();
    state = state.copyWith(status: RecordingStatus.recording);
  }

  Future<RecordingResult> stopRecording() async {
    if (!state.isRecording && !state.isPaused) {
      throw StateError('No active recording to stop.');
    }

    _ticker?.cancel();
    final result = await _audioService.stopRecording();
    await _sttService.stopRealtimeTranscription();
    _transcriptionSubscription?.cancel();

    state = state.copyWith(
      status: RecordingStatus.stopped,
      elapsed: Duration(seconds: result.durationSeconds),
      durationSeconds: result.durationSeconds,
      audioPath: result.path,
    );

    return result;
  }

  Future<void> cancelRecording() async {
    if (state.audioPath != null) {
      await _audioService.deleteAudio(state.audioPath!);
    }

    if (_audioService.isRecording || _audioService.isPlaying) {
      await _audioService.stopRecording();
    }

    await _sttService.cancelRealtimeTranscription();
    _ticker?.cancel();
    _transcriptionSubscription?.cancel();
    state = RecordingState.initial();
  }

  void _startTicker() {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(milliseconds: 300), (_) {
      if (state.isRecording) {
        state = state.copyWith(
          elapsed: state.elapsed + const Duration(milliseconds: 300),
        );
      }
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _transcriptionSubscription?.cancel();
    _amplitudeSubscription?.cancel();
    super.dispose();
  }
}
