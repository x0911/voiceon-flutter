import 'dart:async';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:uuid/uuid.dart';

final audioServiceProvider = Provider<AudioService>((ref) {
  final service = AudioService();
  ref.onDispose(service.dispose);
  return service;
});

class RecordingResult {
  final String path;
  final int durationSeconds;
  final String transcript;

  RecordingResult({
    required this.path,
    required this.durationSeconds,
    this.transcript = '',
  });
}

class AudioService {
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  final FlutterSoundPlayer _player = FlutterSoundPlayer();
  final StreamController<double> _amplitudeController =
      StreamController.broadcast();
  final StreamController<Duration> _playbackPositionController =
      StreamController.broadcast();

  Timer? _maxRecordingTimer;
  Duration _currentRecordingDuration = Duration.zero;
  bool _recorderInitialized = false;
  bool _playerInitialized = false;

  Stream<double> get amplitudeStream => _amplitudeController.stream;
  Stream<Duration> get playbackPositionStream =>
      _playbackPositionController.stream;
  bool get isRecording => _recorder.isRecording;
  bool get isPlaying => _player.isPlaying;

  Future<void> _initRecorder() async {
    if (_recorderInitialized) return;
    await _recorder.openRecorder();
    _recorder.setSubscriptionDuration(const Duration(milliseconds: 200));
    _recorderInitialized = true;
  }

  Future<void> _initPlayer() async {
    if (_playerInitialized) return;
    await _player.openPlayer();
    _player.setSubscriptionDuration(const Duration(milliseconds: 200));
    _playerInitialized = true;
  }

  Future<PermissionStatus> requestMicrophonePermission() async {
    final status = await Permission.microphone.request();
    return status;
  }

  Future<bool> ensureMicrophonePermission() async {
    final status = await Permission.microphone.status;
    if (status.isGranted) {
      return true;
    }

    final requested = await requestMicrophonePermission();
    return requested.isGranted;
  }

  Future<bool> isMicrophonePermissionPermanentlyDenied() async {
    return await Permission.microphone.isPermanentlyDenied;
  }

  Future<bool> shouldShowMicrophonePermissionRationale() async {
    return await Permission.microphone.shouldShowRequestRationale;
  }

  Future<String> _createRecordingPath() async {
    final directory = await getApplicationDocumentsDirectory();
    final recordingsFolder = Directory(p.join(directory.path, 'recordings'));
    if (!await recordingsFolder.exists()) {
      await recordingsFolder.create(recursive: true);
    }

    return p.join(recordingsFolder.path, '${const Uuid().v4()}.m4a');
  }

  Future<RecordingResult> startRecording() async {
    final granted = await ensureMicrophonePermission();
    if (!granted) {
      throw StateError('Microphone permission is required to start recording.');
    }

    await _initRecorder();
    final path = await _createRecordingPath();
    _currentRecordingDuration = Duration.zero;

    await _recorder.startRecorder(
      toFile: path,
      codec: Codec.aacMP4,
      bitRate: 128000,
      sampleRate: 16000,
      numChannels: 1,
      audioSource: AudioSource.microphone,
    );

    _maxRecordingTimer?.cancel();
    _maxRecordingTimer = Timer(const Duration(minutes: 5), () async {
      if (_recorder.isRecording) {
        await stopRecording();
      }
    });

    _recorder.onProgress?.listen((event) {
      _currentRecordingDuration = event.duration;
      if (event.decibels != null) {
        _amplitudeController.add(event.decibels!.clamp(-60.0, 0.0));
      }
    });

    return RecordingResult(path: path, durationSeconds: 0);
  }

  Future<void> pauseRecording() async {
    if (!_recorder.isRecording) return;
    await _recorder.pauseRecorder();
  }

  Future<void> resumeRecording() async {
    if (!_recorder.isPaused) return;
    await _recorder.resumeRecorder();
  }

  Future<RecordingResult> stopRecording() async {
    if (!_recorder.isRecording && !_recorder.isPaused) {
      throw StateError('Recorder is not active.');
    }

    _maxRecordingTimer?.cancel();
    final path = await _recorder.stopRecorder();
    _amplitudeController.add(0);

    return RecordingResult(
      path: path ?? '',
      durationSeconds: _currentRecordingDuration.inSeconds,
    );
  }

  Future<void> playAudio(String path) async {
    final file = File(path);
    if (!await file.exists()) {
      throw StateError('Audio file not found at path: $path');
    }

    await _initPlayer();
    final playbackComplete = Completer<void>();

    await _player.startPlayer(
      fromURI: path,
      codec: Codec.aacMP4,
      whenFinished: () {
        _playbackPositionController.add(Duration.zero);
        if (!playbackComplete.isCompleted) {
          playbackComplete.complete();
        }
      },
    );

    _player.onProgress?.listen((event) {
      _playbackPositionController.add(event.position);
    });

    await playbackComplete.future;
  }

  Future<void> pauseAudio() async {
    if (!_player.isPlaying) return;
    await _player.pausePlayer();
  }

  Future<void> stopAudio() async {
    if (!_player.isPlaying && !_player.isPaused) return;
    await _player.stopPlayer();
    _playbackPositionController.add(Duration.zero);
  }

  Future<void> deleteAudio(String path) async {
    final file = File(path);
    if (await file.exists()) {
      await file.delete();
    }
  }

  Future<void> dispose() async {
    _maxRecordingTimer?.cancel();
    await _amplitudeController.close();
    await _playbackPositionController.close();
    if (_recorderInitialized) {
      await _recorder.closeRecorder();
    }
    if (_playerInitialized) {
      await _player.closePlayer();
    }
  }
}
