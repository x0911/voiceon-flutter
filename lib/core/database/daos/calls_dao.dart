part of '../app_database.dart';

// Note: the utterance column 'text' was renamed to 'utteranceText' in the
// table definition to avoid shadowing drift's built-in text() builder method.

class CallFilterParams {
  final String? searchText;
  final String? calleeName;
  final String? calleeNumber;
  final DateTime? startDate;
  final DateTime? endDate;

  const CallFilterParams({
    this.searchText,
    this.calleeName,
    this.calleeNumber,
    this.startDate,
    this.endDate,
  });
}

@DriftAccessor(tables: [CallsTable, CallUtterancesTable])
class CallsDao extends DatabaseAccessor<AppDatabase> with _$CallsDaoMixin {
  CallsDao(super.db);

  // ── Insert ──────────────────────────────────────────────────────────────

  Future<void> insertCall(CallsTableCompanion call) =>
      into(callsTable).insertOnConflictUpdate(call);

  Future<void> insertUtterances(
    List<CallUtterancesTableCompanion> utterances,
  ) async {
    await batch((b) => b.insertAllOnConflictUpdate(callUtterancesTable, utterances));
  }

  Future<bool> existsBySourceUri(String sourceFileUri) async {
    if (sourceFileUri.isEmpty) return false;
    final count = await (select(callsTable)
      ..where((t) => t.sourceFileUri.equals(sourceFileUri)))
      .get();
    return count.isNotEmpty;
  }

  // ── Watch ───────────────────────────────────────────────────────────────

  Stream<List<CallsTableData>> watchAllCalls() {
    return (select(callsTable)
          ..orderBy([(t) => OrderingTerm.desc(t.startedAt)]))
        .watch();
  }

  Stream<List<CallsTableData>> watchFilteredCalls(CallFilterParams params) {
    final whereClauses = <String>[];
    final variables = <Variable>[];

    if (params.searchText?.trim().isNotEmpty ?? false) {
      final pattern = '%${params.searchText!.trim()}%';
      whereClauses.add(
        '(raw_transcript LIKE ? OR contact_name LIKE ? OR phone_number LIKE ?)',
      );
      variables.addAll([
        Variable.withString(pattern),
        Variable.withString(pattern),
        Variable.withString(pattern),
      ]);
    }

    if (params.calleeName?.trim().isNotEmpty ?? false) {
      whereClauses.add('contact_name LIKE ?');
      variables.add(Variable.withString('%${params.calleeName!.trim()}%'));
    }

    if (params.calleeNumber?.trim().isNotEmpty ?? false) {
      whereClauses.add('phone_number LIKE ?');
      variables.add(Variable.withString('%${params.calleeNumber!.trim()}%'));
    }

    if (params.startDate != null) {
      whereClauses.add('started_at >= ?');
      variables.add(
        Variable.withInt(params.startDate!.millisecondsSinceEpoch),
      );
    }

    if (params.endDate != null) {
      whereClauses.add('started_at <= ?');
      variables.add(
        Variable.withInt(params.endDate!.millisecondsSinceEpoch),
      );
    }

    final whereClause = whereClauses.isEmpty
        ? ''
        : 'WHERE ${whereClauses.join(' AND ')}';

    final sql = '''
SELECT calls_table.*
FROM calls_table
$whereClause
ORDER BY started_at DESC
''';

    return customSelect(
      sql,
      variables: variables,
      readsFrom: {callsTable},
    ).watch().map(
          (rows) => rows.map((row) => callsTable.map(row.data)).toList(),
        );
  }

  // ── Utterances ──────────────────────────────────────────────────────────

  Future<List<CallUtterancesTableData>> getUtterancesForCall(
    String callId,
  ) {
    return (select(callUtterancesTable)
          ..where((t) => t.callId.equals(callId))
          ..orderBy([(t) => OrderingTerm.asc(t.sequence)]))
        .get();
  }

  // ── Update ──────────────────────────────────────────────────────────────

  Future<void> updateCallTranscription(
    String id,
    String status,
    String rawTranscript,
  ) async {
    await (update(callsTable)..where((t) => t.id.equals(id))).write(
      CallsTableCompanion(
        transcriptionStatus: Value(status),
        rawTranscript: Value(rawTranscript),
      ),
    );
  }

  Future<void> updateTranscriptionStatus(String id, String status) async {
    await (update(callsTable)..where((t) => t.id.equals(id))).write(
      CallsTableCompanion(transcriptionStatus: Value(status)),
    );
  }

  // ── Delete ──────────────────────────────────────────────────────────────

  Future<void> deleteCall(String id) async {
    await (delete(callsTable)..where((t) => t.id.equals(id))).go();
  }

  // ── Single fetch ────────────────────────────────────────────────────────

  Future<CallsTableData?> getCallById(String id) {
    return (select(callsTable)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
  }
}
