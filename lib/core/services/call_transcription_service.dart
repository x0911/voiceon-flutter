import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';

import '../models/call_utterance.dart';
import '../repositories/settings_repository.dart';
import '../transcription/transcription_provider_config.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Result type
// ─────────────────────────────────────────────────────────────────────────────

class CallTranscriptionResult {
  final bool success;
  final String rawText;
  final List<CallUtterance> utterances;
  final String? errorMessage;

  const CallTranscriptionResult({
    required this.success,
    required this.rawText,
    required this.utterances,
    this.errorMessage,
  });

  const CallTranscriptionResult.noProvider()
    : success = false,
      rawText = '',
      utterances = const [],
      errorMessage = 'No AI provider configured';

  const CallTranscriptionResult.failed(String message)
    : success = false,
      rawText = '',
      utterances = const [],
      errorMessage = message;
}

// ─────────────────────────────────────────────────────────────────────────────
// Service
// ─────────────────────────────────────────────────────────────────────────────

class CallTranscriptionService {
  final SettingsRepository _settings;

  CallTranscriptionService(this._settings);

  Future<CallTranscriptionResult> transcribeCall(String audioPath) async {
    final config = await _settings.getActiveConfig();
    if (config.provider == null || config.apiKey.isEmpty) {
      return const CallTranscriptionResult.noProvider();
    }

    try {
      final timeout = config.provider == AiProvider.whisperx
          ? const Duration(seconds: 180)
          : const Duration(seconds: 90);

      return await _transcribeWithProvider(
        config.provider!,
        config.apiKey,
        audioPath,
      ).timeout(timeout);
    } on TimeoutException {
      return const CallTranscriptionResult.failed('Transcription timed out');
    } catch (e) {
      return CallTranscriptionResult.failed(e.toString());
    }
  }

  Future<CallTranscriptionResult> _transcribeWithProvider(
    AiProvider provider,
    String apiKey,
    String audioPath,
  ) async {
    switch (provider) {
      case AiProvider.groq:
        return _transcribeGroq(audioPath, apiKey);
      case AiProvider.openai:
        return _transcribeOpenAI(audioPath, apiKey);
      case AiProvider.assemblyai:
        return _transcribeAssemblyAI(audioPath, apiKey);
      case AiProvider.deepgram:
        return _transcribeDeepgram(audioPath, apiKey);
      case AiProvider.revai:
        return _transcribeRevAI(audioPath, apiKey);
      case AiProvider.whisperx:
        return _transcribeWhisperX(audioPath, apiKey);
    }
  }

  // ── Groq (Whisper) ────────────────────────────────────────────────────────

  Future<CallTranscriptionResult> _transcribeGroq(
    String audioPath,
    String apiKey,
  ) async {
    final file = File(audioPath);
    if (!file.existsSync()) {
      throw Exception('Audio file not found at $audioPath');
    }

    final request = http.MultipartRequest(
      'POST',
      Uri.parse('https://api.groq.com/openai/v1/audio/transcriptions'),
    );

    request.headers['Authorization'] = 'Bearer $apiKey';
    request.fields['model'] = 'whisper-large-v3';
    request.fields['response_format'] = 'verbose_json';
    request.fields['prompt'] = _callDiarizationPrompt;

    final fileBytes = await file.readAsBytes();
    request.files.add(
      http.MultipartFile.fromBytes('file', fileBytes, filename: 'call.m4a'),
    );

    debugPrint('--- SENDING TRANSCRIPTION REQUEST (Groq) ---');
    debugPrint('URL: ${request.url}');
    debugPrint('Fields: ${request.fields}');
    debugPrint('--------------------------------------------');

    final response = await request.send();
    final body = await response.stream.bytesToString();

    debugPrint('--- AI RESPONSE (Groq) ---');
    debugPrint(body);
    debugPrint('--------------------------');

    if (response.statusCode != 200) {
      throw Exception('Groq HTTP ${response.statusCode}: $body');
    }

    final decoded = jsonDecode(body) as Map<String, dynamic>;
    final rawText = (decoded['text'] as String? ?? '').trim();

    // Post-process with LLM for diarization
    final diarizedJson = await _postProcessDiarization(
      AiProvider.groq,
      apiKey,
      rawText,
    );
    final utterances = _parseUtterancesFromJson(diarizedJson);

    return CallTranscriptionResult(
      success: true,
      rawText: rawText,
      utterances: utterances,
    );
  }

  // ── OpenAI Whisper ────────────────────────────────────────────────────────

  Future<CallTranscriptionResult> _transcribeOpenAI(
    String audioPath,
    String apiKey,
  ) async {
    final file = File(audioPath);
    if (!file.existsSync()) {
      throw Exception('Audio file not found at $audioPath');
    }

    final request = http.MultipartRequest(
      'POST',
      Uri.parse('https://api.openai.com/v1/audio/transcriptions'),
    );

    request.headers['Authorization'] = 'Bearer $apiKey';
    request.fields['model'] = 'whisper-1';
    request.fields['response_format'] = 'verbose_json';
    request.fields['prompt'] = _callDiarizationPrompt;

    final fileBytes = await file.readAsBytes();
    request.files.add(
      http.MultipartFile.fromBytes('file', fileBytes, filename: 'call.m4a'),
    );

    debugPrint('--- SENDING TRANSCRIPTION REQUEST (OpenAI) ---');
    debugPrint('URL: ${request.url}');
    debugPrint('Fields: ${request.fields}');
    debugPrint('----------------------------------------------');

    final response = await request.send();
    final body = await response.stream.bytesToString();

    debugPrint('--- AI RESPONSE (OpenAI) ---');
    debugPrint(body);
    debugPrint('----------------------------');

    if (response.statusCode != 200) {
      throw Exception('OpenAI HTTP ${response.statusCode}: $body');
    }

    final decoded = jsonDecode(body) as Map<String, dynamic>;
    final rawText = (decoded['text'] as String? ?? '').trim();

    // Post-process with LLM for diarization
    final diarizedJson = await _postProcessDiarization(
      AiProvider.openai,
      apiKey,
      rawText,
    );
    final utterances = _parseUtterancesFromJson(diarizedJson);

    return CallTranscriptionResult(
      success: true,
      rawText: rawText,
      utterances: utterances,
    );
  }

  // ── LLM Diarization (Groq/OpenAI) ─────────────────────────────────────────

  Future<String> _postProcessDiarization(
    AiProvider provider,
    String apiKey,
    String plainText,
  ) async {
    if (plainText.isEmpty) return plainText;

    String endpoint;
    String model;

    if (provider == AiProvider.groq) {
      endpoint = 'https://api.groq.com/openai/v1/chat/completions';
      model = 'llama-3.3-70b-versatile';
    } else {
      endpoint = 'https://api.openai.com/v1/chat/completions';
      model = 'gpt-4o-mini';
    }

    final prompt =
        'You are an AI tasked with diarizing a phone call transcript.\n'
        '$_callDiarizationPrompt\n\n'
        'Here is the raw text transcript to diarize:\n\n'
        '$plainText';

    debugPrint('--- SENDING LLM DIARIZATION REQUEST (${provider.name}) ---');

    final response = await http.post(
      Uri.parse(endpoint),
      headers: {
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'model': model,
        'messages': [
          {
            'role': 'system',
            'content':
                'You are a helpful assistant that outputs only raw JSON arrays.',
          },
          {'role': 'user', 'content': prompt},
        ],
        'temperature': 0.1,
      }),
    );

    if (response.statusCode != 200) {
      debugPrint(
        'LLM Diarization failed: ${response.statusCode} - ${response.body}',
      );
      return plainText; // gracefully degrade to plain text
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    final content =
        json['choices']?[0]?['message']?['content'] as String? ?? '';

    debugPrint('--- LLM DIARIZATION RESPONSE ---');
    debugPrint(content);
    debugPrint('--------------------------------');

    return content.trim();
  }

  // ── AssemblyAI (native speaker diarization) ───────────────────────────────

  Future<CallTranscriptionResult> _transcribeAssemblyAI(
    String audioPath,
    String apiKey,
  ) async {
    final file = File(audioPath);
    if (!file.existsSync()) {
      throw Exception('Audio file not found at $audioPath');
    }

    // Step 1: Upload
    final fileBytes = await file.readAsBytes();

    debugPrint('--- UPLOADING TO ASSEMBLYAI ---');
    debugPrint('URL: https://api.assemblyai.com/v2/upload');

    final uploadResponse = await http.post(
      Uri.parse('https://api.assemblyai.com/v2/upload'),
      headers: {
        'Authorization': apiKey,
        'Content-Type': 'application/octet-stream',
      },
      body: fileBytes,
    );

    if (uploadResponse.statusCode != 200) {
      throw Exception(
        'AssemblyAI upload failed: HTTP ${uploadResponse.statusCode}',
      );
    }

    final uploadUrl = (jsonDecode(uploadResponse.body))['upload_url'] as String;

    // Step 2: Submit with speaker_labels = true
    final bodyJson = jsonEncode({
      'audio_url': uploadUrl,
      'language_detection': true,
      'speaker_labels': true,
      'speech_models': ['universal-3-pro', 'universal-2'],
    });

    debugPrint('--- SUBMITTING TO ASSEMBLYAI ---');
    debugPrint('URL: https://api.assemblyai.com/v2/transcript');
    debugPrint('Body: $bodyJson');
    debugPrint('--------------------------------');

    final submitResponse = await http.post(
      Uri.parse('https://api.assemblyai.com/v2/transcript'),
      headers: {'Authorization': apiKey, 'Content-Type': 'application/json'},
      body: bodyJson,
    );

    if (submitResponse.statusCode != 200) {
      debugPrint('AssemblyAI submit failed: HTTP ${submitResponse.statusCode}');
      debugPrint('AssemblyAI submit response body: ${submitResponse.body}');
      throw Exception(
        'AssemblyAI submit failed: HTTP ${submitResponse.statusCode} - ${submitResponse.body}',
      );
    }

    final jobId = (jsonDecode(submitResponse.body))['id'] as String;

    // Step 3: Poll
    for (int i = 0; i < 60; i++) {
      await Future.delayed(const Duration(seconds: 3));

      final statusResponse = await http.get(
        Uri.parse('https://api.assemblyai.com/v2/transcript/$jobId'),
        headers: {'Authorization': apiKey},
      );

      if (statusResponse.statusCode != 200) {
        throw Exception(
          'AssemblyAI poll failed: HTTP ${statusResponse.statusCode}',
        );
      }

      final statusJson =
          jsonDecode(statusResponse.body) as Map<String, dynamic>;
      final status = statusJson['status'] as String;

      if (status == 'completed') {
        final rawText = (statusJson['text'] as String? ?? '').trim();

        // Parse native utterances array: [{speaker: "A", text: "..."}, ...]
        final List<CallUtterance> utterances = [];
        final utterancesRaw = statusJson['utterances'] as List<dynamic>?;

        if (utterancesRaw != null && utterancesRaw.isNotEmpty) {
          // Map AssemblyAI speaker labels A→person_1, B→person_2, etc.
          final speakerMap = <String, String>{};
          for (int idx = 0; idx < utterancesRaw.length; idx++) {
            final u = utterancesRaw[idx] as Map<String, dynamic>;
            final rawSpeaker = (u['speaker'] as String? ?? 'A').toUpperCase();
            if (!speakerMap.containsKey(rawSpeaker)) {
              speakerMap[rawSpeaker] = 'person_${speakerMap.length + 1}';
            }
            utterances.add(
              CallUtterance(
                id: const Uuid().v4(),
                callId: '',
                speaker: speakerMap[rawSpeaker]!,
                text: (u['text'] as String? ?? '').trim(),
                startMs: u['start'] as int?,
                sequence: idx,
              ),
            );
          }
        }

        return CallTranscriptionResult(
          success: true,
          rawText: rawText,
          utterances: utterances,
        );
      } else if (status == 'error') {
        throw Exception('AssemblyAI error: ${statusJson['error']}');
      }
      // status == 'processing' or 'queued' → keep polling
    }

    throw Exception('AssemblyAI polling timed out after 60 attempts');
  }

  // ── Deepgram (diarize=true) ───────────────────────────────────────────────

  Future<CallTranscriptionResult> _transcribeDeepgram(
    String audioPath,
    String apiKey,
  ) async {
    final file = File(audioPath);
    if (!file.existsSync()) {
      throw Exception('Audio file not found at $audioPath');
    }

    final fileBytes = await file.readAsBytes();

    final url =
        'https://api.deepgram.com/v1/listen'
        '?model=nova-2'
        '&smart_format=true'
        '&detect_language=true'
        '&diarize=true'
        '&utterances=true';

    debugPrint('--- SENDING TRANSCRIPTION REQUEST (Deepgram) ---');
    debugPrint('URL: $url');
    debugPrint('------------------------------------------------');

    final response = await http.post(
      Uri.parse(url),
      headers: {'Authorization': 'Token $apiKey', 'Content-Type': 'audio/mp4'},
      body: fileBytes,
    );

    if (response.statusCode != 200) {
      throw Exception('Deepgram HTTP ${response.statusCode}: ${response.body}');
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;

    // Plain text from the first channel alternative
    final rawText =
        (json['results']?['channels']?[0]?['alternatives']?[0]?['transcript']
                    as String? ??
                '')
            .trim();

    // Parse utterances array: [{speaker: 0, transcript: "..."}, ...]
    final List<CallUtterance> utterances = [];
    final utterancesRaw = json['results']?['utterances'] as List<dynamic>?;

    if (utterancesRaw != null && utterancesRaw.isNotEmpty) {
      final speakerMap = <int, String>{};
      for (int idx = 0; idx < utterancesRaw.length; idx++) {
        final u = utterancesRaw[idx] as Map<String, dynamic>;
        final speakerNum = (u['speaker'] as num? ?? 0).toInt();
        if (!speakerMap.containsKey(speakerNum)) {
          speakerMap[speakerNum] = 'person_${speakerMap.length + 1}';
        }
        utterances.add(
          CallUtterance(
            id: const Uuid().v4(),
            callId: '',
            speaker: speakerMap[speakerNum]!,
            text: (u['transcript'] as String? ?? '').trim(),
            startMs: ((u['start'] as num?)?.toDouble() ?? 0.0 * 1000).toInt(),
            sequence: idx,
          ),
        );
      }
    }

    return CallTranscriptionResult(
      success: true,
      rawText: rawText,
      utterances: utterances,
    );
  }

  // ── Rev.ai (speaker-labeled by default) ──────────────────────────────────

  Future<CallTranscriptionResult> _transcribeRevAI(
    String audioPath,
    String apiKey,
  ) async {
    final file = File(audioPath);
    if (!file.existsSync()) {
      throw Exception('Audio file not found at $audioPath');
    }

    // Step 1: Upload job
    final fileBytes = await file.readAsBytes();
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('https://api.rev.ai/speechtotext/v1/jobs'),
    );
    request.headers['Authorization'] = 'Bearer $apiKey';
    request.fields['metadata'] = 'voiceon_call';
    request.files.add(
      http.MultipartFile.fromBytes('media', fileBytes, filename: 'call.m4a'),
    );

    debugPrint('--- SENDING TRANSCRIPTION REQUEST (Rev.ai) ---');
    debugPrint('URL: ${request.url}');
    debugPrint('Fields: ${request.fields}');
    debugPrint('----------------------------------------------');

    final uploadResponse = await request.send();
    final uploadBody = await uploadResponse.stream.bytesToString();

    if (uploadResponse.statusCode != 201) {
      throw Exception(
        'Rev.ai job creation failed: HTTP ${uploadResponse.statusCode}',
      );
    }

    final jobId = (jsonDecode(uploadBody))['id'] as String;

    // Step 2: Poll
    for (int i = 0; i < 60; i++) {
      await Future.delayed(const Duration(seconds: 3));

      final statusResponse = await http.get(
        Uri.parse('https://api.rev.ai/speechtotext/v1/jobs/$jobId'),
        headers: {'Authorization': 'Bearer $apiKey'},
      );

      if (statusResponse.statusCode != 200) {
        throw Exception(
          'Rev.ai poll failed: HTTP ${statusResponse.statusCode}',
        );
      }

      final statusJson =
          jsonDecode(statusResponse.body) as Map<String, dynamic>;
      final status = statusJson['status'] as String;

      if (status == 'transcribed') {
        // Step 3: Fetch structured transcript
        final transcriptResponse = await http.get(
          Uri.parse(
            'https://api.rev.ai/speechtotext/v1/jobs/$jobId/transcript',
          ),
          headers: {
            'Authorization': 'Bearer $apiKey',
            'Accept': 'application/vnd.rev.transcript.v1.0+json',
          },
        );

        if (transcriptResponse.statusCode != 200) {
          throw Exception(
            'Rev.ai transcript fetch failed: HTTP ${transcriptResponse.statusCode}',
          );
        }

        final transcriptJson =
            jsonDecode(transcriptResponse.body) as Map<String, dynamic>;
        final monologues = transcriptJson['monologues'] as List<dynamic>;

        // Each monologue has a speaker int and a list of elements
        final speakerMap = <int, String>{};
        final utterances = <CallUtterance>[];
        final rawParts = <String>[];

        for (final mono in monologues) {
          final monoMap = mono as Map<String, dynamic>;
          final speakerNum = (monoMap['speaker'] as num? ?? 0).toInt();
          if (!speakerMap.containsKey(speakerNum)) {
            speakerMap[speakerNum] = 'person_${speakerMap.length + 1}';
          }

          // Collect text elements for this monologue turn
          final elements = monoMap['elements'] as List<dynamic>;
          final turnText = StringBuffer();
          int? firstStartMs;

          for (final elem in elements) {
            final elemMap = elem as Map<String, dynamic>;
            if (elemMap['type'] == 'text') {
              turnText.write(elemMap['value'] as String? ?? '');
              firstStartMs ??=
                  ((elemMap['ts'] as num?)?.toDouble() ?? 0.0 * 1000).toInt();
            } else if (elemMap['type'] == 'punct') {
              turnText.write(elemMap['value'] as String? ?? '');
            }
          }

          final text = turnText.toString().trim();
          if (text.isNotEmpty) {
            rawParts.add('${speakerMap[speakerNum]}: $text');
            utterances.add(
              CallUtterance(
                id: const Uuid().v4(),
                callId: '',
                speaker: speakerMap[speakerNum]!,
                text: text,
                startMs: firstStartMs,
                sequence: utterances.length,
              ),
            );
          }
        }

        return CallTranscriptionResult(
          success: true,
          rawText: rawParts.join('\n'),
          utterances: utterances,
        );
      } else if (status == 'failed') {
        throw Exception('Rev.ai failed: ${statusJson['failure_detail']}');
      }
    }

    throw Exception('Rev.ai polling timed out after 60 attempts');
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Shared helpers
  // ─────────────────────────────────────────────────────────────────────────

  /// Prompt injected into Whisper-based providers (Groq, OpenAI).
  /// Instructs the model to return speaker-labeled JSON instead of plain text.
  static const String _callDiarizationPrompt =
      'CRITICAL INSTRUCTIONS — follow exactly:\n'
      '1. Transcribe the audio VERBATIM. Do NOT translate anything.\n'
      '2. If someone speaks Arabic, write Arabic. If someone speaks English, write English.\n'
      '3. If a sentence mixes Arabic and English, write it exactly as spoken — mixed.\n'
      '4. Return ONLY a JSON array. No other text, no markdown, no code fences.\n'
      '5. Each element: { "by": "person_1" or "person_2", "text": "<exact words spoken>" }\n'
      '6. person_1 is the phone owner. person_2 is the other caller.\n'
      '7. Alternate speakers based on natural conversation turns.\n'
      '8. If you cannot determine speaker for a segment, alternate starting with person_1.\n'
      '9. Do NOT merge all speech into one element. Each conversation turn = one element.\n\n'
      'Example of correct output:\n'
      '[{"by":"person_1","text":"Hello, عامل ايه يا مصطفى؟"},{"by":"person_2","text":"Welcome, أنا كويس يا حمدي"}]';

  List<CallUtterance> _parseUtterancesFromJson(String rawText) {
    try {
      // Step 1: strip markdown code fences and leading/trailing whitespace
      String clean = rawText
          .replaceAll(RegExp(r'```json\s*', caseSensitive: false), '')
          .replaceAll(RegExp(r'```\s*'), '')
          .trim();

      // Step 2: extract the JSON array even if surrounded by prose
      // (some models add a sentence before the array)
      final arrayMatch = RegExp(r'\[.*\]', dotAll: true).firstMatch(clean);
      if (arrayMatch != null) {
        clean = arrayMatch.group(0)!;
      }

      final list = jsonDecode(clean) as List<dynamic>;

      return list
          .asMap()
          .entries
          .map((entry) {
            final map = entry.value as Map<String, dynamic>;
            final rawBy = (map['by'] as String? ?? 'person_1')
                .toLowerCase()
                .trim();
            // Normalize: accept "person1", "speaker_1", "a", "1" → "person_1"
            final speaker =
                (rawBy.contains('2') || rawBy == 'b' || rawBy == 'person_2')
                ? 'person_2'
                : 'person_1';
            return CallUtterance(
              id: const Uuid().v4(),
              callId: '', // filled in by caller
              speaker: speaker,
              text: (map['text'] as String? ?? '').trim(),
              startMs: (map['start_ms'] as num?)?.toInt(),
              sequence: entry.key,
            );
          })
          .where((u) => u.text.isNotEmpty) // skip empty utterances
          .toList();
    } catch (_) {
      return [];
    }
  }

  // ── WhisperX (Local) ──────────────────────────────────────────────────────

  Future<CallTranscriptionResult> _transcribeWhisperX(
    String audioPath,
    String apiKey,
  ) async {
    final endpoint = await _settings.getWhisperXEndpoint();
    if (endpoint.isEmpty) {
      throw Exception(
        'WhisperX endpoint is not configured. '
        'Go to Settings → AI Transcription and enter your Base Endpoint.',
      );
    }

    final file = File(audioPath);
    if (!file.existsSync()) {
      throw Exception('Audio file not found at $audioPath');
    }

    final uri = Uri.parse('$endpoint/transcribe').replace(
      queryParameters: {'diarize': 'true'},
    ); // enable speaker diarization for calls
    final request = http.MultipartRequest('POST', uri);
    request.headers['Authorization'] = 'Bearer $apiKey';
    request.files.add(
      await http.MultipartFile.fromPath(
        'file',
        audioPath,
        filename: '${DateTime.now().millisecondsSinceEpoch}.m4a',
      ),
    );

    debugPrint('--- SENDING TRANSCRIPTION REQUEST (WhisperX) ---');
    debugPrint('URL: $uri');
    debugPrint('------------------------------------------------');

    final streamedResponse = await request.send().timeout(
      const Duration(seconds: 120),
    );
    final body = await streamedResponse.stream.bytesToString();

    debugPrint('--- AI RESPONSE (WhisperX) ---');
    debugPrint(body);
    debugPrint('------------------------------');

    if (streamedResponse.statusCode == 401 ||
        streamedResponse.statusCode == 403) {
      throw Exception(
        'Invalid API key. Check your WhisperX API Key in Settings.',
      );
    }
    if (streamedResponse.statusCode != 200) {
      throw Exception(
        'WhisperX server error ${streamedResponse.statusCode}: $body',
      );
    }

    final decoded = jsonDecode(body) as Map<String, dynamic>;
    final rawText = (decoded['text'] as String? ?? '').trim();

    // Try to parse diarized segments if available
    final utterancesJson = decoded['utterances'] as List<dynamic>?;
    List<CallUtterance> utterances = [];

    if (utterancesJson != null && utterancesJson.isNotEmpty) {
      utterances = utterancesJson
          .asMap()
          .entries
          .map((entry) {
            final idx = entry.key;
            final u = entry.value as Map<String, dynamic>;

            return CallUtterance(
              id: const Uuid().v4(),
              callId: '',
              speaker: (u['by'] as String? ?? 'person_1').trim(),
              text: (u['text'] as String? ?? '').trim(),
              startMs: ((u['start_ms'] as num?)?.toDouble() ?? 0).round(),
              sequence: idx,
            );
          })
          .where((u) => u.text.isNotEmpty)
          .toList();
    }

    // If no diarized segments, fall back to single utterance from raw text
    if (utterances.isEmpty && rawText.isNotEmpty) {
      utterances = [
        CallUtterance(
          id: const Uuid().v4(),
          callId: '',
          speaker: 'person_1',
          text: rawText,
          startMs: 0,
          sequence: 0,
        ),
      ];
    }

    return CallTranscriptionResult(
      success: true,
      rawText: rawText,
      utterances: utterances,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Riverpod provider
// ─────────────────────────────────────────────────────────────────────────────

final callTranscriptionServiceProvider =
    FutureProvider<CallTranscriptionService>((ref) async {
      final settingsRepo = await ref.watch(settingsRepositoryProvider.future);
      return CallTranscriptionService(settingsRepo);
    });
