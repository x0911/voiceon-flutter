class CallUtterance {
  final String id;
  final String callId;
  final String speaker; // "person_1" | "person_2"
  final String text;
  final int? startMs;
  final int sequence;

  const CallUtterance({
    required this.id,
    required this.callId,
    required this.speaker,
    required this.text,
    required this.startMs,
    required this.sequence,
  });

  CallUtterance copyWith({
    String? id,
    String? callId,
    String? speaker,
    String? text,
    int? startMs,
    int? sequence,
  }) {
    return CallUtterance(
      id: id ?? this.id,
      callId: callId ?? this.callId,
      speaker: speaker ?? this.speaker,
      text: text ?? this.text,
      startMs: startMs ?? this.startMs,
      sequence: sequence ?? this.sequence,
    );
  }
}
