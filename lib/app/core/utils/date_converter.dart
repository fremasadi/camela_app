String formatTime(int seconds) {
  int minutes = seconds ~/ 60;
  int remaining = seconds % 60;
  return '$minutes:${remaining.toString().padLeft(2, '0')}';
}
