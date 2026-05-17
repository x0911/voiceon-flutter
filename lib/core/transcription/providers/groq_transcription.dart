import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

Future<String> groqTranscribe(String audioPath, String apiKey) async {
  try {
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
    request.fields['prompt'] =
        'This recording contains a mix of Arabic and English. '
        'Transcribe exactly as spoken. '
        'Keep English words in English (Latin script) and Arabic words in Arabic (Arabic script). '
        'Do not translate any part of the audio. '
        'هذا التسجيل يحتوي على مزيج من العربية والإنجليزية. '
        'اكتب النص كما يُقال بالضبط دون ترجمة.';

    final fileBytes = await file.readAsBytes();
    request.files.add(
      http.MultipartFile.fromBytes('file', fileBytes, filename: 'audio.m4a'),
    );

    final response = await request.send();
    final body = await response.stream.bytesToString();

    if (response.statusCode != 200) {
      throw Exception('HTTP ${response.statusCode}: $body');
    }

    final decoded = jsonDecode(body) as Map<String, dynamic>;
    return (decoded['text'] as String? ?? '').trim();
  } catch (e) {
    throw Exception('Groq transcription failed: $e');
  }
}
