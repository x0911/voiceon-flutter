import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/call_vault/call_vault_screen.dart';
import '../../features/call_vault/call_detail_screen.dart';
import '../../features/home/home_screen.dart';
import '../../features/metadata/metadata_screen.dart';
import '../../features/note_detail/note_detail_screen.dart';
import '../../features/recording/recording_screen.dart';
import '../../features/settings/settings_screen.dart';
import '../../features/shell/app_shell.dart';
import '../../core/services/audio_service.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) =>
          AppShell(navigationShell: navigationShell),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/',
              name: 'home',
              builder: (context, state) => const HomeScreen(),
              routes: [
                GoRoute(
                  path: 'note/:id',
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
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/call-vault',
              name: 'callVault',
              builder: (context, state) => const CallVaultScreen(),
              routes: [
                GoRoute(
                  path: ':id',
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
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/settings',
              name: 'settings',
              builder: (context, state) => const SettingsScreen(),
            ),
          ],
        ),
      ],
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
        if (extra is RecordingEditContext) {
          return MetadataScreen(
            recordingResult: extra.recordingResult,
            editingNoteId: extra.noteId,
          );
        }
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
