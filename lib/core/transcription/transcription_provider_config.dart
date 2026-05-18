enum AiProvider {
  groq(
    id: 'groq',
    displayName: 'Groq',
    apiKeyLabel: 'Groq API Key',
    apiKeyHint: 'gsk_...',
    apiKeyUrl: 'https://console.groq.com/keys',
    hasFreeier: true,
    isRecommended: false,
    description: 'Fast & free. Uses Whisper large-v3 model.',
  ),
  openai(
    id: 'openai',
    displayName: 'OpenAI Whisper',
    apiKeyLabel: 'OpenAI API Key',
    apiKeyHint: 'sk-...',
    apiKeyUrl: 'https://platform.openai.com/api-keys',
    hasFreeier: false,
    isRecommended: false,
    description: 'Excellent quality. ~\$0.006/min.',
  ),
  assemblyai(
    id: 'assemblyai',
    displayName: 'AssemblyAI',
    apiKeyLabel: 'AssemblyAI API Key',
    apiKeyHint: 'Your AssemblyAI key',
    apiKeyUrl: 'https://www.assemblyai.com/dashboard',
    hasFreeier: true,
    isRecommended: false,
    description: '5 hours free. High accuracy.',
  ),
  deepgram(
    id: 'deepgram',
    displayName: 'Deepgram Nova-2',
    apiKeyLabel: 'Deepgram API Key',
    apiKeyHint: 'Your Deepgram key',
    apiKeyUrl: 'https://console.deepgram.com',
    hasFreeier: true,
    isRecommended: false,
    description: '\$200 free credit. Very fast.',
  ),
  revai(
    id: 'revai',
    displayName: 'Rev.ai',
    apiKeyLabel: 'Rev.ai API Token',
    apiKeyHint: 'Your Rev.ai token',
    apiKeyUrl: 'https://www.rev.ai/access_token',
    hasFreeier: true,
    isRecommended: false,
    description: '5 free hours trial.',
  ),
  whisperx(
    id: 'whisperx',
    displayName: 'Custom WhisperX',
    apiKeyLabel: 'API Key',
    apiKeyHint: 'The key you set in your WhisperX server',
    apiKeyUrl: 'https://github.com/m-bain/whisperx',
    hasFreeier: true,
    isRecommended: false,
    description: 'Your own WhisperX server with speaker diarization.',
  );

  const AiProvider({
    required this.id,
    required this.displayName,
    required this.apiKeyLabel,
    required this.apiKeyHint,
    required this.apiKeyUrl,
    required this.hasFreeier,
    required this.isRecommended,
    required this.description,
  });

  final String id;
  final String displayName;
  final String apiKeyLabel;
  final String apiKeyHint;
  final String apiKeyUrl;
  final bool hasFreeier;
  final bool isRecommended;
  final String description;

  static AiProvider? fromId(String? id) {
    if (id == null) return null;
    try {
      return AiProvider.values.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }
}
