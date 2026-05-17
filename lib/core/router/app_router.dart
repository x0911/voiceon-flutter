import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/calls/calls_screen.dart';
import '../../features/calls/call_detail_screen.dart';
import '../../features/home/home_screen.dart';
import '../../features/metadata/metadata_screen.dart';
import '../../features/note_detail/note_detail_screen.dart';
import '../../features/recording/recording_screen.dart';
import '../../features/settings/settings_screen.dart';
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
      builder: (context, state) => RecordingScreen(extra: state.extra),
    ),
    GoRoute(
      path: '/metadata',
      name: 'metadata',
      builder: (context, state) {
        final extra = state.extra;
        debugPrint('app_router: Metadata route extra=$extra');
        if (extra is RecordingEditContext) {
          debugPrint(
            'app_router: Metadata route received RecordingEditContext with transcript="${extra.recordingResult.transcript}"',
          );
          return MetadataScreen(
            recordingResult: extra.recordingResult,
            editingNoteId: extra.noteId,
          );
        }
        if (extra is RecordingResult) {
          debugPrint(
            'app_router: Metadata route received RecordingResult with transcript="${extra.transcript}"',
          );
          return MetadataScreen(recordingResult: extra);
        }

        return const Scaffold(
          body: Center(child: Text('Recording details are missing.')),
        );
      },
    ),
    GoRoute(
      path: '/note/:id',
      name: 'noteDetail',
      builder: (context, state) {
        final id = state.pathParameters['id'];
        if (id == null || id.isEmpty) {
          return const Scaffold(
            body: Center(child: Text('Note ID is invalid.')),
          );
        }
        return NoteDetailScreen(noteId: id);
      },
    ),
    GoRoute(
      path: '/settings',
      name: 'settings',
      builder: (context, state) => const SettingsScreen(),
    ),
    GoRoute(
      path: '/calls',
      name: 'calls',
      builder: (context, state) => const CallsScreen(),
    ),
    GoRoute(
      path: '/calls/:id',
      name: 'callDetail',
      builder: (context, state) {
        final id = state.pathParameters['id'];
        if (id == null || id.isEmpty) {
          return const Scaffold(
            body: Center(child: Text('Call ID is invalid.')),
          );
        }
        return CallDetailScreen(callId: id);
      },
    ),
  ],
);
