const _months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

String _two(int n) => n.toString().padLeft(2, '0');

/// "16 Nov 2026, 14:05"
String formatDateTime(DateTime d) => '${d.day} ${_months[d.month - 1]} ${d.year}, ${_two(d.hour)}:${_two(d.minute)}';

/// "16 Nov"
String formatShortDate(DateTime d) => '${d.day} ${_months[d.month - 1]}';

/// "07:05" (mm:ss), never negative.
String formatClock(Duration d) {
  final s = d.isNegative ? 0 : d.inSeconds;
  return '${_two(s ~/ 60)}:${_two(s % 60)}';
}

/// "8 min 12 s"
String formatDuration(Duration d) {
  final s = d.isNegative ? 0 : d.inSeconds;
  final m = s ~/ 60;
  return m == 0 ? '${s % 60} s' : '$m min ${s % 60} s';
}
