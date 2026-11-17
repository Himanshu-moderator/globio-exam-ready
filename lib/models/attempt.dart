/// A learner's sitting of one mock exam.
library;

class AttemptItem {
  AttemptItem({required this.questionId, required this.order, this.chosen, this.heard = 0});

  final String questionId;

  /// Display order of the options, as indices into the question's original
  /// option list. order[0] is the option shown first.
  final List<int> order;

  /// Original option index the learner picked, or null if unanswered.
  int? chosen;

  /// Listening items: how often the recording has been played. Saved with
  /// the attempt so a refresh cannot reset the play limit.
  int heard;

  Map<String, dynamic> toJson() => {'q': questionId, 'o': order, 'c': chosen, if (heard > 0) 'h': heard};

  static AttemptItem? fromJson(Object? j) {
    if (j is! Map) return null;
    final q = j['q'];
    final o = j['o'];
    final c = j['c'];
    if (q is! String || o is! List || o.any((e) => e is! int)) return null;
    if (c != null && c is! int) return null;
    final h = j['h'];
    return AttemptItem(
      questionId: q,
      order: o.cast<int>(),
      chosen: c as int?,
      heard: h is int && h > 0 ? h : 0,
    );
  }
}

class Attempt {
  Attempt({
    required this.id,
    required this.examId,
    required this.startedAt,
    required this.deadline,
    required this.items,
    this.submittedAt,
    this.autoSubmitted = false,
    this.payment,
  });

  /// How the mock was paid: `free:<window id>` or "coins". Null for older data.
  String? payment;

  bool get wasFree => payment?.startsWith('free:') ?? false;

  final String id;
  final String examId;
  final DateTime startedAt;
  final DateTime deadline;
  final List<AttemptItem> items;
  DateTime? submittedAt;

  /// True when the timer ran out or the learner left the exam.
  bool autoSubmitted;

  bool get isFinished => submittedAt != null;
  int get answeredCount => items.where((i) => i.chosen != null).length;

  Map<String, dynamic> toJson() => {
        'id': id,
        'exam': examId,
        'start': startedAt.toUtc().toIso8601String(),
        'deadline': deadline.toUtc().toIso8601String(),
        'submitted': submittedAt?.toUtc().toIso8601String(),
        'auto': autoSubmitted,
        'pay': payment,
        'items': items.map((i) => i.toJson()).toList(),
      };

  /// Returns null for anything malformed, so tampered storage can't crash the app.
  static Attempt? fromJson(Object? j) {
    if (j is! Map) return null;
    try {
      final id = j['id'];
      final exam = j['exam'];
      final start = DateTime.tryParse('${j['start']}');
      final deadline = DateTime.tryParse('${j['deadline']}');
      final submittedRaw = j['submitted'];
      final submitted = submittedRaw == null ? null : DateTime.tryParse('$submittedRaw');
      final rawItems = j['items'];
      if (id is! String || exam is! String || start == null || deadline == null || rawItems is! List) {
        return null;
      }
      if (submittedRaw != null && submitted == null) return null;
      final items = <AttemptItem>[];
      for (final r in rawItems) {
        final item = AttemptItem.fromJson(r);
        if (item == null) return null;
        items.add(item);
      }
      if (items.isEmpty) return null;
      return Attempt(
        id: id,
        examId: exam,
        startedAt: start.toLocal(),
        deadline: deadline.toLocal(),
        items: items,
        submittedAt: submitted?.toLocal(),
        autoSubmitted: j['auto'] == true,
        payment: j['pay'] is String ? j['pay'] as String : null,
      );
    } catch (_) {
      return null;
    }
  }
}
