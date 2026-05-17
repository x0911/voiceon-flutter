import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

Future<String> deepgramTranscribe(String audioPath, String apiKey) async {
  try {
    final file = File(audioPath);
    if (!file.existsSync()) {
      throw Exception('Audio file not found at $audioPath');
    }

    final fileBytes = await file.readAsBytes();

    final response = await http.post(
      Uri.parse(
        'https://api.deepgram.com/v1/listen?model=nova-2&smart_format=true&detect_language=true',
      ),
      headers: {'Authorization': 'Token $apiKey', 'Content-Type': 'audio/mp4'},
      body: fileBytes,
    );

    if (response.statusCode != 200) {
      throw Exception('HTTP ${response.statusCode}: ${response.body}');
    }

    final json = jsonDecode(response.body);
    return json['results']['channels'][0]['alternatives'][0]['transcript']
        as String;
  } catch (e) {
    throw Exception('Deepgram transcription failed: $e');
  }
}
