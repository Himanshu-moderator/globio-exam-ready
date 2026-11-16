import 'dart:math';

import '../models/attempt.dart';
import '../models/quiz.dart';

/// Builds a new mock for a learner.
///
/// • Draws [ExamInfo.perSkill] questions per skill from that exam's own bank,
///   so different exams never share questions.
/// • Prefers questions this learner has seen least often in earlier attempts
///   (ties broken randomly), so every learner — and every retake — gets a
///   different set.
/// • Shuffles the question order and the answer options (Richtig/Falsch keeps
///   its natural order).
class QuizEngine {
  QuizEngine._();

  static Attempt create(
    ExamInfo exam, {
    List<Attempt> history = const [],
    Random? random,
    DateTime? now,
  }) {
    final rnd = random ?? Random();
    final start = now ?? DateTime.now();

    final seen = <String, int>{};
    for (final a in history) {
      if (a.examId != exam.id) continue;
      for (final item in a.items) {
        seen[item.questionId] = (seen[item.questionId] ?? 0) + 1;
      }
    }

    final picked = <Question>[];
    for (final skill in Skill.values) {
      final pool = exam.questions.where((q) => q.skill == skill).toList();
      // Random tie-break key per question, then least-seen first.
      final keys = {for (final q in pool) q.id: rnd.nextDouble()};
      pool.sort((a, b) {
        final bySeen = (seen[a.id] ?? 0).compareTo(seen[b.id] ?? 0);
        return bySeen != 0 ? bySeen : keys[a.id]!.compareTo(keys[b.id]!);
      });
      picked.addAll(pool.take(exam.perSkill));
    }
    picked.shuffle(rnd);

    final items = [
      for (final q in picked)
        AttemptItem(
          questionId: q.id,
          order: q.shuffleOptions
              ? (List<int>.generate(q.options.length, (i) => i)..shuffle(rnd))
              : List<int>.generate(q.options.length, (i) => i),
        ),
    ];

    return Attempt(
      id: '${start.microsecondsSinceEpoch.toRadixString(36)}-${rnd.nextInt(1 << 30).toRadixString(36)}',
      examId: exam.id,
      startedAt: start,
      deadline: start.add(Duration(minutes: exam.minutes)),
      items: items,
    );
  }
}
