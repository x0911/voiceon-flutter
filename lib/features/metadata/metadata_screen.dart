import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/services/audio_service.dart';

class MetadataScreen extends StatelessWidget {
  final RecordingResult recordingResult;

  const MetadataScreen({super.key, required this.recordingResult});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Metadata')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Recording ready for metadata.',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            Text('Path: ${recordingResult.path}'),
            const SizedBox(height: 8),
            Text(
              'Duration: ${_formatDuration(Duration(seconds: recordingResult.durationSeconds))}',
            ),
            const SizedBox(height: 24),
            const Text(
              'This screen will be expanded in Phase 4 to capture label, description, priority, and tagged people.',
            ),
            const Spacer(),
            FilledButton(
              onPressed: () {
                context.go('/');
              },
              child: const Text('Continue to home'),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}
