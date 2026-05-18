import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../repositories/settings_repository.dart';
import '../transcription/transcription_provider_config.dart';
import '../transcription/transcription_result.dart';
import '../transcription/providers/groq_transcription.dart';
import '../transcription/providers/openai_transcription.dart';
import '../transcription/providers/assemblyai_transcription.dart';
import '../transcription/providers/deepgram_transcription.dart';
import '../transcription/providers/revai_transcription.dart';
import '../transcription/providers/whisperx_transcription.dart';

class TranscriptionService {
  final SettingsRepository _settings;

  TranscriptionService(this._settings);

  Future<TranscriptionResult> transcribe(String audioPath) async {
    final config = await _settings.getActiveConfig();
    if (config.provider == null || config.apiKey.isEmpty) {
      return const TranscriptionResult.noApiKey();
    }

    try {
      final timeout = config.provider == AiProvider.whisperx
          ? const Duration(seconds: 180)  // 3 minutes for local WhisperX
          : const Duration(seconds: 60);  // 1 minute for cloud APIs

      final text = await _transcribeWithProvider(
        config.provider!,
        config.apiKey,
        audioPath,
      ).timeout(timeout);
      return TranscriptionResult.success(text);
    } on TimeoutException {
      return const TranscriptionResult.timeout();
    } catch (e) {
      return TranscriptionResult.error(e.toString());
    }
  }

  Future<String> _transcribeWithProvider(
    AiProvider provider,
    String apiKey,
    String audioPath,
  ) async {
    switch (provider) {
      case AiProvider.groq:
        return await groqTranscribe(audioPath, apiKey);
      case AiProvider.openai:
        return await openaiTranscribe(audioPath, apiKey);
      case AiProvider.assemblyai:
        return await assemblyaiTranscribe(audioPath, apiKey);
      case AiProvider.deepgram:
        return await deepgramTranscribe(audioPath, apiKey);
      case AiProvider.revai:
        return await revaiTranscribe(audioPath, apiKey);
      case AiProvider.whisperx:
        final endpoint = await _settings.getWhisperXEndpoint();
        return await WhisperXTranscription().transcribe(
          audioPath,
          apiKey,
          endpoint,
        );
    }
  }

  Future<bool> testConnection(AiProvider provider, String apiKey) async {
    try {
      final result = await _testProviderConnection(
        provider,
        apiKey,
      ).timeout(const Duration(seconds: 15));
      return result;
    } catch (_) {
      return false;
    }
  }

  Future<bool> _testProviderConnection(
    AiProvider provider,
    String apiKey,
  ) async {
    switch (provider) {
      case AiProvider.groq:
        return _testGroqConnection(apiKey);
      case AiProvider.openai:
        return _testOpenaiConnection(apiKey);
      case AiProvider.assemblyai:
        return _testAssemblyaiConnection(apiKey);
      case AiProvider.deepgram:
        return _testDeepgramConnection(apiKey);
      case AiProvider.revai:
        return _testRevaibConnection(apiKey);
      case AiProvider.whisperx:
        return _testWhisperXConnection(apiKey);
    }
  }

  Future<bool> _testGroqConnection(String apiKey) async {
    // Groq doesn't have a simple health check, so we return true if key is non-empty
    return apiKey.isNotEmpty;
  }

  Future<bool> _testOpenaiConnection(String apiKey) async {
    // OpenAI doesn't have a simple health check, so we return true if key is non-empty
    return apiKey.isNotEmpty;
  }

  Future<bool> _testAssemblyaiConnection(String apiKey) async {
    try {
      final response = await http.get(
        Uri.parse('https://api.assemblyai.com/v2/transcript'),
        headers: {'Authorization': apiKey},
      );
      // 200 = valid, 401/403 = invalid key
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  Future<bool> _testDeepgramConnection(String apiKey) async {
    try {
      final response = await http.get(
        Uri.parse('https://api.deepgram.com/v1/projects'),
        headers: {'Authorization': 'Token $apiKey'},
      );
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  Future<bool> _testRevaibConnection(String apiKey) async {
    try {
      final response = await http.get(
        Uri.parse('https://api.rev.ai/speechtotext/v1/jobs'),
        headers: {'Authorization': 'Bearer $apiKey'},
      );
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  Future<bool> _testWhisperXConnection(String apiKey) async {
    final endpoint = await _settings.getWhisperXEndpoint();
    if (endpoint.isEmpty) return false;
    try {
      final response = await http.get(
        Uri.parse('$endpoint/health'),
        headers: {'Authorization': 'Bearer $apiKey'},
      ).timeout(const Duration(seconds: 10));
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}

// Riverpod provider
final transcriptionServiceProvider = FutureProvider<TranscriptionService>((
  ref,
) async {
  final settingsRepo = await ref.watch(settingsRepositoryProvider.future);
  return TranscriptionService(settingsRepo);
});
