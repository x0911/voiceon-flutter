import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/database/app_database.dart';
import '../../core/repositories/settings_repository.dart';
import '../../core/services/transcription_service.dart';
import '../../core/theme/theme_provider.dart';
import '../../core/providers/call_vault_enabled_provider.dart';
import '../../core/transcription/transcription_provider_config.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  // ── Call recording state ─────────────────────────────────────────────────
  static const _callsChannel = MethodChannel('voiceon/calls');
  bool _callVaultEnabled = false;
  String? _callVaultFolderUri;
  String? _detectedFolderPath;

  // ── AI Transcription state ───────────────────────────────────────────────
  late TextEditingController _apiKeyController;
  late TextEditingController _endpointController;
  AiProvider? _selectedProvider;
  bool _showApiKey = false;
  bool _showBaseEndpoint = false;
  bool _isTesting = false;
  String? _testResult;
  bool _testSuccess = false;

  @override
  void initState() {
    super.initState();
    _apiKeyController = TextEditingController();
    _endpointController = TextEditingController();
    _loadSettings();
    _loadCallVaultEnabled();
  }

  // ── Call recording helpers ───────────────────────────────────────────────

  Future<void> _loadCallVaultEnabled() async {
    try {
      final enabled =
          await _callsChannel.invokeMethod<bool>('isCallVaultEnabled') ?? false;
      final folderUri = await _callsChannel.invokeMethod<String?>(
        'getCallVaultFolderUri',
      );
      String? detectedPath;
      if (enabled && folderUri == null) {
        try {
          detectedPath = await _callsChannel.invokeMethod<String?>(
            'autoDetectRecordingsFolder',
          );
        } catch (_) {
          detectedPath = null;
        }
      }
      if (mounted) {
        setState(() {
          _callVaultEnabled = enabled;
          _callVaultFolderUri = folderUri;
          _detectedFolderPath = detectedPath;
        });
      }
    } catch (_) {}
  }

  Future<void> _onCallVaultToggled(bool newValue) async {
    if (newValue) {
      // Show legal consent dialog before enabling
      final accepted = await _showConsentDialog();
      if (!accepted) return;

      // Request required permissions
      final permissionsGranted = await _requestCallPermissions();
      if (!permissionsGranted) return;
    }

    try {
      await _callsChannel.invokeMethod('setCallVaultEnabled', newValue);
      ref.invalidate(callVaultEnabledProvider);
      if (mounted) setState(() => _callVaultEnabled = newValue);
    } catch (_) {}
  }

  Future<void> _pickFolder() async {
    try {
      final uri = await _callsChannel.invokeMethod<String>(
        'pickCallVaultFolder',
      );
      if (uri != null && mounted) {
        setState(() => _callVaultFolderUri = uri);
      }
    } catch (_) {}
  }

  Future<bool> _showConsentDialog() async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: const Text('⚠️ Legal Notice'),
        content: const SingleChildScrollView(
          child: Text(
            'Call Vault imports recordings saved by your phone\'s built-in call recorder.\n\n'
            'Before enabling:\n'
            '• Enable call recording in your Phone app\n'
            '• Select the folder where your Phone app saves recordings\n\n'
            'By enabling, you confirm:\n'
            '• You have the legal right to record calls in your country\n'
            '• You accept full responsibility for compliance with local laws',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('I Understand, Enable'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  Future<bool> _requestCallPermissions() async {
    // Request other permissions (Contacts, Notifications, Phone) via permission_handler
    await [
      Permission.contacts,
      Permission.notification,
      Permission.phone,
    ].request();

    // Check/request READ_CALL_LOG natively since permission_handler doesn't define callLog
    bool callLogGranted = false;
    try {
      callLogGranted = await _callsChannel.invokeMethod<bool>('requestCallLogPermission') ?? false;
    } catch (_) {}

    if (!callLogGranted) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Call log permission is required to match recordings with calls. '
              'Grant it in App Settings.',
            ),
            duration: Duration(seconds: 4),
          ),
        );
      }
      // Still return true — user can use Call Vault without call log access,
      // but matching will be limited
    }

    return true; // always allow enabling; gracefully degrade if permissions missing
  }

  // ── AI Transcription helpers ─────────────────────────────────────────────

  Future<void> _loadSettings() async {
    final settingsRepo = await ref.read(settingsRepositoryProvider.future);
    final provider = await settingsRepo.getSelectedProvider();
    final apiKey = provider != null
        ? await settingsRepo.getApiKey(provider)
        : '';
    final endpoint = await settingsRepo.getWhisperXEndpoint();
    if (mounted) {
      setState(() {
        _selectedProvider = provider;
        _apiKeyController.text = apiKey;
        _endpointController.text = provider == AiProvider.whisperx
            ? endpoint
            : '';
      });
    }
  }

  Future<void> _saveProvider(AiProvider provider) async {
    final settingsRepo = await ref.read(settingsRepositoryProvider.future);
    await settingsRepo.setSelectedProvider(provider);
    final apiKey = await settingsRepo.getApiKey(provider);
    final savedEndpoint = provider == AiProvider.whisperx
        ? await settingsRepo.getWhisperXEndpoint()
        : '';
    if (mounted) {
      setState(() {
        _selectedProvider = provider;
        _apiKeyController.text = apiKey;
        _endpointController.text = savedEndpoint;
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

  Future<void> _saveEndpoint(String endpoint) async {
    if (_selectedProvider == null) return;
    final settingsRepo = await ref.read(settingsRepositoryProvider.future);
    await settingsRepo.setWhisperXEndpoint(endpoint);
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

  // FIX: On Android 11+ (API 30+), canLaunchUrl() returns false for https://
  // URLs unless <queries> intent filters are declared in AndroidManifest.xml.
  // The fix has two parts:
  //   1. This code: always use LaunchMode.externalApplication and call
  //      launchUrl() directly without gating on canLaunchUrl(). If it fails,
  //      show a snackbar with the raw URL so the user can copy it.
  //   2. AndroidManifest.xml: add the <queries> block (see instructions below).
  Future<void> _launchApiKeyUrl() async {
    if (_selectedProvider == null) return;
    final rawUrl = _selectedProvider!.apiKeyUrl;
    final uri = Uri.parse(rawUrl);
    try {
      final success = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (!success && mounted) {
        _showUrlFallbackSnackbar(rawUrl);
      }
    } catch (_) {
      if (mounted) _showUrlFallbackSnackbar(rawUrl);
    }
  }

  void _showUrlFallbackSnackbar(String url) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Cannot open browser. Visit:\n$url'),
        duration: const Duration(seconds: 8),
        action: SnackBarAction(label: 'OK', onPressed: () {}),
      ),
    );
  }

  String _formatFolderUri(String uri) {
    try {
      final decoded = Uri.decodeFull(uri);
      final colonIdx = decoded.lastIndexOf(':');
      if (colonIdx != -1 && colonIdx < decoded.length - 1) {
        final path = decoded.substring(colonIdx + 1);
        final parts = path.split('/').where((p) => p.isNotEmpty).toList();
        return parts.join(' › ');
      }
      return decoded;
    } catch (_) {
      return uri;
    }
  }

  String _formatDetectedPath(String absPath) {
    const marker = '/0/';
    final idx = absPath.indexOf(marker);
    if (idx != -1) {
      final rel = absPath.substring(idx + marker.length);
      return rel.split('/').where((p) => p.isNotEmpty).join(' › ');
    }
    return absPath.split('/').where((p) => p.isNotEmpty).join(' › ');
  }

  void _clearApiKey() {
    _apiKeyController.clear();
    _saveApiKey('');
    setState(() {
      _testResult = null;
      _testSuccess = false;
    });
  }

  void _clearEndpoint() {
    _endpointController.clear();
    _saveEndpoint('');
    setState(() {
      _testResult = null;
      _testSuccess = false;
    });
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    _endpointController.dispose();
    super.dispose();
  }

  Future<void> _confirmClearAllData() async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Clear all data?'),
        content: const Text(
          'This will permanently delete all your notes, call records, '
          'transcriptions, and settings from this device.\n\n'
          'This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Delete Everything'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    try {
      // Clear the database
      final db = ref.read(appDatabaseProvider);
      await db.close();

      // Delete the database file
      final dbFolder = await getApplicationDocumentsDirectory();
      final dbFile = File('${dbFolder.path}/voiceon.sqlite');
      if (await dbFile.exists()) await dbFile.delete();

      // Clear SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      // Clear audio recordings folder
      final recFolder = Directory('${dbFolder.path}/recordings');
      if (await recFolder.exists()) await recFolder.delete(recursive: true);

      // Note: call_vault recordings are NOT deleted (they belong to Phone app)

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('All data cleared. Please restart the app.'),
          duration: Duration(seconds: 4),
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error clearing data: $e')),
        );
      }
    }
  }

  Widget _buildThemeCard({
    required IconData icon,
    required String label,
    required bool selected,
    required VoidCallback onTap,
    required Color? previewColor,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          Container(
            width: 250,
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
                child: Icon(Icons.check_circle, size: 18, color: Colors.green),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);
    final themeNotifier = ref.read(themeModeProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Appearance ──────────────────────────────────────────────
            const Text('Appearance', style: TextStyle(letterSpacing: 1.2)),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _buildThemeCard(
                    icon: Icons.wb_sunny,
                    label: 'Light',
                    selected: themeMode == ThemeMode.light,
                    previewColor: Colors.amber,
                    onTap: () => themeNotifier.setThemeMode(ThemeMode.light),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildThemeCard(
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

            // ── Call Vault ──────────────────────────────────────────
            const Text('Call Vault', style: TextStyle(letterSpacing: 1.2)),
            const SizedBox(height: 12),

            Card(
              margin: EdgeInsets.zero,
              shadowColor: Colors.transparent,
              child: SwitchListTile(
                title: const Text('Enable Call Vault'),
                value: _callVaultEnabled,
                onChanged: _onCallVaultToggled,
                secondary: Icon(Icons.call_outlined),
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              "Import and transcribe recordings from your Phone app",
              style: TextStyle(fontSize: 12),
            ),

            if (_callVaultEnabled) ...[
              const SizedBox(height: 10),
              if (_callVaultFolderUri == null &&
                  _detectedFolderPath != null) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.teal.withAlpha(30),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.teal.withAlpha(80)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.folder_special,
                            color: Colors.teal,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Possible recordings folder found: 📁 ${_formatDetectedPath(_detectedFolderPath!)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Tap below to grant Voiceon access to this folder.',
                        style: TextStyle(fontSize: 12),
                      ),
                      const SizedBox(height: 10),
                      FilledButton.tonal(
                        onPressed: _pickFolder,
                        child: const Text('Grant Access to This Folder'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
              ],
              Card(
                margin: EdgeInsets.zero,
                shadowColor: Colors.transparent,
                child: ListTile(
                  title: const Text('Phone Recordings Folder'),
                  subtitle: Text(
                    _callVaultFolderUri != null
                        ? '📁 ${_formatFolderUri(_callVaultFolderUri!)}'
                        : 'Required — tap to select your Phone app\'s recordings folder',
                    style: TextStyle(
                      color: _callVaultFolderUri == null
                          ? Colors.redAccent
                          : null,
                    ),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.folder_open),
                    onPressed: _pickFolder,
                  ),
                  onTap: _pickFolder,
                ),
              ),
              const SizedBox(height: 10),
              if (_callVaultFolderUri == null) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.amber.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          "Setup Required\n\n"
                          "Step 1: Enable call recording in your Phone app\n\n"
                          "• Samsung: Phone app → ⋮ → Settings → Call recording\n"
                          "• Xiaomi: Phone app → Settings → Call recording\n"
                          "• Other brands: Check your Phone app settings\n\n"
                          "Step 2: Tap 'Phone Recordings Folder' above and select "
                          "the folder where your Phone app saves recordings.\n\n"
                          "Step 3: Open Call Vault from the button below — "
                          "Voiceon will import and transcribe your calls automatically.",
                          style: TextStyle(
                            fontSize: 13,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ] else ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.check_circle_outline,
                        size: 18,
                        color: Colors.green,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Voiceon will automatically import and transcribe new call recordings.',
                          style: TextStyle(
                            fontSize: 13,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 12),
            ],

            const SizedBox(height: 32),

            // ── AI Transcription ────────────────────────────────────────
            const Text(
              'AI Transcription',
              style: TextStyle(letterSpacing: 1.2),
            ),
            const SizedBox(height: 12),

            DropdownButtonFormField<AiProvider>(
              initialValue: _selectedProvider,
              isExpanded: true,
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
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          provider.displayName,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (provider.hasFreeier || provider.isRecommended) ...[
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (provider.isRecommended) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.blue,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  'Recommended',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                            if (provider.hasFreeier) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.green,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  'Free',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ],
                  ),
                );
              }).toList(),
              onChanged: (provider) {
                if (provider != null) _saveProvider(provider);
              },
            ),
            const SizedBox(height: 8),

            if (_selectedProvider != null) ...[
              Text(
                _selectedProvider!.description,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 16),
            ],

            // Show Base Endpoint field ONLY for WhisperX
            if (_selectedProvider == AiProvider.whisperx) ...[
              TextFormField(
                controller: _endpointController,
                obscureText: !_showBaseEndpoint,
                keyboardType: TextInputType.url,
                autocorrect: false,
                decoration: InputDecoration(
                  labelText: 'Base Endpoint',
                  hintText: 'https://abc123.ngrok-free.app',
                  helperText: 'Your ngrok HTTPS URL (no trailing slash)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  suffixIconConstraints: const BoxConstraints(
                    minWidth: 0,
                    minHeight: 0,
                  ),
                  suffixIcon: Padding(
                    padding: const EdgeInsets.only(right: 4),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(
                            _showBaseEndpoint
                                ? Icons.visibility_off
                                : Icons.visibility,
                            size: 20,
                          ),
                          onPressed: () => setState(
                            () => _showBaseEndpoint = !_showBaseEndpoint,
                          ),
                        ),
                        if (_endpointController.text.isNotEmpty)
                          IconButton(
                            icon: const Icon(Icons.clear, size: 20),
                            onPressed: _clearEndpoint,
                          ),
                      ],
                    ),
                  ),
                ),
                onChanged: (value) async {
                  final settingsRepo = await ref.read(
                    settingsRepositoryProvider.future,
                  );
                  await settingsRepo.setWhisperXEndpoint(value);
                  setState(() {
                    _testResult = null;
                    _testSuccess = false;
                  });
                },
              ),
              const SizedBox(height: 12),
            ],

            if (_selectedProvider != null) ...[
              TextFormField(
                controller: _apiKeyController,
                obscureText: !_showApiKey,
                decoration: InputDecoration(
                  labelText: _selectedProvider!.apiKeyLabel,
                  hintText: _selectedProvider!.apiKeyHint,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  suffixIconConstraints: const BoxConstraints(
                    minWidth: 0,
                    minHeight: 0,
                  ),
                  suffixIcon: Padding(
                    padding: const EdgeInsets.only(right: 4),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(
                            _showApiKey
                                ? Icons.visibility_off
                                : Icons.visibility,
                            size: 20,
                          ),
                          onPressed: () =>
                              setState(() => _showApiKey = !_showApiKey),
                        ),
                        if (_apiKeyController.text.isNotEmpty)
                          IconButton(
                            icon: const Icon(Icons.clear, size: 20),
                            onPressed: _clearApiKey,
                          ),
                      ],
                    ),
                  ),
                ),
                onChanged: _saveApiKey,
              ),
              const SizedBox(height: 12),
            ],

            if (_selectedProvider != null) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton.icon(
                    onPressed: _launchApiKeyUrl,
                    icon: const Icon(Icons.open_in_new, size: 16),
                    label: const Text('Get API Key'),
                  ),
                  FilledButton.tonal(
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
            ],

            if (_testResult != null)
              Container(
                width: double.infinity,
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
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _testSuccess ? Icons.check_circle : Icons.error_outline,
                      color: _testSuccess ? Colors.green : Colors.red,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        _testSuccess ? '✓ $_testResult' : '✗ $_testResult',
                        style: TextStyle(
                          color: _testSuccess ? Colors.green : Colors.red,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 32),

            // ── About ───────────────────────────────────────────────────
            const Divider(),
            const SizedBox(height: 16),
            Center(
              child: Column(
                children: [
                  Image.asset(
                    'assets/images/app-logo.png',
                    width: 64,
                    height: 64,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.mic,
                        size: 36,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Voiceon',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Your voice, organized.',
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Version 1.0.0',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade400),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '📦 Your data is backed up to Google Drive automatically.',
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    'When you uninstall, Android will ask if you want to keep your data.',
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // ── Data & Storage ──────────────────────────────────────────────────
            const Text('Data & Storage', style: TextStyle(letterSpacing: 1.2)),
            const SizedBox(height: 12),
            Card(
              margin: EdgeInsets.zero,
              shadowColor: Colors.transparent,
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.backup_outlined),
                    title: const Text('Auto Backup'),
                    subtitle: const Text(
                      'Your notes and call data are automatically backed up to Google Drive '
                      'and restored if you reinstall Voiceon.',
                    ),
                    trailing: Icon(
                      Icons.check_circle,
                      color: Colors.green,
                      size: 20,
                    ),
                  ),
                  const Divider(height: 1, indent: 16, endIndent: 16),
                  ListTile(
                    leading: const Icon(Icons.delete_forever_outlined),
                    title: const Text('Clear All Data'),
                    subtitle: const Text('Permanently delete all notes, call records, and settings'),
                    onTap: _confirmClearAllData,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
