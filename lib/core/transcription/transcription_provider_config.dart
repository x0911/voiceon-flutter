enum AiProvider {
  groq(
    id: 'groq',
    displayName: 'Groq (Free – Recommended)',
    apiKeyLabel: 'Groq API Key',
    apiKeyHint: 'gsk_...',
    apiKeyUrl: 'https://console.groq.com/keys',
    hasFreeier: true,
    description: 'Fast & free. Uses Whisper large-v3 model.',
  ),
  openai(
    id: 'openai',
    displayName: 'OpenAI Whisper',
    apiKeyLabel: 'OpenAI API Key',
    apiKeyHint: 'sk-...',
    apiKeyUrl: 'https://platform.openai.com/api-keys',
    hasFreeier: false,
    description: 'Excellent quality. ~\$0.006/min.',
  ),
  assemblyai(
    id: 'assemblyai',
    displayName: 'AssemblyAI',
    apiKeyLabel: 'AssemblyAI API Key',
    apiKeyHint: 'Your AssemblyAI key',
    apiKeyUrl: 'https://www.assemblyai.com/dashboard',
    hasFreeier: true,
    description: '5 hours free. High accuracy.',
  ),
  deepgram(
    id: 'deepgram',
    displayName: 'Deepgram Nova-2',
    apiKeyLabel: 'Deepgram API Key',
    apiKeyHint: 'Your Deepgram key',
    apiKeyUrl: 'https://console.deepgram.com',
    hasFreeier: true,
    description: '\$200 free credit. Very fast.',
  ),
  revai(
    id: 'revai',
    displayName: 'Rev.ai',
    apiKeyLabel: 'Rev.ai API Token',
    apiKeyHint: 'Your Rev.ai token',
    apiKeyUrl: 'https://www.rev.ai/access_token',
    hasFreeier: true,
    description: '5 free hours trial.',
  );

  const AiProvider({
    required this.id,
    required this.displayName,
    required this.apiKeyLabel,
    required this.apiKeyHint,
    required this.apiKeyUrl,
    required this.hasFreeier,
    required this.description,
  });

  final String id;
  final String displayName;
  final String apiKeyLabel;
  final String apiKeyHint;
  final String apiKeyUrl;
  final bool hasFreeier;
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
