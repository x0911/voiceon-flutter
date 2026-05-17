enum TranscriptionStatus { success, noApiKey, error, timeout }

class TranscriptionResult {
  final TranscriptionStatus status;
  final String text;
  final String? errorMessage;

  const TranscriptionResult.success(this.text)
    : status = TranscriptionStatus.success,
      errorMessage = null;

  const TranscriptionResult.noApiKey()
    : status = TranscriptionStatus.noApiKey,
      text = '',
      errorMessage = null;

  const TranscriptionResult.error(this.errorMessage)
    : status = TranscriptionStatus.error,
      text = '';

  const TranscriptionResult.timeout()
    : status = TranscriptionStatus.timeout,
      text = '',
      errorMessage = 'Transcription timed out';
}
