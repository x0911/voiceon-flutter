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
  final String transcriptionStatus; // "pending"|"processing"|"done"|"failed"|"no_provider"
  final String rawTranscript;
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
    required this.transcriptionStatus,
    required this.rawTranscript,
    required this.utterances,
  });

  /// Display name: contact name if available, otherwise the raw number.
  String get displayName => contactName.isNotEmpty ? contactName : phoneNumber;

  bool get hasUtterances => utterances.isNotEmpty;

  CallRecord copyWith({
    String? id,
    String? phoneNumber,
    String? contactName,
    String? direction,
    DateTime? startedAt,
    DateTime? endedAt,
    int? durationSeconds,
    String? audioPath,
    String? transcriptionStatus,
    String? rawTranscript,
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
      transcriptionStatus: transcriptionStatus ?? this.transcriptionStatus,
      rawTranscript: rawTranscript ?? this.rawTranscript,
      utterances: utterances ?? this.utterances,
    );
  }
}
