import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/repositories/settings_repository.dart';
import '../../core/services/transcription_service.dart';
import '../../core/theme/theme_provider.dart';
import '../../core/transcription/transcription_provider_config.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  late TextEditingController _apiKeyController;
  AiProvider? _selectedProvider;
  bool _showApiKey = false;
  bool _isTesting = false;
  String? _testResult;
  bool _testSuccess = false;

  @override
  void initState() {
    super.initState();
    _apiKeyController = TextEditingController();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final settingsRepo = await ref.read(settingsRepositoryProvider.future);
    final provider = await settingsRepo.getSelectedProvider();
    final apiKey = provider != null
        ? await settingsRepo.getApiKey(provider)
        : '';

    if (mounted) {
      setState(() {
        _selectedProvider = provider;
        _apiKeyController.text = apiKey;
      });
    }
  }

  Future<void> _saveProvider(AiProvider provider) async {
    final settingsRepo = await ref.read(settingsRepositoryProvider.future);
    await settingsRepo.setSelectedProvider(provider);

    // Load the API key for the new provider
    final apiKey = await settingsRepo.getApiKey(provider);
    if (mounted) {
      setState(() {
        _selectedProvider = provider;
        _apiKeyController.text = apiKey;
        _testResult = null;
        _testSuccess = false;
      });
    }
  }

  Future<void> _saveApiKey(String key) async {
    if (_selectedProvider == null) return;

    final settingsRepo = await ref.read(settingsRepositoryProvider.future);
    await settingsRepo.setApiKey(_selectedProvider!, key);

    if (mounted) {
      setState(() {
        _testResult = null;
        _testSuccess = false;
      });
    }
  }

  Future<void> _testConnection() async {
    if (_selectedProvider == null || _apiKeyController.text.isEmpty) {
      setState(() {
        _testResult = 'Please select a provider and enter an API key';
        _testSuccess = false;
      });
      return;
    }

    setState(() {
      _isTesting = true;
      _testResult = null;
    });

    final transcriptionServiceFuture = ref.read(transcriptionServiceProvider);

    if (transcriptionServiceFuture is! AsyncData<TranscriptionService>) {
      setState(() {
        _isTesting = false;
        _testResult = 'Transcription service unavailable';
        _testSuccess = false;
      });
      return;
    }

    final service = transcriptionServiceFuture.value;
    final isValid = await service.testConnection(
      _selectedProvider!,
      _apiKeyController.text,
    );

    if (mounted) {
      setState(() {
        _isTesting = false;
        _testSuccess = isValid;
        _testResult = isValid ? 'Connected' : 'Invalid API key';
      });
    }
  }

  Future<void> _launchApiKeyUrl() async {
    if (_selectedProvider == null) return;

    final url = Uri.parse(_selectedProvider!.apiKeyUrl);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  void _clearApiKey() {
    _apiKeyController.clear();
    _saveApiKey('');
    setState(() {
      _testResult = null;
      _testSuccess = false;
    });
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    super.dispose();
  }

  Widget buildCard({
    required IconData icon,
    required String label,
    required bool selected,
    required VoidCallback onTap,
    required Color? previewColor,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedScale(
        scale: 1.0,
        duration: const Duration(milliseconds: 180),
        child: Stack(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: selected
                      ? Theme.of(context).colorScheme.primary
                      : Colors.grey.shade300,
                  width: selected ? 2 : 1,
                ),
                boxShadow: selected
                    ? [
                        BoxShadow(
                          color: Theme.of(
                            context,
                          ).colorScheme.primary.withAlpha((0.08 * 255).round()),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : null,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: 28, color: previewColor),
                  const SizedBox(height: 12),
                  Text(label, style: Theme.of(context).textTheme.bodyMedium),
                ],
              ),
            ),
            if (selected)
              const Positioned(
                right: 4,
                top: 4,
                child: CircleAvatar(
                  radius: 10,
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.check_circle,
                    size: 18,
                    color: Colors.green,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);
    final themeNotifier = ref.read(themeModeProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Appearance Section
              const Text('Appearance', style: TextStyle(letterSpacing: 1.2)),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: buildCard(
                      icon: Icons.wb_sunny,
                      label: 'Light',
                      selected: themeMode == ThemeMode.light,
                      previewColor: Colors.amber,
                      onTap: () => themeNotifier.setThemeMode(ThemeMode.light),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: buildCard(
                      icon: Icons.nights_stay,
                      label: 'Dark',
                      selected: themeMode == ThemeMode.dark,
                      previewColor: Colors.blueGrey,
                      onTap: () => themeNotifier.setThemeMode(ThemeMode.dark),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // AI Transcription Section
              const Text(
                'AI Transcription',
                style: TextStyle(letterSpacing: 1.2),
              ),
              const SizedBox(height: 12),

              // Provider Dropdown
              DropdownButtonFormField<AiProvider>(
                initialValue: _selectedProvider,
                decoration: InputDecoration(
                  labelText: 'Provider',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                items: AiProvider.values.map((provider) {
                  return DropdownMenuItem(
                    value: provider,
                    child: Row(
                      children: [
                        Expanded(child: Text(provider.displayName)),
                        if (provider.hasFreeier)
                          const SizedBox(
                            height: 20,
                            child: Chip(
                              label: Text(
                                'FREE',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.white,
                                ),
                              ),
                              backgroundColor: Colors.green,
                              padding: EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 0,
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (provider) {
                  if (provider != null) {
                    _saveProvider(provider);
                  }
                },
              ),
              const SizedBox(height: 8),

              // Provider Description
              if (_selectedProvider != null)
                Text(
                  _selectedProvider!.description,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              const SizedBox(height: 16),

              // API Key Field
              if (_selectedProvider != null)
                TextFormField(
                  controller: _apiKeyController,
                  obscureText: !_showApiKey,
                  decoration: InputDecoration(
                    labelText: _selectedProvider!.apiKeyLabel,
                    hintText: _selectedProvider!.apiKeyHint,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    suffixIcon: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(
                            _showApiKey
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          onPressed: () {
                            setState(() {
                              _showApiKey = !_showApiKey;
                            });
                          },
                        ),
                        if (_apiKeyController.text.isNotEmpty)
                          IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: _clearApiKey,
                          ),
                      ],
                    ),
                  ),
                  onChanged: (value) {
                    _saveApiKey(value);
                  },
                ),
              const SizedBox(height: 12),

              // Get API Key and Test buttons
              if (_selectedProvider != null)
                Row(
                  children: [
                    TextButton(
                      onPressed: _launchApiKeyUrl,
                      child: const Text('Get API Key ↗'),
                    ),
                    const Spacer(),
                    ElevatedButton(
                      onPressed: _isTesting ? null : _testConnection,
                      child: _isTesting
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Test'),
                    ),
                  ],
                ),
              const SizedBox(height: 8),

              // Test Result
              if (_testResult != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: _testSuccess
                        ? Colors.green.shade50
                        : Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: _testSuccess
                          ? Colors.green.shade300
                          : Colors.red.shade300,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _testSuccess ? Icons.check_circle : Icons.error_outline,
                        color: _testSuccess ? Colors.green : Colors.red,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _testSuccess ? '✓ $_testResult' : '✗ $_testResult',
                        style: TextStyle(
                          color: _testSuccess ? Colors.green : Colors.red,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
