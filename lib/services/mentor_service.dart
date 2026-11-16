import 'dart:math';

import '../utils/ist.dart';
import 'local_store.dart';
import 'wallet_service.dart';

enum BookingStatus { requested, cancelled }

class MentorBooking {
  MentorBooking({
    required this.id,
    required this.topic,
    required this.slot,
    required this.createdAt,
    this.attemptId,
    this.note = '',
    this.status = BookingStatus.requested,
  });

  final String id;
  final String topic;

  /// Mock attempt to review (for post-exam analysis), if any.
  final String? attemptId;
  final DateTime slot;
  final String note;
  final DateTime createdAt;
  BookingStatus status;

  Map<String, dynamic> toJson() => {
        'id': id,
        'topic': topic,
        'attempt': attemptId,
        'slot': slot.toUtc().toIso8601String(),
        'note': note,
        'created': createdAt.toUtc().toIso8601String(),
        'status': status.name,
      };

  static MentorBooking? fromJson(Map<String, dynamic> j) {
    final id = j['id'], topic = j['topic'], note = j['note'];
    final slot = DateTime.tryParse('${j['slot']}');
    final created = DateTime.tryParse('${j['created']}');
    final status = BookingStatus.values.where((s) => s.name == j['status']).firstOrNull;
    if (id is! String || topic is! String || slot == null || created == null || status == null) return null;
    return MentorBooking(
      id: id,
      topic: topic,
      attemptId: j['attempt'] is String ? j['attempt'] as String : null,
      slot: slot.toLocal(),
      note: note is String ? note : '',
      createdAt: created.toLocal(),
      status: status,
    );
  }
}

/// Mentor sessions: a request + booking stored on the device. A Globio
/// mentor would confirm it; there is no backend in this prototype.
class MentorService {
  MentorService._();

  static const topics = [
    'Post-exam analysis of a mock',
    'Exam strategy & study plan',
    'Speaking & writing practice plan',
    'Which exam / level should I book?',
  ];
  static const noteMax = 300;
  static const minNotice = Duration(hours: 24);

  static String _key(String email) => 'globio.mentor.v1|$email';

  /// Bookable slots for the next 14 days, at least 24 h ahead.
  /// Weekdays: 7, 8, 9 PM IST (after work/college). Weekends: 10, 11 AM, 4, 5 PM IST.
  static List<DateTime> slots({DateTime? now}) {
    final t = now ?? DateTime.now();
    final w = Ist.wall(t);
    final out = <DateTime>[];
    for (var d = 0; d <= 14; d++) {
      final day = DateTime.utc(w.year, w.month, w.day).add(Duration(days: d));
      final weekend = day.weekday >= DateTime.saturday;
      for (final h in weekend ? const [10, 11, 16, 17] : const [19, 20, 21]) {
        final s = Ist.instant(day.year, day.month, day.day, h);
        if (s.difference(t) >= minNotice) out.add(s);
      }
    }
    return out;
  }

  static Future<List<MentorBooking>> bookings(String email) async {
    final raw = await LocalStore.readList(_key(email));
    return raw.map(MentorBooking.fromJson).whereType<MentorBooking>().toList()
      ..sort((a, b) => b.slot.compareTo(a.slot));
  }

  /// Returns null on success, otherwise a message.
  static Future<String?> book(
    String email, {
    required String topic,
    required DateTime slot,
    String? attemptId,
    String note = '',
    DateTime? now,
    Random? random,
  }) async {
    final t = now ?? DateTime.now();
    if (!topics.contains(topic)) return 'Please choose a topic.';
    if (!slots(now: t).contains(slot)) return 'That time is no longer available. Please pick another slot.';
    final all = await bookings(email);
    if (all.any((b) => b.status == BookingStatus.requested && b.slot == slot)) {
      return 'You already have a session at that time.';
    }
    final rnd = random ?? Random();
    final id = '${t.microsecondsSinceEpoch.toRadixString(36)}${rnd.nextInt(1 << 20).toRadixString(36)}';
    final paid = await Wallet.spend(email,
        id: 'mentor:$id', amount: Wallet.mentorPrice, kind: 'spend_mentor', note: 'Mentor session · ${Ist.label(slot)}');
    if (paid != null) return paid;
    final booking = MentorBooking(
      id: id,
      topic: topic,
      attemptId: attemptId,
      slot: slot,
      note: note.trim().length > noteMax ? note.trim().substring(0, noteMax) : note.trim(),
      createdAt: t,
    );
    final ok = await LocalStore.write(_key(email), [booking, ...all].map((b) => b.toJson()).toList());
    if (!ok) {
      await Wallet.add(email, CoinEntry(id: 'refund:$id', amount: Wallet.mentorPrice, kind: 'refund', note: 'Booking failed — refund', at: t));
      return 'Could not save the booking. Your coins were refunded.';
    }
    AppEvents.instance.changed();
    return null;
  }

  static bool canCancel(MentorBooking b, {DateTime? now}) =>
      b.status == BookingStatus.requested && b.slot.difference(now ?? DateTime.now()) >= minNotice;

  /// Cancels a requested session at least 24 h ahead and refunds the coins.
  static Future<String?> cancel(String email, String bookingId, {DateTime? now}) async {
    final t = now ?? DateTime.now();
    final all = await bookings(email);
    final b = all.where((x) => x.id == bookingId).firstOrNull;
    if (b == null) return 'Booking not found.';
    if (!canCancel(b, now: t)) return 'Sessions can be cancelled up to 24 hours before the start.';
    b.status = BookingStatus.cancelled;
    final ok = await LocalStore.write(_key(email), all.map((x) => x.toJson()).toList());
    if (!ok) return 'Could not save. Please try again.';
    await Wallet.add(email, CoinEntry(id: 'refund:${b.id}', amount: Wallet.mentorPrice, kind: 'refund', note: 'Mentor session cancelled — refund', at: t));
    AppEvents.instance.changed();
    return null;
  }
}
