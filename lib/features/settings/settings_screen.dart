import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/theme_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final themeNotifier = ref.read(themeModeProvider.notifier);

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
          scale: selected ? 1.05 : 1.0,
          duration: const Duration(milliseconds: 180),
          child: Stack(
            children: [
              Container(
                width: 110,
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
                            ).colorScheme.primary.withOpacity(0.08),
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

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Appearance', style: TextStyle(letterSpacing: 1.2)),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                buildCard(
                  icon: Icons.wb_sunny,
                  label: 'Light',
                  selected: themeMode == ThemeMode.light,
                  previewColor: Colors.amber,
                  onTap: () => themeNotifier.setThemeMode(ThemeMode.light),
                ),
                const SizedBox(width: 12),
                buildCard(
                  icon: Icons.nights_stay,
                  label: 'Dark',
                  selected: themeMode == ThemeMode.dark,
                  previewColor: Colors.blueGrey,
                  onTap: () => themeNotifier.setThemeMode(ThemeMode.dark),
                ),
                const SizedBox(width: 12),
                buildCard(
                  icon: Icons.brightness_auto,
                  label: 'System',
                  selected: themeMode == ThemeMode.system,
                  previewColor: Theme.of(context).colorScheme.primary,
                  onTap: () => themeNotifier.setThemeMode(ThemeMode.system),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
