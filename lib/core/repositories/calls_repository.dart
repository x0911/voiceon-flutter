import 'dart:io';

import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../database/app_database.dart';
import '../models/call_record.dart';
import '../models/call_utterance.dart';

class CallsRepository {
  final CallsDao _callsDao;

  CallsRepository(this._callsDao);

  // ── Streams ─────────────────────────────────────────────────────────────

  Stream<List<CallRecord>> watchAllCalls() {
    return _callsDao.watchAllCalls().asyncMap(_attachUtterances);
  }

  Stream<List<CallRecord>> watchFilteredCalls(CallFilterParams params) {
    return _callsDao.watchFilteredCalls(params).asyncMap(_attachUtterances);
  }

  // ── Inserts ─────────────────────────────────────────────────────────────

  Future<void> insertCallWithUtterances(
    CallRecord call,
    List<CallUtterance> utterances,
  ) async {
    final companion = CallsTableCompanion.insert(
      id: call.id,
      phoneNumber: call.phoneNumber,
      contactName: Value(call.contactName),
      direction: call.direction,
      startedAt: call.startedAt.millisecondsSinceEpoch,
      endedAt: call.endedAt.millisecondsSinceEpoch,
      durationSeconds: call.durationSeconds,
      audioPath: call.audioPath,
      transcriptionStatus: Value(call.transcriptionStatus),
      rawTranscript: Value(call.rawTranscript),
      createdAt: DateTime.now().millisecondsSinceEpoch,
    );
    await _callsDao.insertCall(companion);

    if (utterances.isNotEmpty) {
      await _callsDao.insertUtterances(
        utterances.map((u) => _utteranceToCompanion(u, call.id)).toList(),
      );
    }
  }

  // ── Queries ──────────────────────────────────────────────────────────────

  Future<List<CallUtterance>> getUtterancesForCall(String callId) async {
    final rows = await _callsDao.getUtterancesForCall(callId);
    return rows.map(_utteranceFromRow).toList();
  }

  Future<CallRecord?> getCallById(String id) async {
    final row = await _callsDao.getCallById(id);
    if (row == null) return null;
    final utterances = await getUtterancesForCall(id);
    return _callFromRow(row, utterances);
  }

  // ── Updates ──────────────────────────────────────────────────────────────

  Future<void> updateTranscription(
    String callId,
    String status,
    String rawTranscript,
    List<CallUtterance> utterances,
  ) async {
    await _callsDao.updateCallTranscription(callId, status, rawTranscript);
    if (utterances.isNotEmpty) {
      await _callsDao.insertUtterances(
        utterances.map((u) => _utteranceToCompanion(u, callId)).toList(),
      );
    }
  }

  // ── Deletes ──────────────────────────────────────────────────────────────

  Future<void> deleteCall(String id) async {
    // Fetch audio path before deleting so we can remove the file from disk
    final call = await _callsDao.getCallById(id);
    await _callsDao.deleteCall(id); // cascade deletes utterances

    if (call != null && call.audioPath.isNotEmpty) {
      final file = File(call.audioPath);
      if (await file.exists()) {
        await file.delete();
      }
    }
  }

  // ── Private helpers ──────────────────────────────────────────────────────

  Future<List<CallRecord>> _attachUtterances(
    List<CallsTableData> rows,
  ) async {
    return Future.wait(
      rows.map((row) async {
        final utterances = await getUtterancesForCall(row.id);
        return _callFromRow(row, utterances);
      }),
    );
  }

  CallRecord _callFromRow(
    CallsTableData row,
    List<CallUtterance> utterances,
  ) {
    return CallRecord(
      id: row.id,
      phoneNumber: row.phoneNumber,
      contactName: row.contactName,
      direction: row.direction,
      startedAt: DateTime.fromMillisecondsSinceEpoch(row.startedAt),
      endedAt: DateTime.fromMillisecondsSinceEpoch(row.endedAt),
      durationSeconds: row.durationSeconds,
      audioPath: row.audioPath,
      transcriptionStatus: row.transcriptionStatus,
      rawTranscript: row.rawTranscript,
      utterances: utterances,
    );
  }

  CallUtterance _utteranceFromRow(CallUtterancesTableData row) {
    return CallUtterance(
      id: row.id,
      callId: row.callId,
      speaker: row.speaker,
      text: row.utteranceText,
      startMs: row.startMs,
      sequence: row.sequence,
    );
  }

  CallUtterancesTableCompanion _utteranceToCompanion(
    CallUtterance u,
    String callId,
  ) {
    return CallUtterancesTableCompanion.insert(
      id: u.id.isNotEmpty ? u.id : const Uuid().v4(),
      callId: callId,
      speaker: u.speaker,
      utteranceText: u.text,
      startMs: Value(u.startMs),
      sequence: u.sequence,
    );
  }
}

final callsRepositoryProvider = Provider<CallsRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return CallsRepository(db.callsDao);
});
