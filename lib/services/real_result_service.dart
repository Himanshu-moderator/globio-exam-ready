import 'dart:math';

import '../models/attempt.dart';
import 'local_store.dart';

/// A learner's real Goethe/ÖSD result, reported by the learner.
///
/// Real exams are taken on paper at a test centre and results are published
/// on the provider's own portal with no public API, so this cannot be pulled
/// in automatically. The learner enters pass/fail (+ score) and it is linked
/// automatically to their latest mock for that exam taken before the exam
/// date — so predicted readiness can be compared with the real outcome.
class RealResult {
  RealResult({
    required this.id,
    required this.examId,
    required this.date,
    required this.passed,
    required this.createdAt,
    this.score,
    this.linkedAttemptId,
  });

  final String id;
  final String examId;
  final DateTime date;
  final bool passed;

  /// 0–100, optional.
  final int? score;
  final String? linkedAttemptId;
  final DateTime createdAt;

  Map<String, dynamic> toJson() => {
        'id': id,
        'exam': examId,
        'date': date.toUtc().toIso8601String(),
        'passed': passed,
        'score': score,
        'attempt': linkedAttemptId,
        'created': createdAt.toUtc().toIso8601String(),
      };

  static RealResult? fromJson(Map<String, dynamic> j) {
    final id = j['id'], exam = j['exam'], passed = j['passed'], score = j['score'];
    final date = DateTime.tryParse('${j['date']}');
    final created = DateTime.tryParse('${j['created']}');
    if (id is! String || exam is! String || passed is! bool || date == null || created == null) return null;
    if (score != null && (score is! int || score < 0 || score > 100)) return null;
    return RealResult(
      id: id,
      examId: exam,
      date: date.toLocal(),
      passed: passed,
      score: score as int?,
      linkedAttemptId: j['attempt'] is String ? j['attempt'] as String : null,
      createdAt: created.toLocal(),
    );
  }
}

class RealResultService {
  RealResultService._();

  static String _key(String email) => 'globio.real.v1|$email';

  static Future<List<RealResult>> all(String email) async {
    final raw = await LocalStore.readList(_key(email));
    return raw.map(RealResult.fromJson).whereType<RealResult>().toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  /// The mock the prediction comes from: the latest finished attempt of that
  /// exam submitted on or before the real exam day (else the latest one).
  static Attempt? autoLink(List<Attempt> history, String examId, DateTime examDate) {
    final endOfDay = DateTime(examDate.year, examDate.month, examDate.day, 23, 59, 59);
    final mine = history.where((a) => a.examId == examId && a.isFinished).toList()
      ..sort((a, b) => b.submittedAt!.compareTo(a.submittedAt!));
    for (final a in mine) {
      if (!a.submittedAt!.isAfter(endOfDay)) return a;
    }
    return mine.firstOrNull;
  }

  static Future<String?> add(
    String email, {
    required String examId,
    required DateTime date,
    required bool passed,
    int? score,
    String? linkedAttemptId,
    DateTime? now,
  }) async {
    final t = now ?? DateTime.now();
    if (date.isAfter(t)) return 'The exam date cannot be in the future.';
    if (score != null && (score < 0 || score > 100)) return 'Score must be between 0 and 100.';
    final list = await all(email);
    final r = RealResult(
      id: '${t.microsecondsSinceEpoch.toRadixString(36)}${Random().nextInt(1 << 20).toRadixString(36)}',
      examId: examId,
      date: date,
      passed: passed,
      score: score,
      linkedAttemptId: linkedAttemptId,
      createdAt: t,
    );
    final ok = await LocalStore.write(_key(email), [r, ...list].map((x) => x.toJson()).toList());
    if (!ok) return 'Could not save — browser storage is blocked.';
    AppEvents.instance.changed();
    return null;
  }

  static Future<void> remove(String email, String id) async {
    final list = await all(email);
    await LocalStore.write(_key(email), list.where((r) => r.id != id).map((x) => x.toJson()).toList());
    AppEvents.instance.changed();
  }
}
