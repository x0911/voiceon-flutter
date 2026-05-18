import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/providers/call_vault_enabled_provider.dart';

class AppShell extends ConsumerWidget {
  final StatefulNavigationShell navigationShell;

  const AppShell({super.key, required this.navigationShell});

  void _onTabTapped(int index, bool callsEnabled) {
    final branchIndex = callsEnabled ? index : (index == 0 ? 0 : 2);
    navigationShell.goBranch(
      branchIndex,
      initialLocation: branchIndex == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final callsEnabledAsync = ref.watch(callVaultEnabledProvider);
    final callsEnabled = callsEnabledAsync.valueOrNull ?? false;
    final currentBranchIndex = navigationShell.currentIndex;
    final selectedIndex = callsEnabled
        ? currentBranchIndex
        : (currentBranchIndex == 2 ? 1 : 0);

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: _VoiceonBottomNav(
        currentIndex: selectedIndex,
        callsEnabled: callsEnabled,
        onTabTapped: (index) => _onTabTapped(index, callsEnabled),
        onNewNote: () => context.push('/record'),
      ),
    );
  }
}

class _VoiceonBottomNav extends StatelessWidget {
  final int currentIndex;
  final bool callsEnabled;
  final ValueChanged<int> onTabTapped;
  final VoidCallback onNewNote;

  const _VoiceonBottomNav({
    required this.currentIndex,
    required this.callsEnabled,
    required this.onTabTapped,
    required this.onNewNote,
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
      if (callsEnabled)
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
    final leftCount = callsEnabled ? 2 : 1;

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
                  if (i == leftCount) SizedBox(width: centerBtnSize + 16),
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
                onTap: onNewNote,
                child: Container(
                  width: centerBtnSize,
                  height: centerBtnSize,
                  decoration: BoxDecoration(
                    color: colorScheme.primary,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: colorScheme.primary.withAlpha(100),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.mic_rounded,
                    color: colorScheme.onPrimary,
                    size: 26,
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
