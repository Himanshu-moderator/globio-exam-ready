import '../data/exams.dart';
import '../data/topics.dart';
import '../models/attempt.dart';
import '../models/quiz.dart';

/// How "ready" is decided.
///
/// 1. Each skill (vocabulary, grammar, reading) gets a percentage.
/// 2. Readiness score = 60% × overall score + 40% × weakest skill.
///    The weakest skill weighs heavily because real exams fail you on a
///    weak part even when the total looks fine (Goethe A1: every part must
///    be passed; B1: every module needs 60%; ÖSD: minimums per part).
/// 3. Verdict, judged against the real exam's pass mark (P):
///    • Ready to book   — overall ≥ P + 15 and every skill ≥ P
///    • Almost ready    — overall ≥ P and every skill ≥ P − 20
///    • Not ready yet   — anything below that
///    The +15 safety margin exists because a 15-question check is shorter
///    and calmer than the real exam (nerves, timing, listening, speaking).
class Readiness {
  Readiness._();

  static const readyMargin = 15;
  static const almostBand = 20;
  static const overallWeight = 0.6;
  static const weakestWeight = 0.4;
  static const maxFocusAreas = 3;

  static AttemptResult evaluate(ExamInfo exam, Attempt attempt) {
    final reviews = <QuestionReview>[];
    for (final item in attempt.items) {
      final q = questionById(exam, item.questionId);
      if (q == null) continue; // unknown id (old or tampered data): skip safely
      final validOrder = item.order.length == q.options.length &&
          item.order.toSet().length == q.options.length &&
          item.order.every((i) => i >= 0 && i < q.options.length);
      final order = validOrder ? item.order : List<int>.generate(q.options.length, (i) => i);
      final chosen = (item.chosen != null && item.chosen! >= 0 && item.chosen! < q.options.length)
          ? item.chosen
          : null;
      reviews.add(QuestionReview(
        question: q,
        order: order,
        chosen: chosen,
        isCorrect: chosen == q.answer,
      ));
    }

    final skills = <Skill, SkillScore>{
      for (final s in Skill.values)
        s: SkillScore(
          skill: s,
          correct: reviews.where((r) => r.question.skill == s && r.isCorrect).length,
          total: reviews.where((r) => r.question.skill == s).length,
        ),
    };
    final scored = skills.values.where((s) => s.total > 0).toList();
    final correct = reviews.where((r) => r.isCorrect).length;
    final total = reviews.length;
    final overall = total == 0 ? 0 : (correct * 100 / total).round();
    final weakest = scored.isEmpty ? 0 : scored.map((s) => s.pct).reduce((a, b) => a < b ? a : b);
    final readinessScore = (overallWeight * overall + weakestWeight * weakest).round();

    final p = exam.passPct;
    final Verdict verdict;
    if (overall >= p + readyMargin && weakest >= p) {
      verdict = Verdict.ready;
    } else if (overall >= p && weakest >= p - almostBand) {
      verdict = Verdict.almost;
    } else {
      verdict = Verdict.notYet;
    }

    // Focus areas: topics with the most mistakes, weakest skill first on ties.
    final misses = <String, int>{};
    final topicSkill = <String, Skill>{};
    for (final r in reviews.where((r) => !r.isCorrect)) {
      misses[r.question.topic] = (misses[r.question.topic] ?? 0) + 1;
      topicSkill[r.question.topic] = r.question.skill;
    }
    final topics = misses.keys.where(topicGuides.containsKey).toList()
      ..sort((a, b) {
        final byMisses = misses[b]!.compareTo(misses[a]!);
        if (byMisses != 0) return byMisses;
        return skills[topicSkill[a]]!.pct.compareTo(skills[topicSkill[b]]!.pct);
      });
    // Cover every skill that is below "strong" first (one topic each, weakest
    // skill first), then fill the remaining slots by number of mistakes.
    final picked = <String>[];
    final weakSkills = skills.values
        .where((s) => s.total > 0 && s.pct < p + readyMargin)
        .toList()
      ..sort((a, b) => a.pct.compareTo(b.pct));
    for (final s in weakSkills) {
      final t = topics.where((t) => topicSkill[t] == s.skill && !picked.contains(t));
      if (t.isNotEmpty && picked.length < maxFocusAreas) picked.add(t.first);
    }
    for (final t in topics) {
      if (picked.length >= maxFocusAreas) break;
      if (!picked.contains(t)) picked.add(t);
    }
    final focus = picked
        .map((t) => FocusArea(
              topicId: t,
              guide: topicGuides[t]!,
              misses: misses[t]!,
              skill: topicSkill[t]!,
            ))
        .toList();

    return AttemptResult(
      exam: exam,
      attempt: attempt,
      correct: correct,
      total: total,
      overallPct: overall,
      weakestPct: weakest,
      readinessScore: readinessScore,
      verdict: verdict,
      skills: skills,
      focusAreas: focus,
      reviews: reviews,
    );
  }

  static SkillStatus skillStatus(int pct, int passPct) {
    if (pct >= passPct + readyMargin) return SkillStatus.strong;
    if (pct >= passPct) return SkillStatus.borderline;
    return SkillStatus.weak;
  }
}

enum Verdict { ready, almost, notYet }

extension VerdictText on Verdict {
  String get title => switch (this) {
        Verdict.ready => 'Ready to book',
        Verdict.almost => 'Almost ready',
        Verdict.notYet => 'Not ready yet',
      };

  String get message => switch (this) {
        Verdict.ready => 'You are comfortably above the pass mark in every skill. Book your exam and keep practising listening and speaking.',
        Verdict.almost => 'You are around the pass mark. Fix the focus areas below and take another mock before you book.',
        Verdict.notYet => 'Booking now risks losing your exam fee. Work on the focus areas below first, then take another mock.',
      };
}

enum SkillStatus { strong, borderline, weak }

extension SkillStatusText on SkillStatus {
  String get label => switch (this) {
        SkillStatus.strong => 'Strong',
        SkillStatus.borderline => 'Borderline',
        SkillStatus.weak => 'Needs work',
      };
}

class SkillScore {
  const SkillScore({required this.skill, required this.correct, required this.total});
  final Skill skill;
  final int correct;
  final int total;
  int get pct => total == 0 ? 0 : (correct * 100 / total).round();
}

class QuestionReview {
  const QuestionReview({
    required this.question,
    required this.order,
    required this.chosen,
    required this.isCorrect,
  });
  final Question question;
  final List<int> order;

  /// Original option index picked, or null if unanswered.
  final int? chosen;
  final bool isCorrect;

  bool get unanswered => chosen == null;
}

class FocusArea {
  const FocusArea({
    required this.topicId,
    required this.guide,
    required this.misses,
    required this.skill,
  });
  final String topicId;
  final TopicGuide guide;
  final int misses;
  final Skill skill;
}

class AttemptResult {
  const AttemptResult({
    required this.exam,
    required this.attempt,
    required this.correct,
    required this.total,
    required this.overallPct,
    required this.weakestPct,
    required this.readinessScore,
    required this.verdict,
    required this.skills,
    required this.focusAreas,
    required this.reviews,
  });

  final ExamInfo exam;
  final Attempt attempt;
  final int correct;
  final int total;
  final int overallPct;
  final int weakestPct;
  final int readinessScore;
  final Verdict verdict;
  final Map<Skill, SkillScore> skills;
  final List<FocusArea> focusAreas;
  final List<QuestionReview> reviews;

  bool get passedMock => overallPct >= exam.passPct;
}
