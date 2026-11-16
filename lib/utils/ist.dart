/// Time helpers in India Standard Time (UTC+5:30), independent of the
/// device's time zone — Globio's learners and schedules are in IST.
class Ist {
  Ist._();

  static const offset = Duration(hours: 5, minutes: 30);

  /// Wall-clock IST for an instant. The returned DateTime is marked UTC but
  /// its fields (year, hour …) read as IST.
  static DateTime wall(DateTime instant) => instant.toUtc().add(offset);

  /// The instant for an IST wall-clock time.
  static DateTime instant(int y, int m, int d, [int h = 0, int min = 0]) =>
      DateTime.utc(y, m, d, h, min).subtract(offset);

  /// "2026-11-16" — the IST calendar day, used to key daily questions.
  static String dayKey(DateTime instant) {
    final w = wall(instant);
    return '${w.year}-${w.month.toString().padLeft(2, '0')}-${w.day.toString().padLeft(2, '0')}';
  }

  static const _days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  static const _months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

  /// "Fri 20 Nov, 6:00 PM IST"
  static String label(DateTime instant) {
    final w = wall(instant);
    final h12 = w.hour % 12 == 0 ? 12 : w.hour % 12;
    final ampm = w.hour < 12 ? 'AM' : 'PM';
    return '${_days[w.weekday - 1]} ${w.day} ${_months[w.month - 1]}, $h12:${w.minute.toString().padLeft(2, '0')} $ampm IST';
  }

  /// "Fri 20 Nov"
  static String dateLabel(DateTime instant) {
    final w = wall(instant);
    return '${_days[w.weekday - 1]} ${w.day} ${_months[w.month - 1]}';
  }
}

/// The free mock: released every second Friday at 6:00 PM IST and open for
/// 24 hours (until Saturday 6:00 PM IST).
///
/// Why this slot: working professionals are free after office on Friday
/// evening, college students on Saturday morning/afternoon, and it matches
/// Globio's own evening demo slots (4 PM / 8 PM IST) and weekend classes.
class FreeMockSchedule {
  FreeMockSchedule._();

  /// First release: Friday 20 Nov 2026, 18:00 IST.
  static final DateTime anchor = Ist.instant(2026, 11, 20, 18, 0);
  static const every = Duration(days: 14);
  static const openFor = Duration(hours: 24);

  /// The window that is open at [now], or null.
  static FreeWindow? openAt(DateTime now) {
    if (now.isBefore(anchor)) return null;
    final k = now.difference(anchor).inMicroseconds ~/ every.inMicroseconds;
    final start = anchor.add(every * k);
    final end = start.add(openFor);
    return now.isBefore(end) ? FreeWindow(start, end) : null;
  }

  /// The next window that starts after [now].
  static FreeWindow next(DateTime now) {
    if (now.isBefore(anchor)) return FreeWindow(anchor, anchor.add(openFor));
    final k = now.difference(anchor).inMicroseconds ~/ every.inMicroseconds + 1;
    final start = anchor.add(every * k);
    return FreeWindow(start, start.add(openFor));
  }
}

class FreeWindow {
  const FreeWindow(this.start, this.end);
  final DateTime start;
  final DateTime end;

  /// Stable id, e.g. "free-2026-11-20".
  String get id => 'free-${Ist.dayKey(start)}';
}
