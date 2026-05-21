import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../models/call_record.dart';
import '../repositories/calls_repository.dart';
import 'call_transcription_service.dart';

class SyncResult {
  final int imported;
  final int skipped;
  final int failed;
  final int total;

  const SyncResult({
    required this.imported,
    required this.skipped,
    required this.failed,
    required this.total,
  });

  factory SyncResult.zero() =>
      const SyncResult(imported: 0, skipped: 0, failed: 0, total: 0);
}

class CallVaultSyncService {
  static const _channel = MethodChannel('voiceon/calls');
  static const _syncCooldownMs = 60 * 1000; // don't re-sync within 1 minute

  final CallsRepository _repo;
  final Ref _ref;

  // Observable sync state (use ValueNotifier so UI can react)
  final ValueNotifier<SyncState> syncState = ValueNotifier(SyncState.idle());

  bool _isSyncing = false;
  int? _lastSyncAt;

  CallVaultSyncService(this._repo, this._ref);

  /// Called once from the root widget initState.
  /// Also callable manually from pull-to-refresh.
  /// [force] bypasses the cooldown check.
  Future<SyncResult> sync({bool force = false}) async {
    if (_isSyncing) return SyncResult.zero();
    if (!force && _lastSyncAt != null &&
        DateTime.now().millisecondsSinceEpoch - _lastSyncAt! < _syncCooldownMs) {
      return SyncResult.zero();
    }

    // Fix: remove previously broken imports so they get re-imported correctly
    await _repo.deleteCallsWithBrokenAudioPath();

    // 1. Check if feature is enabled
    final isEnabled = await _channel.invokeMethod<bool>('isCallVaultEnabled') ?? false;
    if (!isEnabled) return SyncResult.zero();

    // 2. Get configuration
    final folderUri = await _channel.invokeMethod<String>('getCallVaultFolderUri');
    final enabledSinceMs = await _channel.invokeMethod<int>('getCallVaultEnabledSinceMs');
    if (folderUri == null || enabledSinceMs == null) return SyncResult.zero();

    _isSyncing = true;
    syncState.value = SyncState.running(current: 0, total: 0);

    try {
      // 3. Get matched call log + recording file pairs from native
      final rawFiles = await _channel.invokeListMethod<Map>('getMatchedCallRecordings', {
        'folderUri': folderUri,
        'enabledSinceMs': enabledSinceMs,
      });
      if (rawFiles == null || rawFiles.isEmpty) {
        syncState.value = SyncState.done(result: SyncResult.zero());
        return SyncResult.zero();
      }

      // 4. Filter out files already in DB
      final newFiles = <Map>[];
      for (final file in rawFiles) {
        final uri = file['sourceFileUri'] as String? ?? '';
        if (uri.isEmpty) continue;
        final alreadyExists = await _repo.existsBySourceUri(uri);
        if (!alreadyExists) newFiles.add(file);
      }

      syncState.value = SyncState.running(current: 0, total: newFiles.length);

      int imported = 0, failed = 0;

      // 5. Process each new file
      for (int i = 0; i < newFiles.length; i++) {
        final file = newFiles[i];
        final name = file['fileName'] as String? ?? '';
        syncState.value = SyncState.running(
          current: i + 1,
          total: newFiles.length,
          currentFileName: name,
        );

        try {
          await _importAndTranscribe(file, enabledSinceMs);
          imported++;
        } catch (e, st) {
          debugPrint('Sync error on file $name: $e\n$st');
          failed++;
        }
      }

      final result = SyncResult(
        imported: imported,
        skipped: rawFiles.length - newFiles.length,
        failed: failed,
        total: rawFiles.length,
      );
      _lastSyncAt = DateTime.now().millisecondsSinceEpoch;
      syncState.value = SyncState.done(result: result);
      return result;

    } catch (e) {
      syncState.value = SyncState.idle();
      return SyncResult.zero();
    } finally {
      _isSyncing = false;
    }
  }

  Future<void> _importAndTranscribe(Map fileInfo, int enabledSinceMs) async {
    final sourceUri = fileInfo['sourceFileUri'] as String? ?? '';
    final fileName = fileInfo['fileName'] as String? ?? '';
    final fileSizeBytes = fileInfo['fileSizeBytes'] as int? ?? 0;
    final fileExtension = fileInfo['fileExtension'] as String? ?? 'm4a';
    final phoneNumber = fileInfo['phoneNumber'] as String? ?? '';
    final contactName = fileInfo['contactName'] as String? ?? '';
    final direction = fileInfo['direction'] as String? ?? 'unknown';
    final callDateMs = fileInfo['callDateMs'] as int? ?? 0;
    final callEndMs = fileInfo['callEndMs'] as int? ?? 0;
    final durationSeconds = fileInfo['durationSeconds'] as int? ?? 0;

    if (sourceUri.isEmpty) {
      debugPrint('Skipping $fileName — no source URI');
      return;
    }

    // Copy file from SAF URI to app-private storage
    // Direct file path access is blocked on Android 11+ (scoped storage)
    final copyResult = await _channel.invokeMapMethod<String, dynamic>(
      'copyCallVaultFile',
      {'sourceUri': sourceUri},
    );

    if (copyResult == null) {
      debugPrint('Skipping $fileName — copy failed (null result)');
      return;
    }

    final audioPath = copyResult['destPath'] as String? ?? '';
    final audioDuration = copyResult['durationSeconds'] as int? ?? durationSeconds;

    if (audioPath.isEmpty) {
      debugPrint('Skipping $fileName — copy returned empty path');
      return;
    }

    // Verify copied file exists
    final file = File(audioPath);
    if (!await file.exists()) {
      debugPrint('Skipping $fileName — copied file not found at: $audioPath');
      return;
    }

    final uuid = const Uuid().v4();
    final startedAt = DateTime.fromMillisecondsSinceEpoch(callDateMs);
    final endedAt = DateTime.fromMillisecondsSinceEpoch(
      callEndMs > 0 ? callEndMs : callDateMs + (durationSeconds * 1000),
    );

    // Display name fallback
    final resolvedContactName = contactName.isNotEmpty
        ? contactName
        : (phoneNumber.isEmpty ? 'Unknown caller' : '');

    // Save to DB with status "processing"
    final call = CallRecord(
      id: uuid,
      phoneNumber: phoneNumber,
      contactName: resolvedContactName,
      direction: direction,
      startedAt: startedAt,
      endedAt: endedAt,
      durationSeconds: audioDuration,
      audioPath: audioPath,       // app-private copy
      fileSizeBytes: fileSizeBytes,
      fileExtension: fileExtension,
      sourceFileUri: sourceUri,   // SAF URI for dedup
      transcriptionStatus: 'processing',
      rawTranscript: '',
      utterances: [],
    );
    await _repo.insertCallWithUtterances(call, []);

    // Transcribe
    try {
      final transcriptionService = await _ref.read(callTranscriptionServiceProvider.future);
      final result = await transcriptionService.transcribeCall(audioPath)
          .timeout(const Duration(seconds: 90));
      final utterances = result.utterances.map((u) => u.copyWith(callId: uuid)).toList();
      await _repo.updateTranscription(
        uuid,
        result.success ? 'done' : 'failed',
        result.rawText,
        utterances,
      );
    } catch (_) {
      await _repo.updateTranscription(uuid, 'failed', '', []);
    }
  }

  Future<void> retranscribe(String callId, String audioPath) async {
    await _repo.updateTranscriptionStatus(callId, 'processing');
    try {
      final transcriptionService = await _ref.read(callTranscriptionServiceProvider.future);
      final result = await transcriptionService.transcribeCall(audioPath)
          .timeout(const Duration(seconds: 90));
      final utterances = result.utterances.map((u) => u.copyWith(callId: callId)).toList();
      await _repo.updateTranscription(
        callId,
        result.success ? 'done' : 'failed',
        result.rawText,
        utterances,
      );
    } catch (_) {
      await _repo.updateTranscription(callId, 'failed', '', []);
    }
  }
}

// Sync state for UI
class SyncState {
  final bool isRunning;
  final int current;
  final int total;
  final String currentFileName;
  final SyncResult? result;

  const SyncState._({
    required this.isRunning,
    this.current = 0,
    this.total = 0,
    this.currentFileName = '',
    this.result,
  });

  factory SyncState.idle() => const SyncState._(isRunning: false);
  factory SyncState.running({required int current, required int total, String currentFileName = ''}) =>
      SyncState._(isRunning: true, current: current, total: total, currentFileName: currentFileName);
  factory SyncState.done({required SyncResult result}) =>
      SyncState._(isRunning: false, result: result);
}

final callVaultSyncServiceProvider = Provider<CallVaultSyncService>((ref) {
  final repo = ref.watch(callsRepositoryProvider);
  return CallVaultSyncService(repo, ref);
});
