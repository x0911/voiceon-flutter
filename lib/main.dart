import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/router/app_router.dart';
import 'core/services/call_event_service.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_provider.dart';

void main() {
  runApp(const ProviderScope(child: VoiceonApp()));
}

class VoiceonApp extends ConsumerStatefulWidget {
  const VoiceonApp({super.key});

  @override
  ConsumerState<VoiceonApp> createState() => _VoiceonAppState();
}

class _VoiceonAppState extends ConsumerState<VoiceonApp> {
  @override
  void initState() {
    super.initState();
    // Initialize call event service
    ref.read(callEventServiceProvider);
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: 'Voiceon',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      routerConfig: appRouter,
    );
  }
}
