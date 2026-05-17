import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/call_record.dart';
import '../repositories/calls_repository.dart';
import 'call_transcription_service.dart';

class CallEventService {
  final MethodChannel _channel = const MethodChannel('voiceon/calls');
  final CallsRepository _callsRepo;
  final CallTranscriptionService _transcriptionService;

  CallEventService(this._callsRepo, this._transcriptionService);

  void initialize() {
    _channel.setMethodCallHandler(_handleNativeCall);
  }

  Future<dynamic> _handleNativeCall(MethodCall call) async {
    if (call.method == 'onCallRecorded') {
      final args = Map<String, dynamic>.from(call.arguments as Map);
      await _processNewCall(args);
    }
  }

  Future<void> _processNewCall(Map<String, dynamic> args) async {
    final phoneNumber = args['phoneNumber'] as String? ?? '';
    
    // 1. Resolve contact name
    String contactName = '';
    try {
      contactName = await _channel.invokeMethod<String>(
        'getContactName', 
        phoneNumber,
      ) ?? '';
    } catch (_) {}

    // 2. Build call record
    final callId = args['id'] as String;
    final startedAt = args['startedAt'] as int;
    final endedAt = args['endedAt'] as int;
    final call = CallRecord(
      id: callId,
      phoneNumber: phoneNumber,
      contactName: contactName,
      direction: args['direction'] as String? ?? 'incoming',
      startedAt: DateTime.fromMillisecondsSinceEpoch(startedAt),
      endedAt: DateTime.fromMillisecondsSinceEpoch(endedAt),
      durationSeconds: args['durationSeconds'] as int? ?? 0,
      audioPath: args['audioPath'] as String,
      transcriptionStatus: 'processing',
      rawTranscript: '',
      utterances: const [],
    );

    // 3. Save to DB immediately (shows in Calls list right away)
    await _callsRepo.insertCallWithUtterances(call, const []);

    // 4. Transcribe in background
    try {
      final result = await _transcriptionService.transcribeCall(call.audioPath);
      
      // Assign callId to utterances
      final utterances = result.utterances
          .map((u) => u.copyWith(callId: callId))
          .toList();

      await _callsRepo.updateTranscription(
        callId,
        result.success ? 'done' : 'failed',
        result.rawText,
        utterances,
      );
    } catch (e) {
      await _callsRepo.updateTranscription(callId, 'failed', '', const []);
    }
  }
}

final callEventServiceProvider = FutureProvider<CallEventService>((ref) async {
  final callsRepo = ref.watch(callsRepositoryProvider);
  final transcriptionService = await ref.watch(callTranscriptionServiceProvider.future);
  
  final service = CallEventService(callsRepo, transcriptionService);
  service.initialize();
  return service;
});
