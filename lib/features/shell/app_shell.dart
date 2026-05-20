import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class AppShell extends ConsumerWidget {
  final StatefulNavigationShell navigationShell;

  const AppShell({super.key, required this.navigationShell});

  void _onTabTapped(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentBranchIndex = navigationShell.currentIndex;
    final selectedIndex = currentBranchIndex;

    // Watch current location to disable + button when already recording
    final currentLocation = GoRouterState.of(context).uri.path;
    final isOnRecordingFlow = currentLocation.startsWith('/record') ||
        currentLocation.startsWith('/metadata');

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: _VoiceonBottomNav(
        currentIndex: selectedIndex,
        onTabTapped: (index) => _onTabTapped(index),
        onNewNote: isOnRecordingFlow ? null : () => context.push('/record'),
      ),
    );
  }
}

class _VoiceonBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTabTapped;
  final VoidCallback? onNewNote; // nullable — null means disabled

  const _VoiceonBottomNav({
    required this.currentIndex,
    required this.onTabTapped,
    this.onNewNote, // optional
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final tabs = <_NavTab>[
      _NavTab(
        icon: Icons.mic_none_rounded,
        activeIcon: Icons.mic_rounded,
        label: 'Notes',
      ),
      _NavTab(
        icon: Icons.list_alt_outlined,
        activeIcon: Icons.list_alt_rounded,
        label: 'Todo',
      ),
      _NavTab(
        icon: Icons.call_outlined,
        activeIcon: Icons.call_rounded,
        label: 'Calls',
      ),
      _NavTab(
        icon: Icons.settings_outlined,
        activeIcon: Icons.settings_rounded,
        label: 'Settings',
      ),
    ];

    const navBarHeight = 68.0;
    const centerBtnSize = 52.0;

    return SafeArea(
      child: Container(
        height: navBarHeight + 8,
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerLow,
          border: Border(
            top: BorderSide(
              color: colorScheme.outlineVariant.withAlpha(100),
              width: 0.5,
            ),
          ),
        ),
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            Row(
              children: [
                for (int i = 0; i < tabs.length; i++) ...[
                  if (i == 2) SizedBox(width: centerBtnSize + 16),
                  Expanded(
                    child: _NavTabItem(
                      tab: tabs[i],
                      isActive: i == currentIndex,
                      onTap: () => onTabTapped(i),
                      colorScheme: colorScheme,
                    ),
                  ),
                ],
              ],
            ),
            Positioned(
              top: -10,
              child: GestureDetector(
                onTap: onNewNote, // null = no-op (GestureDetector handles null gracefully)
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 200),
                  opacity: onNewNote != null ? 1.0 : 0.4,
                  child: Container(
                    width: centerBtnSize,
                    height: centerBtnSize,
                    decoration: BoxDecoration(
                      color: colorScheme.primary,
                      shape: BoxShape.circle,
                      boxShadow: onNewNote != null
                          ? [
                              BoxShadow(
                                color: colorScheme.primary.withAlpha(100),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ]
                          : null,
                    ),
                    child: Icon(
                      Icons.add,
                      color: colorScheme.onPrimary,
                      size: 26,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavTab {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  const _NavTab({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}

class _NavTabItem extends StatelessWidget {
  final _NavTab tab;
  final bool isActive;
  final VoidCallback onTap;
  final ColorScheme colorScheme;

  const _NavTabItem({
    required this.tab,
    required this.isActive,
    required this.onTap,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    final color = isActive ? colorScheme.primary : colorScheme.onSurfaceVariant;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Icon(
                isActive ? tab.activeIcon : tab.icon,
                key: ValueKey(isActive),
                color: color,
                size: 24,
              ),
            ),
            const SizedBox(height: 4),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                fontSize: 11,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                color: color,
              ),
              child: Text(tab.label),
            ),
            const SizedBox(height: 4),
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutCubic,
              height: 3,
              width: isActive ? 24 : 0,
              decoration: BoxDecoration(
                color: colorScheme.primary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
