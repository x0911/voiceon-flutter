import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

Future<String> revaiTranscribe(String audioPath, String apiKey) async {
  try {
    final file = File(audioPath);
    if (!file.existsSync()) {
      throw Exception('Audio file not found at $audioPath');
    }

    // Step 1: Upload audio and create job
    final fileBytes = await file.readAsBytes();
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('https://api.rev.ai/speechtotext/v1/jobs'),
    );

    request.headers['Authorization'] = 'Bearer $apiKey';
    request.fields['metadata'] = 'voiceon';
    request.files.add(
      http.MultipartFile.fromBytes('media', fileBytes, filename: 'audio.m4a'),
    );

    final response = await request.send();
    final body = await response.stream.bytesToString();

    if (response.statusCode != 201) {
      throw Exception('Job creation failed: HTTP ${response.statusCode}');
    }

    final jobJson = jsonDecode(body);
    final jobId = jobJson['id'] as String;

    // Step 2: Poll for completion (max 30 polls, 3-second intervals)
    for (int i = 0; i < 30; i++) {
      await Future.delayed(const Duration(seconds: 3));

      final statusResponse = await http.get(
        Uri.parse('https://api.rev.ai/speechtotext/v1/jobs/$jobId'),
        headers: {'Authorization': 'Bearer $apiKey'},
      );

      if (statusResponse.statusCode != 200) {
        throw Exception(
          'Status check failed: HTTP ${statusResponse.statusCode}',
        );
      }

      final statusJson = jsonDecode(statusResponse.body);
      final status = statusJson['status'] as String;

      if (status == 'transcribed') {
        // Step 3: Get transcript
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
            'Transcript fetch failed: HTTP ${transcriptResponse.statusCode}',
          );
        }

        final transcriptJson = jsonDecode(transcriptResponse.body);
        final elements = transcriptJson['monologues'] as List<dynamic>;

        final textParts = <String>[];
        for (final mono in elements) {
          final elements2 = mono['elements'] as List<dynamic>;
          for (final elem in elements2) {
            if (elem['type'] == 'text') {
              textParts.add(elem['value'] as String);
            }
          }
        }

        return textParts.join('');
      } else if (status == 'failed') {
        throw Exception(
          'Transcription failed: ${statusJson['failure_detail']}',
        );
      }
    }

    throw Exception('Transcription polling timed out after 30 attempts');
  } catch (e) {
    throw Exception('Rev.ai transcription failed: $e');
  }
}
