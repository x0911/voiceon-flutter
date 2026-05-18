import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class WhisperXTranscription {
  /// Sends audio file to the local WhisperX server and returns transcription.
  ///
  /// [audioPath] — absolute path to the .m4a audio file
  /// [apiKey]    — bearer token set in the WhisperX server
  /// [endpoint]  — base URL, e.g. https://abc123.ngrok-free.app
  ///
  /// Returns the full transcript text.
  /// Throws a descriptive exception on failure.
  Future<String> transcribe(
    String audioPath,
    String apiKey,
    String endpoint,
  ) async {
    if (endpoint.isEmpty) {
      throw Exception(
        'WhisperX endpoint is not configured. '
        'Go to Settings → AI Transcription and enter your Base Endpoint.',
      );
    }

    final uri = Uri.parse('$endpoint/transcribe');
    final file = File(audioPath);

    if (!await file.exists()) {
      throw Exception('Audio file not found at: $audioPath');
    }

    final request = http.MultipartRequest('POST', uri);
    request.headers['Authorization'] = 'Bearer $apiKey';
    request.files.add(
      await http.MultipartFile.fromPath(
        'file',
        audioPath,
        filename: '${DateTime.now().millisecondsSinceEpoch}.m4a',
      ),
    );

    final streamedResponse = await request.send().timeout(
      const Duration(seconds: 120), // WhisperX can be slow on first run
    );
    final body = await streamedResponse.stream.bytesToString();

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

    final json = jsonDecode(body) as Map<String, dynamic>;
    return (json['text'] as String? ?? '').trim();
  }
}
