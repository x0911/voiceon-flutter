import 'call_utterance.dart';

class CallRecord {
  final String id;
  final String phoneNumber;
  final String contactName;
  final String direction; // "incoming" | "outgoing"
  final DateTime startedAt;
  final DateTime endedAt;
  final int durationSeconds;
  final String audioPath;
  final int fileSizeBytes;
  final String fileExtension;
  final String transcriptionStatus; // "pending"|"processing"|"done"|"failed"|"no_provider"
  final String rawTranscript;
  final String sourceFileUri;
  final List<CallUtterance> utterances;

  const CallRecord({
    required this.id,
    required this.phoneNumber,
    required this.contactName,
    required this.direction,
    required this.startedAt,
    required this.endedAt,
    required this.durationSeconds,
    required this.audioPath,
    required this.fileSizeBytes,
    required this.fileExtension,
    required this.transcriptionStatus,
    required this.rawTranscript,
    required this.sourceFileUri,
    required this.utterances,
  });

  /// Display name: contact name if available, otherwise the raw number.
  String get displayName => contactName.isNotEmpty ? contactName : phoneNumber;

  bool get hasUtterances => utterances.isNotEmpty;

  /// Human-readable file size, e.g. "2.4 MB"
  String get formattedFileSize {
    if (fileSizeBytes < 1024) return '$fileSizeBytes B';
    if (fileSizeBytes < 1024 * 1024) return '${(fileSizeBytes / 1024).toStringAsFixed(1)} KB';
    return '${(fileSizeBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  CallRecord copyWith({
    String? id,
    String? phoneNumber,
    String? contactName,
    String? direction,
    DateTime? startedAt,
    DateTime? endedAt,
    int? durationSeconds,
    String? audioPath,
    int? fileSizeBytes,
    String? fileExtension,
    String? transcriptionStatus,
    String? rawTranscript,
    String? sourceFileUri,
    List<CallUtterance>? utterances,
  }) {
    return CallRecord(
      id: id ?? this.id,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      contactName: contactName ?? this.contactName,
      direction: direction ?? this.direction,
      startedAt: startedAt ?? this.startedAt,
      endedAt: endedAt ?? this.endedAt,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      audioPath: audioPath ?? this.audioPath,
      fileSizeBytes: fileSizeBytes ?? this.fileSizeBytes,
      fileExtension: fileExtension ?? this.fileExtension,
      transcriptionStatus: transcriptionStatus ?? this.transcriptionStatus,
      rawTranscript: rawTranscript ?? this.rawTranscript,
      sourceFileUri: sourceFileUri ?? this.sourceFileUri,
      utterances: utterances ?? this.utterances,
    );
  }
}
