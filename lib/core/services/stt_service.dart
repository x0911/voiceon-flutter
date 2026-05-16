import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

final sttServiceProvider = Provider<SttService>((ref) {
  final service = SttService();
  ref.onDispose(service.dispose);
  return service;
});

class SttService {
  final SpeechToText _speech = SpeechToText();
  final StreamController<String> _transcriptionController =
      StreamController.broadcast();
  bool _initialized = false;
  String _lastRecognizedText = '';

  Stream<String> get transcriptionStream => _transcriptionController.stream;
  bool get isAvailable => _initialized;
  bool get isListening => _speech.isListening;
  String get lastRecognizedText => _lastRecognizedText;

  Future<bool> initialize() async {
    if (_initialized) {
      return true;
    }

    final permission = await Permission.microphone.status;
    if (!permission.isGranted) {
      final requestResult = await Permission.microphone.request();
      if (!requestResult.isGranted) {
        return false;
      }
    }

    _initialized = await _speech.initialize(
      onStatus: _onStatus,
      onError: _onError,
      debugLogging: false,
    );
    return _initialized;
  }

  Future<List<LocaleName>> getAvailableLocales() async {
    if (!await initialize()) {
      return [];
    }
    return await _speech.locales();
  }

  Future<String?> getDefaultLocaleId() async {
    if (!await initialize()) {
      return null;
    }
    final systemLocale = await _speech.systemLocale();
    return systemLocale?.localeId;
  }

  Future<bool> startRealtimeTranscription({String? localeId}) async {
    if (!await initialize()) {
      return false;
    }

    final locale = localeId ?? await getDefaultLocaleId();
    await _speech.listen(
      onResult: _onResult,
      localeId: locale,
      listenFor: const Duration(minutes: 5),
      pauseFor: const Duration(seconds: 5),
      listenOptions: SpeechListenOptions(
        partialResults: true,
        cancelOnError: true,
        listenMode: ListenMode.dictation,
      ),
      onSoundLevelChange: _onSoundLevelChange,
    );

    return true;
  }

  Future<void> stopRealtimeTranscription() async {
    if (_speech.isListening) {
      await _speech.stop();
    }
  }

  Future<void> cancelRealtimeTranscription() async {
    if (_speech.isListening) {
      await _speech.cancel();
    }
  }

  Future<String> transcribeFile(String path) async {
    // The current speech_to_text package does not support direct audio-file transcription.
    // This method is a placeholder for future integration with a file-based STT service.
    return '';
  }

  void _onResult(SpeechRecognitionResult result) {
    _lastRecognizedText = result.recognizedWords;
    _transcriptionController.add(_lastRecognizedText);
  }

  void _onStatus(String status) {
    if (status == 'notListening' && _speech.isListening == false) {
      _transcriptionController.add(_lastRecognizedText);
    }
  }

  void _onError(SpeechRecognitionError error) {
    _transcriptionController.add('');
  }

  void _onSoundLevelChange(double level) {
    // No-op for now; available for future waveform/tuning integration.
  }

  Future<void> dispose() async {
    await _transcriptionController.close();
    if (_speech.isListening) {
      await _speech.stop();
    }
  }
}
