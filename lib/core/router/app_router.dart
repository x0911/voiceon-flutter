import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/home/home_screen.dart';
import '../../features/metadata/metadata_screen.dart';
import '../../features/recording/recording_screen.dart';
import '../../core/services/audio_service.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      name: 'home',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/record',
      name: 'record',
      builder: (context, state) => const RecordingScreen(),
    ),
    GoRoute(
      path: '/metadata',
      name: 'metadata',
      builder: (context, state) {
        final extra = state.extra;
        if (extra is RecordingResult) {
          return MetadataScreen(recordingResult: extra);
        }

        return const Scaffold(
          body: Center(child: Text('Recording details are missing.')),
        );
      },
    ),
  ],
);
