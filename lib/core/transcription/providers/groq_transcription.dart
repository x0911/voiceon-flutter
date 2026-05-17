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
    request.fields['response_format'] = 'json';

    final fileBytes = await file.readAsBytes();
    request.files.add(
      http.MultipartFile.fromBytes('file', fileBytes, filename: 'audio.m4a'),
    );

    final response = await request.send();
    final body = await response.stream.bytesToString();

    if (response.statusCode != 200) {
      throw Exception('HTTP ${response.statusCode}: $body');
    }

    final json = jsonDecode(body);
    return json['text'] as String;
  } catch (e) {
    throw Exception('Groq transcription failed: $e');
  }
}
