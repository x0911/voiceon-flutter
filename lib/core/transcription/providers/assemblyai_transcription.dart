import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

Future<String> assemblyaiTranscribe(String audioPath, String apiKey) async {
  try {
    final file = File(audioPath);
    if (!file.existsSync()) {
      throw Exception('Audio file not found at $audioPath');
    }

    // Step 1: Upload audio file
    final fileBytes = await file.readAsBytes();
    final uploadResponse = await http.post(
      Uri.parse('https://api.assemblyai.com/v2/upload'),
      headers: {
        'Authorization': apiKey,
        'Content-Type': 'application/octet-stream',
      },
      body: fileBytes,
    );

    if (uploadResponse.statusCode != 200) {
      throw Exception('Upload failed: HTTP ${uploadResponse.statusCode}');
    }

    final uploadJson = jsonDecode(uploadResponse.body);
    final uploadUrl = uploadJson['upload_url'] as String;

    // Step 2: Submit transcription job
    final submitResponse = await http.post(
      Uri.parse('https://api.assemblyai.com/v2/transcript'),
      headers: {'Authorization': apiKey, 'Content-Type': 'application/json'},
      body: jsonEncode({
        'audio_url': uploadUrl,
        'language_detection': true,
        'speech_models': ['universal-3-pro', 'universal-2'],
      }),
    );

    if (submitResponse.statusCode != 200) {
      throw Exception('Submit failed: HTTP ${submitResponse.statusCode}');
    }

    final submitJson = jsonDecode(submitResponse.body);
    final jobId = submitJson['id'] as String;

    // Step 3: Poll for completion (max 30 polls, 3-second intervals)
    for (int i = 0; i < 30; i++) {
      await Future.delayed(const Duration(seconds: 3));

      final statusResponse = await http.get(
        Uri.parse('https://api.assemblyai.com/v2/transcript/$jobId'),
        headers: {'Authorization': apiKey},
      );

      if (statusResponse.statusCode != 200) {
        throw Exception(
          'Status check failed: HTTP ${statusResponse.statusCode}',
        );
      }

      final statusJson = jsonDecode(statusResponse.body);
      final status = statusJson['status'] as String;

      if (status == 'completed') {
        return statusJson['text'] as String;
      } else if (status == 'error') {
        throw Exception('Transcription error: ${statusJson['error']}');
      }
    }

    throw Exception('Transcription polling timed out after 30 attempts');
  } catch (e) {
    throw Exception('AssemblyAI transcription failed: $e');
  }
}
