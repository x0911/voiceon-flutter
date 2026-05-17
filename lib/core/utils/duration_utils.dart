String formatCallDuration(int seconds) {
  if (seconds < 60) return '${seconds}s';
  final m = seconds ~/ 60;
  final s = seconds % 60;
  return s > 0 ? '${m}m ${s}s' : '${m}m';
}
