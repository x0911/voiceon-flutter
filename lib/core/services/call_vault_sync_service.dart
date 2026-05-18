import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
      // 3. List files from native
      final rawFiles = await _channel.invokeListMethod<Map>('listCallVaultFiles', {
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
        final uri = file['uri'] as String;
        final alreadyExists = await _repo.existsBySourceUri(uri);
        if (!alreadyExists) newFiles.add(file);
      }

      syncState.value = SyncState.running(current: 0, total: newFiles.length);

      int imported = 0, failed = 0;

      // 5. Process each new file
      for (int i = 0; i < newFiles.length; i++) {
        final file = newFiles[i];
        syncState.value = SyncState.running(
          current: i + 1,
          total: newFiles.length,
          currentFileName: file['name'] as String? ?? '',
        );

        try {
          await _importAndTranscribe(file, enabledSinceMs);
          imported++;
        } catch (e, st) {
          debugPrint('Sync error on file ${file['name']}: $e\n$st');
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
    final sourceUri = fileInfo['uri'] as String;
    final fileName = fileInfo['name'] as String? ?? '';
    final lastModifiedMs = fileInfo['lastModifiedMs'] as int? ?? 0;
    final fileSizeBytes = fileInfo['sizeBytes'] as int? ?? 0;

    // Parse phone number and direction from filename
    final phoneNumber = _extractPhoneNumber(fileName);
    final direction = _extractDirection(fileName);

    // Resolve contact name
    String contactName = '';
    if (phoneNumber.isNotEmpty) {
      try {
        contactName = await _channel.invokeMethod<String>('getContactName', phoneNumber) ?? '';
      } catch (_) {}
    }
    if (contactName.isEmpty && phoneNumber.isEmpty) contactName = 'Unknown caller';

    // Copy file to app storage via native
    final copyResult = await _channel.invokeMapMethod<String, dynamic>(
      'copyCallVaultFile',
      {'sourceUri': sourceUri},
    );
    if (copyResult == null) throw Exception('File copy failed');

    final destPath = copyResult['destPath'] as String;
    final ext = copyResult['extension'] as String? ?? 'm4a';
    final durationSeconds = copyResult['durationSeconds'] as int? ?? 0;
    final uuid = copyResult['id'] as String;

    // Approximate started_at from file modification time
    final startedAt = DateTime.fromMillisecondsSinceEpoch(lastModifiedMs)
        .subtract(Duration(seconds: durationSeconds));
    final endedAt = DateTime.fromMillisecondsSinceEpoch(lastModifiedMs);

    // Save to DB with status "processing"
    final call = CallRecord(
      id: uuid,
      phoneNumber: phoneNumber,
      contactName: contactName,
      direction: direction,
      startedAt: startedAt,
      endedAt: endedAt,
      durationSeconds: durationSeconds,
      audioPath: destPath,
      fileSizeBytes: fileSizeBytes,
      fileExtension: ext,
      sourceFileUri: sourceUri,
      transcriptionStatus: 'processing',
      rawTranscript: '',
      utterances: [],
    );
    await _repo.insertCallWithUtterances(call, []);

    // Transcribe
    try {
      final transcriptionService = await _ref.read(callTranscriptionServiceProvider.future);
      final result = await transcriptionService.transcribeCall(destPath)
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

  // --- Filename parsing helpers ---

  String _extractPhoneNumber(String filename) {
    // Match international format (+...) or local digits (7-15 digits)
    final intl = RegExp(r'\+\d{7,15}');
    final local = RegExp(r'(?<![.\d])\d{7,15}(?![.\d])');
    return intl.firstMatch(filename)?.group(0) ??
           local.firstMatch(filename)?.group(0) ??
           '';
  }

  String _extractDirection(String filename) {
    final lower = filename.toLowerCase();
    if (lower.contains('incoming') || lower.contains('_in_') || lower.contains('_in.')) {
      return 'incoming';
    }
    if (lower.contains('outgoing') || lower.contains('_out_') || lower.contains('_out.')) {
      return 'outgoing';
    }
    return 'unknown';
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
