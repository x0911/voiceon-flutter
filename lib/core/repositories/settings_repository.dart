import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../transcription/transcription_provider_config.dart';

class SettingsRepository {
  final SharedPreferences _prefs;

  SettingsRepository(this._prefs);

  Future<AiProvider?> getSelectedProvider() async {
    final providerId = _prefs.getString('ai_selected_provider');
    return AiProvider.fromId(providerId);
  }

  Future<void> setSelectedProvider(AiProvider provider) async {
    await _prefs.setString('ai_selected_provider', provider.id);
  }

  Future<String> getApiKey(AiProvider provider) async {
    return _prefs.getString('ai_key_${provider.id}') ?? '';
  }

  Future<void> setApiKey(AiProvider provider, String key) async {
    if (key.isEmpty) {
      await _prefs.remove('ai_key_${provider.id}');
    } else {
      await _prefs.setString('ai_key_${provider.id}', key);
    }
  }

  Future<({AiProvider? provider, String apiKey})> getActiveConfig() async {
    final provider = await getSelectedProvider();
    if (provider == null) {
      return (provider: null, apiKey: '');
    }
    final apiKey = await getApiKey(provider);
    return (provider: provider, apiKey: apiKey);
  }

  // WhisperX custom base endpoint (e.g. https://abc123.ngrok-free.app)
  Future<String> getWhisperXEndpoint() async {
    return _prefs.getString('whisperx_endpoint') ?? '';
  }

  Future<void> setWhisperXEndpoint(String endpoint) async {
    await _prefs.setString('whisperx_endpoint', endpoint.trim().replaceAll(RegExp(r'/+$'), ''));
  }
}

final settingsRepositoryProvider = FutureProvider<SettingsRepository>((
  ref,
) async {
  final prefs = await SharedPreferences.getInstance();
  return SettingsRepository(prefs);
});
